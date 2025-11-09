import app from './app.js';

const PORT = process.env.PORT || 5001;

app.listen(PORT, () => {
  console.log(`🚀 ParkPredict API Server listening on http://localhost:${PORT}`);
  console.log(`Test your API at: http://localhost:${PORT}/api/status`);
});