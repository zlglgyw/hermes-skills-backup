#!/bin/bash
# qwen — quick chat with local Qwen2.5-0.5B via llama-server
# Copy to ~/bin/qwen and chmod +x
# Usage: qwen "your question"  (one-shot)
#        qwen                  (interactive)

PORT=8080
URL="http://localhost:$PORT/v1/chat/completions"

if ! curl -sf http://localhost:$PORT/v1/models > /dev/null 2>&1; then
  echo "Server not running. Start with: qwen-server start"
  exit 1
fi

if [ $# -gt 0 ]; then
  # one-shot mode
  curl -sf "$URL" -H "Content-Type: application/json" -d "{
    \"model\": \"qwen\",
    \"messages\": [{\"role\": \"user\", \"content\": \"$*\"}],
    \"max_tokens\": 256,
    \"temperature\": 0.7
  }" | python3 -c "import sys,json; print(json.load(sys.stdin)['choices'][0]['message']['content'])" 2>/dev/null
else
  # interactive mode
  echo "Qwen2.5-0.5B (local) — type 'exit' to quit"
  echo "---"
  while true; do
    printf "You: "
    read -r line
    [ "$line" = "exit" ] && break
    [ -z "$line" ] && continue
    response=$(curl -sf "$URL" -H "Content-Type: application/json" -d "{
      \"model\": \"qwen\",
      \"messages\": [{\"role\": \"user\", \"content\": \"$line\"}],
      \"max_tokens\": 256,
      \"temperature\": 0.7
    }" | python3 -c "import sys,json; print(json.load(sys.stdin)['choices'][0]['message']['content'])" 2>/dev/null)
    echo "Qwen: $response"
    echo "---"
  done
fi
