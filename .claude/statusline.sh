#!/bin/bash
# Claude Code statusLine для команды TrueStats.
#
# Показывает в одну строку:
#   ~/p/g/t/ai-toolkit (main) | Opus 4.6 • ctx 9% | 🔥 5h 80% (~1h23m) • 7d 28% (~2d21h)
#
# - Промежуточные папки сжаты до первой буквы (последняя — полная)
# - Текущая git-ветка
# - Название модели (обрезано до 10 символов)
# - % использования контекстного окна
# - 🔥 — индикатор peak hours Anthropic (будни 13:00-19:00 UTC = 16:00-22:00 МСК).
#       Локальная TZ определяется автоматически.
# - % rate-limit за 5 часов и время до сброса окна
# - % rate-limit за 7 дней и время до сброса недельного окна
#
# Подключение: положить в ~/.claude/statusline.sh + добавить в ~/.claude/settings.json:
#   {
#     "statusLine": { "type": "command", "command": "bash ~/.claude/statusline.sh" }
#   }
#
# Зависимости: bash, jq, git (опционально для отображения ветки), GNU date
#
# Конфигурация (опциональные env-переменные):
#   CLAUDE_STATUSLINE_PEAK_HOURS_LOCAL  диапазон peak-часов в ЛОКАЛЬНОЙ TZ
#                                       (формат "10-19"); если не задан — берутся
#                                       Anthropic-defaults: 13:00-19:00 UTC
#                                       (= 16:00-22:00 МСК), TZ — автоматически
#   CLAUDE_STATUSLINE_PEAK_DAYS         дни недели для peak (1=пн..7=вс), дефолт "1-5"
#   CLAUDE_STATUSLINE_PEAK_ICON         значок peak-часов, дефолт 🔥
#   CLAUDE_STATUSLINE_MODEL_MAXLEN      макс. длина имени модели, дефолт 10

# Read JSON input from stdin and extract all needed fields in one jq call
input=$(cat)
eval "$(echo "$input" | jq -r '
  @sh "cwd=\(.workspace.current_dir // .cwd // ".")",
  @sh "model_name=\(.model.display_name // "?")",
  @sh "ctx_pct=\(.context_window.used_percentage // 0 | floor)",
  @sh "rl5h_pct=\(.rate_limits.five_hour.used_percentage // 0 | floor)",
  @sh "rl5h_resets=\(.rate_limits.five_hour.resets_at // 0)",
  @sh "rl7d_pct=\(.rate_limits.seven_day.used_percentage // 0 | floor)",
  @sh "rl7d_resets=\(.rate_limits.seven_day.resets_at // 0)"
')"

