# dotfiles

My Dot Files

## Codex

`.codex/AGENTS.md` と `.codex/agents/*.toml` を Codex のグローバル設定として共有します。

macOS で ChatGPT、Codex アプリ、Codex CLI を終了し、dotfiles で次を実行します。
Claude から `~/.codex/AGENTS.md` を生成する定期ジョブを設定している場合は、先に停止してください。

```sh
python3 scripts/link-codex.py
```

`~/.codex` がこのチェックアウトの `.codex/` を指すようになります。
移行前の `~/.codex` は `~/.codex-local/home/` に保存されます。
既存のセッション、認証、端末ごとの `config.toml` はそこへのリンクを通じて使います。
`.codex/.gitignore` で追跡対象を共有設定に限定しています。

すでに `config.toml` がある端末では、`AGENTS.md` 全体を読み込めるよう
`project_doc_max_bytes = 131072` をファイルのトップレベルに設定してください。

`git clean -fdx` などで端末データへのリンクが消えた場合は、Codex を起動する前に
同じスクリプトを再実行するとリンクを復旧できます。

## エージェント共通設定

`.config/opencode/rules/` と `.config/opencode/skills/` を正として、Claude Code と Codex のグローバル設定を同期します。

```sh
python3 scripts/sync-agent-config.py
python3 scripts/link-agent-skills.py
```

`.claude/CLAUDE.md` と `.codex/AGENTS.md` はルールから生成し、`.claude/skills/<name>` は `.config/opencode/skills/<name>` への相対 symlink にします。`.claude/skills` はこのチェックアウトが管理するため、管理外のスキルは置かないでください。ルールやスキルを編集したら `python3 scripts/sync-agent-config.py` を実行してからコミットしてください。新しいルールを追加するときは、`scripts/agent_config.py` の `RULE_ORDER` にも追加します。`--check` は、生成物と symlink が正と一致しているか確認します。

`python3 scripts/link-agent-skills.py` は、`~/.agents/skills` と `~/.claude/skills` に各スキルの相対 symlink を作成します。既存の `find-skills` など管理対象外のエントリには触れず、canonical のスキル名と同名の管理外エントリがある場合は上書きせずにエラーにします。`~/.claude` や `~/.agents` が symlink の場合は書き込みを拒否します。canonical 側で削除・改名されたスキルを指す古いリンクは、`--check` で報告し、書き込み時に削除します。canonical のスキルを指す別名リンクは残します。canonical 側にまだ存在しないスキルを指す意図的な dangling link も、管理対象の古いリンクとして削除します。既存リンクが同じ実体を指していても、相対パスでない場合はエラーにします。

終了コードは 0（一致）、1（差分あり）、2（エラー）です。`--check` を付けると、リンクを作成せずに確認だけを行います。

信頼できないチェックアウトでは書き込みモードを実行しないでください。まず `--check` で同期漏れがないか確認し、内容を確認できた場合だけ生成してください。
