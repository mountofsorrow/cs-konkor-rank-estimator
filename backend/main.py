from fastapi import FastAPI
from pydantic import BaseModel
import joblib
import numpy as np

app = FastAPI()
model = joblib.load("model.pkl")

class InputData(BaseModel):
    Mathematics: float
    English: float
    Specialized1: float
    Specialized2: float
    Specialized3: float
    Specialized4: float
    Quota: int
    EffectiveGPA: float

@app.post("/predict")
def predict(data: InputData):
    features = np.array([[
        data.Mathematics,
        data.English,
        data.Specialized1,
        data.Specialized2,
        data.Specialized3,
        data.Specialized4,
        data.Quota,
        data.EffectiveGPA
    ]])

    pred = model.predict(features)[0]
    return {"rank": int(pred)}
