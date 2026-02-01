#!/usr/bin/env python3
"""
DSLR - Data Science Logistic Regression
Hogwarts House Sorting using One-vs-All Logistic Regression
"""

import sys
import csv
import math
import json
from typing import List, Dict, Optional, Tuple


def sigmoid(z: float) -> float:
    """Sigmoid activation function."""
    if z < -500:
        return 0.0
    if z > 500:
        return 1.0
    return 1.0 / (1.0 + math.exp(-z))


def normalize(values: List[float]) -> Tuple[List[float], float, float]:
    """Normalize values to 0-1 range."""
    valid = [v for v in values if v is not None]
    if not valid:
        return values, 0, 1
    min_val = min(valid)
    max_val = max(valid)
    if max_val == min_val:
        return [0.5 if v is not None else None for v in values], min_val, max_val
    return [(v - min_val) / (max_val - min_val) if v is not None else None for v in values], min_val, max_val


def fill_missing(values: List[float], mean: float) -> List[float]:
    """Fill missing values with mean."""
    return [v if v is not None else mean for v in values]


def parse_float(s: str) -> Optional[float]:
    """Parse string to float, return None if invalid."""
    try:
        return float(s) if s.strip() else None
    except ValueError:
        return None


class LogisticRegression:
    """One-vs-All Logistic Regression classifier."""

    def __init__(self, learning_rate: float = 0.1, iterations: int = 1000):
        self.lr = learning_rate
        self.iterations = iterations
        self.weights: Dict[str, List[float]] = {}
        self.biases: Dict[str, float] = {}
        self.feature_stats: Dict[str, Tuple[float, float]] = {}
        self.feature_means: Dict[str, float] = {}
        self.classes: List[str] = []
        self.features: List[str] = []

    def fit(self, X: List[List[float]], y: List[str], features: List[str]):
        """Train the model using gradient descent."""
        self.classes = list(set(y))
        self.features = features
        n_samples = len(X)
        n_features = len(X[0]) if X else 0

        # Initialize weights for each class
        for cls in self.classes:
            self.weights[cls] = [0.0] * n_features
            self.biases[cls] = 0.0

        # Train binary classifier for each class (One-vs-All)
        for cls in self.classes:
            # Binary labels: 1 if this class, 0 otherwise
            y_binary = [1.0 if label == cls else 0.0 for label in y]

            # Gradient descent
            for _ in range(self.iterations):
                # Forward pass
                predictions = []
                for i in range(n_samples):
                    z = self.biases[cls]
                    for j in range(n_features):
                        z += self.weights[cls][j] * X[i][j]
                    predictions.append(sigmoid(z))

                # Backward pass - compute gradients
                dw = [0.0] * n_features
                db = 0.0
                for i in range(n_samples):
                    error = predictions[i] - y_binary[i]
                    for j in range(n_features):
                        dw[j] += error * X[i][j]
                    db += error

                # Update weights
                for j in range(n_features):
                    self.weights[cls][j] -= self.lr * dw[j] / n_samples
                self.biases[cls] -= self.lr * db / n_samples

    def predict_proba(self, x: List[float]) -> Dict[str, float]:
        """Predict probability for each class."""
        probs = {}
        for cls in self.classes:
            z = self.biases[cls]
            for j in range(len(x)):
                z += self.weights[cls][j] * x[j]
            probs[cls] = sigmoid(z)
        return probs

    def predict(self, x: List[float]) -> str:
        """Predict class label."""
        probs = self.predict_proba(x)
        return max(probs.keys(), key=lambda k: probs[k])

    def save(self, filename: str):
        """Save model to JSON file."""
        model_data = {
            'weights': self.weights,
            'biases': self.biases,
            'classes': self.classes,
            'features': self.features,
            'feature_stats': self.feature_stats,
            'feature_means': self.feature_means
        }
        with open(filename, 'w') as f:
            json.dump(model_data, f, indent=2)

    def load(self, filename: str):
        """Load model from JSON file."""
        with open(filename, 'r') as f:
            model_data = json.load(f)
        self.weights = model_data['weights']
        self.biases = model_data['biases']
        self.classes = model_data['classes']
        self.features = model_data['features']
        self.feature_stats = model_data.get('feature_stats', {})
        self.feature_means = model_data.get('feature_means', {})


