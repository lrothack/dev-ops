import pytest
import random
from argparse import Namespace
import sampleproject.main


@pytest.fixture
def args_ns_ref():
    return Namespace()


def test_parseargs(args_ns_ref):
    arg_list = []
    args_ns = sampleproject.main.parse_args(arg_list)
    # Define reference/expected result
    args_ns_ref.verbose = False
    args_ns_ref.quiet = False
    assert args_ns == args_ns_ref


def test_parseargs_verbose(args_ns_ref):
    arg_list = ['--verbose']
    args_ns = sampleproject.main.parse_args(arg_list)
    args_ns_ref.verbose = True
    args_ns_ref.quiet = False
    assert args_ns == args_ns_ref


def test_parseargs_quiet(args_ns_ref):
    arg_list = ['--quiet']
    args_ns = sampleproject.main.parse_args(arg_list)
    args_ns_ref.verbose = False
    args_ns_ref.quiet = True
    assert args_ns == args_ns_ref


def test_add(self):
    a = random.randint(0, 100)
    b = random.randint(0, 100)
    assert a+b == sampleproject.main.Calc.add(a, b)


if __name__ == "__main__":
    pytest.main()
