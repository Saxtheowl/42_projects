"""
Exercise 01 - TinyStatistician
Statistical methods: mean, median, quartile, percentile, variance, standard deviation
Forbidden: Any functions which calculate mean, median, quartiles, percentiles, variance or standard deviation
"""


class TinyStatistician:
    """
    A class that provides basic statistical methods.
    All methods take a list or numpy array as input.
    """

    @staticmethod
    def _validate_input(x):
        """
        Validate input and convert to list of floats.
        Returns None if invalid.
        """
        if x is None:
            return None

        # Try to convert to list
        try:
            if hasattr(x, 'tolist'):
                # numpy array
                data = x.tolist()
            elif isinstance(x, list):
                data = list(x)
            else:
                return None

            # Check if empty
            if len(data) == 0:
                return None

            # Flatten if needed and convert to float
            flat = []
            for item in data:
                if isinstance(item, (list, tuple)):
                    for val in item:
                        flat.append(float(val))
                else:
                    flat.append(float(item))

            if len(flat) == 0:
                return None

            return flat

        except (TypeError, ValueError):
            return None

    def mean(self, x):
        """
        Computes the mean of a given non-empty list or array x.
        Returns the mean as a float, otherwise None.
        """
        data = self._validate_input(x)
        if data is None:
            return None

        total = 0.0
        for val in data:
            total += val
        return total / len(data)

    def median(self, x):
        """
        Computes the median (50th percentile) of a given non-empty list or array x.
        Returns the median as a float, otherwise None.
        """
        data = self._validate_input(x)
        if data is None:
            return None

        sorted_data = sorted(data)
        n = len(sorted_data)

        if n % 2 == 1:
            return float(sorted_data[n // 2])
        else:
            mid1 = sorted_data[n // 2 - 1]
            mid2 = sorted_data[n // 2]
            return (mid1 + mid2) / 2.0

    def quartile(self, x):
        """
        Computes the 1st and 3rd quartiles (25th and 75th percentiles).
        Returns a list of 2 floats [Q1, Q3], otherwise None.
        """
        data = self._validate_input(x)
        if data is None:
            return None

        q1 = self.percentile(data, 25)
        q3 = self.percentile(data, 75)

        if q1 is None or q3 is None:
            return None

        return [q1, q3]

    def percentile(self, x, p):
        """
        Computes the expected percentile of a given non-empty list or array x.
        Uses linear interpolation between closest ranks.
        Returns the percentile as a float, otherwise None.
        """
        data = self._validate_input(x)
        if data is None:
            return None

        if not isinstance(p, (int, float)) or p < 0 or p > 100:
            return None

        sorted_data = sorted(data)
        n = len(sorted_data)

        if n == 1:
            return float(sorted_data[0])

        # Calculate the rank (0-indexed position)
        # Using linear interpolation method
        rank = (p / 100) * (n - 1)
        lower_idx = int(rank)
        upper_idx = lower_idx + 1

        if upper_idx >= n:
            return float(sorted_data[-1])

        # Linear interpolation
        fraction = rank - lower_idx
        lower_val = sorted_data[lower_idx]
        upper_val = sorted_data[upper_idx]

        return lower_val + fraction * (upper_val - lower_val)

    def var(self, x):
        """
        Computes the sample variance of a given non-empty list or array x.
        Uses (n-1) denominator (Bessel's correction).
        Returns the variance as a float, otherwise None.
        """
        data = self._validate_input(x)
        if data is None:
            return None

        n = len(data)
        if n < 2:
            return None

        mean_val = self.mean(data)
        if mean_val is None:
            return None

        sum_sq_diff = 0.0
        for val in data:
            sum_sq_diff += (val - mean_val) ** 2

        return sum_sq_diff / (n - 1)

    def std(self, x):
        """
        Computes the sample standard deviation of a given non-empty list or array x.
        Returns the standard deviation as a float, otherwise None.
        """
        variance = self.var(x)
        if variance is None:
            return None

        # Manual square root using Newton's method
        return self._sqrt(variance)

    @staticmethod
    def _sqrt(x):
        """Compute square root using Newton's method."""
        if x < 0:
            return None
        if x == 0:
            return 0.0

        guess = x / 2.0
        for _ in range(100):  # Max iterations
            new_guess = (guess + x / guess) / 2.0
            if abs(new_guess - guess) < 1e-15:
                break
            guess = new_guess

        return guess
