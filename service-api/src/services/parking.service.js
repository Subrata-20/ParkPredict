
const MOCK_PARKING_LOTS = [
  {
    id: "Lot-A",
    name: "Main St. Garage (Lot A)",
    location: { lat: 18.5204, lng: 73.8567 }, // Pune coords
    spots: Array.from({ length: 44 }, (_, i) => `Lot-A-${String(i + 1).padStart(2, '0')}`)
  },
  {
    id: "Lot-B",
    name: "VW Tower Parking (Lot B)",
    location: { lat: 18.5230, lng: 73.8525 }, // Nearby coords
    spots: Array.from({ length: 50 }, (_, i) => `Lot-B-${String(i + 1).padStart(2, '0')}`)
  },
  {
    id: "Lot-C",
    name: "Buffer Lot (Lot C)",
    location: { lat: 18.5190, lng: 73.8580 }, // Nearby buffer
    spots: Array.from({ length: 6 }, (_, i) => `Lot-C-${String(i + 1).padStart(2, '0')}`)
  }
];

const ALL_SPOT_IDS = MOCK_PARKING_LOTS.flatMap(lot => lot.spots);


let bookings = [];
let bookingCounter = 1;
const OVERSTAY_PROBABILITY = 0.3; // 30% chance

const isSpotConflicted = (spotId, startTime, endTime) => {
  const newStart = new Date(startTime);
  const newEnd = new Date(endTime);

  return bookings.some(booking => {
    if (booking.spotId !== spotId) {
      return false; // Not the same spot
    }

    return newStart < booking.endTime && newEnd > booking.startTime;
  });
};


const getLotBySpotId = (spotId) => {
   if (!spotId) {
    return MOCK_PARKING_LOTS[0]; 
  }
  const lot = MOCK_PARKING_LOTS.find(lot => lot.id === spotId.split('-')[0]);
  return lot || MOCK_PARKING_LOTS[0]; 
};

export const createBooking = (spotId, startTime, endTime, userId) => {

  if (!ALL_SPOT_IDS.includes(spotId)) {
    return { success: false, error: `Spot ID '${spotId}' does not exist.` };
  }
 
  if (isSpotConflicted(spotId, startTime, endTime)) {
    return { success: false, error: 'Spot is already booked for this time slot.' };
  }

  const newBooking = {
    id: bookingCounter++,
    userId: userId || `user_${bookingCounter}`,
    spotId: spotId,
    startTime: new Date(startTime),
    endTime: new Date(endTime),
  };

  // --- Overstay Simulation ---
  newBooking.actualDepartureTime = new Date(endTime); 
  if (Math.random() < OVERSTAY_PROBABILITY) {
    const overstayMinutes = Math.floor(Math.random() * (20 - 5 + 1)) + 5; 
    newBooking.actualDepartureTime.setMinutes(newBooking.actualDepartureTime.getMinutes() + overstayMinutes);
    console.log(`SIMULATION: Booking ${newBooking.id} for spot ${spotId} will overstay by ${overstayMinutes} mins.`);
  }

  bookings.push(newBooking);
  
  // This line was causing the crash you saw earlier, now fixed
  const lot = getLotBySpotId(spotId);
  console.log(`INFO: Created Booking ID ${newBooking.id} for spot ${spotId} in ${lot.name}`);
  return { success: true, booking: newBooking };
};

export const cancelBooking = (bookingId) => {
  const id = parseInt(bookingId, 10);
  const bookingIndex = bookings.findIndex(b => b.id === id);

  if (bookingIndex === -1) {
    return { success: false, error: 'Booking not found.' };
  }

  const [cancelledBooking] = bookings.splice(bookingIndex, 1);
  console.log(`INFO: Cancelled Booking ID ${id} for spot ${cancelledBooking.spotId}`);
  return { success: true, booking: cancelledBooking };
};

//Finds the 'actual' status of a spot at a specific moment.
 
export const getSpotStatusAtTime = (spotId, atTime) => {
  const activeBooking = bookings.find(b =>
    b.spotId === spotId &&
    atTime >= b.startTime &&
    atTime < b.actualDepartureTime 
  );

  if (activeBooking) {
    const isOverstay = atTime > activeBooking.endTime;
    return {
      status: 'occupied',
      ...activeBooking, // Return all booking info
      isOverstay: isOverstay
    };
  }
  return { status: 'free' };
};

/**
 * Tries to find a free "buffer" spot from a provided list.
 */
export const findAvailableBufferSpot = (atTime, bufferLotId = "Lot-C") => {
  const bufferLot = MOCK_PARKING_LOTS.find(lot => lot.id === bufferLotId);
  if (!bufferLot) return null;

  for (const spotId of bufferLot.spots) {
    const spotState = getSpotStatusAtTime(spotId, atTime);
    if (spotState.status === 'free') {
      return { status: 'free', spotId: spotId };
    }
  }
  return null; 
};

export const findAvailableLots = (startTime, endTime) => {
  const availableLots = MOCK_PARKING_LOTS.map(lot => {
    let availableCount = 0;
    
    // Check each spot in the lot
    for (const spotId of lot.spots) {
      if (!isSpotConflicted(spotId, startTime, endTime)) {
        availableCount++;
      }
    }
    
    return {
      id: lot.id,
      name: lot.name,
      location: lot.location,
      totalSpots: lot.spots.length,
      availableCount: availableCount,
    };
  });

  return availableLots;
};