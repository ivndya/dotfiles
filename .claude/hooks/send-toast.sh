#!/usr/bin/env bash
# Обёртка над Windows toast (toast.ps1) с тумблером включения/выключения.
# ТОЛЬКО WSL. На macOS тосты не нужны (решение Ивана 2026-08-31) — там скрипт
# ничего не делает, сигнал даёт подсветка вкладки tmux (agent-alert.sh).
# Уведомления ВЫКЛючены, если существует файл ~/.claude/notify-off.
# Управление из шелла: cnotify on|off|status (функция в ~/.zshrc).
# Использование: send-toast.sh "<Title>" "<Message>"

# Тумблер: если уведомления выключены — тихо выходим (tmux-подсветка не зависит от этого).
[ -f "$HOME/.claude/notify-off" ] && exit 0

title="${1:-Claude Code}"
message="${2:-}"

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Не WSL (нет wslpath/powershell.exe) — молча выходим: нативных уведомлений
# на других системах не делаем.
command -v wslpath >/dev/null 2>&1 && command -v powershell.exe >/dev/null 2>&1 || exit 0

ps1_win=$(wslpath -w "${script_dir}/toast.ps1")
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$ps1_win" \
  -Title "$title" -Message "$message" >/dev/null 2>&1

exit 0
