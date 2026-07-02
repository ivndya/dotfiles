// OpenCode plugin — подсветка tmux-окна + Windows toast (WSL2) при завершении хода.
// Событие session.idle = ассистент закончил и ждёт тебя (аналог Claude Code Stop).
// Ставит тот же tmux-флаг @claude_alert done, что и остальные агентские CLI,
// так что подсветку 🔔 рисует существующий window-status-format в tmux.conf.

export const TmuxAlert = async ({ $ }) => {
  const home = process.env.HOME
  return {
    event: async ({ event }) => {
      if (event.type !== "session.idle") return
      if (!process.env.TMUX || !process.env.TMUX_PANE) return
      try {
        // Оранжевый 🔔 «завершил», если окно не на виду (проверка внутри helper).
        await $`${home}/.config/tmux/agent-alert.sh done`.quiet()
        // Windows toast через общий тумблер (cnotify on/off → ~/.claude/notify-off).
        await $`${home}/.claude/hooks/send-toast.sh ${"OpenCode"} ${"Агент завершил работу"}`.quiet()
      } catch {
        // Никогда не роняем плагин из-за сбоя уведомления.
      }
    },
  }
}
