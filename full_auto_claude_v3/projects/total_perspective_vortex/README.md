# Total Perspective Vortex - PCA

Principal Component Analysis implementation from scratch.

## Features

- Data normalization (zero mean, unit variance)
- Covariance matrix computation
- Eigenvalue decomposition (power iteration)
- Dimensionality reduction
- Explained variance calculation
- ASCII visualization

## Usage

```bash
# Run demo with synthetic data
python tpv.py demo

# Apply PCA to dataset
python tpv.py data.csv [n_components]
```

## Algorithm

1. **Normalize**: Center data and scale to unit variance
2. **Covariance**: Compute feature covariance matrix
3. **Eigen decomposition**: Find principal components using power iteration
4. **Transform**: Project data onto principal components

## Output

- `pca_results.csv` - Transformed data with reduced dimensions
- Console output showing:
  - Eigenvalues
  - Explained variance ratios
  - Principal component vectors
  - ASCII scatter plot

## Data Format

CSV with features in columns (last column = label):
```
feature1,feature2,...,label
1.2,3.4,...,A
5.6,7.8,...,B
```

## Author

Implementation for 42 curriculum.
