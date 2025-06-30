# Credit Decision Engine Example

An AI/ML-powered credit decision engine for financial institutions, demonstrating automated credit risk assessment with machine learning pipelines integrated into secure CI/CD workflows.

## Overview

This example demonstrates:
- **ML-Powered Credit Scoring**: Real-time credit risk assessment using machine learning models
- **Automated Decision Making**: Rule-based and AI-driven loan approval workflows
- **Model Governance**: MLOps practices for financial services
- **Regulatory Compliance**: Explainable AI for regulatory requirements
- **Data Privacy**: PII protection and anonymization
- **A/B Testing**: Model performance comparison and gradual rollouts

## Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Data Sources  │    │   ML Pipeline    │    │   Decision API  │
├─────────────────┤    ├──────────────────┤    ├─────────────────┤
│ • Credit Bureau │───▶│ • Feature Eng    │───▶│ • REST API      │
│ • Bank Statements│    │ • Model Training │    │ • Real-time     │
│ • KYC Data      │    │ • Model Registry │    │   Scoring       │
│ • External APIs │    │ • A/B Testing    │    │ • Batch Scoring │
└─────────────────┘    │ • Model Monitor  │    └─────────────────┘
                       └──────────────────┘
```

## Technology Stack

- **Backend**: Python 3.11, FastAPI, Pydantic
- **ML Framework**: Scikit-learn, XGBoost, MLflow
- **Data Processing**: Pandas, NumPy, Apache Spark
- **Model Serving**: MLflow Model Registry, Seldon Core
- **Database**: PostgreSQL, MongoDB (for unstructured data)
- **Message Queue**: Apache Kafka for real-time data streaming
- **Monitoring**: Prometheus, Grafana, MLflow Tracking
- **Infrastructure**: Docker, Kubernetes, Helm

## Quick Start

### Prerequisites

- Python 3.11+
- Docker & Docker Compose
- PostgreSQL 14+
- MLflow server

### Setup

```bash
# Clone the repository
git clone https://github.com/your-org/credit-decision-engine.git
cd credit-decision-engine

# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Start infrastructure services
docker-compose up -d postgres mongodb mlflow kafka

# Run database migrations
alembic upgrade head

# Train initial model
python scripts/train_model.py

# Start the API server
uvicorn app.main:app --reload

# Access the API documentation
open http://localhost:8000/docs
```

## Project Structure

```
credit-decision-engine/
├── app/
│   ├── api/                  # FastAPI routes
│   ├── core/                 # Core configuration
│   ├── models/               # ML models and schemas
│   ├── services/             # Business logic
│   └── main.py               # Application entry point
├── data/
│   ├── raw/                  # Raw training data
│   ├── processed/            # Processed features
│   └── external/             # External data sources
├── notebooks/                # Jupyter notebooks for analysis
├── models/                   # Trained model artifacts
├── scripts/                  # Training and deployment scripts
├── tests/                    # Unit and integration tests
├── docker-compose.yml        # Local development setup
├── Dockerfile                # Container image
├── requirements.txt          # Python dependencies
└── README.md                 # This file
```

## Core Features

### 1. Credit Scoring API

```python
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from app.services.credit_scoring import CreditScoringService

app = FastAPI(title="Credit Decision Engine")

class CreditRequest(BaseModel):
    customer_id: str
    annual_income: float
    employment_years: int
    existing_debt: float
    loan_amount: float
    loan_purpose: str
    credit_history: dict

class CreditDecision(BaseModel):
    score: float
    decision: str  # APPROVED, REJECTED, MANUAL_REVIEW
    confidence: float
    explanation: dict
    risk_factors: list[str]

@app.post("/api/v1/credit/score", response_model=CreditDecision)
async def score_credit_application(request: CreditRequest):
    """
    Evaluate credit application and return decision with explanation.
    """
    try:
        scoring_service = CreditScoringService()
        decision = await scoring_service.evaluate_application(request)
        return decision
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
```

### 2. ML Model Training Pipeline

```python
import mlflow
import mlflow.sklearn
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
from sklearn.model_selection import cross_val_score
from sklearn.metrics import classification_report, roc_auc_score

