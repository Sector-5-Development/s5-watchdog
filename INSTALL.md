# FiveM Watchdog
### by Sector 5 Development

*FiveM servers built, optimized, and maintained right.*

---

## Install guide

Watchdog reads your server's console and, when something fatal appears, tells you **in plain
English what broke and how to fix it** — in your own Discord.

Install takes about five minutes. You do not need to edit `server.cfg` if your resources are
organised in bracket folders.

---

## Before you start

You need three things:

1. **Your licence key** — sent to you when you signed up. It looks like a long random string.
2. **A Discord webhook** for the channel you want diagnoses posted in (below).
3. **File access to your server** — FTP, SFTP or your host's file manager.

### Getting the Discord webhook

1. In Discord, open **Server Settings → Integrations → Webhooks → New Webhook**
2. Pick the channel diagnoses should land in. A private staff channel is the right choice —
   diagnoses quote raw console output, which sometimes contains player identifiers.
3. Click **Copy Webhook URL**
4. Send that URL to us. That is what routes reports to you and nowhere else.

> **The bot does not need to join your Discord.** Reports arrive through the webhook. Nobody
> gets access to your server, and we never ask for one.

---

## Step 1 — Upload the resource

Drop the `s5-watchdog` folder into your resources directory.

If you use bracket folders (`[core]`, `[standalone]`, and so on), put it inside one that is
already started with `ensure`. Then there is nothing to add to `server.cfg` at all.

If you do not use bracket folders, add this line to `server.cfg`:

```
ensure s5-watchdog
```

## Step 2 — Fill in your details

Open `s5-watchdog/config.lua` and set two values:

```lua
Config.Key        = 'the licence key we sent you'
Config.ServerName = 'Your Server Name'
```

**Leave `Config.SendEnabled` as `false` for now.** That is deliberate — see the next step.

## Step 3 — Restart and prove capture works

Restart the server, or run `refresh` then `ensure s5-watchdog` in the live console.

You should see:

```
[FiveM Watchdog] console capture active - by Sector 5 Development
[FiveM Watchdog by Sector 5 Development] started — sending false, cooldown 600s, buffer 2500 lines
```

Now type this in the **server console**:

```
watchdog
```

It reports how many console lines it has captured. If that number is above zero, capture is
working on your build.

> **Why this step exists.** `RegisterConsoleListener` is the one API Watchdog depends on that
> is not guaranteed on every FXServer build. Proving capture before enabling sending means you
> never end up wondering whether silence is "nothing broke" or "it was never working".

**If it says `RegisterConsoleListener is NOT available`**, stop here and tell us — your build
cannot support console capture and we will refund you rather than sell you something that
cannot work.

## Step 4 — Turn sending on

Set this in `config.lua`:

```lua
Config.SendEnabled = true
```

Restart the resource. That is the install finished.

## Step 5 — Confirm end to end

In the server console:

```
watchdogsend
```

That forces one report regardless of whether anything broke. Within a few seconds you should
see a message in your Discord channel.

If the service recognises nothing in your logs, **it stays silent** — that is correct
behaviour, not a failure. The console will still confirm the send succeeded.

---

## Commands

All are **server console only**. Players cannot run them and they do nothing in chat.

| Command | What it does |
|---|---|
| `watchdog` | Status — lines captured, buffer size, whether sending is on, last trigger |
| `watchdogsend` | Force one report now, ignoring the trigger list (still respects cooldown) |
| `watchdogtail 40` | Print the last 40 captured lines, to see what it is holding |

---

## What it does and does not do

**Does**
- Runs **server-side only**. Nothing runs on players' machines, nothing is streamed.
- Keeps the last 2,500 console lines in memory.
- Sends that buffer **only** when a line matches the trigger list, and at most once every
  10 minutes.

**Does not**
- Touch any other resource, your database, or any files.
- Run anything on player machines.
- Give anyone access to your server.
- Send anything at all while `Config.SendEnabled` is `false`.

**Removing it** is deleting the folder and, if you added one, the `ensure` line. Nothing is
left behind — no database tables, no config files elsewhere, no scheduled tasks.

---

## Privacy — read this bit

Watchdog sends **raw server console output**. FiveM console output can include player
identifiers such as licence and Steam IDs, and occasionally IP addresses, depending on which
resources you run.

That is why diagnoses should go to a **private staff channel**, not a public one. Choose the
webhook channel accordingly.

We store what is needed to produce your diagnosis and nothing else. We do not sell it, and we
do not use one customer's logs to serve another.

---

## Troubleshooting

**`Config.Key is not set — refusing to send`**
You left the placeholder in `config.lua`. Paste your licence key.

**`send failed, HTTP 401`**
The key is wrong, or your licence has lapsed. Check for a stray space when you pasted it.

**`send failed, HTTP 429`**
You are sending faster than your plan allows. It will resume by itself; nothing is broken.

**Nothing appears in Discord, but the console says the send succeeded**
That is the normal "we found nothing we recognise" outcome. Watchdog stays quiet rather than
guessing — a confidently wrong diagnosis is worse than no diagnosis.

**`RegisterConsoleListener is NOT available`**
Your FXServer build does not expose console capture. Tell us and we will refund you.

---

## Support

Open a ticket in the Sector 5 Development Discord: **https://discord.gg/7w9NgEgvY6**

Include your server name and, if something failed, the exact console line. That is usually
enough to fix it in one reply.

---

<div align="center">

**FiveM Watchdog** · built and maintained by **Sector 5 Development**

Server builds · script installs · vehicle packs · graphics packs · Discord buildouts

**https://discord.gg/7w9NgEgvY6**

</div>
