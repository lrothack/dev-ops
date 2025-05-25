"""Implements the package.
"""

import numpy as np


class Calc:

    @staticmethod
    def add(a: int, b: int) -> int:
        print(a, b)
        return np.sum([a, b])
