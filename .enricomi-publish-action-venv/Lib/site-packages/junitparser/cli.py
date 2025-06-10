from argparse import ArgumentParser
from glob import iglob
from itertools import chain

from . import JUnitXml, version


def merge(paths, output, suite_name):
    """Merge XML report."""
    result = JUnitXml()
    for path in paths:
        result += JUnitXml.fromfile(path)

    result.update_statistics()
    if suite_name:
        result.name = suite_name
    result.write(output, to_console=output == "-")
    return 0


def verify(paths):
    """Verify if none of the testcases failed or errored."""
    # We could grab the number of failures and errors from the statistics of the root element
    # or from the test suites elements, but those attributes are not guaranteed to be present
    # or correct. So we'll just loop over all the testcases.
    for path in paths:
        xml = JUnitXml.fromfile(path)
        for suite in xml:
            for case in suite:
                if not case.is_passed and not case.is_skipped:
                    return 1
    return 0


def _parser(prog_name=None):  # pragma: no cover
    """Create the CLI arg parser."""
    parser = ArgumentParser(description="Junitparser CLI helper.", prog=prog_name)

    parser.add_argument(
        "-v", "--version", action="version", version="%(prog)s " + version
    )

    command_parser = parser.add_subparsers(dest="command", help="command")
    command_parser.required = True

    # command: merge
    merge_parser = command_parser.add_parser(
        "merge", help="Merge JUnit XML format reports with junitparser."
    )
    merge_parser.add_argument(
        "--glob",
        help="Treat original XML path(s) as glob(s).",
        dest="paths_are_globs",
        action="store_true",
        default=False,
    )
    merge_parser.add_argument("paths", nargs="+", help="Original XML path(s).")
    merge_parser.add_argument(
        "output", help='Merged XML Path, setting to "-" will output to the console'
    )
    merge_parser.add_argument(
        "--suite-name",
        help="Name added to <testsuites>.",
    )

    # command: verify
    merge_parser = command_parser.add_parser(
        "verify",
        help="Return a non-zero exit code if one of the testcases failed or errored.",
    )
    merge_parser.add_argument(
        "--glob",
        help="Treat original XML path(s) as glob(s).",
        dest="paths_are_globs",
        action="store_true",
        default=False,
    )
    merge_parser.add_argument(
        "paths", nargs="+", help="XML path(s) of reports to verify."
    )

    return parser


def main(args=None, prog_name=None):
    """CLI's main runner."""
    args = args or _parser(prog_name=prog_name).parse_args()
    if args.command == "merge":
        return merge(
            chain.from_iterable(iglob(path) for path in args.paths)
            if args.paths_are_globs
            else args.paths,
            args.output,
            args.suite_name,
        )
    if args.command == "verify":
        return verify(
            chain.from_iterable(iglob(path) for path in args.paths)
            if args.paths_are_globs
            else args.paths
        )
    return 255
