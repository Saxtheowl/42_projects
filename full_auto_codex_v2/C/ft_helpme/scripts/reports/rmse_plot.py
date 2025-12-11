#!/usr/bin/env python3
"""Utility to summarize RMSE logs and optionally save a simple plot."""

import argparse
import json
import math
import os
import sys


def load_history(path):
    if not os.path.isfile(path):
        raise FileNotFoundError(path)
    with open(path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    if not isinstance(data, list):
        raise ValueError('history JSON must be a list of {{"epoch":n, "rmse":v}}')
    return data


def summarize(history):
    rmses = [entry.get('rmse') for entry in history if entry.get('rmse') is not None]
    if not rmses:
        return 'No RMSE values found'
    avg = sum(rmses) / len(rmses)
    best = min(rmses)
    worst = max(rmses)
    return f'RMSE samples={len(rmses)} avg={avg:.4f} best={best:.4f} worst={worst:.4f}'


def ascii_plot(history):
    vals = [entry.get('rmse', 0.0) for entry in history]
    if not vals:
        return 'no data'
    minval = min(vals)
    maxval = max(vals)
    span = maxval - minval if maxval > minval else 1.0
    width = min(60, max(10, len(vals)))
    step = max(1, len(vals) // width)
    lines = []
    for i in range(0, len(vals), step):
        chunk = vals[i:i+step]
        avg = sum(chunk) / len(chunk)
        level = int((avg - minval) / span * 10)
        lines.append(f"{i:04d}: " + ('#' * (level + 1)))
    return '\n'.join(lines)


def try_plot(history, png_path):
    try:
        import matplotlib.pyplot as plt
    except ImportError:
        return False, 'matplotlib unavailable'
    epochs = [entry.get('epoch', idx) for idx, entry in enumerate(history)]
    rmses = [entry.get('rmse', 0.0) for entry in history]
    plt.figure()
    plt.plot(epochs, rmses, marker='o')
    plt.xlabel('epoch')
    plt.ylabel('RMSE')
    plt.title('RMSE history')
    plt.grid(True)
    plt.tight_layout()
    plt.savefig(png_path)
    return True, f'saved {png_path}'


def main():
    parser = argparse.ArgumentParser(description='Summarize RMSE logs and optionally save a plot.')
    parser.add_argument('history', help='JSON file exported by ft_linear_regression training (list of {"epoch":n, "rmse":v}).')
    parser.add_argument('--png', help='Optional PNG path (requires matplotlib).')
    args = parser.parse_args()

    try:
        history = load_history(args.history)
    except Exception as exc:
        print('FAILED', exc, file=sys.stderr)
        sys.exit(1)

    print(summarize(history))
    print('ASCII sparkline:')
    print(ascii_plot(history))
    if args.png:
        ok, msg = try_plot(history, args.png)
        print('plot:', msg)
    else:
        print('plot: skipped (no --png)')


if __name__ == '__main__':
    main()
