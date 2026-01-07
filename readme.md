# Konkor CS Rank Estimator

this project predicts **Computer Science Konkor ranks** based on user entered subject percentages using a **machine learning model**
it consists of a flutter frontend & a fastapi backend that serves ml predictions
it needs couple of adjustments & fixes for both back + front (idk when i be back on those)

## how to Run:

### backend 
```bash
cd backend
pip install -r requirements.txt
uvicorn main:app --reload
```

### frotnend 
```bash
cd frontend
flutter pub get
flutter run -d chrome
```
