# Powerlevel10k instant prompt — держать у самого верха.
# Код, требующий ввода с консоли, должен идти ВЫШЕ этого блока.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ── Oh My Zsh ──────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git fzf-tab zsh-autosuggestions zsh-syntax-highlighting history-substring-search)
source "$ZSH/oh-my-zsh.sh"
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# ── PATH ───────────────────────────────────────────────────
export PATH="$HOME/.cargo/bin:$HOME/.local/bin:$HOME/.opencode/bin:$PATH"
export ANDROID_HOME="$HOME/Android/Sdk"
export PATH="$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools"

# ── Инструменты ────────────────────────────────────────────
eval "$(zoxide init zsh)"
# brew: /opt/homebrew на макбуке, linuxbrew на ПК
for _brew in /opt/homebrew/bin/brew /home/linuxbrew/.linuxbrew/bin/brew /usr/local/bin/brew; do
  [[ -x "$_brew" ]] && { eval "$("$_brew" shellenv)"; break }
done
unset _brew

# ── fzf: Ctrl+R история, Ctrl+T файлы, Alt+C cd ────────────
eval "$(fzf --zsh)"
# fzf --zsh перебивает Tab-бинд fzf-tab (плагины грузятся раньше) — возвращаем
enable-fzf-tab
# Цвета fzf — из активной темы терминала (общая с alacritty, tmux и nvim,
# переключается командой `theme`). Тема пересобирает FZF_DEFAULT_OPTS из
# FZF_BASE_OPTS, поэтому повторный source не плодит дублей --color.
export FZF_BASE_OPTS="--height=60% --layout=reverse --border"
[[ -r ~/.config/theme/active/fzf.sh ]] && source ~/.config/theme/active/fzf.sh

# Обёртка над ~/.local/bin/theme: подхватывает новые цвета fzf сразу, без
# перезапуска шелла (у fzf нет способа перечитать опции из файла).
theme() {
  command theme "$@" || return
  source ~/.config/theme/active/fzf.sh
}
_theme() { compadd $(ls ~/.config/theme/themes) toggle }
(( $+functions[compdef] )) && compdef _theme theme
export FZF_DEFAULT_COMMAND='fd --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:300 {}'"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --color=always --icons {}'"

# fzf-tab: Tab-дополнение через fzf (с превью директорий)
zstyle ':completion:*' menu no
zstyle ':fzf-tab:*' use-fzf-default-opts yes
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always --icons $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --color=always --icons $realpath'

# ── bat ────────────────────────────────────────────────────
export BAT_THEME="Dracula"
# Цветные man-страницы
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# ── Клавиши ────────────────────────────────────────────────
bindkey ^y autosuggest-accept
# Alt+C в русской раскладке шлёт «с» (кириллицу) — дублируем бинд fzf-cd
bindkey '^[с' fzf-cd-widget

# ── Алиасы ─────────────────────────────────────────────────
alias gco='git checkout'
alias gp='git pull'
alias gf='git fetch'
alias nv='nvim'
alias lg='lazygit'
alias ld='lazydocker'
alias ag='agent'
alias ocode='opencode'

# eza вместо ls, bat вместо cat (только в интерактивном шелле)
alias ls='eza --icons'
alias ll='eza -la --icons --git'
alias lsa='eza -lah --icons --git'
alias lt='eza --tree --level=2 --icons'
alias cat='bat -pp'

# yazi: файловый менеджер; при выходе шелл остаётся в последней директории
y() {
  local tmp cwd
  tmp="$(mktemp -t yazi-cwd.XXXXXX)"
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(<"$tmp")" && [[ -n "$cwd" && "$cwd" != "$PWD" ]]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

# ── Прокси через WSL-хост ──────────────────────────────────
# _PROXY_URL и автозапуск (proxy-on -q) задаются в ~/.zshrc.local.
proxy-on()     { export http_proxy="$_PROXY_URL" https_proxy="$_PROXY_URL" HTTP_PROXY="$_PROXY_URL" HTTPS_PROXY="$_PROXY_URL"; [[ "${1:-}" == "-q" ]] || echo "Proxy ON ($_PROXY_URL)"; }
proxy-off()    { unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY ALL_PROXY no_proxy NO_PROXY; echo "Proxy OFF"; }
proxy-status() { if [[ -n "${http_proxy:-}" ]]; then echo "Proxy ON: $http_proxy"; else echo "Proxy OFF"; fi }
alias pon=proxy-on poff=proxy-off pst=proxy-status

# ── Claude Code ────────────────────────────────────────────
# Всегда классический TUI-рендерер (tui=default): env-переменная сильнее
# сохранённой настройки tui в settings.json, поэтому форсим напрямую.
export CLAUDE_CODE_DISABLE_ALTERNATE_SCREEN=1
# Немигающая каретка: серверный фиче-гейт tengu_native_cursor включает
# «настоящий» курсор терминала, который Claude Code прячет/показывает при
# каждой перерисовке — через ConPTY это видно как мигание во время работы
# агента. Возврат на программную каретку (статичный блок, не прячется):
# гейт выставлен в false в ~/.claude.json (cachedGrowthBookFeatures), а
# эта переменная не даёт кэшу перезатереться с сервера (заодно
# замораживает прочие удалённые фиче-роллауты Claude Code).
export DISABLE_GROWTHBOOK=1

# Запуск: cl [уровень] [pw] [fig] [обычные аргументы claude]. Без уровня —
# дефолт (fable + xhigh из settings.local.json). Уровни задаются env-переменными
# на одну сессию и сохранённые настройки не трогают. Шпаргалка: cl help.
# pw — подключить playwright MCP (вынесен из ~/.claude.json: каждая сессия
# держала свой экземпляр, ~115 МБ, а браузер нужен редко).
# fig — Figma MCP (mcp.figma.com, чтение макетов). Пишущие инструменты
# заблокированы через permissions.deny в ~/.claude/settings.json.
cl() {
  local model='' effort=''
  local -a mcp
  while (( $# )); do
    case "$1" in
      pw)           mcp+=(--mcp-config "$HOME/.claude/mcp/playwright.json"); shift ;;
      pwh)          mcp+=(--mcp-config "$HOME/.claude/mcp/playwright-headed.json"); shift ;;
      fig|figma)    mcp+=(--mcp-config "$HOME/.claude/mcp/figma.json"); shift ;;
      mid|m)        model='claude-fable-5[1m]'; effort=medium; shift ;;
      low|l)        model='claude-fable-5[1m]'; effort=low;    shift ;;
      min|s|sonnet) model='claude-sonnet-5';    effort=low;    shift ;;
      help|h|-h|--help)
        command cat <<'EOF'
  cl        fable  + xhigh    дефолт: максимум ума, не торопится
  cl mid    fable  + medium   умная, но заметно быстрее
  cl low    fable  + low      умная и быстрая
  cl min    sonnet + low      самая лёгкая, для мелочей

  cl pw     + playwright MCP (браузер). Комбинируется: cl low pw
  cl pwh    + playwright с видимым окном (логины руками), закрывать browser_close
  cl fig    + figma MCP (макеты, только чтение). Тоже комбинируется

