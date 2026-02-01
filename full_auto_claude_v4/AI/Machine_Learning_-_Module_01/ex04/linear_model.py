"""
Exercise 04: Practicing Linear Regression

Evaluates a linear regression model on a small dataset about space pilots
and "blue pills" effect on driving performance.
"""
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import os
import sys

# Add parent directory to path to import MyLinearRegression
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'ex03'))
from my_linear_regression import MyLinearRegression as MyLR


def load_data(filepath):
    """Load the dataset from CSV file."""
    try:
        data = pd.read_csv(filepath)
        return data
    except Exception as e:
        print(f"Error loading data: {e}")
        return None


def plot_predictions(x, y, y_hat, save_path=None):
    """
    Plot the data with the hypothesis line.

    Args:
        x: Input features (blue pill quantity)
        y: Actual scores
        y_hat: Predicted scores
        save_path: Optional path to save the plot
    """
    plt.figure(figsize=(10, 6))

    # Plot actual data points
    plt.scatter(x, y, c='cyan', label=r'$S_{true}(pills)$', s=100, zorder=5)

    # Plot predictions
    plt.scatter(x, y_hat, c='lime', marker='s', label=r'$S_{predict}(pills)$', s=60, zorder=4)

    # Plot prediction line
    sorted_indices = np.argsort(x.flatten())
    x_sorted = x[sorted_indices]
    y_hat_sorted = y_hat[sorted_indices]
    plt.plot(x_sorted, y_hat_sorted, 'g--', alpha=0.7, linewidth=2)

    plt.xlabel('Quantity of blue pill (in micrograms)')
    plt.ylabel('Space driving score')
    plt.title('Space Driving Score vs Blue Pill Quantity')
    plt.legend()
    plt.grid(True, alpha=0.3)

    if save_path:
        plt.savefig(save_path, dpi=150, bbox_inches='tight')
        print(f"Plot saved to {save_path}")
    plt.show()


def plot_loss_function(x, y, theta_optimal, save_path=None):
    """
    Plot the loss function J(theta) as a function of theta_1 for different theta_0 values.

    Args:
        x: Input features
        y: Actual scores
        theta_optimal: Optimal theta values from training
        save_path: Optional path to save the plot
    """
    plt.figure(figsize=(10, 6))

    # Define range for theta_1
    theta1_range = np.linspace(-14, -4, 100)

    # Define different theta_0 values around the optimal
    theta0_base = theta_optimal[0, 0]
    theta0_values = [theta0_base - 10, theta0_base - 5, theta0_base,
                     theta0_base + 5, theta0_base + 10, theta0_base + 15]

    colors = ['blue', 'orange', 'green', 'red', 'purple', 'brown']

    for i, theta0 in enumerate(theta0_values):
        losses = []
        for theta1 in theta1_range:
            theta = np.array([[theta0], [theta1]])
            lr_temp = MyLR(theta)
            y_hat = lr_temp.predict_(x)
            loss = lr_temp.loss_(y, y_hat)
            losses.append(loss)

        label = rf'$J(\theta_0=c_{i},\theta_1)$'
        plt.plot(theta1_range, losses, color=colors[i % len(colors)], label=label, linewidth=2)

    plt.xlabel(r'$\theta_1$')
    plt.ylabel(r'cost function $J(\theta_0, \theta_1)$')
    plt.title(r'Evolution of the loss function $J$ as a function of $\theta_1$ for different values of $\theta_0$')
    plt.legend()
    plt.grid(True, alpha=0.3)
    plt.xlim(-14, -4)
    plt.ylim(0, 150)

    if save_path:
        plt.savefig(save_path, dpi=150, bbox_inches='tight')
        print(f"Plot saved to {save_path}")
    plt.show()


def main():
    """Main function to run linear regression on the blue pills dataset."""
    # Get the directory of this script
    script_dir = os.path.dirname(os.path.abspath(__file__))
    csv_path = os.path.join(script_dir, "are_blue_pills_magics.csv")

    # Load data
    print("Loading data...")
    data = load_data(csv_path)
    if data is None:
        return

    print(f"Dataset shape: {data.shape}")
    print(f"Columns: {data.columns.tolist()}")
    print("\nData preview:")
    print(data.head())

    # Prepare data
    Xpill = np.array(data['Micrograms']).reshape(-1, 1)
    Yscore = np.array(data['Score']).reshape(-1, 1)

    print(f"\nX (Micrograms) shape: {Xpill.shape}")
    print(f"Y (Score) shape: {Yscore.shape}")

    # Test with given thetas
    print("\n" + "="*60)
    print("Testing with pre-defined theta values:")
    print("="*60)

    linear_model1 = MyLR(np.array([[89.0], [-8]]))
    linear_model2 = MyLR(np.array([[89.0], [-6]]))

    Y_model1 = linear_model1.predict_(Xpill)
    Y_model2 = linear_model2.predict_(Xpill)

    mse1 = MyLR.mse_(Yscore, Y_model1)
    mse2 = MyLR.mse_(Yscore, Y_model2)

    print(f"\nModel 1 (theta=[89, -8]):")
    print(f"  MSE: {mse1}")
    # Expected: 57.60304285714282

    print(f"\nModel 2 (theta=[89, -6]):")
    print(f"  MSE: {mse2}")
    # Expected: 232.16344285714285

    # Train a model with gradient descent
    print("\n" + "="*60)
    print("Training model with gradient descent:")
    print("="*60)

    # Initialize with reasonable starting values
    linear_model_trained = MyLR(np.array([[89.0], [-8]]), alpha=1e-2, max_iter=10000)
    linear_model_trained.fit_(Xpill, Yscore)

    print(f"\nTrained theta values:")
    print(f"  theta_0: {linear_model_trained.thetas[0, 0]:.6f}")
    print(f"  theta_1: {linear_model_trained.thetas[1, 0]:.6f}")

    Y_trained = linear_model_trained.predict_(Xpill)
    mse_trained = MyLR.mse_(Yscore, Y_trained)
    print(f"  MSE: {mse_trained:.6f}")

    # Create plots
    print("\n" + "="*60)
    print("Creating plots...")
    print("="*60)

    # Plot 1: Predictions vs actual data
    plot_predictions(Xpill, Yscore, Y_trained,
                     save_path=os.path.join(script_dir, "plot_predictions.png"))

    # Plot 2: Loss function
    plot_loss_function(Xpill, Yscore, linear_model_trained.thetas,
                       save_path=os.path.join(script_dir, "plot_loss_function.png"))

    print("\n" + "="*60)
    print("Summary:")
    print("="*60)
    print(f"Final model: y = {linear_model_trained.thetas[0, 0]:.4f} + {linear_model_trained.thetas[1, 0]:.4f} * x")
    print(f"Final MSE: {mse_trained:.6f}")
    print("\nDone!")


if __name__ == "__main__":
    main()
