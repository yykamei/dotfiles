"""Tests for the canonical agent configuration synchronizer."""

from __future__ import annotations

import contextlib
import io
import tempfile
import unittest
from pathlib import Path

import agent_config


class AgentConfigTest(unittest.TestCase):
    """Exercise rendering and drift detection against a temporary checkout."""

    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        rules = self.root / agent_config.RULE_DIR
        rules.mkdir(parents=True)
        for name in agent_config.RULE_ORDER:
            (rules / name).write_text(
                f"# Rule {name}\n\nBody of {name}.\n", encoding="utf-8"
            )

    def tearDown(self) -> None:
        self.temp.cleanup()

    def test_render_demotes_headings_and_writes_both_outputs(self) -> None:
        changed = agent_config.sync_rules(self.root, check=False)
        self.assertEqual(
            set(changed), {str(path) for path in agent_config.GENERATED_RULES}
        )
        contents = [
            (self.root / relative).read_text(encoding="utf-8")
            for relative in agent_config.GENERATED_RULES
        ]
        self.assertEqual(contents[0], contents[1])
        self.assertIn("## Rule core-philosophy.md", contents[0])

    def test_render_preserves_headings_inside_fences(self) -> None:
        path = self.root / agent_config.RULE_DIR / "markdown-fence-safety.md"
        path.write_text(
            "# Fence\n\n~~~markdown\n# Example\n~~~\n", encoding="utf-8"
        )
        rendered = agent_config.render_rules(self.root)
        self.assertIn("## Fence", rendered)
        self.assertIn("~~~markdown\n# Example\n~~~", rendered)

    def test_check_accepts_current_output(self) -> None:
        agent_config.sync_rules(self.root, check=False)
        self.assertEqual(agent_config.sync_rules(self.root, check=True), [])

    def test_check_detects_rule_drift(self) -> None:
        agent_config.sync_rules(self.root, check=False)
        path = self.root / agent_config.GENERATED_RULES[0]
        path.write_text("stale\n", encoding="utf-8")
        self.assertEqual(
            agent_config.sync_rules(self.root, check=True),
            [str(agent_config.GENERATED_RULES[0])],
        )

    def test_missing_rule_reports_error(self) -> None:
        (self.root / agent_config.RULE_DIR / agent_config.RULE_ORDER[0]).unlink()
        with self.assertRaises(agent_config.ConfigError):
            agent_config.render_rules(self.root)

    def test_render_rejects_unexpected_rule(self) -> None:
        (self.root / agent_config.RULE_DIR / "extra.md").write_text(
            "# Extra\n", encoding="utf-8"
        )
        with self.assertRaises(agent_config.ConfigError):
            agent_config.render_rules(self.root)

    def test_render_rejects_unterminated_fence(self) -> None:
        path = self.root / agent_config.RULE_DIR / "language.md"
        path.write_text("# Language\n\n~~~text\nunclosed\n", encoding="utf-8")
        with self.assertRaises(agent_config.ConfigError):
            agent_config.render_rules(self.root)

    def test_render_strips_bom(self) -> None:
        path = self.root / agent_config.RULE_DIR / "language.md"
        path.write_bytes(b"\xef\xbb\xbf# Language\n\nText.\n")
        rendered = agent_config.render_rules(self.root)
        self.assertIn("## Language", rendered)
        self.assertNotIn("\ufeff", rendered)

    def test_check_detects_crlf_output(self) -> None:
        agent_config.sync_rules(self.root, check=False)
        path = self.root / agent_config.GENERATED_RULES[0]
        path.write_bytes(path.read_bytes().replace(b"\n", b"\r\n"))
        self.assertEqual(
            agent_config.sync_rules(self.root, check=True),
            [str(agent_config.GENERATED_RULES[0])],
        )

    def test_refuses_symlinked_output(self) -> None:
        outside = Path(self.temp.name) / "outside.md"
        outside.write_text("safe\n", encoding="utf-8")
        path = self.root / agent_config.GENERATED_RULES[0]
        path.parent.mkdir(parents=True, exist_ok=True)
        path.symlink_to(outside)
        with self.assertRaises(agent_config.ConfigError):
            agent_config.sync_rules(self.root, check=False)
        self.assertEqual(outside.read_text(encoding="utf-8"), "safe\n")

    def test_refuses_symlinked_output_parent(self) -> None:
        outside = Path(self.temp.name) / "outside"
        outside.mkdir()
        (self.root / ".claude").symlink_to(outside, target_is_directory=True)
        with self.assertRaises(agent_config.ConfigError):
            agent_config.sync_rules(self.root, check=False)
        self.assertFalse((outside / "CLAUDE.md").exists())

    def test_refuses_symlinked_rule(self) -> None:
        outside = Path(self.temp.name) / "outside.md"
        outside.write_text("# Outside\n", encoding="utf-8")
        path = self.root / agent_config.RULE_DIR / "language.md"
        path.unlink()
        path.symlink_to(outside)
        with self.assertRaises(agent_config.ConfigError):
            agent_config.render_rules(self.root)

    def test_refuses_output_escaping_repository(self) -> None:
        outside = tempfile.TemporaryDirectory()
        self.addCleanup(outside.cleanup)
        (self.root / ".claude").symlink_to(outside.name, target_is_directory=True)
        with self.assertRaises(agent_config.ConfigError) as context:
            agent_config.sync_rules(self.root, check=False)
        self.assertIn("escapes the repository", str(context.exception))

    def test_reports_parent_that_is_a_file(self) -> None:
        (self.root / ".claude").write_text("not a directory\n", encoding="utf-8")
        with self.assertRaises(agent_config.ConfigError) as context:
            agent_config.sync_rules(self.root, check=False)
        self.assertNotIn(str(self.root), str(context.exception))

    def test_render_rejects_level_six_heading(self) -> None:
        path = self.root / agent_config.RULE_DIR / "language.md"
        path.write_text("# Language\n\n###### Deep\n", encoding="utf-8")
        with self.assertRaises(agent_config.ConfigError):
            agent_config.render_rules(self.root)

    def test_write_preserves_existing_mode(self) -> None:
        agent_config.sync_rules(self.root, check=False)
        path = self.root / agent_config.GENERATED_RULES[0]
        path.chmod(0o600)
        path.write_text("stale\n", encoding="utf-8")
        agent_config.sync_rules(self.root, check=False)
        self.assertEqual(path.stat().st_mode & 0o777, 0o600)

    def test_render_handles_indented_and_backtick_fences(self) -> None:
        path = self.root / agent_config.RULE_DIR / "language.md"
        path.write_text(
            "# Language\n\n"
            "  ```markdown\n# Example\n  ```\n\n"
            "    ~~~\n# Indented example\n    ~~~\n",
            encoding="utf-8",
        )
        rendered = agent_config.render_rules(self.root)
        self.assertIn("\n# Example\n", rendered)
        self.assertIn("\n# Indented example\n", rendered)

    def test_render_keeps_fence_open_with_trailing_text(self) -> None:
        path = self.root / agent_config.RULE_DIR / "language.md"
        path.write_text(
            "# Language\n\n"
            "~~~markdown\n# Example\n~~~ not a close\n# Still inside\n~~~\n",
            encoding="utf-8",
        )
        rendered = agent_config.render_rules(self.root)
        self.assertIn("\n# Example\n", rendered)
        self.assertIn("\n# Still inside\n", rendered)

    def test_check_does_not_create_outputs(self) -> None:
        changed = agent_config.sync_rules(self.root, check=True)
        self.assertEqual(len(changed), 2)
        self.assertFalse((self.root / agent_config.GENERATED_RULES[0]).exists())

    def test_main_reports_check_exit_codes(self) -> None:
        with contextlib.redirect_stderr(io.StringIO()):
            self.assertEqual(agent_config.main(["--check"], root=self.root), 1)
            agent_config.sync_rules(self.root, check=False)
            self.assertEqual(agent_config.main(["--check"], root=self.root), 0)
            (self.root / agent_config.RULE_DIR / agent_config.RULE_ORDER[0]).unlink()
            self.assertEqual(agent_config.main(["--check"], root=self.root), 2)

    def test_main_write_creates_outputs(self) -> None:
        with contextlib.redirect_stdout(io.StringIO()):
            self.assertEqual(agent_config.main([], root=self.root), 0)
        expected = agent_config.render_rules(self.root).encode("utf-8")
        for relative in agent_config.GENERATED_RULES:
            self.assertEqual((self.root / relative).read_bytes(), expected)
