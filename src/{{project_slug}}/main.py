"""Demonstrates CLI definition and parsing and provides an entry-point for the
application.
"""

import argparse
import logging
import platform
import sys

import {{project_slug}}


def parse_args(args_list: list[str]) -> argparse.Namespace:
    """Parse command-line arguments

    Params:
        args_list: list of strings with command-line flags (sys.argv[1:])
    """
    logger = logging.getLogger(f"{__name__}:parse_args")
    description = "{{project_description}}"
    parser = argparse.ArgumentParser(description=description)
    parser.add_argument(
        "--quiet", action="store_true", help="Only print warning/error messages"
    )
    parser.add_argument("--verbose", action="store_true", help="Print debug messages")
    #
    # Add more command-line arguments and/or sub-commands
    #

    # Parse arguments in order to obtain results in argparse.Namespace object
    args_ns = parser.parse_args(args_list)

    # Set log level according to command-line flags
    if args_ns.verbose:
        {{project_slug}}.LOGCONFIG.debug()
        logger.debug("%s:: %s\n", platform.node(), " ".join(sys.argv))
    elif args_ns.quiet:
        {{project_slug}}.LOGCONFIG.warning()

    return args_ns


def main() -> None:
    """Entry point for the command-line interface"""
    logger = logging.getLogger(f"{__name__}:main")
    args_ns = parse_args(sys.argv[1:])
    logger.info(args_ns)
    # Start application according to parsing result in args_ns


if __name__ == "__main__":
    main()
