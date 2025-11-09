import { 
  getSpotStatusAtTime, 
  findAvailableBufferSpot, 
  createBooking,
  cancelBooking
} from '../services/parking.service.js';
import { sendPushNotification } from '../services/notification.service.js';

const AI_SERVICE_URL = 'http://localhost:5002/api/predict/overstay';



export const handleCreateBooking = (req, res) => {
  try {
    const { spotId, startTime, endTime, userId } = req.body;

    if (!spotId || !startTime || !endTime) {
      return res.status(400).json({ error: 'spotId, startTime, and endTime are required.' });
    }

    const result = createBooking(spotId, startTime, endTime, userId);

    if (result.success) {
      return res.status(201).json({
        message: 'Booking created successfully!',
        booking: result.booking,
      });
    } else {
      return res.status(409).json({ error: result.error }); // 409 Conflict
    }

  } catch (error) {
    console.error('Unhandled error in handleCreateBooking:', error);
    res.status(500).json({ error: 'An internal server error occurred.' });
  }
};

/**
 * Handle 'Booking Management (Cancel)'
 */
export const handleCancelBooking = (req, res) => {
  try {
    const { id } = req.params; // Get the ID from the URL parameter
    
    if (!id) {
      return res.status(400).json({ error: 'Booking ID is required.' });
    }

    const result = cancelBooking(id);

    if (result.success) {
      return res.status(200).json({
        message: `Booking ${id} cancelled successfully.`,
        booking: result.booking,
      });
    } else {
      return res.status(404).json({ error: 'Booking not found.' }); // 404 Not Found
    }

  } catch (error) {
    console.error('Unhandled error in handleCancelBooking:', error);
    res.status(500).json({ error: 'An internal server error occurred.' });
  }
};

export const handleUserArrival = async (req, res) => {
  try {
    const { spotId, arrivalTime, userId } = req.body;

    if (!spotId || !arrivalTime || !userId) {
      return res.status(400).json({ error: 'spotId, arrivalTime, and userId are required.' });
    }

    const arrivalDateTime = new Date(arrivalTime);

    const currentSpotState = getSpotStatusAtTime(spotId, arrivalDateTime);

    // --- Scenario 1: The "Happy Path" ---
    if (currentSpotState.status === 'free') {
      console.log(`INFO: [Flow 1] Happy Path: Spot ${spotId} is free.`);
      return res.status(200).json({
        flow: 'FLOW_1_HAPPY_PATH',
        message: 'Your spot is ready!',
        spotId: spotId,
      });
    }

    // --- Scenario 2: "Conflict - Re-booking" ---
    console.log(`WARN: [Flow 2] Conflict: Spot ${spotId} is occupied by ${currentSpotState.userId}. Finding buffer...`);
    
    const bufferSpot = findAvailableBufferSpot(arrivalDateTime); // Use default buffer lot

    if (bufferSpot) {
      console.log(`INFO: [Flow 2] Success: Re-booking user to buffer spot ${bufferSpot.spotId}.`);

      const title = "Your Parking Spot Has Changed!";
      const body = `Your spot ${spotId} was occupied. We've moved you to ${bufferSpot.spotId} at no extra cost.`;
      sendPushNotification(userId, title, body);

      return res.status(200).json({
        flow: 'FLOW_2_REBOOKING',
        message: 'Your spot was occupied, but we found you a new one!',
        originalSpotId: spotId,
        newSpotId: bufferSpot.spotId,
        overstayingUser: currentSpotState.userId,
      });
    }

    // --- Scenario 3: "Conflict - Zero Inventory" ---
    // The spot is 'occupied' AND all buffer spots are also full.
    console.log(`ERROR: [Flow 3] Zero Inventory: Spot ${spotId} occupied, NO buffer spots available.`);
    
    let predictedWaitTimeMinutes = 10; 
    let predictionSource = 'default_fallback';

    try {
      console.log(`INFO: [Flow 3] Calling AI Service at ${AI_SERVICE_URL} for prediction...`);
      
      const aiResponse = await fetch(AI_SERVICE_URL, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          startTime: currentSpotState.startTime,
          endTime: currentSpotState.endTime
        })
      });

      if (!aiResponse.ok) {
        throw new Error(`AI service responded with status ${aiResponse.status}`);
      }

      const predictionResult = await aiResponse.json();
      
      // Calculate the *actual wait time* from the arrival time
      const overstayEndTime = new Date(new Date(currentSpotState.endTime).getTime() + predictionResult.predicted_overstay_minutes * 60000);
      const waitTimeMs = overstayEndTime.getTime() - arrivalDateTime.getTime();
      
      predictedWaitTimeMinutes = Math.max(1, Math.round(waitTimeMs / 60000));
      predictionSource = predictionResult.source;

      console.log(`INFO: [Flow 3] AI Service responded: Predicted Overstay=${predictionResult.predicted_overstay_minutes} min. Calculated Wait Time=${predictedWaitTimeMinutes} min.`);

    } catch (aiError) {
      console.error(`ERROR: [Flow 3] AI Service call failed: ${aiError.message}.`);
      console.error("Falling back to simulated wait time calculation.");
      
      if (currentSpotState.actualDepartureTime) {
        const waitTimeMs = currentSpotState.actualDepartureTime.getTime() - arrivalDateTime.getTime();
        predictedWaitTimeMinutes = Math.max(1, Math.round(waitTimeMs / 60000));
        predictionSource = 'local_simulation_fallback';
      }
    }

    // Send the push notification
    const title = "Parking Conflict at Your Spot!";
    const body = `Your spot ${spotId} is occupied. Predicted wait: ~${predictedWaitTimeMinutes} min. Please see app for options.`;
    sendPushNotification(userId, title, body);


    return res.status(200).json({
      flow: 'FLOW_3_ZERO_INVENTORY',
      message: 'We\'re sorry, the lot is 100% full.',
      details: `Your spot (${spotId}) is still occupied. We predict it will be free in ~${predictedWaitTimeMinutes} minutes.`,
      predictionSource: predictionSource, // For debugging
      options: [
        {
          id: 'WAIT',
          title: 'Wait for Spot',
          subtitle: `Get ${predictedWaitTimeMinutes} minutes of parking on us.`
        },
        {
          id: 'CANCEL',
          title: 'I Can\'t Wait (Cancel)',
          subtitle: 'Get a full refund + a service credit.'
        }
      ]
    });

  } catch (error) {
    console.error('Unhandled error in handleUserArrival:', error);
    res.status(500).json({ error: 'An internal server error occurred.' });
  }
};