Остальное пробрасывается в claude: cl low -c, cl mid --resume, cl -p '…'
EOF
        return ;;
      *) break ;;
    esac
  done
  if [[ -n $model ]]; then
    ANTHROPIC_MODEL=$model CLAUDE_CODE_EFFORT_LEVEL=$effort claude "${mcp[@]}" "$@"
  else
    claude "${mcp[@]}" "$@"
  fi
}
alias cls='cl min'  # привычный ярлык для слабой сессии
# statusline: локальные «рабочие часы» вместо дефолтных UTC 13-19.
export CLAUDE_STATUSLINE_PEAK_HOURS_LOCAL="9-18"
# вкл/выкл Windows-уведомления от хуков (tmux-подсветка работает независимо).
cnotify() {
  case "${1:-status}" in
    on)  rm -f ~/.claude/notify-off && echo "Claude toasts: ON" ;;
    off) touch ~/.claude/notify-off && echo "Claude toasts: OFF" ;;
    *)   [ -f ~/.claude/notify-off ] && echo "Claude toasts: OFF" || echo "Claude toasts: ON" ;;
  esac
}

# Локальные секреты / машинно-специфичное (вне git, см. README).
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# ── Автозапуск tmux (в самом конце — вызов держит сессию) ───
if [[ -z "$TMUX" ]]; then
  tmux attach-session -t default || tmux new-session -s default
fi

# The next line updates PATH for CLI.
if [ -f "$HOME/yandex-cloud/path.bash.inc" ]; then source "$HOME/yandex-cloud/path.bash.inc"; fi

# The next line enables shell command completion for yc.
if [ -f "$HOME/yandex-cloud/completion.zsh.inc" ]; then source "$HOME/yandex-cloud/completion.zsh.inc"; fi


# ── Размер шрифта Ghostty из шелла ──────────────────────────
# Ghostty не умеет менять шрифт по escape-последовательности и не имеет IPC
# на macOS, поэтому команда «нажимает» хоткей из ~/.config/ghostty/config
# через System Events. Нужен доступ: Настройки → Конфиденциальность и
# безопасность → Универсальный доступ → Ghostty.
ghostty-font-toggle() {
  local state=~/.cache/ghostty-font-size want="${1:-toggle}" code err
  if [[ $want == toggle ]]; then
    [[ $(cat $state 2>/dev/null) == small ]] && want=big || want=small
  fi
  case $want in
    big|b|17)   want=big   code=18 ;;   # key code 18 = «1» → super+ctrl+digit_1 = 17pt
    medium|m|16) want=medium code=20 ;; # key code 20 = «3» → super+ctrl+digit_3 = 16pt
    small|s|14) want=small code=19 ;;   # key code 19 = «2» → super+ctrl+digit_2 = 14pt
    *) print -u2 "usage: ghostty-font-toggle [big|medium|small|toggle]"; return 2 ;;
  esac
  err=$(osascript -e "tell application \"System Events\" to key code $code using {command down, control down}" 2>&1) || {
    print -u2 "ghostty-font-toggle: не вышло нажать хоткей: $err"
    print -u2 "ghostty-font-toggle: выдай Ghostty доступ в Универсальный доступ и повтори"
    return 1
  }
  mkdir -p "${state:h}" && print -r -- "$want" > $state
}

# Открыть файл браузером: на маке `open`, из WSL — виндовый браузер
open-html() {
  if command -v wslpath >/dev/null 2>&1; then
    local w; w="$(wslpath -w "${1:a}")" && (cd /mnt/c && /mnt/c/Windows/System32/cmd.exe /c start "" "$w")
  else
    open "${1:a}"
  fi
}
