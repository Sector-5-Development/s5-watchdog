-- ─────────────────────────────────────────────────────────────────────────────
-- s5-watchdog  ·  FiveM Watchdog by Sector 5 Development
-- Support: https://discord.gg/7w9NgEgvY6
-- ─────────────────────────────────────────────────────────────────────────────

Config = {}

-- ── Start here ───────────────────────────────────────────────────────────────
-- This ships FALSE on purpose.
--
-- With sending off, the resource captures your console output and tells you what
-- it saw, but makes no outbound request at all. That lets you prove capture works
-- on YOUR server before a single line leaves the box.
--
-- Leave it false for the first restart. Run /watchdog in the server console and
-- confirm it reports captured lines. Only then set this to true.
Config.SendEnabled = false

-- Your licence key. You were given this when you signed up.
-- The service rejects a wrong or missing key with a 401 and tells you nothing else.
Config.Key = 'REPLACE_WITH_YOUR_KEY'

-- The name that appears on your diagnoses in Discord. Use your server's name.
Config.ServerName = 'REPLACE_WITH_YOUR_SERVER_NAME'

-- ── You should not need to change anything below this line ───────────────────

-- Where reports are sent.
Config.Endpoint = 'https://s5-discord-bot.bryansanchez379.workers.dev/ingest'

-- How many console lines to keep and send. The service only scans the most recent
-- 2500, so sending more is wasted bandwidth.
Config.BufferLines = 2500

-- Minimum gap between sends, in seconds. FiveM logs errors constantly; without
-- this, one bad restart would bury your Discord channel. Default is 10 minutes.
Config.CooldownSeconds = 600

-- Lines that suggest something genuinely broke.
--
-- These are deliberately loose. The service stays SILENT when its rule library
-- recognises nothing, so a false trigger costs one wasted request and produces no
-- Discord noise at all. Missing a real crash is the expensive failure here, not
-- triggering too often — so do not tighten these to reduce "spam". There is none.
Config.Triggers = {
    'SCRIPT ERROR',
    'Unhandled exception',
    'data file mounter',
    'failed to instantiate',
    "couldn't be started",
    'Pool .- is full',
    'exhausted',
}
