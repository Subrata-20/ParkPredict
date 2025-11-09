import express from 'express';
import { 
  handleUserArrival, 
  handleCreateBooking,
  handleCancelBooking
} from '../controllers/booking.controller.js';

const router = express.Router();

router.post('/arrive', handleUserArrival);

router.post('/book', handleCreateBooking);

router.delete('/:id', handleCancelBooking);

export default router;