def load_csv(filename: str) -> Tuple[List[Dict], List[str]]:
    """Load CSV file and return data with headers."""
    with open(filename, 'r') as f:
        reader = csv.reader(f)
        headers = next(reader)
        data = [{headers[i]: row[i] for i in range(len(headers))} for row in reader]
    return data, headers


def describe_data(data: List[Dict], headers: List[str]):
    """Print statistical description of numerical features."""
    print(f"{'Feature':<25} {'Count':>8} {'Mean':>12} {'Std':>12} {'Min':>12} {'Max':>12}")
    print("=" * 85)

    for col in headers:
        values = [parse_float(row.get(col, '')) for row in data]
        valid = [v for v in values if v is not None]

        if not valid:
            continue

        count = len(valid)
        mean = sum(valid) / count
        variance = sum((v - mean) ** 2 for v in valid) / count
        std = math.sqrt(variance)
        min_val = min(valid)
        max_val = max(valid)

        print(f"{col:<25} {count:>8} {mean:>12.2f} {std:>12.2f} {min_val:>12.2f} {max_val:>12.2f}")


def histogram(data: List[Dict], feature: str, label_col: str = 'Hogwarts House'):
    """Print ASCII histogram for a feature grouped by label."""
    groups: Dict[str, List[float]] = {}

    for row in data:
        label = row.get(label_col, '')
        value = parse_float(row.get(feature, ''))
        if label and value is not None:
            if label not in groups:
                groups[label] = []
            groups[label].append(value)

    print(f"\nHistogram: {feature}")
    print("=" * 60)

    for label, values in sorted(groups.items()):
        if not values:
            continue
        mean = sum(values) / len(values)
        min_val = min(values)
        max_val = max(values)
        bar_len = int((mean - min_val) / (max_val - min_val + 0.001) * 40) if max_val > min_val else 20
        print(f"{label:<15} {'#' * max(1, bar_len)} (mean: {mean:.2f})")


def scatter_matrix(data: List[Dict], features: List[str], label_col: str = 'Hogwarts House'):
    """Print correlation matrix for features."""
    print("\nCorrelation Matrix")
    print("=" * 60)

    # Get valid values for each feature
    feature_data = {}
    for feat in features:
        values = [parse_float(row.get(feat, '')) for row in data]
        valid = [v for v in values if v is not None]
        if valid:
            feature_data[feat] = values

    valid_features = list(feature_data.keys())

    # Print header
    print(f"{'':>20}", end='')
    for f in valid_features[:5]:
        print(f"{f[:8]:>10}", end='')
    print()

    # Print correlations
    for f1 in valid_features[:5]:
        print(f"{f1[:18]:>20}", end='')
        for f2 in valid_features[:5]:
            # Calculate Pearson correlation
            v1 = feature_data[f1]
            v2 = feature_data[f2]

            pairs = [(a, b) for a, b in zip(v1, v2) if a is not None and b is not None]
            if len(pairs) < 2:
                print(f"{'N/A':>10}", end='')
                continue

            x = [p[0] for p in pairs]
            y = [p[1] for p in pairs]

            n = len(pairs)
            mean_x = sum(x) / n
            mean_y = sum(y) / n

            num = sum((xi - mean_x) * (yi - mean_y) for xi, yi in zip(x, y))
            den_x = math.sqrt(sum((xi - mean_x) ** 2 for xi in x))
            den_y = math.sqrt(sum((yi - mean_y) ** 2 for yi in y))

            if den_x * den_y > 0:
                corr = num / (den_x * den_y)
                print(f"{corr:>10.3f}", end='')
            else:
                print(f"{'N/A':>10}", end='')
        print()


