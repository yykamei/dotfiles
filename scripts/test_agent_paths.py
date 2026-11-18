"""Tests for the shared agent path validation helpers."""

from __future__ import annotations

import tempfile
import unittest
from pathlib import Path

import agent_paths


class TestError(RuntimeError):
    """Error type used by the tests in place of ConfigError or LinkError."""


class AgentPathsTest(unittest.TestCase):
    """Exercise the validation branches used by both agent scripts."""

    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name).resolve()

    def tearDown(self) -> None:
        self.temp.cleanup()

    def test_check_path_rejects_symlink(self) -> None:
        target = self.root / "target"
        target.write_text("target\n", encoding="utf-8")
        link = self.root / "link"
        link.symlink_to(target)
        with self.assertRaises(TestError):
            agent_paths.check_path(
                self.root, link, TestError, lambda path: str(path)
            )

    def test_check_directory_rejects_regular_file(self) -> None:
        path = self.root / "file"
        path.write_text("file\n", encoding="utf-8")
        with self.assertRaises(TestError):
            agent_paths.check_directory(
                self.root, path, TestError, lambda path: str(path)
            )

    def test_skill_directories_rejects_symlinked_root(self) -> None:
        outside = self.root / "outside"
        outside.mkdir()
        source = self.root / "skills"
        source.symlink_to(outside, target_is_directory=True)
        with self.assertRaises(TestError):
            agent_paths.skill_directories(
                source, source, TestError, lambda path: str(path)
            )

    def test_skill_directories_rejects_file_at_skill_name(self) -> None:
        source = self.root / "skills"
        source.mkdir()
        (source / "security-review").write_text("file\n", encoding="utf-8")
        with self.assertRaises(TestError):
            agent_paths.skill_directories(
                self.root, source, TestError, lambda path: str(path)
            )
