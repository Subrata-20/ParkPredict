import express from 'express';
import bookingRoutes from './booking.routes.js';
import parkingRoutes from './parking.routes.js'; 

const router = express.Router();

router.use('/booking', bookingRoutes);

router.use('/parking', parkingRoutes);

//other routes(We can implement later)
// router.use('/users', userRoutes);
// router.use('/payments', paymentRoutes);

export default router;