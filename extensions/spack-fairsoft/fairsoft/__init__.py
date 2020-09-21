# Copyright 2020 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
# Copyright 2020 GSI Helmholtz Centre for Heavy Ion Research GmbH, Darmstadt
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)
"""Module that represents a FairSoft git repo

Provides useful infos and operations on it:

root_dir  Abs. path to the root of the FairSoft repo
env_dir   Abs. path to /env directory
repos_dir Abs. path to /repos directory

configure_repos()            Enforce correct repo config.
get_available_distros()      Return list of '<release>.<variant>' distro names.
get_distro_env_name(distro)  Compute the environment name for the given distro name.
get_distro_info(distro)      Return an info dictionary about given distro.
manage_site_config_dir(config_dir)
    Manage symlinks from spack site config dir to given config_dir entries.
"""

import functools
import os

import llnl.util.tty as tty
from ruamel.yaml.main import safe_load
import spack.paths
from spack.config import config
import spack.environment as ev
from spack.repo import Repo, RepoPath
from spack.util.executable import which

root_dir = os.path.abspath(
    os.path.join(os.path.dirname(__file__), *([os.pardir] * 3)))
env_dir = os.path.join(root_dir, 'env')
repos_dir = os.path.join(root_dir, 'repos')


def _repo_eq(self, other):
    """TODO: Consider upstreaming as spack.repo.Repo.__eq__()"""
    return self.root == other.root


def _repo_path_eq(self, other):
    """TODO: Consider upstreaming as spack.repo.RepoPath.__eq__()"""
    return self.repos == other.repos


Repo.__eq__ = _repo_eq  # monkeypatch spack.repo.Repo.__eq__()
RepoPath.__eq__ = _repo_path_eq  # monkeypatch spack.repo.RepoPath.__eq__()


def _update_repos_section(scope, expected):
    """Update the repos section in given scope to match expected values if needed

    Return True if an update was performed.
    """
    actual = config.get('repos', scope=scope) or []
    if not actual == expected:
        tty.debug('{}:{} not equal to {} -> updating ...'.format(
            scope, 'repos', expected))
        config.update_config('repos', expected, scope=scope)
        return True
    return False


def configure_repos():
    """Enforce correct repo config.

    0: fairsoft
    1: fairsoft-backports
    2: builtin

    If expected repo config is not present, set it.

    Return True if a config update was performed.
    """
    fairsoft_path = os.path.join(repos_dir, 'fairsoft')
    fairsoft_backports_path = os.path.join(repos_dir, 'fairsoft-backports')
    builtin_path = '$spack/var/spack/repos/builtin'

    expected = RepoPath(fairsoft_path, fairsoft_backports_path, builtin_path)
    # We accept if the repo config correct, no matter from which sections it comes
    actual = RepoPath(*(config.get('repos') or []))

    res = False
    if not actual == expected:
        # Now we have to write it somewhere, so we hardcode each section
        res = _update_repos_section('defaults', [builtin_path]) or res
        res = _update_repos_section('system', []) or res
        res = _update_repos_section(
            'site', [fairsoft_path, fairsoft_backports_path]) or res
        res = _update_repos_section('user', []) or res
    return res


def create_distro(distro):
    """Create given distro by (re-)creating a named environment"""
    active_env = ev.get_env({'env': distro}, '')
    release, variant = distro.split('.')
    env_name = get_distro_env_name(distro)
    env_path = os.path.join(env_dir, release, variant, 'spack.yaml')
    commit_file = os.path.join(ev.root(env_name), 'commit_hash')

    if active_env:
        tty.die('Found active environment `{}`.'.format(active_env.name),
                'This is not supported by this command.',
                'Please deactivate to continue:',
                '    spack env deactivate')

    git = which('git', required=True)
    commit_hash = git('-C', root_dir, 'rev-parse', 'HEAD', output=str)
    last_commit_hash = None

    if ev.exists(env_name):
        if os.path.exists(commit_file):
            with open(commit_file, 'r') as f:
                last_commit_hash = f.read()
        if last_commit_hash != commit_hash:
            tty.debug('Removing environment `{}` because \
                      {} ({}) != {} (current `git rev-parse HEAD`)'.format(
                          env_name, last_commit_hash, commit_file, commit_hash))
            env = ev.read(env_name)
            env.destroy()

    env = None
    if ev.exists(env_name):
        env = ev.read(env_name)
    else:
        tty.debug('Creating environment `{}` from {}'.format(env_name,
                                                             env_path))
        env = ev.create(env_name, env_path)
        with env.write_transaction():
            env.write()
            tty.debug('Writing commit_hash {} to {}'.format(commit_hash, commit_file))
            with open(commit_file, 'w') as f:
                f.write(commit_hash)

    return env


@functools.lru_cache(maxsize=100, typed=False)
def get_available_distros():
    """Return list of '<release>.<variant>' distro names.

    List is generated from the directory names in `/env/<release>/<variant>`.
    """
    envs = []
    for release in os.listdir(env_dir):
        for variant in os.listdir(os.path.join(env_dir, release)):
            envs.append('{}.{}'.format(release.lower(), variant.lower()))
    return envs


def get_distro_info(distro):
    """Return an info dictionary about given distro."""
    release, variant = distro.split('.')
    info_file = os.path.join(env_dir, release, variant, 'info.yaml')
    data = {'info': {}}
    if os.path.exists(info_file):
        tty.debug('Reading distro info file {}'.format(info_file))
        with open(info_file) as f:
            data = safe_load(f)

    info = data['info']
    return {
        'name': distro,
        'release': release,
        'variant': variant,
        'description': info['description'] if 'description' in info else 'None'
    }


@functools.lru_cache(maxsize=100, typed=False)
def get_distro_env_name(distro):
    """Compute the environment name for the given distro name."""
    return 'fairsoft_{}_{}'.format(*distro.split('.'))


def manage_site_config_dir(config_dir):
    """Manage symlinks from spack site config dir to given config_dir entries."""
    fairsoft = os.path.abspath(config_dir)
    site = os.path.join(spack.paths.etc_path, 'spack')
    tty.debug('Managing symlinks from {} to {}'.format(site, fairsoft))

    def compute_symlink_and_target(site, fairsoft, entry):
        return [
            os.path.join(site, entry),
            os.path.relpath(os.path.join(fairsoft, entry), start=site)
        ]

    # Remove dangling and unexpected symlinks
    for entry in os.listdir(site):
        symlink, target = compute_symlink_and_target(site, fairsoft, entry)
        if os.path.islink(symlink):
            readlink = os.readlink(symlink)
            if readlink != target:
                tty.debug('Removing unexpected symlink {} to {} (expected {})'.
                          format(symlink, readlink, target))
                os.remove(symlink)
            if not os.path.exists(os.path.abspath(os.path.join(site,
                                                               readlink))):
                tty.debug('Removing dangling symlink {} to {}'.format(
                    symlink, readlink))
                os.remove(symlink)

    # Add missing symlinks
    for entry in os.listdir(fairsoft):
        symlink, target = compute_symlink_and_target(site, fairsoft, entry)
        if not (os.path.islink(symlink) and os.readlink(symlink) == target):
            tty.debug('Add missing symlink {} to {}'.format(symlink, target))
            os.symlink(target, symlink)
