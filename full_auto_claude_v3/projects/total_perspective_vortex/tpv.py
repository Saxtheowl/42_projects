#!/usr/bin/env python3
"""
Total Perspective Vortex - Dimensionality Reduction
PCA (Principal Component Analysis) implementation from scratch
"""

import sys
import math
import csv
from typing import List, Tuple, Optional


def mean(values: List[float]) -> float:
    """Calculate mean."""
    return sum(values) / len(values) if values else 0


def std(values: List[float]) -> float:
    """Calculate standard deviation."""
    if len(values) < 2:
        return 0
    m = mean(values)
    variance = sum((v - m) ** 2 for v in values) / len(values)
    return math.sqrt(variance)


def normalize_data(X: List[List[float]]) -> Tuple[List[List[float]], List[float], List[float]]:
    """Normalize data to zero mean and unit variance."""
    if not X:
        return X, [], []

    n_samples = len(X)
    n_features = len(X[0])

    means = []
    stds = []

    for j in range(n_features):
        col = [X[i][j] for i in range(n_samples)]
        m = mean(col)
        s = std(col)
        means.append(m)
        stds.append(s if s > 0 else 1)

    X_norm = []
    for i in range(n_samples):
        row = [(X[i][j] - means[j]) / stds[j] for j in range(n_features)]
        X_norm.append(row)

    return X_norm, means, stds


def matrix_multiply(A: List[List[float]], B: List[List[float]]) -> List[List[float]]:
    """Matrix multiplication."""
    m = len(A)
    n = len(B[0])
    p = len(B)

    C = [[0.0] * n for _ in range(m)]
    for i in range(m):
        for j in range(n):
            for k in range(p):
                C[i][j] += A[i][k] * B[k][j]
    return C


def transpose(A: List[List[float]]) -> List[List[float]]:
    """Matrix transpose."""
    m = len(A)
    n = len(A[0]) if A else 0
    return [[A[i][j] for i in range(m)] for j in range(n)]


def covariance_matrix(X: List[List[float]]) -> List[List[float]]:
    """Compute covariance matrix."""
    X_t = transpose(X)
    n = len(X)
    cov = matrix_multiply(X_t, X)
    return [[cov[i][j] / (n - 1) for j in range(len(cov[0]))] for i in range(len(cov))]


def vector_norm(v: List[float]) -> float:
    """Vector norm."""
    return math.sqrt(sum(x * x for x in v))


def normalize_vector(v: List[float]) -> List[float]:
    """Normalize vector."""
    norm = vector_norm(v)
    return [x / norm for x in v] if norm > 0 else v


def matrix_vector_multiply(A: List[List[float]], v: List[float]) -> List[float]:
    """Multiply matrix by vector."""
    return [sum(A[i][j] * v[j] for j in range(len(v))) for i in range(len(A))]


def power_iteration(A: List[List[float]], num_iterations: int = 100) -> Tuple[float, List[float]]:
    """Power iteration to find dominant eigenvalue and eigenvector."""
    n = len(A)
    v = [1.0 / math.sqrt(n)] * n  # Initial guess

    for _ in range(num_iterations):
        Av = matrix_vector_multiply(A, v)
        v_new = normalize_vector(Av)

        # Check convergence
        diff = sum((a - b) ** 2 for a, b in zip(v, v_new))
        v = v_new
        if diff < 1e-10:
            break

    # Compute eigenvalue
    Av = matrix_vector_multiply(A, v)
    eigenvalue = sum(Av[i] * v[i] for i in range(n))

    return eigenvalue, v


def deflate_matrix(A: List[List[float]], eigenvalue: float, eigenvector: List[float]) -> List[List[float]]:
    """Deflate matrix by removing the contribution of an eigenvalue/eigenvector pair."""
    n = len(A)
    A_new = [[A[i][j] for j in range(n)] for i in range(n)]

    for i in range(n):
        for j in range(n):
            A_new[i][j] -= eigenvalue * eigenvector[i] * eigenvector[j]

    return A_new


def compute_pca(X: List[List[float]], n_components: int) -> Tuple[List[List[float]], List[float], List[List[float]]]:
    """
    Compute PCA.
    Returns: (transformed_data, eigenvalues, eigenvectors)
    """
    # Normalize data
    X_norm, _, _ = normalize_data(X)

    # Compute covariance matrix
    cov = covariance_matrix(X_norm)

    # Find eigenvalues and eigenvectors using power iteration
    eigenvalues = []
    eigenvectors = []

    A = cov
    for _ in range(n_components):
        eigenvalue, eigenvector = power_iteration(A)
        eigenvalues.append(eigenvalue)
        eigenvectors.append(eigenvector)
        A = deflate_matrix(A, eigenvalue, eigenvector)

    # Transform data
    # X_transformed = X_norm @ eigenvectors.T
    eigenvectors_t = transpose(eigenvectors)
    X_transformed = matrix_multiply(X_norm, eigenvectors_t)

    return X_transformed, eigenvalues, eigenvectors


def explained_variance_ratio(eigenvalues: List[float]) -> List[float]:
    """Calculate explained variance ratio."""
    total = sum(eigenvalues)
    return [ev / total for ev in eigenvalues] if total > 0 else eigenvalues


