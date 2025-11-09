import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.tree import DecisionTreeRegressor
from sklearn.preprocessing import StandardScaler
from sklearn.pipeline import Pipeline
import joblib
import os

# --- Constants ---
MODEL_DIR = "models"
MODEL_PATH = os.path.join(MODEL_DIR, "overstay_model.pkl")
DATA_PATH = "../data/parking_lot_simulation_data.csv"


def train_model():
    """
    Loads the simulation data, engineers features, and trains
    a model to predict overstay duration.
    """
    print("--- Starting AI Model Training ---")

    # 1. Load Data
    try:
        df = pd.read_csv(DATA_PATH)
    except FileNotFoundError:
        print(f"Error: Data file not found at {DATA_PATH}")
        print("Please make sure 'parking_lot_simulation_data.csv' is in the 'data' folder.")
        return

    print(f"Loaded {len(df)} events from CSV.")

    # 2. Feature Engineering
    df_departures = df[df['status'] == 'free'].copy()

    # Convert timestamps to datetime objects
    df_departures['timestamp'] = pd.to_datetime(df_departures['timestamp'])
    df_departures['booked_end'] = pd.to_datetime(df_departures['booked_end'])


    df_departures['overstay_minutes'] = (df_departures['timestamp'] - df_departures['booked_end']).dt.total_seconds() / 60
    
    # We only want to learn from *actual* overstays (not understays)
    df_departures['overstay_minutes'] = df_departures['overstay_minutes'].apply(lambda x: max(0, x))
    
    # --- Create Input Features (what the model learns from) ---
    # We need to use the *arrival* time, not departure. We'll join the tables.
    df_arrivals = df[df['status'] == 'occupied'][['user_id', 'timestamp']]
    df_arrivals = df_arrivals.rename(columns={'timestamp': 'arrival_time'})
    
    df_model = pd.merge(df_departures, df_arrivals, on='user_id', how='left')
    
    # Drop rows where we couldn't find the arrival (shouldn't happen)
    df_model = df_model.dropna(subset=['arrival_time'])

    # Ensure arrival_time is datetime so arithmetic works correctly
    df_model['arrival_time'] = pd.to_datetime(df_model['arrival_time'])

    # Feature 1: Time of day (hour)
    df_model['arrival_hour'] = df_model['arrival_time'].dt.hour

    # Feature 2: Day of week
    df_model['day_of_week'] = df_model['arrival_time'].dt.dayofweek

    # Feature 3: Booked duration
    df_model['booked_duration_minutes'] = (df_model['booked_end'] - df_model['arrival_time']).dt.total_seconds() / 60

    print("Feature engineering complete.")

    # 3. Model Training
    
    # Define our features (X) and target (y)
    features = ['arrival_hour', 'day_of_week', 'booked_duration_minutes']
    target = 'overstay_minutes'

    X = df_model[features]
    y = df_model[target]

    # Split the data
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

    # Create a simple Decision Tree pipeline
    # We scale the features first, then run the regressor
    pipeline = Pipeline([
        ('scaler', StandardScaler()),
        ('regressor', DecisionTreeRegressor(max_depth=10, random_state=42))
    ])

    # Train the model
    pipeline.fit(X_train, y_train)
    
    # Evaluate the model (just for our info)
    score = pipeline.score(X_test, y_test)
    print(f"Model trained. R-squared (accuracy) on test data: {score:.2f}")

    # 4. Save the Model
    # Ensure the 'models' directory exists
    os.makedirs(MODEL_DIR, exist_ok=True)
    
    joblib.dump(pipeline, MODEL_PATH)
    # Avoid non-ASCII characters that can raise encoding errors on some consoles
    print(f"Model successfully saved to {MODEL_PATH}")
    print("--- AI Model Training Complete ---")


if __name__ == "__main__":
    train_model()