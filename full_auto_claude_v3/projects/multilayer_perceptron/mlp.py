#!/usr/bin/env python3
"""
Multilayer Perceptron - Neural Network from scratch
Binary classification with backpropagation
"""

import sys
import math
import json
import csv
from typing import List, Tuple, Optional
from dataclasses import dataclass, field
import random


def sigmoid(x: float) -> float:
    """Sigmoid activation."""
    if x < -500:
        return 0.0
    if x > 500:
        return 1.0
    return 1.0 / (1.0 + math.exp(-x))


def sigmoid_derivative(x: float) -> float:
    """Derivative of sigmoid."""
    s = sigmoid(x)
    return s * (1 - s)


def relu(x: float) -> float:
    """ReLU activation."""
    return max(0.0, x)


def relu_derivative(x: float) -> float:
    """Derivative of ReLU."""
    return 1.0 if x > 0 else 0.0


def softmax(values: List[float]) -> List[float]:
    """Softmax function."""
    max_val = max(values)
    exp_vals = [math.exp(v - max_val) for v in values]
    sum_exp = sum(exp_vals)
    return [e / sum_exp for e in exp_vals]


def cross_entropy_loss(predicted: List[float], target: int) -> float:
    """Cross entropy loss."""
    epsilon = 1e-15
    return -math.log(max(predicted[target], epsilon))


def binary_cross_entropy(predicted: float, target: float) -> float:
    """Binary cross entropy loss."""
    epsilon = 1e-15
    predicted = max(min(predicted, 1 - epsilon), epsilon)
    return -(target * math.log(predicted) + (1 - target) * math.log(1 - predicted))


@dataclass
class Layer:
    """Neural network layer."""
    input_size: int
    output_size: int
    activation: str = 'sigmoid'
    weights: List[List[float]] = field(default_factory=list)
    biases: List[float] = field(default_factory=list)

    def __post_init__(self):
        if not self.weights:
            # Xavier initialization
            limit = math.sqrt(6.0 / (self.input_size + self.output_size))
            self.weights = [
                [random.uniform(-limit, limit) for _ in range(self.input_size)]
                for _ in range(self.output_size)
            ]
        if not self.biases:
            self.biases = [0.0] * self.output_size

    def forward(self, inputs: List[float]) -> Tuple[List[float], List[float]]:
        """Forward pass. Returns (outputs, pre_activation)."""
        pre_activation = []
        for j in range(self.output_size):
            z = self.biases[j]
            for i in range(self.input_size):
                z += self.weights[j][i] * inputs[i]
            pre_activation.append(z)

        if self.activation == 'sigmoid':
            outputs = [sigmoid(z) for z in pre_activation]
        elif self.activation == 'relu':
            outputs = [relu(z) for z in pre_activation]
        elif self.activation == 'softmax':
            outputs = softmax(pre_activation)
        else:
            outputs = pre_activation

        return outputs, pre_activation


