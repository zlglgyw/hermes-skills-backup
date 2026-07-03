# HuggingFace GGUF Discovery for Constrained Devices

## Tree API (no auth)

```
GET https://huggingface.co/api/models/{repo}/tree/main
```

Filter JSON for files ending in `.gguf`. Fields: `path`, `size` (bytes).

## Common repos for small models

- `Qwen/Qwen2.5-0.5B-Instruct-GGUF`
- `Qwen/Qwen2.5-1.5B-Instruct-GGUF`
- `bartowski/SmolLM-135M-Instruct-GGUF`
- `bartowski/gemma-3-1b-it-GGUF`
- `TinyLlama/TinyLlama-1.1B-Chat-v1.0-GGUF` (may not exist; check bartowski fork)

## Quant selection for <1GB budget

| Quant | Quality | Size (0.5B) | Use |
|-------|---------|-------------|-----|
| Q2_K | Low | ~395MB | Last resort |
| Q4_0 | OK | ~408MB | Tight budget |
| Q4_K_M | Good | ~468MB | **Default pick** |
| Q5_K_M | Better | ~497MB | If space allows |
| Q8_0 | Best | ~644MB | If 1.5GB+ free |

Rule of thumb: Q4_K_M unless storage forces Q2.

## llama-server command (OpenAI-compatible)

```bash
~/llama.cpp/build/bin/llama-server \
    --hf-repo Qwen/Qwen2.5-0.5B-Instruct-GGUF \
    --hf-file qwen2.5-0.5b-instruct-q4_k_m.gguf \
    -c 2048 \
    -t $(nproc) \
    --host 127.0.0.1 \
    --port 8080
```

Then test:
```bash
curl http://localhost:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"Hello"}]}'
```
