# Konkor CS Rank Estimator

this project predicts **Computer Science Konkor ranks** based on user entered subject percentages using a **machine learning model**
it consists of a flutter frontend & a fastapi backend that serves ml predictions

## how to Run:

### backend 
```bash
cd backend
pip install -r requirements.txt
uvicorn main:app --
```

### frotnend 
cd frontend
flutter pub get
flutter run -d chrome