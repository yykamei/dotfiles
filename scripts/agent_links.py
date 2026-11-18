"""Link the canonical skills into Codex and Claude Code home directories.

Codex reads user skills from `~/.agents/skills` and Claude Code from
`~/.claude/skills`. This module creates per-skill relative symlinks to the
canonical tree under `.config/opencode/skills` and refuses to overwrite
unrelated entries such as `find-skills`.

```python
from pathlib import Path
from agent_links import link_skills

link_skills(Path.home(), Path("/path/to/dotfiles/.config/opencode/skills"))
```
"""

from __future__ import annotations

import argparse
import os
import sys
from collections.abc import Callable
from pathlib import Path

from agent_paths import check_directory, display_relative, skill_directories

TARGETS = (Path(".agents/skills"), Path(".claude/skills"))


class LinkError(RuntimeError):
    """Raised when a link cannot be created safely."""


def _current_link(
    link: Path, expected: str, display: Callable[[Path], str]
) -> bool:
    if not link.is_symlink():
        return False
    try:
        return os.readlink(link) == expected
    except OSError as error:
        raise LinkError(
            f"cannot read {display(link)}: {error.strerror or error}"
        ) from error


def _managed_link(link: Path, source: Path) -> bool:
    if not link.is_symlink():
        return False
    try:
        resolved = link.resolve(strict=False)
    except (OSError, RuntimeError):
        return False
    if not resolved.is_relative_to(source):
        return False
    try:
        resolved.stat()
    except FileNotFoundError:
        return True
    except OSError:
        return False
    return False


def link_skills(home: Path, source: Path, *, check: bool = False) -> list[Path]:
    """Create or verify per-skill symlinks under the agent home directories.

    Returns the links that are missing or stale. With `check=True`, nothing is
    created or removed. Raises `LinkError` rather than overwriting an existing
    file, directory, or symlink that points somewhere else.
    """
    if source.is_symlink():
        raise LinkError(f"refusing symlinked path: {source}")
    home = home.resolve()
    source = source.resolve()
    display_home = lambda path: display_relative(home, path)
    skills = skill_directories(
        source,
        source,
        LinkError,
        lambda path: display_relative(source, path),
    )
    expected_names = {skill.name for skill in skills}
    missing = []
    stale = []

    for relative in TARGETS:
        target = home / relative
        check_directory(home, target, LinkError, display_home)
        if target.is_dir():
            try:
                entries = sorted(target.iterdir())
            except OSError as error:
                raise LinkError(
                    f"cannot list {display_home(target)}: "
                    f"{error.strerror or error}"
                ) from error
            for entry in entries:
                if entry.name in expected_names:
                    continue
                if _managed_link(entry, source):
                    stale.append(entry)
        for skill in skills:
            link = target / skill.name
            expected = os.path.relpath(skill, target)
            if _current_link(link, expected, display_home):
                continue
            if link.is_symlink():
                raise LinkError(f"link points elsewhere: {display_home(link)}")
            if link.exists():
                raise LinkError(f"path already exists: {display_home(link)}")
            missing.append(link)

    if check:
        return sorted(stale + missing)

    for path in stale:
        if not path.is_symlink():
            raise LinkError(f"refusing to remove non-symlink: {display_home(path)}")
        try:
            path.unlink()
        except OSError as error:
            raise LinkError(
                f"cannot remove {display_home(path)}: {error.strerror or error}"
            ) from error

    for relative in TARGETS:
        target = home / relative
        try:
            target.mkdir(parents=True, exist_ok=True)
        except OSError as error:
            raise LinkError(
                f"cannot create {display_home(target)}: "
                f"{error.strerror or error}"
            ) from error
        check_directory(home, target, LinkError, display_home)
        for skill in skills:
            link = target / skill.name
            expected = os.path.relpath(skill, target)
            if _current_link(link, expected, display_home):
                continue
            try:
                link.symlink_to(expected, target_is_directory=True)
            except OSError as error:
                raise LinkError(
                    f"cannot create {display_home(link)}: "
                    f"{error.strerror or error}"
                ) from error
    return sorted(stale + missing)


def main(
    argv: list[str] | None = None,
    *,
    home: Path | None = None,
    source: Path | None = None,
) -> int:
    """CLI entry point for link-agent-skills.py."""
    parser = argparse.ArgumentParser(
        description=(
            "Link the canonical skills into ~/.agents/skills and "
            "~/.claude/skills."
        )
    )
    parser.add_argument("--check", action="store_true", help="verify without writing")
    args = parser.parse_args(argv)
    root = Path(__file__).resolve().parents[1]
    target_home = (home if home is not None else Path.home()).resolve()
    target_source = (
        source if source is not None else root / ".config/opencode/skills"
    )
    try:
        changed = link_skills(target_home, target_source, check=args.check)
    except (LinkError, OSError) as error:
        print(f"error: {error}", file=sys.stderr)
        return 2
    if args.check:
        for path in changed:
            print(f"out of date: {display_relative(target_home, path)}", file=sys.stderr)
        return 1 if changed else 0
    for path in changed:
        print(f"updated: {display_relative(target_home, path)}")
    return 0
