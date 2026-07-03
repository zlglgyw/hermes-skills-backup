---
name: termux-llm
description: "Run local LLMs on Termux/Android (aarch64). Build llama.cpp, manage OOM, pick tiny models."
version: 1.0.0
author: hermes-agent
platforms: [linux]
tags: [termux, android, llama.cpp, local-llm, aarch64, mobile, oom]
---

# Termux LLM — Local Models on Android

Run GGUF models on Android via Termux. Complements `llama-cpp` skill with Android-specific pitfalls.

## When to use

- Building llama.cpp on Termux/Android (aarch64)
- Choosing tiny models that fit mobile storage/RAM
- Debugging OOM kills during builds or inference
- Running local models as a lightweight "brain" on phone/tablet

## Hardware Assessment

Always check first:

```bash
uname -m           # expect aarch64
nproc              # core count (typically 4-8)
free -h            # available RAM
df -h $HOME        # free storage (often tight: 1-5GB)
```

Key constraint: Android OOM killer is aggressive. Reported RAM (e.g. 12GB) != available RAM (~5-6GB).

## Install llama.cpp

```bash
pkg install cmake git clang
git clone --depth 1 https://github.com/ggml-org/llama.cpp
cd llama.cpp
cmake -B build -DCMAKE_BUILD_TYPE=Release -DGGML_CPU_AARCH64=ON
cmake --build build --config Release -j2
```

**CRITICAL: Always use `-j2`, never `-j$(nproc)`.** See Pitfalls below.

## Tiny Models for Mobile

Storage budget: model file + ~200MB build artifacts + inference RAM.

| Model | Quant | Size | Quality | Notes |
|-------|-------|------|---------|-------|
| Qwen2.5-0.5B | Q4_K_M | 468MB | Good for simple tasks | Best ratio |
| Gemma-3-1B | Q4_K_M | ~700MB | Better quality | Needs more storage |
| SmolLM-135M | Q4 | ~100MB | Very basic | Minimal footprint |
| TinyLlama-1.1B | Q4_K_M | ~600MB | Decent | Middle ground |

Check available GGUFs via tree API:
```bash
curl -s "https://huggingface.co/api/models/<repo>/tree/main" | python3 -c "
import sys,json
for x in json.load(sys.stdin):
    if x['path'].endswith('.gguf'):
        print(f\"{x['path']} {x.get('size',0)//1024//1024}MB\")
"
```

## Running Inference

```bash
~/llama.cpp/build/bin/llama-cli \
    -m ~/models/model.gguf \
    -n 256 -t $(($(nproc)/2)) -p "Hello"
```

Use half cores (`-t $(($(nproc)/2))`) to leave headroom for OS and other apps.

## Pitfalls

### OOM kill during build (exit code -9)

`-j$(nproc)` spawns 8+ compiler processes. Combined with Android services and other running apps, this exceeds available RAM. Both the build AND co-running processes (e.g. a gateway server) get killed.

**Always use `-j2`**. If still killed, use `-j1`. Check for zombie cmake processes before retry:

```bash
ps aux | grep cmake | grep -v grep
kill <old_pids>
```

### Zombie cmake processes

Killed cmake builds leave zombie processes that consume resources. Always clean up before rebuilding:

```bash
pkill -f "cmake --build" 2>/dev/null
```

### Storage too small

Model download + build can exceed available storage. Check with `df -h $HOME` before starting. Q4_K_M of a 0.5B model is ~468MB; build artifacts ~200MB. Total: ~700MB minimum.

### Gateway + build compete for RAM

Running a Hermes gateway alongside a llama.cpp build on the same device = OOM risk. Either:
1. Build with `-j1` while gateway runs
2. Stop gateway, build, restart gateway
3. Build during low-activity periods
