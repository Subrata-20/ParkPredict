import express from 'express';
import cors from 'cors';
import mainRouter from './api/index.js';

const app = express();

app.use(cors());

app.use(express.json());

app.use('/api', mainRouter);

app.get('/api/status', (req, res) => {
  res.status(200).json({ status: 'ok', service: 'ParkPredict API' });
});

export default app;