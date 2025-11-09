from flask import Flask, jsonify, request
from flask_cors import CORS
import joblib
import pandas as pd
import os

app = Flask(__name__)
CORS(app) 

MODEL_PATH = os.path.join("models", "overstay_model.pkl")
model = None

try:
    model = joblib.load(MODEL_PATH)
    print(f"✅ Model loaded successfully from {MODEL_PATH}")
except FileNotFoundError:
    print(f"⚠️ WARNING: Model file not found at {MODEL_PATH}")
    print("Please run 'python train_model.py' first.")
    model = None
except Exception as e:
    print(f"Error loading model: {e}")
    model = None


@app.route('/api/status', methods=['GET'])
def status():
    """A simple health check for the AI service."""
    model_status = "loaded" if model else "not_found"
    return jsonify({
        "status": "ok",
        "service": "ParkPredict AI Service",
        "model_status": model_status
    })

@app.route('/api/predict/overstay', methods=['POST'])
def predict_overstay():
    """
    Predicts the overstay duration for a given booking.
    This is the "True AI Core".
    """
    if model is None:
        print("Model not loaded. Returning a 10-minute fallback prediction.")
        return jsonify({
            "predicted_overstay_minutes": 10,
            "source": "fallback_simulation"
        }), 503 # Service Unavailable

    try:

        data = request.get_json()
        print(f"AI Service: Received prediction request: {data}")

        arrival_time = pd.to_datetime(data.get('startTime'))
        booked_end = pd.to_datetime(data.get('endTime'))
        
        features = {
            'arrival_hour': arrival_time.hour,
            'day_of_week': arrival_time.dayofweek,
            'booked_duration_minutes': (booked_end - arrival_time).total_seconds() / 60
        }
        

        features_df = pd.DataFrame([features], columns=['arrival_hour', 'day_of_week', 'booked_duration_minutes'])


        prediction_minutes = model.predict(features_df)[0]
        

        prediction_minutes = max(0, round(prediction_minutes))

        print(f"AI Service: Prediction complete. Predicted overstay: {prediction_minutes} minutes.")


        return jsonify({
            "predicted_overstay_minutes": prediction_minutes,
            "source": "ml_model_v1"
        })

    except Exception as e:
        print(f"Error during prediction: {e}")
        return jsonify({"error": "Prediction failed", "details": str(e)}), 500


if __name__ == '__main__':
    app.run(debug=True, port=5002)