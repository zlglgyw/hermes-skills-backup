# Termux-Specific Setup

Android/Termux quirks for local LLM setup.

## Environment

- Architecture: aarch64 (ARM64)
- RAM: Typically 6-12GB (5-8GB usable)
- Storage: Limited (~1-5GB free typical)
- Home: /data/data/com.termux/files/home

## Pitfalls

### /tmp Directory
**Problem**: `/tmp` may not exist or be writable on Termux.

**Fix**: Use `~/tmp` instead.
```bash
mkdir -p ~/tmp
# Use ~/tmp/llama-server.log instead of /tmp/llama-server.log
```

### Build OOM
**Problem**: Building llama.cpp with `-j8` causes OOM kills.

**Fix**: Use `-j2` or `-j4`.
```bash
cmake -B build
cmake --build build -j2
```

### Storage Space
**Problem**: Models can fill storage quickly.

**Check**:
```bash
df -h ~
ls -lh ~/models/
```

**Cleanup**:
```bash
rm ~/models/old-model.gguf
```

### Process Limits
**Problem**: Too many background processes crash system.

**Fix**: Limit concurrent servers to 1-2.

## Recommended Settings (11GB RAM device)

### Small Models (< 2GB, e.g. Qwen2.5-0.5B, SmolLM3-3B)
```bash
llama-server -m model.gguf -c 65536 --threads 4
```

### Large Models (> 4GB, e.g. 8B Q4_K_M)
```bash
# 16K context works, 64K OOMs on 11GB device
llama-server -m model.gguf -c 16384 --threads 4
```

### Flags to Avoid
- `--mlock`: causes heavy swap/OOM on Android
- `-ngl 99`: no GPU on most Termux builds, ignored silently

## Auto-Start on Termux

### Termux:Boot
Install Termux:Boot from F-Droid.

Add boot script:
```bash
mkdir -p ~/.termux/boot
cat > ~/.termux/boot/start-llm.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
~/start-llm.sh
EOF
chmod +x ~/.termux/boot/start-llm.sh
```

### Cron Alternative
```bash
# In Termux, use hermes cron instead of system crontab
hermes cron create --name llm-autostart \
    --schedule "@reboot" \
    --script "~/start-llm.sh"
```

## Download Tips

### Resume Interrupted Downloads
```bash
curl -L -C - "https://huggingface.co/<repo>/resolve/main/<file>.gguf" \
    -o ~/models/<file>.gguf --progress-bar
```

### Download to SD Card (if available)
```bash
# Check mount points
df -h | grep /storage

# Download to external storage
curl -L "..." -o /storage/emulated/0/Download/model.gguf
```

## Monitoring

### Check Server Status
```bash
curl -s http://localhost:8080/health
```

### Check Memory Usage
```bash
free -h
```

### Check Server Logs
```bash
tail -f ~/tmp/llama-server.log
```

### Kill Server
```bash
pkill -f "llama-server.*8080"
```
