# DSLR - Data Science Logistic Regression

Hogwarts House sorting using One-vs-All Logistic Regression.

## Features

- Data visualization (describe, histogram, scatter plot)
- One-vs-All Logistic Regression classifier
- Gradient descent optimization
- Feature normalization
- Model persistence (JSON)

## Usage

```bash
# Describe dataset statistics
python logreg.py describe dataset_train.csv

# Show histograms
python logreg.py histogram dataset_train.csv

# Show correlation matrix
python logreg.py scatter dataset_train.csv

# Train model
python logreg.py train dataset_train.csv weights.json

# Predict
python logreg.py predict dataset_test.csv weights.json houses.csv

# Run complete demo
python logreg.py demo
```

## Algorithm

1. **Feature Selection**: Numerical features with >50% valid values
2. **Preprocessing**: Missing value imputation with mean, normalization
3. **Training**: One-vs-All with gradient descent
4. **Prediction**: Select class with highest probability

## Author

Implementation for 42 curriculum.
