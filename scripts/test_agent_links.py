"""Tests for linking shared skills into agent home directories."""

from __future__ import annotations

import contextlib
import io
import os
import tempfile
import unittest
from pathlib import Path

import agent_links


class AgentLinksTest(unittest.TestCase):
    """Exercise link creation, idempotency, and conflict handling."""

    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory()
        self.home = (Path(self.temp.name) / "home").resolve()
        self.home.mkdir()
        self.source = (Path(self.temp.name) / "skills").resolve()
        self._add_skill("alpha")
        self._add_skill("beta")

    def tearDown(self) -> None:
        self.temp.cleanup()

    def _add_skill(self, name: str) -> None:
        path = self.source / name
        path.mkdir(parents=True)
        (path / "SKILL.md").write_text(
            f"---\nname: {name}\n---\n", encoding="utf-8"
        )
        references = path / "references"
        references.mkdir()
        (references / "guide.md").write_text("guide\n", encoding="utf-8")

    def test_links_every_skill_for_every_target(self) -> None:
        changed = agent_links.link_skills(self.home, self.source)
        self.assertEqual(len(changed), 4)
        for relative in agent_links.TARGETS:
            target = self.home / relative
            for name in ("alpha", "beta"):
                link = target / name
                self.assertTrue(link.is_symlink())
                self.assertEqual(
                    os.readlink(link),
                    os.path.relpath(self.source / name, target),
                )
                self.assertEqual(link.resolve(), (self.source / name).resolve())

    def test_second_run_is_idempotent(self) -> None:
        agent_links.link_skills(self.home, self.source)
        self.assertEqual(agent_links.link_skills(self.home, self.source), [])

    def test_check_reports_missing_links_without_creating_them(self) -> None:
        changed = agent_links.link_skills(self.home, self.source, check=True)
        self.assertEqual(len(changed), 4)
        self.assertFalse((self.home / ".agents/skills").exists())
        self.assertFalse((self.home / ".claude/skills").exists())

    def test_refuses_existing_directory(self) -> None:
        conflict = self.home / ".claude/skills/alpha"
        conflict.mkdir(parents=True)
        with self.assertRaises(agent_links.LinkError):
            agent_links.link_skills(self.home, self.source)
        self.assertTrue(conflict.is_dir())
        self.assertFalse(conflict.is_symlink())
        self.assertFalse((self.home / ".agents/skills").exists())

    def test_refuses_existing_file(self) -> None:
        conflict = self.home / ".agents/skills/beta"
        conflict.parent.mkdir(parents=True)
        conflict.write_text("conflict\n", encoding="utf-8")
        with self.assertRaises(agent_links.LinkError):
            agent_links.link_skills(self.home, self.source)
        self.assertEqual(conflict.read_text(encoding="utf-8"), "conflict\n")
        self.assertFalse((self.home / ".claude/skills").exists())

    def test_refuses_wrong_target_symlink(self) -> None:
        link = self.home / ".agents/skills/alpha"
        link.parent.mkdir(parents=True)
        link.symlink_to(self.source / "beta", target_is_directory=True)
        with self.assertRaises(agent_links.LinkError):
            agent_links.link_skills(self.home, self.source)
        self.assertEqual(link.resolve(), (self.source / "beta").resolve())

    def test_refuses_symlinked_target_parent(self) -> None:
        outside = Path(self.temp.name) / "outside"
        outside.mkdir()
        (self.home / ".agents").symlink_to(outside, target_is_directory=True)
        with self.assertRaises(agent_links.LinkError):
            agent_links.link_skills(self.home, self.source)
        self.assertFalse((outside / "skills").exists())

    def test_refuses_symlinked_claude_parent(self) -> None:
        outside = Path(self.temp.name) / "outside"
        outside.mkdir()
        (self.home / ".claude").symlink_to(outside, target_is_directory=True)
        with self.assertRaises(agent_links.LinkError):
            agent_links.link_skills(self.home, self.source)
        self.assertFalse((outside / "skills").exists())

    def test_refuses_symlinked_source_root(self) -> None:
        outside = Path(self.temp.name) / "outside-skills"
        outside.mkdir()
        source = Path(self.temp.name) / "linked-skills"
        source.symlink_to(outside, target_is_directory=True)
        with self.assertRaises(agent_links.LinkError):
            agent_links.link_skills(self.home, source)

    def test_refuses_skill_without_skill_md(self) -> None:
        incomplete = self.source / "incomplete"
        incomplete.mkdir()
        with self.assertRaises(agent_links.LinkError):
            agent_links.link_skills(self.home, self.source)

    def test_check_reports_stale_managed_link(self) -> None:
        stale = self.home / ".agents/skills/old"
        stale.parent.mkdir(parents=True)
        stale.symlink_to(self.source / "old", target_is_directory=True)
        changed = agent_links.link_skills(self.home, self.source, check=True)
        self.assertIn(stale, changed)
        self.assertTrue(stale.is_symlink())

    def test_write_removes_stale_managed_link(self) -> None:
        stale = self.home / ".agents/skills/old"
        stale.parent.mkdir(parents=True)
        stale.symlink_to(self.source / "old", target_is_directory=True)
        agent_links.link_skills(self.home, self.source)
        self.assertFalse(stale.exists() or stale.is_symlink())

    def test_leaves_unrelated_symlink(self) -> None:
        outside = Path(self.temp.name) / "outside"
        outside.mkdir()
        unrelated = self.home / ".agents/skills/other"
        unrelated.parent.mkdir(parents=True)
        unrelated.symlink_to(outside, target_is_directory=True)
        agent_links.link_skills(self.home, self.source)
        self.assertTrue(unrelated.is_symlink())
        self.assertEqual(unrelated.resolve(), outside.resolve())

    def test_keeps_live_alias_into_source(self) -> None:
        alias = self.home / ".agents/skills/alias"
        alias.parent.mkdir(parents=True)
        alias.symlink_to(self.source / "alpha", target_is_directory=True)
        changed = agent_links.link_skills(self.home, self.source, check=True)
        self.assertNotIn(alias, changed)
        agent_links.link_skills(self.home, self.source)
        self.assertTrue(alias.is_symlink())
        self.assertEqual(alias.resolve(), (self.source / "alpha").resolve())

    def test_conflict_preserves_stale_link(self) -> None:
        stale = self.home / ".agents/skills/old"
        stale.parent.mkdir(parents=True)
        stale.symlink_to(self.source / "old", target_is_directory=True)
        conflict = self.home / ".claude/skills/alpha"
        conflict.mkdir(parents=True)
        with self.assertRaises(agent_links.LinkError):
            agent_links.link_skills(self.home, self.source)
        self.assertTrue(stale.is_symlink())

    def test_leaves_unrelated_entries_untouched(self) -> None:
        unrelated = self.home / ".agents/skills/find-skills"
        unrelated.mkdir(parents=True)
        (unrelated / "SKILL.md").write_text(
            "---\nname: find-skills\n---\n", encoding="utf-8"
        )
        agent_links.link_skills(self.home, self.source)
        self.assertFalse(unrelated.is_symlink())
        self.assertTrue((unrelated / "SKILL.md").is_file())

    def test_rejects_invalid_skill_name(self) -> None:
        invalid = self.source / "Bad_Name"
        invalid.mkdir()
        (invalid / "SKILL.md").write_text("---\nname: bad\n---\n", encoding="utf-8")
        with self.assertRaises(agent_links.LinkError):
            agent_links.link_skills(self.home, self.source, check=True)

    def test_rejects_symlinked_source_file(self) -> None:
        outside = Path(self.temp.name) / "outside.md"
        outside.write_text("outside\n", encoding="utf-8")
        (self.source / "alpha" / "linked.md").symlink_to(outside)
        with self.assertRaises(agent_links.LinkError):
            agent_links.link_skills(self.home, self.source, check=True)

    def test_main_reports_exit_codes(self) -> None:
        with contextlib.redirect_stderr(io.StringIO()):
            self.assertEqual(
                agent_links.main(
                    ["--check"], home=self.home, source=self.source
                ),
                1,
            )
            with contextlib.redirect_stdout(io.StringIO()):
                self.assertEqual(
                    agent_links.main([], home=self.home, source=self.source),
                    0,
                )
            self.assertEqual(
                agent_links.main(
                    ["--check"], home=self.home, source=self.source
                ),
                0,
            )
            conflict = self.home / ".claude/skills/alpha"
            conflict.unlink()
            conflict.mkdir()
            self.assertEqual(
                agent_links.main(
                    ["--check"], home=self.home, source=self.source
                ),
                2,
            )
