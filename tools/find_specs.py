#! /usr/bin/python3

import sys
from argparse import ArgumentParser
from spack.environment import find_environment


def get_parser():
    parser = ArgumentParser()
    parser.add_argument("packagename")
    return parser


def main():
    parser = get_parser()
    args = parser.parse_args()

    env = find_environment(args)
    if env is None:
        sys.stderr.write("No environment\n")
        sys.exit(1)

    reslist = []

    for spec in env.user_specs:
        s = str(spec)
        if s.startswith(args.packagename + '@'):
#            reslist.insert(0, s)
            pass
        else:
            reslist.append("^" + s)

    print(" ".join(reslist))


if __name__ == '__main__':
    main()
    