def load_csv(filename: str) -> Tuple[List[List[float]], List[str], Optional[List[str]]]:
    """Load dataset from CSV."""
    X = []
    headers = []
    labels = []

    with open(filename, 'r') as f:
        reader = csv.reader(f)
        headers = next(reader, [])

        for row in reader:
            features = []
            for val in row[:-1]:
                try:
                    features.append(float(val))
                except ValueError:
                    features.append(0.0)
            X.append(features)
            labels.append(row[-1] if row else '')

    return X, headers[:-1], labels


def run_demo():
    """Run PCA demo."""
    print("Total Perspective Vortex - PCA Demo")
    print("=" * 50)

    # Generate synthetic data
    import random
    random.seed(42)

    print("\nGenerating synthetic 4D dataset...")
    n_samples = 200
    n_features = 4

    X = []
    labels = []

    for i in range(n_samples):
        # Create correlated features
        base = random.gauss(0, 1)
        x1 = base + random.gauss(0, 0.5)
        x2 = base * 0.8 + random.gauss(0, 0.5)
        x3 = random.gauss(0, 1)  # Independent
        x4 = x1 * 0.5 + x3 * 0.5 + random.gauss(0, 0.3)

        X.append([x1, x2, x3, x4])
        labels.append('A' if base > 0 else 'B')

    print(f"Dataset: {n_samples} samples, {n_features} features")

    # Run PCA
    print("\nRunning PCA...")
    n_components = 2
    X_pca, eigenvalues, eigenvectors = compute_pca(X, n_components)

    print(f"\nEigenvalues: {[f'{ev:.4f}' for ev in eigenvalues]}")

    variance_ratio = explained_variance_ratio(eigenvalues)
    print(f"Explained variance ratio: {[f'{v:.2%}' for v in variance_ratio]}")
    print(f"Cumulative explained variance: {sum(variance_ratio):.2%}")

    print("\nPrincipal components (eigenvectors):")
    for i, ev in enumerate(eigenvectors):
        print(f"  PC{i+1}: [{', '.join(f'{v:.4f}' for v in ev)}]")

    # Show some transformed samples
    print(f"\nTransformed data (first 5 samples):")
    print(f"{'Original (4D)':<40} -> {'Reduced (2D)':<20}")
    for i in range(5):
        orig = ', '.join(f'{x:.2f}' for x in X[i])
        trans = ', '.join(f'{x:.2f}' for x in X_pca[i])
        print(f"  [{orig}] -> [{trans}]")

    # Save results
    with open('pca_results.csv', 'w') as f:
        f.write('PC1,PC2,Label\n')
        for i in range(len(X_pca)):
            f.write(f'{X_pca[i][0]:.6f},{X_pca[i][1]:.6f},{labels[i]}\n')
    print("\nResults saved to pca_results.csv")

    # Generate ASCII scatter plot
    print("\nPCA Scatter Plot (ASCII):")
    print("-" * 50)

    # Find bounds
    min_x = min(row[0] for row in X_pca)
    max_x = max(row[0] for row in X_pca)
    min_y = min(row[1] for row in X_pca)
    max_y = max(row[1] for row in X_pca)

    width, height = 50, 20
    plot = [[' ' for _ in range(width)] for _ in range(height)]

    for i, (pc1, pc2) in enumerate([row[:2] for row in X_pca]):
        x = int((pc1 - min_x) / (max_x - min_x + 0.001) * (width - 1))
        y = int((pc2 - min_y) / (max_y - min_y + 0.001) * (height - 1))
        y = height - 1 - y  # Flip y
        plot[y][x] = 'A' if labels[i] == 'A' else 'B'

    for row in plot:
        print('|' + ''.join(row) + '|')
    print('+' + '-' * width + '+')
    print('  ' + 'PC1 →')


def main():
    """Main entry point."""
    if len(sys.argv) < 2:
        print("Total Perspective Vortex - PCA")
        print("\nUsage:")
        print("  python tpv.py demo                        - Run demo")
        print("  python tpv.py <data.csv> [n_components]   - Run PCA on data")
        return

    if sys.argv[1] == 'demo':
        run_demo()
        return

    # Load data
    filename = sys.argv[1]
    n_components = int(sys.argv[2]) if len(sys.argv) > 2 else 2

    print(f"Loading data from {filename}...")
    X, headers, labels = load_csv(filename)
    print(f"Loaded {len(X)} samples with {len(X[0])} features")

    # Run PCA
    print(f"\nRunning PCA with {n_components} components...")
    X_pca, eigenvalues, eigenvectors = compute_pca(X, n_components)

    print(f"\nEigenvalues: {eigenvalues}")
    print(f"Explained variance: {explained_variance_ratio(eigenvalues)}")

    # Save
    output = 'pca_output.csv'
    with open(output, 'w') as f:
        f.write(','.join(f'PC{i+1}' for i in range(n_components)) + ',Label\n')
        for i in range(len(X_pca)):
            f.write(','.join(f'{X_pca[i][j]:.6f}' for j in range(n_components)))
            f.write(f',{labels[i] if i < len(labels) else ""}\n')
    print(f"Output saved to {output}")


if __name__ == "__main__":
    main()
