import os
import subprocess
# noinspection PyUnresolvedReferences
import sys
# noinspection PyUnresolvedReferences
import time

os.environ['GUM_CHOOSE_CURSOR_FOREGROUND'] = '6'
os.environ['GUM_CHOOSE_SELECTED_FOREGROUND'] = '6'
os.environ['GUM_CONFIRM_PROMPT_FOREGROUND'] = '4'
os.environ['GUM_CONFIRM_SELECTED_BACKGROUND'] = '6'
os.environ['GUM_CONFIRM_UNSELECTED_BACKGROUND'] = '0'
os.environ['GUM_CHOOSE_HEADER_FOREGROUND'] = '4'
os.environ['GUM_INPUT_CURSOR_BACKGROUND'] = '6'
os.environ['GUM_INPUT_PROMPT_FOREGROUND'] = '4'
os.environ['GUM_INPUT_WIDTH'] = '100'
os.environ['GUM_SPIN_SPINNER_FOREGROUND'] = '6'
os.environ['GUM_WRITE_CURSOR_FOREGROUND'] = '6'
os.environ['GUM_WRITE_PROMPT_FOREGROUND'] = '4'


def get_remotes():
    cmd = subprocess.Popen(
        ['git', 'remote'],
        stdout=subprocess.PIPE,
    )
    stdout, _ = cmd.communicate()
    remotes = stdout.decode().splitlines()
    if 'origin' in remotes:
        remotes = ['origin'] + [remote for remote in remotes if remote != 'origin']
    return remotes


def get_local_branches():
    cmd = subprocess.Popen(
        ['git', 'branch', '--format=%(refname:short)'],
        stdout=subprocess.PIPE,
    )
    stdout, _ = cmd.communicate()
    return stdout.decode().splitlines()


def get_remote_branches():
    cmd = subprocess.Popen(
        ['git', 'branch', '-r', '--format=%(refname:short)'],
        stdout=subprocess.PIPE,
    )
    stdout, _ = cmd.communicate()
    return stdout.decode().splitlines()


def get_local_branch_commit(branch):
    cmd = subprocess.Popen(
        ['git', 'rev-parse', 'refs/heads/{}'.format(branch)],
        stdout=subprocess.PIPE,
    )
    stdout, _ = cmd.communicate()
    return stdout.decode().strip()


def get_head_commit():
    cmd = subprocess.Popen(
        ['git', 'rev-parse', 'HEAD'],
        stdout=subprocess.PIPE,
    )
    stdout, _ = cmd.communicate()
    return stdout.decode().strip()
