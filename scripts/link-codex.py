#!/usr/bin/env python3
"""Codex を終了した状態で実行する。使用例: python3 scripts/link-codex.py"""

import os
from pathlib import Path
import subprocess
import sys


def link_codex(home, settings):
    """保存済みデータをホームに保ち、Codex の設定を dotfiles にリンクする。

    例: link_codex(Path.home(), Path('/path/to/dotfiles/.codex'))
    """
    codex_home = home / '.codex'
    linked_home = codex_home.is_symlink()
    if linked_home and codex_home.resolve() != settings:
        raise ValueError(f'別のリンクがあります: {codex_home}')
    if codex_home.exists() and not codex_home.is_dir():
        raise ValueError(f'ディレクトリではありません: {codex_home}')
    if settings == codex_home or codex_home in settings.parents:
        raise ValueError('dotfiles は既存の ~/.codex の外に配置してください。')
    if not (settings / 'AGENTS.md').is_file() or not (settings / '.gitignore').is_file():
        raise ValueError(f'dotfiles の Codex 設定が見つかりません: {settings}')

    running = subprocess.run(
        ['pgrep', '-x', '-u', str(os.getuid()), 'ChatGPT|Codex|codex|codex-cli'],
        stdout=subprocess.DEVNULL,
    )
    if running.returncode == 0:
        raise ValueError('ChatGPT、Codex アプリ、Codex CLI を終了してから再実行してください。')
    if running.returncode != 1:
        raise ValueError('Codex が終了しているか確認できませんでした。')

    private = home / '.codex-local'
    storage = private / 'home'
    source = storage if linked_home else codex_home
    installed = source.is_dir()
    if linked_home and not installed:
        raise ValueError(f'移行済みのデータが見つかりません: {storage}')

    managed_names = {'.gitignore', 'AGENTS.md', 'agents'}
    runtime_names = {'sessions', 'archived_sessions'}
    if installed:
        runtime_names.update(entry.name for entry in source.iterdir()
                             if entry.name not in managed_names)
    else:
        runtime_names.add('config.toml')

    if not linked_home:
        private.mkdir(mode=0o700)
    linked = []
    created = []
    try:
        for name in sorted(runtime_names):
            target = settings / name
            original = storage / name
            if linked_home and target.is_symlink() and target.readlink() == original:
                continue
            target.symlink_to(original)
            linked.append(target)

        if linked_home:
            return
        if installed:
            codex_home.rename(storage)
        else:
            storage.mkdir(mode=0o700)
            config = storage / 'config.toml'
            config.write_text('project_doc_max_bytes = 131072\n')
            created.append(config)

        for name in ('sessions', 'archived_sessions'):
            directory = storage / name
            if not directory.is_dir():
                directory.mkdir(mode=0o700)
                created.append(directory)
        codex_home.symlink_to(settings, target_is_directory=True)
    except (OSError, KeyboardInterrupt):
        if not linked_home and codex_home.is_symlink() and codex_home.readlink() == settings:
            raise
        for path in reversed(created):
            if path.is_dir():
                path.rmdir()
            else:
                path.unlink()
        if not linked_home:
            if installed and storage.is_dir():
                storage.rename(codex_home)
            elif storage.is_dir():
                storage.rmdir()
            private.rmdir()
        for path in reversed(linked):
            path.unlink()
        raise


if __name__ == '__main__':
    if len(sys.argv) > 2:
        raise SystemExit('使い方: python3 scripts/link-codex.py [dotfiles のパス]')
    repo = Path(sys.argv[1] if len(sys.argv) == 2 else __file__).resolve()
    if len(sys.argv) == 1:
        repo = repo.parents[1]
    try:
        link_codex(Path.home().resolve(), (repo / '.codex').resolve())
    except (OSError, ValueError, KeyboardInterrupt) as error:
        raise SystemExit(f'Codex の設定をリンクできませんでした。{error}') from error
    print(f'{Path.home() / ".codex"} -> {repo / ".codex"}')
