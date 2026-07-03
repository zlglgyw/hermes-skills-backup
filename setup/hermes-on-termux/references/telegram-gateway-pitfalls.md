# Telegram Gateway Pitfalls

## Bot token verified but gateway hangs on "Connecting"

Gateway uses DNS-over-HTTPS to discover Telegram fallback IPs. Can take 30-60s on slow networks. Check `~/.hermes/logs/gateway.log` for:
```
[Telegram] Connected to Telegram (polling mode)
gateway.telegram connected
```

## Verify token independently

```bash
curl -s "https://api.telegram.org/bot<TOKEN>/getMe" | python3 -m json.tool
```

If `ok: true`, token is valid. Problem is network or gateway config.

## nohup blocked

Hermes intercepts shell backgrounding (`nohup`, `disown`, `&`). Use:
```python
terminal(command="hermes gateway run", background=True, notify_on_complete=True)
```

## Gateway dies on Termux app close

Termux may be killed by Android battery optimization. Fixes:
1. Settings → Battery → Termux → Unrestricted
2. Termux:Boot plugin for auto-start
3. `termux-wake-lock` to prevent sleep

## ALLOWED_USERS must be set

Without `TELEGRAM_ALLOWED_USERS`, bot responds to anyone who finds it. Always set to your user ID. Comma-separated for multiple users.

## Commands registered but not visible

Gateway logs `60 cmds registered, 60 hidden (over 60 limit)`. Normal — Telegram limits menu size. Use `/commands` in chat for full list.