def prepare_features(data: List[Dict], features: List[str],
                     model: Optional[LogisticRegression] = None,
                     fit: bool = False) -> Tuple[List[List[float]], LogisticRegression]:
    """Prepare feature matrix from data."""
    if model is None:
        model = LogisticRegression()

    # Select numerical features
    numerical_features = []
    for feat in features:
        values = [parse_float(row.get(feat, '')) for row in data]
        valid = [v for v in values if v is not None]
        if len(valid) > len(data) * 0.5:  # At least 50% valid
            numerical_features.append(feat)

    # Skip index and non-useful columns
    skip_cols = {'Index', 'Hogwarts House', 'First Name', 'Last Name',
                 'Birthday', 'Best Hand'}
    numerical_features = [f for f in numerical_features if f not in skip_cols]

    if fit:
        model.features = numerical_features

    # Build feature matrix
    X = []
    for row in data:
        x = []
        for feat in (model.features if not fit else numerical_features):
            value = parse_float(row.get(feat, ''))
            x.append(value)
        X.append(x)

    # Normalize each feature
    for j, feat in enumerate(model.features if not fit else numerical_features):
        col = [X[i][j] for i in range(len(X))]

        if fit:
            # Calculate stats during training
            valid = [v for v in col if v is not None]
            mean = sum(valid) / len(valid) if valid else 0
            model.feature_means[feat] = mean

            col_filled = fill_missing(col, mean)
            col_norm, min_v, max_v = normalize(col_filled)
            model.feature_stats[feat] = (min_v, max_v)
        else:
            # Use saved stats during prediction
            mean = model.feature_means.get(feat, 0)
            col_filled = fill_missing(col, mean)
            min_v, max_v = model.feature_stats.get(feat, (0, 1))
            if max_v != min_v:
                col_norm = [(v - min_v) / (max_v - min_v) for v in col_filled]
            else:
                col_norm = [0.5] * len(col_filled)

        for i in range(len(X)):
            X[i][j] = col_norm[i]

    return X, model


def train(data_file: str, model_file: str = 'weights.json'):
    """Train the model on training data."""
    print(f"Loading training data from {data_file}...")
    data, headers = load_csv(data_file)
    print(f"Loaded {len(data)} samples")

    # Get labels
    label_col = 'Hogwarts House'
    y = [row.get(label_col, '') for row in data]

    # Remove samples without labels
    valid_idx = [i for i, label in enumerate(y) if label]
    data = [data[i] for i in valid_idx]
    y = [y[i] for i in valid_idx]

    print(f"Training samples: {len(data)}")
    print(f"Classes: {set(y)}")

    # Prepare features
    X, model = prepare_features(data, headers, fit=True)
    print(f"Features: {model.features}")

    # Train model
    print("\nTraining...")
    model.fit(X, y, model.features)

    # Calculate accuracy
    correct = sum(1 for i in range(len(X)) if model.predict(X[i]) == y[i])
    accuracy = correct / len(X) * 100
    print(f"Training accuracy: {accuracy:.2f}%")

    # Save model
    model.save(model_file)
    print(f"Model saved to {model_file}")


def predict(data_file: str, model_file: str = 'weights.json', output_file: str = 'houses.csv'):
    """Predict labels for test data."""
    print(f"Loading model from {model_file}...")
    model = LogisticRegression()
    model.load(model_file)

    print(f"Loading test data from {data_file}...")
    data, headers = load_csv(data_file)
    print(f"Loaded {len(data)} samples")

    # Prepare features
    X, _ = prepare_features(data, headers, model=model)

    # Predict
    predictions = [model.predict(x) for x in X]

    # Save predictions
    with open(output_file, 'w') as f:
        f.write("Index,Hogwarts House\n")
        for i, pred in enumerate(predictions):
            f.write(f"{i},{pred}\n")

    print(f"Predictions saved to {output_file}")

    # Print distribution
    from collections import Counter
    dist = Counter(predictions)
    print("\nPrediction distribution:")
    for house, count in sorted(dist.items()):
        print(f"  {house}: {count}")


