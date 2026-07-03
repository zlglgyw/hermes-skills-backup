---
name: local-llm-setup
description: Setup local LLM with llama.cpp + Hermes custom provider integration. Download GGUF, configure server, auto-start, memory estimation.
version: 1.0.0
author: Hermes Agent
tags: [llama.cpp, gguf, local-llm, hermes, custom-provider, auto-start, termux]
platforms: [linux, macos, android]
---

# Local LLM Setup

End-to-end workflow for running local GGUF models with Hermes Agent integration.

## When to Use

- Download and setup GGUF models from HuggingFace
- Configure llama-server for local inference
- Integrate local models as Hermes custom providers
- Setup auto-start and monitoring scripts
- Estimate memory requirements for context length

## Quick Start

### 1. Download Model

```bash
# Check file size
curl -sI "https://huggingface.co/<repo>/resolve/main/<file>.gguf" | grep content-length

# Download
curl -L "https://huggingface.co/<repo>/resolve/main/<file>.gguf" \
    -o ~/models/<file>.gguf --progress-bar
```

### 2. Start Server

```bash
~/llama.cpp/build/bin/llama-server \
    -m ~/models/model.gguf \
    --host 0.0.0.0 \
    --port 8080 \
    -c 65536 \
    -ngl 0 \
    --threads 4
```

### 3. Configure Hermes

```yaml
# ~/.hermes/config.yaml
custom_providers:
  - name: local
    base_url: http://localhost:8080/v1
    model: ~/models/model.gguf
    models:
      ~/models/model.gguf:
        context_length: 65536
```

```bash
hermes config set model.default local
hermes config set model.provider custom
```

### 4. Test

```bash
curl -s http://localhost:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"hi"}],"max_tokens":20}'
```

## Memory Estimation

### Formula
```
Total RAM ≈ Model Size + KV Cache + Overhead
```

### KV Cache (simplified)
- 0.5B-1B params, 65K context: ~0.5-1 GB
- 3B params, 65K context: ~2-3 GB
- 8B params, 16K context: ~1.5 GB
- 8B params, 65K context: ~6-7 GB ← needs ~11GB total with model

### Real-World on 11GB RAM (Termux)
```
SmolLM3-3B Q4_K_M (1.8GB) + 64K ctx  → ~5GB total  ✓
Qwen2.5-0.5B Q4_K_M (468MB) + 64K ctx → ~2GB total  ✓
Hermes-3-8B Q4_K_M (4.6GB) + 16K ctx  → ~6GB total  ✓
Hermes-3-8B Q4_K_M (4.6GB) + 64K ctx  → ~11GB total ✗ OOM
```

### Rule of Thumb
```
Max Context ≈ (Available RAM - Model Size) / 0.1 MB per 1K tokens (8B)
Max Context ≈ (Available RAM - Model Size) / 0.05 MB per 1K tokens (3B)
```

Check actual available: `free -h` → "available" column, not "free".

## Auto-Start Scripts

### Start Script
```bash
#!/bin/bash
# ~/start-llm.sh
MODEL=~/models/model.gguf
PORT=8080
CONTEXT=65536

pkill -f "llama-server.*${PORT}" 2>/dev/null
sleep 1

nohup ~/llama.cpp/build/bin/llama-server \
    -m "$MODEL" --host 0.0.0.0 --port "$PORT" \
    -c "$CONTEXT" -ngl 0 --threads 4 \
    &>~/tmp/llama-server.log &

echo "Server started (pid: $!)"
```

### Monitor Script
```bash
#!/bin/bash
# ~/monitor-llm.sh
if ! curl -s http://localhost:8080/health >/dev/null 2>&1; then
    echo "Server down, restarting..."
    ~/start-llm.sh
fi
```

### Cron Jobs
```bash
# Daily restart
hermes cron create --name llm-restart \
    --schedule "0 0 * * *" \
    --script "pkill -f 'llama-server.*8080'; sleep 2; ~/start-llm.sh"

# Monitor every 5 minutes
crontab -e
# Add: */5 * * * * ~/monitor-llm.sh
```

## Multiple Providers

```yaml
custom_providers:
  - name: small
    base_url: http://localhost:8080/v1
    model: ~/models/qwen2.5-0.5b.gguf
    models:
      ~/models/qwen2.5-0.5b.gguf:
        context_length: 32768
  
  - name: large
    base_url: http://localhost:8081/v1
    model: ~/models/llama-3-8b.gguf
    models:
      ~/models/llama-3-8b.gguf:
        context_length: 131072
```

Switch: `hermes config set model.default small`

## Search Models

```bash
# API search
curl -sL "https://huggingface.co/api/models?search=gguf+128k&limit=10" | jq '.[].id'

# Check sizes
curl -sL "https://huggingface.co/api/models/<repo>/tree/main" | \
    jq '.[] | select(.path | endswith(".gguf")) | {path, size}'
```

## Pitfalls

1. **Context mismatch**: `-c` flag must match `context_length` in config
2. **Port conflicts**: Check `lsof -i :8080` before starting
3. **RAM exhaustion**: Monitor with `free -h` during inference
4. **Slow downloads**: HuggingFace can be slow; use `--progress-bar`
5. **Termux /tmp**: Use `~/tmp` instead of `/tmp` on Android/Termux
6. **Log location**: Always use `~/tmp/` for logs on Termux
7. **Build threads**: Use `-j2` or `-j4` on Termux to avoid OOM during build
8. **--mlock on Termux**: Don't use `--mlock` on Android/Termux — it tries to pin all model memory and causes heavy swapping or OOM. Let the OS manage paging.
9. **External storage paths**: Model can be loaded directly from `/storage/emulated/0/Download/ai/` — no need to copy to `~/models/` first. Works fine, saves disk space.
10. **Language support**: SmolLM3 is English-only. Qwen2.5 series supports Indonesian/multilingual. Choose model based on required language.

## References

- **[termux-setup.md](references/termux-setup.md)** - Android/Termux quirks, boot scripts, memory limits
- **[download-workflow.md](references/download-workflow.md)** - HuggingFace search, file size checks, download methods
