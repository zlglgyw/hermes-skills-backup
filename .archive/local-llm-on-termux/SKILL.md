---
name: local-llm-on-termux
description: "Run local LLMs (llama.cpp + GGUF) on Android via Termux. Build, model selection, OOM management, gateway coexistence."
version: 1.0.0
author: hermes
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [termux, android, llama.cpp, gguf, local-inference, mobile, aarch64]
---

# Local LLM on Termux (Android)

Run GGUF models locally on Android phones via Termux + llama.cpp.

## Prerequisites

```bash
pkg install cmake git clang
```

All three are in Termux stable repo. No `brew` or system package manager.

## Build llama.cpp

```bash
git clone --depth 1 https://github.com/ggml-org/llama.cpp.git
cd llama.cpp
cmake -B build -DCMAKE_BUILD_TYPE=Release -DGGML_CPU_AARCH64=ON
cmake --build build --config Release -j2   # see OOM section
```

`-DGGML_CPU_AARCH64=ON` enables ARM NEON optimizations. Critical for perf on phones.

### Pitfall: Build parallelism vs OOM

Phones have 6-8 cores but limited RAM (4-12GB). `-j$(nproc)` WILL OOM-kill if other heavy processes (hermes gateway, browser) run simultaneously.

**Strategy**: stop competing processes first, then build at full parallelism:

```bash
hermes gateway stop   # or pkill -f "hermes gateway"
cmake --build build --config Release -j$(nproc)
# restart gateway after build
```

If user insists on max speed ("pake full, abaikan yang lain"), do it — just kill gateway first to free ~200MB.

**Safe fallback** if gateway must stay: `-j2` works but 3-4x slower.

### Pitfall: `tail -N` pipe hides progress

`cmake --build ... 2>&1 | tail -20` produces ZERO output until build finishes. Use this for background builds where you poll status via `ls build/bin/`. For foreground where user watches, drop the pipe.

### Pitfall: Partial build is usable

`llama-cli` and `llama-server` build early. You don't need to wait for all 48+ binaries. Check with:
```bash
ls build/bin/llama-cli build/bin/llama-server 2>/dev/null
```

## Model Selection for Low Storage

Typical phone: 1-5GB free storage after Termux + deps.

| Model | Q4_K_M Size | Quality | Speed (8-core aarch64) |
|-------|-------------|---------|----------------------|
| Qwen2.5-0.5B | 468MB | OK for simple tasks | ~20 tok/s gen, ~50 tok/s prompt |
| SmolLM-135M | ~100MB | Very basic | Very fast |
| Gemma-3-1B | ~700MB | Good for size | ~12 tok/s |
| TinyLlama-1.1B | ~600MB | Decent | ~15 tok/s |

**Recommendation for tight storage**: Qwen2.5-0.5B Q4_K_M. Best quality/size ratio under 500MB.

## Running

### One-shot generation
```bash
~/llama.cpp/build/bin/llama-cli \
  -m ~/models/model.gguf \
  -p "Your prompt here" \
  -n 100 \
  --no-display-prompt \
  -e  # use this if prompt needs special formatting
```

### Pitfall: Interactive mode trap

`llama-cli -p "prompt"` enters interactive mode after generation, printing infinite empty `>` prompts. Use `--no-display-prompt` and set `-n` (max tokens). For non-interactive one-shot, also add `--log-disable` to reduce noise.

### OpenAI-compatible server
```bash
~/llama.cpp/build/bin/llama-server \
  -m ~/models/model.gguf \
  -c 2048 \
  --host 0.0.0.0 \
  --port 8080
```

Test:
```bash
curl http://localhost:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"messages": [{"role": "user", "content": "hello"}]}'
```

## Downloading GGUF from HuggingFace

Find available quants via tree API:
```bash
curl -s "https://huggingface.co/api/models/<repo>/tree/main" | \
  python3 -c "import sys,json; [print(f'{x[\"path\"]} {x.get(\"size\",0)//1024//1024}MB') for x in json.load(sys.stdin) if x['path'].endswith('.gguf')]"
```

Download:
```bash
mkdir -p ~/models
curl -L -o ~/models/file.gguf "https://huggingface.co/<repo>/resolve/main/<file>.gguf"
```

## Gateway Coexistence

When hermes gateway runs alongside llama-server, watch total RAM. Both together can easily OOM on 4-8GB devices. Options:
- Run gateway OR local model, not both simultaneously
- Use very small models (0.5B) if both needed
- Set llama-server `--n-gpu-layers 0` (CPU only, lower memory)
