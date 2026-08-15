# FiveM Watchdog

**Your server crashed. txAdmin told you it went down. Nothing told you why.**

Watchdog reads your server console, notices when something fatal appears, and sends
the recent output for diagnosis. You get a plain-English answer in your Discord —
what broke and what to do about it — instead of a log dump to scroll through at 2am.

It is not an uptime monitor. Uptime monitoring is already solved and already free.
This answers the question that comes *after* the alert.

```
Pool full: TxdStore
  Your texture pool is exhausted. This is the ceiling, not a leak — the engine
  clamps TxdStore and it cannot be raised in gameconfig.xml.
  Most likely cause: a vehicle pack added since the last clean restart.
  What to do: pull the most recently added pack and restart. If the crash
  follows a single filename every time, that car is the one.
```

That is the shape of a real diagnosis, produced from a rule library built out of
production incidents on live servers — not from documentation.

---

## What this repository contains

Everything that runs **on your server**. Three Lua files, ~200 lines, no
dependencies, no database, no exports, no events, nothing client-side.

```
fivem-watchdog/
  fxmanifest.lua
  config.lua       ← the only file you edit
  server.lua       ← ring buffer, trigger match, one HTTPS POST
```

Read all of it before you install it. That is why it is public: you should not have
to trust a black box with your console output, and "the pack looks popular" is not a
security review. A FiveM resource that phones home should be one you can audit in
five minutes.

**What is not here:** the rule library and the diagnosis engine. Those run on the
service side and are what the subscription pays for. The client is open; the brain is
the product. If you would rather write your own rules against your own logs, this
resource gives you the capture half for free and the MIT licence to do what you like
with it.

---

## Install

1. Drop the `fivem-watchdog` folder into your `resources/` directory.
2. Add `ensure fivem-watchdog` to your `server.cfg`.
3. Restart. **Leave `Config.SendEnabled = false` for this first restart.**
4. Run `/watchdog` in the server console. It reports what it captured — locally,
   with nothing sent anywhere.
5. Once you have seen it working on your own box, paste your licence key into
   `Config.Key`, set `Config.ServerName`, set `Config.SendEnabled = true`, restart.

Full detail, including what a first diagnosis looks like: [INSTALL.md](INSTALL.md).

### It ships silent on purpose

`Config.SendEnabled` starts `false`. Nothing leaves your server until you have
watched it capture your own console and decided you are happy. A tool that starts
transmitting the moment you install it has earned suspicion; this one does not ask
for trust before it has shown you anything.

---

## What gets sent

When a trigger line appears and the cooldown has elapsed, one HTTPS POST containing:

- the most recent console lines (default 2500, set by `Config.BufferLines`)
- the server name you configured
- your licence key

Nothing else. No player data, no identifiers, no IP addresses, no database
contents, no file contents. The payload is assembled in `server.lua` — it is short,
and you can confirm this yourself rather than taking this paragraph's word for it.

Sends are rate limited to one per `Config.CooldownSeconds` (default 10 minutes),
because a crash loop generates errors continuously and burying your own Discord
channel would make the tool useless.

**Silence is the design.** When the rule library recognises nothing, the service says
nothing. No "all clear" pings, no daily summaries. If Watchdog speaks, something
happened.

---

## Pricing

| | |
|---|---|
| **$25/month** per server | |
| **$250/year** per server | two months free |
| **Free** | included with any Sector 5 Development care plan |
| Setup | free |

The resource in this repository is MIT licensed and always free. The subscription is
for the diagnosis service it talks to.

**[Get a key in Discord →](https://discord.gg/7w9NgEgvY6)**

---

## Support

Open a ticket in [the Sector 5 Development Discord](https://discord.gg/7w9NgEgvY6).

Issues and pull requests against this resource are welcome. If Watchdog misdiagnosed
a crash on your server, that is the most useful thing you can report — the rule
library grows from real incidents, and yours would make it better for everyone
running it.

---

Built by **Sector 5 Development** — FiveM deployment, script installs, and server work.
