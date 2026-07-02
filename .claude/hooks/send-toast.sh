#!/usr/bin/env bash
# Обёртка над Windows toast (toast.ps1) с тумблером включения/выключения.
# Уведомления ВЫКЛючены, если существует файл ~/.claude/notify-off.
# Управление из шелла: cnotify on|off|status (функция в ~/.zshrc).
# Использование: send-toast.sh "<Title>" "<Message>"

# Тумблер: если уведомления выключены — тихо выходим (tmux-подсветка не зависит от этого).
[ -f "$HOME/.claude/notify-off" ] && exit 0

title="${1:-Claude Code}"
message="${2:-}"

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ps1_win=$(wslpath -w "${script_dir}/toast.ps1")

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$ps1_win" \
  -Title "$title" -Message "$message" >/dev/null 2>&1

exit 0