class MLP:
    """Multilayer Perceptron."""

    def __init__(self, layer_sizes: List[int], activations: Optional[List[str]] = None):
        """
        Initialize MLP.
        layer_sizes: [input_size, hidden1, hidden2, ..., output_size]
        """
        self.layers: List[Layer] = []

        if activations is None:
            # Default: ReLU hidden, sigmoid output
            activations = ['relu'] * (len(layer_sizes) - 2) + ['sigmoid']

        for i in range(len(layer_sizes) - 1):
            self.layers.append(Layer(
                input_size=layer_sizes[i],
                output_size=layer_sizes[i + 1],
                activation=activations[i]
            ))

    def forward(self, inputs: List[float]) -> Tuple[List[float], List[Tuple]]:
        """Forward pass through all layers."""
        cache = []  # Store for backprop: (inputs, pre_activation)
        current = inputs

        for layer in self.layers:
            outputs, pre_act = layer.forward(current)
            cache.append((current, pre_act))
            current = outputs

        return current, cache

    def backward(self, cache: List[Tuple], target: List[float], output: List[float],
                 learning_rate: float):
        """Backward pass with gradient descent."""
        # Output layer error (for sigmoid + binary cross entropy)
        deltas = [output[i] - target[i] for i in range(len(output))]

        # Backpropagate through layers
        for layer_idx in range(len(self.layers) - 1, -1, -1):
            layer = self.layers[layer_idx]
            inputs, pre_act = cache[layer_idx]

            # Gradients for this layer
            weight_grads = [[0.0] * layer.input_size for _ in range(layer.output_size)]
            bias_grads = [0.0] * layer.output_size

            for j in range(layer.output_size):
                bias_grads[j] = deltas[j]
                for i in range(layer.input_size):
                    weight_grads[j][i] = deltas[j] * inputs[i]

            # Calculate deltas for previous layer
            if layer_idx > 0:
                prev_layer = self.layers[layer_idx - 1]
                _, prev_pre_act = cache[layer_idx - 1]
                new_deltas = [0.0] * layer.input_size

                for i in range(layer.input_size):
                    error = 0.0
                    for j in range(layer.output_size):
                        error += deltas[j] * layer.weights[j][i]

                    if prev_layer.activation == 'sigmoid':
                        new_deltas[i] = error * sigmoid_derivative(prev_pre_act[i])
                    elif prev_layer.activation == 'relu':
                        new_deltas[i] = error * relu_derivative(prev_pre_act[i])
                    else:
                        new_deltas[i] = error

                deltas = new_deltas

            # Update weights
            for j in range(layer.output_size):
                layer.biases[j] -= learning_rate * bias_grads[j]
                for i in range(layer.input_size):
                    layer.weights[j][i] -= learning_rate * weight_grads[j][i]

    def train(self, X: List[List[float]], y: List[List[float]],
              epochs: int = 100, learning_rate: float = 0.1,
              batch_size: int = 32, verbose: bool = True):
        """Train the network."""
        n_samples = len(X)

        for epoch in range(epochs):
            # Shuffle data
            indices = list(range(n_samples))
            random.shuffle(indices)

            total_loss = 0.0
            correct = 0

            for i in indices:
                # Forward
                output, cache = self.forward(X[i])

                # Loss
                for j in range(len(output)):
                    total_loss += binary_cross_entropy(output[j], y[i][j])

                # Accuracy
                predicted = 1 if output[0] > 0.5 else 0
                actual = 1 if y[i][0] > 0.5 else 0
                if predicted == actual:
                    correct += 1

                # Backward
                self.backward(cache, y[i], output, learning_rate)

            if verbose and (epoch + 1) % 10 == 0:
                avg_loss = total_loss / n_samples
                accuracy = correct / n_samples * 100
                print(f"Epoch {epoch + 1}/{epochs} - Loss: {avg_loss:.4f} - Accuracy: {accuracy:.2f}%")

    def predict(self, inputs: List[float]) -> List[float]:
        """Predict for single sample."""
        output, _ = self.forward(inputs)
        return output

    def predict_class(self, inputs: List[float]) -> int:
        """Predict class label."""
        output = self.predict(inputs)
        return 1 if output[0] > 0.5 else 0

    def save(self, filename: str):
        """Save model to JSON."""
        model_data = {
            'layers': []
        }
        for layer in self.layers:
            model_data['layers'].append({
                'input_size': layer.input_size,
                'output_size': layer.output_size,
                'activation': layer.activation,
                'weights': layer.weights,
                'biases': layer.biases
            })

        with open(filename, 'w') as f:
            json.dump(model_data, f)

    def load(self, filename: str):
        """Load model from JSON."""
        with open(filename, 'r') as f:
            model_data = json.load(f)

        self.layers = []
        for layer_data in model_data['layers']:
            layer = Layer(
                input_size=layer_data['input_size'],
                output_size=layer_data['output_size'],
                activation=layer_data['activation'],
                weights=layer_data['weights'],
                biases=layer_data['biases']
            )
            self.layers.append(layer)


def load_csv(filename: str) -> Tuple[List[List[float]], List[int]]:
    """Load dataset from CSV."""
    X = []
    y = []

    with open(filename, 'r') as f:
        reader = csv.reader(f)
        headers = next(reader, None)

        for row in reader:
            # Assume last column is label
            features = []
            for val in row[:-1]:
                try:
                    features.append(float(val))
                except ValueError:
                    features.append(0.0)
            X.append(features)

            # Label
            try:
                y.append(int(row[-1]))
            except ValueError:
                y.append(1 if row[-1].lower() in ['m', 'malignant', 'positive', 'yes', '1'] else 0)

    return X, y


def normalize_features(X: List[List[float]]) -> Tuple[List[List[float]], List[Tuple[float, float]]]:
    """Normalize features to 0-1 range."""
    if not X:
        return X, []

    n_features = len(X[0])
    stats = []

    for j in range(n_features):
        col = [X[i][j] for i in range(len(X))]
        min_val = min(col)
        max_val = max(col)
        stats.append((min_val, max_val))

    X_norm = []
    for sample in X:
        norm_sample = []
        for j, val in enumerate(sample):
            min_val, max_val = stats[j]
            if max_val != min_val:
                norm_sample.append((val - min_val) / (max_val - min_val))
            else:
                norm_sample.append(0.5)
        X_norm.append(norm_sample)

    return X_norm, stats


def split_data(X: List, y: List, test_ratio: float = 0.2) -> Tuple:
    """Split data into train/test sets."""
    n = len(X)
    indices = list(range(n))
    random.shuffle(indices)

    split_idx = int(n * (1 - test_ratio))
    train_idx = indices[:split_idx]
    test_idx = indices[split_idx:]

    X_train = [X[i] for i in train_idx]
    y_train = [y[i] for i in train_idx]
    X_test = [X[i] for i in test_idx]
    y_test = [y[i] for i in test_idx]

    return X_train, X_test, y_train, y_test


