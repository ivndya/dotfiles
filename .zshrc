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
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# ── fzf: Ctrl+R история, Ctrl+T файлы, Alt+C cd ────────────
eval "$(fzf --zsh)"
# fzf --zsh перебивает Tab-бинд fzf-tab (плагины грузятся раньше) — возвращаем
enable-fzf-tab
# Палитра Dracula — в тон tmux
export FZF_DEFAULT_OPTS="
  --height=60% --layout=reverse --border
  --color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9
  --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9
  --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6
  --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4"
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

# Запуск: cl [уровень] [обычные аргументы claude]. Без уровня — дефолт
# (fable + xhigh из settings.local.json). Уровни задаются env-переменными
# на одну сессию и сохранённые настройки не трогают. Шпаргалка: cl help.
cl() {
  case "${1:-}" in
    mid|m)        shift; ANTHROPIC_MODEL='claude-fable-5[1m]' CLAUDE_CODE_EFFORT_LEVEL=medium claude "$@" ;;
    low|l)        shift; ANTHROPIC_MODEL='claude-fable-5[1m]' CLAUDE_CODE_EFFORT_LEVEL=low claude "$@" ;;
    min|s|sonnet) shift; ANTHROPIC_MODEL='claude-sonnet-5' CLAUDE_CODE_EFFORT_LEVEL=low claude "$@" ;;
    help|h|-h|--help)
      command cat <<'EOF'
  cl        fable  + xhigh    дефолт: максимум ума, не торопится
  cl mid    fable  + medium   умная, но заметно быстрее
  cl low    fable  + low      умная и быстрая
  cl min    sonnet + low      самая лёгкая, для мелочей

Остальное пробрасывается в claude: cl low -c, cl mid --resume, cl -p '…'
EOF
      ;;
    *) claude "$@" ;;
  esac
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
if [ -f '/home/ivan/yandex-cloud/path.bash.inc' ]; then source '/home/ivan/yandex-cloud/path.bash.inc'; fi

# The next line enables shell command completion for yc.
if [ -f '/home/ivan/yandex-cloud/completion.zsh.inc' ]; then source '/home/ivan/yandex-cloud/completion.zsh.inc'; fi


# Открыть файл виндовым браузером из WSL (open-html report.html)
open-html() { local w; w="$(wslpath -w "${1:a}")" && (cd /mnt/c && /mnt/c/Windows/System32/cmd.exe /c start "" "$w") }
