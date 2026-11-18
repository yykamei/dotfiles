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
