# Copyright 2020 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
# Copyright 2020 GSI Helmholtz Centre for Heavy Ion Research GmbH, Darmstadt
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

import argparse
import sys

import llnl.util.tty as tty
import llnl.util.tty.color as color
from llnl.util.tty.colify import colify
from spack.cmd.clean import clean
from spack.cmd.compiler import compiler_find
from spack.cmd.repo import repo_list
import spack.extensions.fairsoft as ext
from spack.spec import version_color
from spack.util.executable import which
from textwrap import wrap

description = 'manage FairSoft distros'
section = 'FairSoft distro'
level = 'short'


def _spack_clean_ms():
    """Call `spack clean -ms`"""
    args = argparse.Namespace()
    args.specs = False
    args.stage = True
    args.downloads = False
    args.failures = False
    args.misc_cache = True
    args.python_cache = False
    args.all = False
    clean(None, args)


def _spack_compiler_find_scope_site():
    """Call `spack compiler find --scope site`"""
    args = argparse.Namespace()
    args.add_paths = None
    args.scope = 'site'
    compiler_find(args)


def _spack_repo_list():
    """Call `spack repo list`"""
    args = argparse.Namespace()
    args.scope = None
    repo_list(args)


def avail(_args):
    """show available FairSoft distros"""
    distros = sorted(ext.get_distros())

    if sys.stdout.isatty():
        if not distros:
            tty.msg('No distros')
        else:
            tty.msg('{} distros'.format(len(distros)))

    colify(distros, indent=4, cols=1)


def info(args):
    """show info on a FairSoft distro"""
    cl_header = '@*b'
    cl_plain = '@.'
    cl_version = version_color
    info = ext.get_distro_info(args.distro)

    color.cprint('{}Distro:{}   {}'.format(cl_header, cl_plain, info['name']))
    color.cprint('')
    color.cprint('{}Description:{}'.format(cl_header, cl_plain))
    colify(wrap(info['description'], width=70), indent=4, cols=1)
    color.cprint('')
    color.cprint('{}Release:{} {}{}{}'.format(cl_header, cl_plain, cl_version,
                                              info['release'], cl_plain))
    color.cprint('')
    color.cprint('{}Variant:{} {}'.format(cl_header, cl_plain,
                                          info['variant']))
    color.cprint('')
    color.cprint('{}Packages:{} {}'.format(cl_header, cl_plain, 'TODO'))
    color.cprint('')
    color.cprint('{}Prerequisites installed:{} {}'.format(
        cl_header, cl_plain, 'TODO'))
    color.cprint('')
    color.cprint('{}Installed:{} {}'.format(cl_header, cl_plain, 'TODO'))
    color.cprint('')


def install(_args):
    """install a FairSoft distro"""
    raise NotImplementedError('NOT YET IMPLEMENTED')


def list(_args):
    """list installed FairSoft distros"""
    raise NotImplementedError('NOT YET IMPLEMENTED')


def setup(args):
    """setup spack for FairSoft

    Tasks performed:
    1. `git submodule update --init`
    2. `spack compiler find --scope site`
    3. Manage fairsoft site config dir
    4. Check/Update repo config
    5. `spack clean -ms`

    Do not run in parallel to another running spack command!
    """
    if not args.skip_git:
        git = which('git', required=True)
        git('-C', ext.root_dir, 'submodule', 'update', '--init')
    if not args.skip_compiler:
        _spack_compiler_find_scope_site()
    if args.config_dir:
        ext.manage_site_config_dir(args.config_dir[0])
    if not args.skip_repos and ext.configure_repos():
        tty.info('Updated repo config')
        _spack_repo_list()
    if not args.skip_clean:
        _spack_clean_ms()
    tty.info('Report problems at https://github.com/FairRootGroup/FairSoft/issues/new')


def view(_args):
    """manage symlink spack views on a FairSoft distro"""
    raise NotImplementedError('NOT YET IMPLEMENTED')


# Map subcommand to action function
_action = {
    'avail': avail,
    'info': info,
    'install': install,
    'list': list,
    'setup': setup,
    'view': view
}


def _trim_docstring(docstring):
    """Dedent docstrings as specified by PEP-0257.

    Reference implementation from https://www.python.org/dev/peps/pep-0257/

    `sys.maxint` replaced with `sys.maxsize`.
    """
    if not docstring:
        return ''
    # Convert tabs to spaces (following the normal Python rules)
    # and split into a list of lines:
    lines = docstring.expandtabs().splitlines()
    # Determine minimum indentation (first line doesn't count):
    indent = sys.maxsize
    for line in lines[1:]:
        stripped = line.lstrip()
        if stripped:
            indent = min(indent, len(line) - len(stripped))
    # Remove indentation (first line is special):
    trimmed = [lines[0].strip()]
    if indent < sys.maxsize:
        for line in lines[1:]:
            trimmed.append(line[indent:].rstrip())
    # Strip off trailing and leading blank lines:
    while trimmed and not trimmed[-1]:
        trimmed.pop()
    while trimmed and not trimmed[0]:
        trimmed.pop(0)
    # Return a single string:
    return '\n'.join(trimmed)


def _add_cmd(parsers, cmd):
    """Helper to add subcmd parser

    Uses the summary line of the action function's docstring
    as short help text and the body docstring as long
    description.
    """
    docstring = _action[cmd].__doc__
    summary = _trim_docstring(docstring.splitlines()[0])
    body = '\n'.join(_trim_docstring(docstring).splitlines()[1:])
    return parsers.add_parser(cmd,
                              help=summary,
                              description=summary,
                              epilog=body)


def setup_parser(parser):
    """Define CLI subcommands and options"""
    subcmds = parser.add_subparsers(metavar='SUBCOMMAND',
                                    dest='fairsoft_subcommand')
    _add_cmd(subcmds, 'avail')

    info_cmd = _add_cmd(subcmds, 'info')
    info_cmd.add_argument('distro',
                          choices=ext.get_distros(),
                          help='name of distro to print details about')

    _add_cmd(subcmds, 'install')

    _add_cmd(subcmds, 'list')

    setup_cmd = _add_cmd(subcmds, 'setup')
    setup_cmd.add_argument('--skip-clean',
                           action='store_true',
                           help='do not run `spack clean -ms`')
    setup_cmd.add_argument('--skip-compiler',
                           action='store_true',
                           help='do not run `spack compiler find --scope site`')
    setup_cmd.add_argument('--skip-git',
                           action='store_true',
                           help='do not run `git submodule update --init`')
    setup_cmd.add_argument('--skip-repos',
                           action='store_true',
                           help='do not configure repos')
    setup_cmd.add_argument('--config-dir', nargs=1, default=None,
                           help='symlink provided config dir')

    _add_cmd(subcmds, 'view')


def fairsoft(_parser, args):
    """Dispatch to SUBCOMMAND action function"""
    _action[args.fairsoft_subcommand](args)
