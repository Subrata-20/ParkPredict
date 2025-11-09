import { findAvailableLots } from '../services/parking.service.js';

export const handleSearchParking = (req, res) => {
  try {
    const { startTime, endTime } = req.query;

    if (!startTime || !endTime) {
      return res.status(400).json({ error: 'startTime and endTime query parameters are required.' });
    }
    

    const availableLots = findAvailableLots(startTime, endTime);
    
    res.status(200).json(availableLots);

  } catch (error) {
    console.error('Error in handleSearchParking:', error);
    res.status(500).json({ error: 'An internal server error occurred.' });
  }
};