# ----- path: convert to ~/ form, then shrink intermediate dirs to first char -----
home_path="${cwd/#$HOME/\~}"
IFS='/' read -ra _parts <<< "$home_path"
_last_idx=$((${#_parts[@]} - 1))
shortened_path=""
for i in "${!_parts[@]}"; do
    p="${_parts[$i]}"
    if [ "$i" -eq 0 ]; then
        shortened_path="$p"
    elif [ "$i" -eq "$_last_idx" ]; then
        shortened_path+="/$p"
    else
        if [[ "$p" == .* ]]; then
            shortened_path+="/${p:0:2}"
        else
            shortened_path+="/${p:0:1}"
        fi
    fi
done

# ----- shorten model name -----
# Strip " (...)" suffix first ("Opus 4.6 (1M context)" -> "Opus 4.6"),
# then truncate to MAXLEN with ellipsis.
model_maxlen="${CLAUDE_STATUSLINE_MODEL_MAXLEN:-10}"
short_model="${model_name%% (*}"
if [ "${#short_model}" -gt "$model_maxlen" ]; then
    short_model="${short_model:0:$((model_maxlen - 1))}…"
fi

# ----- git branch -----
git_branch=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null)
    [ -n "$branch" ] && git_branch=" (\033[36m$branch\033[0m)"
fi

# ----- color helper: red if >=80, yellow if >=50, default otherwise -----
colorize_pct() {
    local pct="$1"
    local label="$2"
    if [ "$pct" -ge 80 ]; then
        printf "\033[31m%s%s%%\033[0m" "$label" "$pct"
    elif [ "$pct" -ge 50 ]; then
        printf "\033[33m%s%s%%\033[0m" "$label" "$pct"
    else
        printf "%s%s%%" "$label" "$pct"
    fi
}

ctx_info=$(colorize_pct "$ctx_pct" "ctx ")
rl5h_info=$(colorize_pct "$rl5h_pct" "5h ")
rl7d_info=$(colorize_pct "$rl7d_pct" "7d ")

# ----- peak-hours marker -----
# Default: Anthropic-documented peak window = weekdays 13:00-19:00 UTC.
# Comparison is done via UNIX timestamps so it always works correctly
# in any local TZ — пользователь ничего не настраивает.
# Override: задать локальные часы через CLAUDE_STATUSLINE_PEAK_HOURS_LOCAL="10-19".
now_ts=$(date +%s)
peak_days="${CLAUDE_STATUSLINE_PEAK_DAYS:-1-5}"
peak_day_start="${peak_days%-*}"
peak_day_end="${peak_days#*-}"

if [ -n "$CLAUDE_STATUSLINE_PEAK_HOURS_LOCAL" ]; then
    # Локальный override: парсим "START-END", считаем сегодняшние границы в локальной TZ
    peak_start_h="${CLAUDE_STATUSLINE_PEAK_HOURS_LOCAL%-*}"
    peak_end_h="${CLAUDE_STATUSLINE_PEAK_HOURS_LOCAL#*-}"
    today_local=$(date +%Y-%m-%d)
    peak_start_ts=$(date -d "${today_local} ${peak_start_h}:00:00" +%s 2>/dev/null)
    peak_end_ts=$(date -d "${today_local} ${peak_end_h}:00:00" +%s 2>/dev/null)
    dow=$(date +%u)
else
    # Anthropic default: 13:00-19:00 UTC будни (UTC date для согласованности)
    today_utc=$(date -u +%Y-%m-%d)
    peak_start_ts=$(date -d "${today_utc}T13:00:00Z" +%s 2>/dev/null)
    peak_end_ts=$(date -d "${today_utc}T19:00:00Z" +%s 2>/dev/null)
    dow=$(date -u +%u)
fi

peak_marker=""
if [ -n "$peak_start_ts" ] && [ -n "$peak_end_ts" ] \
   && [ "$dow" -ge "$peak_day_start" ] && [ "$dow" -le "$peak_day_end" ] \
   && [ "$now_ts" -ge "$peak_start_ts" ] && [ "$now_ts" -lt "$peak_end_ts" ]; then
    peak_marker="${CLAUDE_STATUSLINE_PEAK_ICON:-🔥} "
fi

# ----- reset countdown for 5h limit -----
reset_in=""
if [ -n "$rl5h_resets" ] && [ "$rl5h_resets" -gt "$now_ts" ] 2>/dev/null; then
    diff=$((rl5h_resets - now_ts))
    h=$((diff / 3600))
    m=$(((diff % 3600) / 60))
    if [ "$h" -gt 0 ]; then
        reset_in=" (~${h}h${m}m)"
    else
        reset_in=" (~${m}m)"
    fi
fi

# ----- reset countdown for 7d limit (days + hours) -----
reset_in_7d=""
if [ -n "$rl7d_resets" ] && [ "$rl7d_resets" -gt "$now_ts" ] 2>/dev/null; then
    diff=$((rl7d_resets - now_ts))
    d=$((diff / 86400))
    h=$(((diff % 86400) / 3600))
    if [ "$d" -gt 0 ]; then
        reset_in_7d=" (~${d}d${h}h)"
    else
        m=$(((diff % 3600) / 60))
        reset_in_7d=" (~${h}h${m}m)"
    fi
fi

# ----- final output -----
echo -e "${shortened_path}${git_branch} | ${short_model} • ${ctx_info} | ${peak_marker}${rl5h_info}${reset_in} • ${rl7d_info}${reset_in_7d}"