def run_demo():
    """Run demo with synthetic breast cancer-like data."""
    print("Multilayer Perceptron Demo")
    print("=" * 50)
    print("\nGenerating synthetic dataset...")

    random.seed(42)

    # Generate synthetic data (similar to breast cancer dataset)
    n_samples = 500
    n_features = 10

    X = []
    y = []

    for _ in range(n_samples):
        # Class 0 (benign)
        if random.random() < 0.5:
            features = [random.gauss(3, 1) for _ in range(n_features)]
            y.append(0)
        # Class 1 (malignant)
        else:
            features = [random.gauss(6, 1.5) for _ in range(n_features)]
            y.append(1)
        X.append(features)

    print(f"Dataset: {n_samples} samples, {n_features} features")
    print(f"Class distribution: {sum(1 for yi in y if yi == 0)} benign, {sum(1 for yi in y if yi == 1)} malignant")

    # Normalize
    X, _ = normalize_features(X)

    # Split
    X_train, X_test, y_train, y_test = split_data(X, y, test_ratio=0.2)
    print(f"Train: {len(X_train)}, Test: {len(X_test)}")

    # Convert labels to one-hot
    y_train_oh = [[float(yi)] for yi in y_train]
    y_test_oh = [[float(yi)] for yi in y_test]

    # Create network
    print("\nCreating network: [10] -> [16] -> [8] -> [1]")
    mlp = MLP([n_features, 16, 8, 1], activations=['relu', 'relu', 'sigmoid'])

    # Train
    print("\nTraining...")
    mlp.train(X_train, y_train_oh, epochs=100, learning_rate=0.1, verbose=True)

    # Evaluate
    print("\nEvaluating on test set...")
    correct = 0
    tp, fp, tn, fn = 0, 0, 0, 0

    for i in range(len(X_test)):
        pred = mlp.predict_class(X_test[i])
        actual = y_test[i]

        if pred == actual:
            correct += 1

        if pred == 1 and actual == 1:
            tp += 1
        elif pred == 1 and actual == 0:
            fp += 1
        elif pred == 0 and actual == 0:
            tn += 1
        else:
            fn += 1

    accuracy = correct / len(X_test) * 100
    precision = tp / (tp + fp) if (tp + fp) > 0 else 0
    recall = tp / (tp + fn) if (tp + fn) > 0 else 0
    f1 = 2 * precision * recall / (precision + recall) if (precision + recall) > 0 else 0

    print(f"\nTest Results:")
    print(f"  Accuracy:  {accuracy:.2f}%")
    print(f"  Precision: {precision:.4f}")
    print(f"  Recall:    {recall:.4f}")
    print(f"  F1 Score:  {f1:.4f}")

    print("\nConfusion Matrix:")
    print(f"           Predicted")
    print(f"           0    1")
    print(f"Actual 0  {tn:3d}  {fp:3d}")
    print(f"       1  {fn:3d}  {tp:3d}")

    # Save model
    mlp.save('mlp_model.json')
    print("\nModel saved to mlp_model.json")


def main():
    """Main entry point."""
    if len(sys.argv) < 2:
        print("Multilayer Perceptron - Neural Network")
        print("\nUsage:")
        print("  python mlp.py demo              - Run demo")
        print("  python mlp.py train <data.csv>  - Train on dataset")
        print("  python mlp.py predict <data.csv> <model.json>")
        return

    cmd = sys.argv[1]

    if cmd == 'demo':
        run_demo()

    elif cmd == 'train':
        if len(sys.argv) < 3:
            print("Usage: python mlp.py train <data.csv> [model.json]")
            return

        print(f"Loading data from {sys.argv[2]}...")
        X, y = load_csv(sys.argv[2])
        print(f"Loaded {len(X)} samples with {len(X[0])} features")

        X, _ = normalize_features(X)
        X_train, X_test, y_train, y_test = split_data(X, y)

        y_train_oh = [[float(yi)] for yi in y_train]

        n_features = len(X[0])
        mlp = MLP([n_features, 32, 16, 1], activations=['relu', 'relu', 'sigmoid'])

        mlp.train(X_train, y_train_oh, epochs=100, learning_rate=0.1)

        # Test accuracy
        correct = sum(1 for i in range(len(X_test))
                     if mlp.predict_class(X_test[i]) == y_test[i])
        print(f"\nTest accuracy: {correct / len(X_test) * 100:.2f}%")

        model_file = sys.argv[3] if len(sys.argv) > 3 else 'mlp_model.json'
        mlp.save(model_file)
        print(f"Model saved to {model_file}")

    elif cmd == 'predict':
        if len(sys.argv) < 4:
            print("Usage: python mlp.py predict <data.csv> <model.json>")
            return

        print(f"Loading model from {sys.argv[3]}...")
        mlp = MLP([1, 1])  # Placeholder, will be overwritten
        mlp.load(sys.argv[3])

        print(f"Loading data from {sys.argv[2]}...")
        X, _ = load_csv(sys.argv[2])
        X, _ = normalize_features(X)

        print("\nPredictions:")
        for i, sample in enumerate(X[:10]):  # First 10
            pred = mlp.predict(sample)
            pred_class = 1 if pred[0] > 0.5 else 0
            print(f"  Sample {i}: {pred[0]:.4f} -> Class {pred_class}")

    else:
        print(f"Unknown command: {cmd}")


if __name__ == "__main__":
    main()