class CreditModelTrainer:
    def __init__(self, experiment_name="credit_scoring"):
        mlflow.set_experiment(experiment_name)
        
    def train_model(self, X_train, y_train, X_test, y_test):
        """Train and evaluate credit scoring model."""
        
        with mlflow.start_run():
            # Log parameters
            mlflow.log_param("model_type", "ensemble")
            mlflow.log_param("train_size", len(X_train))
            mlflow.log_param("test_size", len(X_test))
            
            # Train Random Forest
            rf_model = RandomForestClassifier(
                n_estimators=100,
                max_depth=10,
                random_state=42
            )
            rf_model.fit(X_train, y_train)
            
            # Evaluate model
            y_pred = rf_model.predict(X_test)
            y_prob = rf_model.predict_proba(X_test)[:, 1]
            
            accuracy = rf_model.score(X_test, y_test)
            auc_score = roc_auc_score(y_test, y_prob)
            
            # Log metrics
            mlflow.log_metric("accuracy", accuracy)
            mlflow.log_metric("auc_score", auc_score)
            
            # Log model
            mlflow.sklearn.log_model(
                rf_model, 
                "credit_scoring_model",
                registered_model_name="CreditScoringModel"
            )
            
            # Feature importance
            feature_importance = dict(zip(
                X_train.columns, 
                rf_model.feature_importances_
            ))
            mlflow.log_dict(feature_importance, "feature_importance.json")
            
            return rf_model, accuracy, auc_score
```

### 3. Feature Engineering

```python
import pandas as pd
import numpy as np
from datetime import datetime, timedelta

class FeatureEngineer:
    def __init__(self):
        self.feature_transformers = {}
        
    def create_features(self, customer_data: dict) -> pd.DataFrame:
        """Create features for credit scoring model."""
        
        features = {}
        
        # Basic demographic features
        features['age'] = self._calculate_age(customer_data.get('date_of_birth'))
        features['annual_income'] = customer_data.get('annual_income', 0)
        features['employment_years'] = customer_data.get('employment_years', 0)
        
        # Credit history features
        credit_history = customer_data.get('credit_history', {})
        features['credit_score'] = credit_history.get('score', 0)
        features['total_accounts'] = len(credit_history.get('accounts', []))
        features['active_accounts'] = len([
            acc for acc in credit_history.get('accounts', []) 
            if acc.get('status') == 'active'
        ])
        
        # Financial ratios
        features['debt_to_income'] = (
            customer_data.get('existing_debt', 0) / 
            max(customer_data.get('annual_income', 1), 1)
        )
        features['loan_to_income'] = (
            customer_data.get('loan_amount', 0) / 
            max(customer_data.get('annual_income', 1), 1)
        )
        
        # Risk indicators
        features['has_defaults'] = any(
            acc.get('status') == 'default' 
            for acc in credit_history.get('accounts', [])
        )
        features['recent_inquiries'] = len([
            inq for inq in credit_history.get('inquiries', [])
            if self._is_recent(inq.get('date'))
        ])
        
        return pd.DataFrame([features])
    
    def _calculate_age(self, date_of_birth):
        if not date_of_birth:
            return 0
        dob = datetime.strptime(date_of_birth, '%Y-%m-%d')
        return (datetime.now() - dob).days // 365
    
    def _is_recent(self, date_str, months=6):
        if not date_str:
            return False
        date = datetime.strptime(date_str, '%Y-%m-%d')
        cutoff = datetime.now() - timedelta(days=months * 30)
        return date > cutoff
```

### 4. Model Governance and Explainability

```python
import shap
from lime.lime_tabular import LimeTabularExplainer

class ModelExplainer:
    def __init__(self, model, training_data):
        self.model = model
        self.training_data = training_data
        self.explainer = LimeTabularExplainer(
            training_data.values,
            feature_names=training_data.columns,
            class_names=['Reject', 'Approve'],
            mode='classification'
        )
        
    def explain_prediction(self, instance, feature_names):
        """Provide explanation for a single prediction."""
        
        # LIME explanation
        lime_explanation = self.explainer.explain_instance(
            instance.values[0], 
            self.model.predict_proba,
            num_features=10
        )
        
        # SHAP explanation
        shap_explainer = shap.TreeExplainer(self.model)
        shap_values = shap_explainer.shap_values(instance)
        
        # Format explanation for API response
        explanation = {
            'lime_explanation': lime_explanation.as_list(),
            'shap_values': {
                feature: float(value) 
                for feature, value in zip(feature_names, shap_values[1][0])
            },
            'feature_importance': dict(zip(
                feature_names, 
                self.model.feature_importances_
            ))
        }
        
        return explanation
