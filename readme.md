<img width="1326" height="936" alt="{CEAAA9C5-97AB-41BE-A219-EB514A37A56E}" src="https://github.com/user-attachments/assets/caf2e6eb-fca7-49df-b5b7-8b0365d3cceb" /># Konkor CS Rank Estimator

this project predicts **Computer Science Konkor ranks** based on user entered subject percentages using a **machine learning model**
it consists of a flutter frontend & a fastapi backend that serves ml predictions

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
