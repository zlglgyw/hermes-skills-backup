# HuggingFace GGUF Download Workflow

Find and download GGUF models from HuggingFace.

## Search Models

### By Keyword
```bash
# Search for 128K context models
curl -sL "https://huggingface.co/api/models?search=gguf+128k&limit=10" | jq '.[].id'

# Search for specific size
curl -sL "https://huggingface.co/api/models?search=gguf+3b&limit=10" | jq '.[].id'
```

### By Tag
```bash
# Filter by llama.cpp compatible
curl -sL "https://huggingface.co/models?apps=llama.cpp&sort=trending&limit=10"
```

## Check File Sizes

### List GGUF Files in Repo
```bash
curl -sL "https://huggingface.co/api/models/<repo>/tree/main" | \
    jq '.[] | select(.path | endswith(".gguf")) | {path, size}'
```

### Get Specific File Size
```bash
curl -sI "https://huggingface.co/<repo>/resolve/main/<file>.gguf" | grep content-length
```

### Convert Bytes to Human-Readable
```bash
# Example: 1915306592 bytes = 1.83 GB
echo "scale=2; 1915306592 / 1024 / 1024 / 1024" | bc
```

## Download Methods

### curl (Recommended)
```bash
# Basic download
curl -L "https://huggingface.co/<repo>/resolve/main/<file>.gguf" \
    -o ~/models/<file>.gguf

# With progress bar
curl -L "https://huggingface.co/<repo>/resolve/main/<file>.gguf" \
    -o ~/models/<file>.gguf --progress-bar

# Resume interrupted download
curl -L -C - "https://huggingface.co/<repo>/resolve/main/<file>.gguf" \
    -o ~/models/<file>.gguf --progress-bar
```

### huggingface-cli
```bash
# Install
pip install huggingface-hub

# Download specific file
huggingface-cli download <repo> <file>.gguf --local-dir ~/models/

# Download with token (for gated models)
huggingface-cli download <repo> <file>.gguf --token $HF_TOKEN --local-dir ~/models/
```

### wget
```bash
wget "https://huggingface.co/<repo>/resolve/main/<file>.gguf" -O ~/models/<file>.gguf
```

## Find Models by Size

### Small Models (< 2GB)
```bash
curl -sL "https://huggingface.co/api/models?search=gguf+0.5b&limit=10" | jq '.[].id'
curl -sL "https://huggingface.co/api/models?search=gguf+1b&limit=10" | jq '.[].id'
```

### Medium Models (2-8GB)
```bash
curl -sL "https://huggingface.co/api/models?search=gguf+3b&limit=10" | jq '.[].id'
curl -sL "https://huggingface.co/api/models?search=gguf+7b&limit=10" | jq '.[].id'
```

### Large Models (> 8GB)
```bash
curl -sL "https://huggingface.co/api/models?search=gguf+13b&limit=10" | jq '.[].id'
curl -sL "https://huggingface.co/api/models?search=gguf+70b&limit=10" | jq '.[].id'
```

## Find Models by Context Length

### 128K Context
```bash
curl -sL "https://huggingface.co/api/models?search=gguf+128k&limit=10" | jq '.[].id'
```

### 64K Context
```bash
curl -sL "https://huggingface.co/api/models?search=gguf+64k&limit=10" | jq '.[].id'
```

## Popular Repos

### Unsloth (Optimized Models)
```bash
curl -sL "https://huggingface.co/api/models?author=unsloth&limit=10" | jq '.[].id'
```

### TheBloke (Classic GGUF)
```bash
curl -sL "https://huggingface.co/api/models?author=TheBloke&limit=10" | jq '.[].id'
```

### Bartowski (Recent Models)
```bash
curl -sL "https://huggingface.co/api/models?author=bartowski&limit=10" | jq '.[].id'
```

## Example Workflow

### Find SmolLM3 128K
```bash
# Search
curl -sL "https://huggingface.co/api/models?search=SmolLM3+128K+GGUF&limit=5" | jq '.[].id'

# Check files
curl -sL "https://huggingface.co/api/models/unsloth/SmolLM3-3B-128K-GGUF/tree/main" | \
    jq '.[] | select(.path | endswith(".gguf")) | {path, size}'

# Get Q4_K_M size
curl -sI "https://huggingface.co/unsloth/SmolLM3-3B-128K-GGUF/resolve/main/SmolLM3-3B-128K-Q4_K_M.gguf" | grep content-length

# Download
curl -L "https://huggingface.co/unsloth/SmolLM3-3B-128K-GGUF/resolve/main/SmolLM3-3B-128K-Q4_K_M.gguf" \
    -o ~/models/SmolLM3-3B-128K-Q4_K_M.gguf --progress-bar
```

## Pitfalls

1. **Large files**: GGUF files can be 1-100GB. Always check size first.
2. **Interrupted downloads**: Use `curl -C -` to resume.
3. **Rate limiting**: HuggingFace may rate limit. Add delays between requests.
4. **Gated models**: Some require HF token. Use `--token` flag.
5. **Filename mismatch**: Verify exact filename from tree API before downloading.