```

### 5. Real-time Decision Service

```python
from fastapi import BackgroundTasks
import asyncio
import aioredis

class CreditScoringService:
    def __init__(self):
        self.model_cache = {}
        self.redis = None
        
    async def evaluate_application(self, request: CreditRequest) -> CreditDecision:
        """Evaluate credit application in real-time."""
        
        # Load model from cache or registry
        model = await self._get_model()
        
        # Feature engineering
        feature_engineer = FeatureEngineer()
        features = feature_engineer.create_features(request.dict())
        
        # Make prediction
        prediction_proba = model.predict_proba(features)[0]
        score = float(prediction_proba[1])  # Probability of approval
        
        # Make decision based on thresholds
        decision = self._make_decision(score)
        
        # Generate explanation
        explainer = ModelExplainer(model, self.training_data)
        explanation = explainer.explain_prediction(features, features.columns)
        
        # Identify risk factors
        risk_factors = self._identify_risk_factors(features, explanation)
        
        # Log decision for monitoring
        await self._log_decision(request, score, decision)
        
        return CreditDecision(
            score=score,
            decision=decision,
            confidence=max(prediction_proba),
            explanation=explanation,
            risk_factors=risk_factors
        )
    
    def _make_decision(self, score: float) -> str:
        """Apply business rules to make final decision."""
        if score >= 0.8:
            return "APPROVED"
        elif score >= 0.4:
            return "MANUAL_REVIEW"
        else:
            return "REJECTED"
    
    def _identify_risk_factors(self, features, explanation) -> list[str]:
        """Identify top risk factors based on model explanation."""
        risk_factors = []
        
        # Extract negative SHAP values (risk factors)
        shap_values = explanation['shap_values']
        for feature, value in shap_values.items():
            if value < -0.1:  # Significant negative impact
                risk_factors.append(f"High {feature.replace('_', ' ')}")
        
        return risk_factors[:5]  # Top 5 risk factors
```

## ML Pipeline Automation

### 1. Training Pipeline

```yaml
# .github/workflows/ml-pipeline.yml
name: ML Model Training Pipeline

on:
  schedule:
    - cron: '0 2 * * 0'  # Weekly retraining
  workflow_dispatch:
    inputs:
      retrain_type:
        description: 'Type of retraining'
        required: true
        default: 'incremental'
        type: choice
        options:
          - incremental
          - full

env:
  PYTHON_VERSION: '3.11'
  MLFLOW_TRACKING_URI: ${{ secrets.MLFLOW_TRACKING_URI }}

jobs:
  data-validation:
    name: Validate Training Data
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: ${{ env.PYTHON_VERSION }}

    - name: Install dependencies
      run: |
        pip install -r requirements.txt

    - name: Validate data quality
      run: |
        python scripts/validate_data.py
        
    - name: Check for data drift
      run: |
        python scripts/detect_data_drift.py

  model-training:
    name: Train ML Model
    runs-on: ubuntu-latest
    needs: data-validation
    environment: ml-training
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: ${{ env.PYTHON_VERSION }}

    - name: Install dependencies
      run: |
        pip install -r requirements.txt

    - name: Download training data
      run: |
        python scripts/download_data.py
      env:
        DATABASE_URL: ${{ secrets.TRAINING_DATABASE_URL }}

    - name: Train model
      run: |
        python scripts/train_model.py \
          --experiment-name "credit_scoring_${{ github.run_id }}" \
          --retrain-type "${{ github.event.inputs.retrain_type || 'incremental' }}"

    - name: Evaluate model
      run: |
        python scripts/evaluate_model.py

    - name: Upload model artifacts
      uses: actions/upload-artifact@v4
      with:
        name: model-artifacts
        path: models/

  model-testing:
    name: Test Model Performance
    runs-on: ubuntu-latest
    needs: model-training
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Download model artifacts
      uses: actions/download-artifact@v4
      with:
        name: model-artifacts
        path: models/

    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: ${{ env.PYTHON_VERSION }}

    - name: Install dependencies
      run: |
        pip install -r requirements.txt

    - name: Run model tests
      run: |
        python -m pytest tests/model_tests.py -v

    - name: Performance benchmarking
      run: |
        python scripts/benchmark_model.py

    - name: Bias and fairness testing
      run: |
        python scripts/test_model_fairness.py

  compliance-validation:
    name: Regulatory Compliance Check
    runs-on: ubuntu-latest
    needs: model-testing
    
    steps:
    - name: Explainability validation
      run: |
        python scripts/validate_explainability.py

    - name: RBI compliance check
      run: |
        python scripts/rbi_compliance_check.py

    - name: Model documentation generation
      run: |
        python scripts/generate_model_docs.py

  model-deployment:
    name: Deploy Model to Registry
    runs-on: ubuntu-latest
    needs: compliance-validation
    if: github.ref == 'refs/heads/main'
    environment: production
    
    steps:
    - name: Register model in MLflow
      run: |
        python scripts/register_model.py \
          --model-name "CreditScoringModel" \
          --stage "Production"

    - name: Update model serving
      run: |
        kubectl apply -f k8s/model-serving.yml
