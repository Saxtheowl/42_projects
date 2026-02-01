# Multilayer Perceptron - Neural Network

Binary classification neural network implemented from scratch.

## Features

- Configurable layer architecture
- Activation functions: Sigmoid, ReLU, Softmax
- Backpropagation with gradient descent
- Xavier weight initialization
- Binary cross-entropy loss
- Model persistence (JSON)

## Usage

```bash
# Run demo with synthetic data
python mlp.py demo

# Train on custom dataset
python mlp.py train data.csv model.json

# Make predictions
python mlp.py predict data.csv model.json
```

## Network Architecture

Default architecture for demo:
- Input: 10 features
- Hidden 1: 16 neurons (ReLU)
- Hidden 2: 8 neurons (ReLU)
- Output: 1 neuron (Sigmoid)

## Algorithm

1. **Forward Pass**: Compute activations through layers
2. **Loss Calculation**: Binary cross-entropy
3. **Backward Pass**: Compute gradients via chain rule
4. **Weight Update**: Gradient descent

## Data Format

CSV with features in all columns except last (label):
```
feature1,feature2,...,label
1.2,3.4,...,0
5.6,7.8,...,1
```

## Metrics

- Accuracy
- Precision
- Recall
- F1 Score
- Confusion Matrix

## Author

Implementation for 42 curriculum.