def main():
    """Main entry point."""
    if len(sys.argv) < 2:
        print("DSLR - Data Science Logistic Regression")
        print("\nUsage:")
        print("  python logreg.py describe <dataset.csv>")
        print("  python logreg.py histogram <dataset.csv> [feature]")
        print("  python logreg.py scatter <dataset.csv>")
        print("  python logreg.py train <dataset.csv> [weights.json]")
        print("  python logreg.py predict <dataset.csv> [weights.json] [output.csv]")
        print("  python logreg.py demo")
        return

    cmd = sys.argv[1]

    if cmd == 'demo':
        # Generate demo dataset
        print("Generating demo Hogwarts dataset...")

        # Create synthetic data
        import random
        random.seed(42)

        houses = ['Gryffindor', 'Hufflepuff', 'Ravenclaw', 'Slytherin']
        features = ['Arithmancy', 'Astronomy', 'Herbology', 'Defense',
                   'Divination', 'Muggle Studies', 'Ancient Runes',
                   'History', 'Transfiguration', 'Potions', 'Charms', 'Flying']

        # House characteristics (mean offsets for each feature)
        house_traits = {
            'Gryffindor': [0, -10, 5, 20, -5, 0, 0, 0, 10, 5, 10, 15],
            'Hufflepuff': [5, 5, 20, 0, 5, 10, 5, 5, 0, 5, 5, 0],
            'Ravenclaw': [20, 15, 0, 5, 10, 5, 15, 15, 15, 5, 15, 0],
            'Slytherin': [10, 0, -5, 10, 0, -5, 10, 0, 5, 20, 5, 5]
        }

        data_rows = []
        for i in range(400):
            house = houses[i % 4]
            row = {
                'Index': str(i),
                'Hogwarts House': house,
                'First Name': f'Student{i}',
                'Last Name': f'Name{i}',
                'Birthday': '2000-01-01',
                'Best Hand': 'Right' if random.random() > 0.3 else 'Left'
            }

            traits = house_traits[house]
            for j, feat in enumerate(features):
                # Base score + house trait + random noise
                score = 50 + traits[j] + random.gauss(0, 15)
                score = max(0, min(100, score))
                row[feat] = f"{score:.2f}"

            data_rows.append(row)

        # Save training data
        train_file = 'dataset_train.csv'
        headers = ['Index', 'Hogwarts House', 'First Name', 'Last Name',
                   'Birthday', 'Best Hand'] + features

        with open(train_file, 'w') as f:
            f.write(','.join(headers) + '\n')
            for row in data_rows:
                f.write(','.join(row.get(h, '') for h in headers) + '\n')

        print(f"Created {train_file} with {len(data_rows)} samples")

        # Create test set (without labels)
        test_rows = data_rows[300:]
        test_file = 'dataset_test.csv'

        with open(test_file, 'w') as f:
            f.write(','.join(headers) + '\n')
            for row in test_rows:
                row_copy = row.copy()
                row_copy['Hogwarts House'] = ''  # Remove label
                f.write(','.join(row_copy.get(h, '') for h in headers) + '\n')

        print(f"Created {test_file} with {len(test_rows)} samples")

        # Run full pipeline
        print("\n--- Describe ---")
        describe_data(data_rows[:300], features)

        print("\n--- Train ---")
        train(train_file)

        print("\n--- Predict ---")
        predict(test_file)

    elif cmd == 'describe':
        if len(sys.argv) < 3:
            print("Usage: python logreg.py describe <dataset.csv>")
            return
        data, headers = load_csv(sys.argv[2])
        describe_data(data, headers)

    elif cmd == 'histogram':
        if len(sys.argv) < 3:
            print("Usage: python logreg.py histogram <dataset.csv> [feature]")
            return
        data, headers = load_csv(sys.argv[2])

        if len(sys.argv) > 3:
            histogram(data, sys.argv[3])
        else:
            # Find most homogeneous feature
            numerical = [h for h in headers if h not in
                        {'Index', 'Hogwarts House', 'First Name', 'Last Name', 'Birthday', 'Best Hand'}]
            for feat in numerical[:3]:
                histogram(data, feat)

    elif cmd == 'scatter':
        if len(sys.argv) < 3:
            print("Usage: python logreg.py scatter <dataset.csv>")
            return
        data, headers = load_csv(sys.argv[2])
        numerical = [h for h in headers if h not in
                    {'Index', 'Hogwarts House', 'First Name', 'Last Name', 'Birthday', 'Best Hand'}]
        scatter_matrix(data, numerical)

    elif cmd == 'train':
        if len(sys.argv) < 3:
            print("Usage: python logreg.py train <dataset.csv> [weights.json]")
            return
        model_file = sys.argv[3] if len(sys.argv) > 3 else 'weights.json'
        train(sys.argv[2], model_file)

    elif cmd == 'predict':
        if len(sys.argv) < 3:
            print("Usage: python logreg.py predict <dataset.csv> [weights.json] [output.csv]")
            return
        model_file = sys.argv[3] if len(sys.argv) > 3 else 'weights.json'
        output_file = sys.argv[4] if len(sys.argv) > 4 else 'houses.csv'
        predict(sys.argv[2], model_file, output_file)

    else:
        print(f"Unknown command: {cmd}")


if __name__ == "__main__":
    main()
