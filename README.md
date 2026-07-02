# dotfiles

Личные конфиги, которые живут прямо в `$HOME` под git. Репозиторий
инициализирован в `~`, а `.gitignore` устроен по принципу «запретить всё,
разрешить точечно»: первая строка `*` игнорирует весь домашний каталог, а
`!`-правила вручную вайтлистят только нужные файлы. Поэтому `git status` в `~`
всегда чистый — видны лишь отслеживаемые конфиги.

## Что внутри

| Область | Файлы | Примечание |
|---|---|---|
| Терминалы | `.config/alacritty/`, `.config/ghostty/` | конфиги эмуляторов |
| Shell | `.zshrc`, `.p10k.zsh` | секреты вынесены в `~/.zshrc.local` (вне git, см. ниже) |
| tmux | `.config/tmux/tmux.conf` | плагины (TPM) в игноре |
| Neovim | `.config/nvim/**` | lazy.nvim, `lazy-lock.json` в игноре |
| Claude Code | `.claude/settings.json`, `statusline.sh`, `hooks/`, `rules/` | без секретов; про `bypassPermissions` — см. Оговорки |
| opencode | `.config/opencode/AGENTS.md` | `opencode.json` с MCP-токенами в игноре |
| Cursor CLI | `.cursor/statusline.sh` | остальное (mcp.json, cli-config.json) в игноре |

