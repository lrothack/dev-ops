"""Implements the package."""

import numpy as np


class Calc:

    @staticmethod
    def add(a: int, b: int) -> int:
        print(a, b)
        return int(np.sum([a, b]))
