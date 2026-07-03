#!/bin/bash
# qwen-server — start/stop/status for local llama-server
# Copy to ~/bin/qwen-server and chmod +x

SERVER_BIN="$HOME/llama.cpp/build/bin/llama-server"
MODEL="$HOME/models/qwen2.5-0.5b-instruct-q4_k_m.gguf"
PID_FILE="$HOME/.local/run/qwen-server.pid"
LOG_FILE="$HOME/.local/log/qwen-server.log"
PORT=8080

mkdir -p "$(dirname "$PID_FILE")" "$(dirname "$LOG_FILE")"

case "${1:-start}" in
  start)
    if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
      echo "Already running (PID $(cat "$PID_FILE"))"
      exit 0
    fi
    echo "Starting Qwen2.5-0.5B on :$PORT ..."
    "$SERVER_BIN" -m "$MODEL" --host 0.0.0.0 --port $PORT -c 2048 -ngl 0 \
      > "$LOG_FILE" 2>&1 &
    echo $! > "$PID_FILE"
    sleep 3
    if kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
      echo "OK (PID $(cat "$PID_FILE")) — http://localhost:$PORT/v1"
    else
      echo "FAILED — check $LOG_FILE"
      exit 1
    fi
    ;;
  stop)
    if [ -f "$PID_FILE" ]; then
      kill "$(cat "$PID_FILE")" 2>/dev/null
      rm -f "$PID_FILE"
      echo "Stopped"
    else
      echo "Not running"
    fi
    ;;
  status)
    if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
      echo "Running (PID $(cat "$PID_FILE"))"
    else
      echo "Not running"
    fi
    ;;
  *)
    echo "Usage: qwen-server [start|stop|status]"
    ;;
esac