Конфиги с секретами и PII (MCP-токены, API-ключи, auth) **намеренно не в git** —
их нужно воссоздать вручную, см. раздел [Файлы вне git](#файлы-вне-git-создать-вручную).

## Установка на новом устройстве

### 0. Зависимости

Поставь через пакетный менеджер системы: `git`, `zsh`, `tmux`, `neovim`
(≥ 0.9), `jq` (нужен статуслайнам Claude и Cursor), плюс сами терминалы
(alacritty / ghostty) при необходимости. AI-CLI (`claude`, `opencode`, `cursor`,
`codex`) ставятся отдельно по инструкциям их вендоров.

### 1. Забрать репозиторий в `$HOME`

Репо разворачивается поверх существующего домашнего каталога. `checkout -f`
**перезапишет** локальные версии отслеживаемых файлов (например уже лежащий
`~/.config/nvim`) — на чистой машине это то что нужно, но если в `~` есть ценные
несохранённые конфиги, сначала сделай их бэкап.

```bash
cd ~
git init
git remote add origin git@github.com:ivndya/dotfiles.git
git fetch origin
git checkout -f main
git branch --set-upstream-to=origin/main main   # чтобы работал git pull
```

### 2. Shell (zsh + oh-my-zsh + powerlevel10k)

`.zshrc` и `.p10k.zsh` приезжают из репо. **Секреты в `.zshrc` не хранятся** —
они вынесены в `~/.zshrc.local`, который не трекается и подключается в конце
`.zshrc` строкой `[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local`.

`.zshrc` рассчитывает на oh-my-zsh, тему powerlevel10k и два кастомных плагина
(`zsh-autosuggestions`, `zsh-syntax-highlighting` из строки `plugins=(...)`):

```bash
# oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git       "$ZSH_CUSTOM/themes/powerlevel10k"
git clone https://github.com/zsh-users/zsh-autosuggestions             "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
git clone https://github.com/zsh-users/zsh-syntax-highlighting         "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
```

Затем создай `~/.zshrc.local` и перенеси туда свои токены/ключи (со старой
машины или заново). `.zshrc` также инициализирует `zoxide`, `nvm`, `brew`,
`pnpm` — если чего-то из этого нет, при старте будут безвредные
`command not found`; ненужные строки можно закомментировать.

### 3. tmux

Плагины (`.config/tmux/plugins/`) в игноре. Поставь TPM и подтяни плагины:

```bash
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
tmux              # запусти сессию
# внутри tmux нажми  prefix + I  — TPM установит sensible / yank / dracula
```

### 4. Neovim

Ничего доустанавливать руками не нужно — `lazy.nvim` сам склонируется при первом
запуске (bootstrap в `lua/config/lazy.lua`), затем подтянет плагины и Mason
поставит LSP-серверы:

```bash
nvim            # дождись установки плагинов, при желании :Lazy sync / :Mason
```

### 5. AI-инструменты: Claude Code / opencode / Cursor

Конфиги без секретов приедут из репо. Дальше:

1. **Логин** — создаёт локальные auth-файлы (вне git):
   `claude` (веб-логин), `cursor login`, `codex login`, авторизация opencode.
2. **MCP-серверы и ключи** — воссоздай файлы из
   [раздела ниже](#файлы-вне-git-создать-вручную).
3. **WSL-нотификации Claude** — хуки `notify-stop.sh` / `notify-input.sh`
   вызывают `powershell.exe` (тост через `toast.ps1`). Работают только под
   **WSL2**; на нативном Linux/macOS их надо отключить или переписать под
   `notify-send` / `osascript` (правится в `.claude/settings.json`).

## Файлы вне git (создать вручную)

| Файл | Как получить |
|---|---|
| `~/.zshrc.local` | секреты/токены для шелла (`.zshrc` их из него подгружает) — перенести со старой машины |
| `~/.claude/.credentials.json` | появляется после логина в `claude` |
| `~/.claude/settings.local.json` | локальные permission-оверрайды (опционально) |
| `~/.config/opencode/opencode.json` | MCP-серверы + ключи (шаблон ниже) |
| `~/.cursor/mcp.json` | MCP-серверы + ключи (шаблон ниже) |
| `~/.cursor/cli-config.json` | появляется/дополняется при `cursor login` + настройке моделей |
| `~/.config/cursor/auth.json` | появляется при `cursor login` |
| `~/.codex/config.toml` | модель (шаблон ниже) |
| `~/.codex/auth.json` | появляется при `codex login` |

Шаблоны MCP-конфигов (подставь свои токены вместо `<...>`):

```jsonc
// ~/.cursor/mcp.json  (и аналогичная секция "mcp" в ~/.config/opencode/opencode.json)
{
  "mcpServers": {
    "context7": {
      "url": "https://mcp.context7.com/mcp",
      "headers": { "CONTEXT7_API_KEY": "<CONTEXT7_KEY>" }
    }
  }
}
```

```toml
# ~/.codex/config.toml
model = "gpt-5.5"
model_reasoning_effort = "medium"
```

## Как добавить новый файл в трекинг

`.gitignore` игнорирует всё, поэтому новый файл нужно явно разрешить. Если его
родительский каталог сам под `*` — сначала «открой» каталог, потом файл:

```gitignore
!.config/foo/
!.config/foo/config.toml
```

Если у инструмента есть **собственный** вложенный `.gitignore` с whitelist-ами
(как у Cursor — он тянет транскрипты/скиллы), не открывай весь каталог — добавь
один файл принудительно:

```bash
git add -f .cursor/statusline.sh
```

**Перед коммитом всегда проверяй, что не утекли секреты:**

```bash
git diff --cached | grep -inE 'bearer |ctx7sk-|mcp_[0-9a-f]{16}|password|secret|token'
```

## Оговорки

- **`bypassPermissions`.** `.claude/settings.json` содержит
  `"defaultMode": "bypassPermissions"` и `"skipDangerousModePermissionPrompt": true`.
  На любой машине, куда раскатан этот репо, Claude Code стартует без запросов
  разрешений. Если это нежелательно — вынеси эти ключи в `settings.local.json`
  (он не трекается).
- **Публичный репозиторий.** `ivndya/dotfiles` открыт всему миру — никаких
  токенов, ключей и PII в коммитах.
- **WSL-специфика.** Хуки Claude завязаны на `powershell.exe`; вне WSL2 их надо
  адаптировать.