```

### 2. Model Monitoring

```python
import mlflow
import pandas as pd
from evidently import ColumnMapping
from evidently.report import Report
from evidently.metric_preset import DataDriftPreset, TargetDriftPreset

class ModelMonitor:
    def __init__(self, model_name, reference_data):
        self.model_name = model_name
        self.reference_data = reference_data
        
    def detect_data_drift(self, current_data):
        """Detect data drift in incoming requests."""
        
        column_mapping = ColumnMapping()
        column_mapping.target = 'approved'
        column_mapping.prediction = 'prediction'
        
        # Create drift report
        data_drift_report = Report(metrics=[
            DataDriftPreset(),
            TargetDriftPreset()
        ])
        
        data_drift_report.run(
            reference_data=self.reference_data,
            current_data=current_data,
            column_mapping=column_mapping
        )
        
        # Extract drift metrics
        drift_report = data_drift_report.as_dict()
        
        # Check for significant drift
        drift_detected = any(
            metric.get('result', {}).get('drift_detected', False)
            for metric in drift_report['metrics']
        )
        
        if drift_detected:
            self._trigger_retraining_alert(drift_report)
            
        return drift_detected, drift_report
    
    def monitor_model_performance(self, predictions, actuals):
        """Monitor model performance over time."""
        
        # Calculate performance metrics
        from sklearn.metrics import accuracy_score, roc_auc_score
        
        accuracy = accuracy_score(actuals, predictions > 0.5)
        auc = roc_auc_score(actuals, predictions)
        
        # Log metrics to MLflow
        with mlflow.start_run():
            mlflow.log_metric("live_accuracy", accuracy)
            mlflow.log_metric("live_auc", auc)
            
        # Check for performance degradation
        if accuracy < 0.75 or auc < 0.8:
            self._trigger_performance_alert(accuracy, auc)
            
        return {"accuracy": accuracy, "auc": auc}
    
    def _trigger_retraining_alert(self, drift_report):
        """Trigger alert for data drift detection."""
        # Send alert to operations team
        pass
    
    def _trigger_performance_alert(self, accuracy, auc):
        """Trigger alert for performance degradation."""
        # Send alert to ML team
        pass
```

## Testing Strategy

### 1. Model Unit Tests

```python
import pytest
import pandas as pd
import numpy as np
from app.models.credit_scoring import CreditScoringModel

class TestCreditScoringModel:
    
    @pytest.fixture
    def sample_data(self):
        return pd.DataFrame({
            'annual_income': [50000, 80000, 30000],
            'credit_score': [750, 680, 600],
            'debt_to_income': [0.3, 0.4, 0.6],
            'employment_years': [3, 7, 1]
        })
    
    @pytest.fixture
    def trained_model(self, sample_data):
        model = CreditScoringModel()
        # Train with sample data
        y = np.array([1, 1, 0])  # Approved, Approved, Rejected
        model.fit(sample_data, y)
        return model
    
    def test_model_prediction_range(self, trained_model, sample_data):
        """Test that predictions are in valid range."""
        predictions = trained_model.predict_proba(sample_data)
        
        assert all(0 <= pred <= 1 for pred in predictions[:, 1])
    
    def test_model_consistency(self, trained_model, sample_data):
        """Test that model produces consistent results."""
        pred1 = trained_model.predict_proba(sample_data)
        pred2 = trained_model.predict_proba(sample_data)
        
        np.testing.assert_array_equal(pred1, pred2)
    
    def test_feature_importance(self, trained_model):
        """Test that model has reasonable feature importance."""
        importance = trained_model.feature_importances_
        
        # Credit score should be important
        feature_names = trained_model.feature_names_in_
        credit_score_idx = list(feature_names).index('credit_score')
        
        assert importance[credit_score_idx] > 0.1
