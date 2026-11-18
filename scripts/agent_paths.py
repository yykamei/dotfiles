"""Shared path validation for the agent configuration scripts.

Both the repository synchronizer and the home-directory linker must reject
symlinked paths, non-regular files, and paths outside their configured root.
This module keeps that logic in one place; callers pass their own exception
class and a display function.

```python
from pathlib import Path
from agent_paths import check_path, display_relative

check_path(
    Path("/repo"),
    Path("/repo/file"),
    RuntimeError,
    lambda path: display_relative(Path("/repo"), path),
)
```
"""

from __future__ import annotations

import os
import re
import stat
from collections.abc import Callable
from pathlib import Path

SKILL_NAME = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")
ErrorFactory = Callable[[str], Exception]
Display = Callable[[Path], str]


def display_relative(root: Path, path: Path) -> str:
    """Return a path relative to root, or the absolute path when outside."""
    try:
        return str(path.relative_to(root))
    except ValueError:
        return str(path)


def check_components(
    root: Path, path: Path, error: ErrorFactory, display: Display
) -> None:
    """Reject paths outside root and symlinked components below it."""
    try:
        resolved = path.resolve(strict=False)
        resolved_root = root.resolve()
    except (OSError, RuntimeError) as exc:
        detail = getattr(exc, "strerror", None) or "symlink loop"
        raise error(f"cannot resolve {display(path)}: {detail}") from exc
    if not resolved.is_relative_to(resolved_root):
        raise error(f"path escapes the allowed root: {display(path)}")

    current = path
    while current != root:
        if current.is_symlink():
            raise error(f"refusing symlinked path: {display(current)}")
        if current.parent == current:
            break
        current = current.parent


def lstat_mode(path: Path, error: ErrorFactory, display: Display) -> int | None:
    """Return the mode of path without following a leaf symlink, or None."""
    try:
        return path.lstat().st_mode
    except FileNotFoundError:
        return None
    except OSError as exc:
        raise error(f"cannot inspect {display(path)}: {exc.strerror or exc}") from exc


def check_path(
    root: Path, path: Path, error: ErrorFactory, display: Display
) -> None:
    """Reject symlinked or non-regular files and paths outside root."""
    check_components(root, path, error, display)
    mode = lstat_mode(path, error, display)
    if mode is not None and not stat.S_ISREG(mode):
        raise error(f"refusing non-regular path: {display(path)}")


def check_directory(
    root: Path, path: Path, error: ErrorFactory, display: Display
) -> None:
    """Reject symlinked or non-directory paths and paths outside root."""
    check_components(root, path, error, display)
    mode = lstat_mode(path, error, display)
    if mode is not None and not stat.S_ISDIR(mode):
        raise error(f"refusing non-directory path: {display(path)}")


def walk_skill_tree(
    root: Path, skill: Path, error: ErrorFactory, display: Display
) -> None:
    """Reject symlinks and non-regular files anywhere below a skill."""
    def onerror(exc: OSError) -> None:
        filename = getattr(exc, "filename", None)
        if filename is None:
            raise error(f"cannot inspect skill tree: {exc.strerror or exc}") from exc
        raise error(
            f"cannot inspect {display(Path(filename))}: {exc.strerror or exc}"
        ) from exc

    for directory, dirnames, filenames in os.walk(
        skill, followlinks=False, onerror=onerror
    ):
        for name in dirnames + filenames:
            path = Path(directory) / name
            if path.is_symlink():
                raise error(f"refusing symlinked path: {display(path)}")
            if name in dirnames:
                check_directory(root, path, error, display)
            else:
                check_path(root, path, error, display)


def skill_directories(
    root: Path, source: Path, error: ErrorFactory, display: Display
) -> list[Path]:
    """Validate a canonical skill tree and return its skill directories.

    `source` must live under `root`; callers that pass `source == root` rely on
    the explicit symlink check below because the component walk skips the root.
    """
    if source.is_symlink():
        raise error(f"refusing symlinked path: {display(source)}")
    check_directory(root, source, error, display)
    if not source.is_dir():
        raise error(f"skill source is not a directory: {display(source)}")

    directories = []
    for path in sorted(source.iterdir()):
        if path.is_symlink():
            raise error(f"refusing symlinked path: {display(path)}")
        if not SKILL_NAME.fullmatch(path.name):
            if path.is_dir():
                raise error(f"invalid skill directory name: {path.name}")
            continue
        if not path.is_dir():
            raise error(f"skill path is not a directory: {display(path)}")
        check_directory(root, path, error, display)
        if not (path / "SKILL.md").is_file():
            raise error(f"skill is missing SKILL.md: {display(path)}")
        walk_skill_tree(root, path, error, display)
        directories.append(path)
    return directories
