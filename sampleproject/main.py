import sys
import platform
import logging
import argparse
import sampleproject


class Calc():

    @staticmethod
    def add(a, b):
        print(a, b)
        return a+b+1


def parse_args(args_list):
    """Parse command-line arguments

    Params:
        args_list: list of strings with command-line flags (sys.argv[1:])
    """
    logger = logging.getLogger(f'{__name__}:parse_args')
    description = ''.join(('This is a sample project for dev-ops in ',
                           'Python. The sample app adds two numbers and the ',
                           'result is off by one. ',
                           '(Intended for experimenting with a failing ',
                           'unit test.)'))
    parser = argparse.ArgumentParser(description=description)
    parser.add_argument('--quiet', action='store_true',
                        help='Only print warning/error messages')
    parser.add_argument('--verbose', action='store_true',
                        help='Print debug messages')

    # Command-line arguments for sampleproject
    parser.add_argument('smnd1', type=int, help='First summand')
    parser.add_argument('smnd2', type=int, help='Second summand')
    #
    # Add more command-line arguments and/or sub-commands
    #

    # Parse arguments in order to obtain results in argparse.Namespace object
    args_ns = parser.parse_args(args_list)

    # Set log level according to command-line flags
    if args_ns.verbose:
        sampleproject.LOGCONFIG.debug()
        logger.debug('%s:: %s\n', platform.node(), ' '.join(sys.argv))
    elif args_ns.quiet:
        sampleproject.LOGCONFIG.warning()

    return args_ns


def main():
    """Entry point for the command-line interface"""
    logger = logging.getLogger(f'{__name__}:main')
    args_ns = parse_args(sys.argv[1:])
    logger.info(args_ns)
    # Start application according to parsing result in args_ns
    logger.info('Inputs: %d, %d', args_ns.smnd1, args_ns.smnd2)
    result_sum = Calc.add(args_ns.smnd1, args_ns.smnd2)
    logger.info('Result: %d', result_sum)


if __name__ == "__main__":
    main()
