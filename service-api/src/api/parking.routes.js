import express from 'express';
import { handleSearchParking } from '../controllers/parking.controller.js';

const router = express.Router();
router.get('/search', handleSearchParking);

export default router;