# Deployment ke HP Rooted

## Sinkronisasi via GitHub

Skills di-sync lewat repo `zlglgyw/hermes-skills-backup`.

### Setup Pertama Kali
```bash
cd ~/.hermes/skills
git clone https://github.com/zlglgyw/hermes-skills-backup.git .
```

### Update
```bash
cd ~/.hermes/skills
git pull
```

### Push dari HP Rooted
```bash
cd ~/.hermes/skills
git config user.name "zlglgyw"
git config user.email "zlglgyw@users.noreply.github.com"
git add -A
git commit -m "update dari hp rooted"
git push
```

## Config Hermes di HP Rooted

### Context Length
JANGAN edit `~/.hermes/config.yaml` langsung — `patch` tool di-block.
Pakai: `hermes config edit` (vim) atau `hermes config set <key> <value>`.

### Setting Context per Model
```bash
hermes config set providers.custom.models.<path>.context_length 131072
```

### Context Recommendation
| Model | RAM | Max Context |
|-------|-----|-------------|
| Qwen2.5-0.5B | 4GB free | 128K OK |
| SmolLM3-3B | 2.5GB free | 64K max |
| Hermes-8B | 1GB free | 16-32K max |
