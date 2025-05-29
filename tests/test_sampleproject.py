import random
from argparse import Namespace

import pytest

import sampleproject.main


@pytest.fixture
def args_ns_ref():
    args_ns = Namespace()
    args_ns.summand1 = 2
    args_ns.summand2 = 2
    return args_ns


def test_parseargs(args_ns_ref):
    arg_list = ["2", "2"]
    args_ns = sampleproject.main.parse_args(arg_list)
    # Define reference/expected result
    args_ns_ref.verbose = False
    args_ns_ref.quiet = False
    assert args_ns == args_ns_ref


def test_parseargs_verbose(args_ns_ref):
    arg_list = ["--verbose", "2", "2"]
    args_ns = sampleproject.main.parse_args(arg_list)
    args_ns_ref.verbose = True
    args_ns_ref.quiet = False
    assert args_ns == args_ns_ref


def test_parseargs_quiet(args_ns_ref):
    arg_list = ["--quiet", "2", "2"]
    args_ns = sampleproject.main.parse_args(arg_list)
    args_ns_ref.verbose = False
    args_ns_ref.quiet = True
    assert args_ns == args_ns_ref


def test_add():
    a = random.randint(0, 100)
    b = random.randint(0, 100)
    assert a + b == sampleproject.main.Calc.add(a, b)


if __name__ == "__main__":
    pytest.main()