```

### 2. Integration Tests

```python
import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

class TestCreditScoringAPI:
    
    def test_credit_scoring_endpoint(self):
        """Test the credit scoring API endpoint."""
        request_data = {
            "customer_id": "test_123",
            "annual_income": 75000,
            "employment_years": 5,
            "existing_debt": 15000,
            "loan_amount": 25000,
            "loan_purpose": "home_improvement",
            "credit_history": {
                "score": 720,
                "accounts": [
                    {"type": "credit_card", "status": "active"},
                    {"type": "auto_loan", "status": "closed"}
                ]
            }
        }
        
        response = client.post("/api/v1/credit/score", json=request_data)
        
        assert response.status_code == 200
        data = response.json()
        
        assert "score" in data
        assert "decision" in data
        assert "explanation" in data
        assert 0 <= data["score"] <= 1
        assert data["decision"] in ["APPROVED", "REJECTED", "MANUAL_REVIEW"]
    
    def test_invalid_request(self):
        """Test API validation with invalid data."""
        invalid_request = {
            "customer_id": "",  # Invalid empty ID
            "annual_income": -1000,  # Invalid negative income
        }
        
        response = client.post("/api/v1/credit/score", json=invalid_request)
        assert response.status_code == 422
```

## Deployment

### 1. Docker Configuration

```dockerfile
FROM python:3.11-slim

# Create non-root user
RUN addgroup --system --gid 1001 mluser && \
    adduser --system --uid 1001 --gid 1001 mluser

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python dependencies
COPY requirements.txt /app/
WORKDIR /app
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . /app/

# Set ownership
RUN chown -R mluser:mluser /app

# Switch to non-root user
USER mluser

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8000/health || exit 1

# Run application
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### 2. Kubernetes Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: credit-decision-engine
  namespace: ml-services
spec:
  replicas: 3
  selector:
    matchLabels:
      app: credit-decision-engine
  template:
    metadata:
      labels:
        app: credit-decision-engine
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 1001
        fsGroup: 1001
      containers:
      - name: api
        image: your-registry/credit-decision-engine:latest
        ports:
        - containerPort: 8000
        env:
        - name: MLFLOW_TRACKING_URI
          valueFrom:
            secretKeyRef:
              name: ml-secrets
              key: mlflow-uri
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: ml-secrets
              key: database-url
        resources:
          requests:
            memory: "2Gi"
            cpu: "1"
          limits:
            memory: "4Gi"
            cpu: "2"
        livenessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 8000
          initialDelaySeconds: 5
          periodSeconds: 5
```

## Compliance and Governance

### 1. Model Documentation

```python
# Model Card Template for Regulatory Compliance
MODEL_CARD = {
    "model_details": {
        "name": "Credit Decision Engine v2.1",
        "description": "ML model for automated credit risk assessment",
        "version": "2.1.0",
        "date": "2024-01-15",
        "type": "Ensemble (Random Forest + Gradient Boosting)",
        "paper": "Internal Research Paper CDE-2024-001"
    },
    "intended_use": {
        "primary_uses": "Credit risk assessment for personal loans",
        "primary_users": "Credit officers and automated decision systems",
        "out_of_scope": "Commercial loans, credit cards"
    },
    "training_data": {
        "datasets": "Historical loan data from 2019-2023",
        "preprocessing": "Feature engineering, outlier removal, SMOTE",
        "size": "50,000 loan applications"
    },
    "evaluation_data": {
        "datasets": "Holdout test set from 2023",
        "size": "10,000 loan applications",
        "motivation": "Time-based split to simulate real-world deployment"
    },
    "quantitative_analyses": {
        "accuracy": 0.87,
        "precision": 0.85,
        "recall": 0.82,
        "f1_score": 0.83,
        "auc_roc": 0.91
    },
    "ethical_considerations": {
        "fairness_constraints": "Equal opportunity across gender and ethnicity",
        "bias_mitigation": "Fairness-aware model training and post-processing",
        "protected_attributes": ["gender", "ethnicity", "religion"]
    },
    "recommendations": [
        "Regular retraining every 3 months",
        "Continuous monitoring for bias and drift",
        "Human oversight for edge cases"
    ]
}
```

This credit decision engine provides a comprehensive example of implementing ML models in financial services with proper governance, monitoring, and regulatory compliance.