--[[
  FiveM Watchdog — by Sector 5 Development
  https://discord.gg/7w9NgEgvY6

  Server console capture and crash reporting.

  Keeps the last N console lines in memory. When a line looks like something
  genuinely broke, sends the buffer to the Watchdog service, which runs it
  through the FiveM Watchdog rule library and posts a plain-English diagnosis to
  the Discord channel you nominated.

  Why this direction: a Cloudflare Worker cannot reach this server. Outbound
  fetches to a bare IP are refused by Cloudflare (error 1003), and the server has
  no hostname. Outbound FROM here is ordinary HTTP and works, so the server pushes.

  Safety properties, deliberately:
    - Server-side only. Nothing runs on players' machines.
    - Read-only. Touches no other resource, no database, no files.
    - Silent by default. Config.SendEnabled starts false so capture can be proven
      before any data leaves the box.
    - Rate limited. One send per Config.CooldownSeconds, no matter what.
    - Removing it is deleting the folder and one ensure line.
]]

local buffer = {}       -- ring buffer of recent console lines
local head = 0          -- how many lines have ever been written
local lastSendAt = 0    -- os.time() of the last outbound request
local captured = 0      -- total lines seen, for the status command
local triggeredBy = nil -- the line that armed a send

--- Store a line, overwriting the oldest once the buffer is full.
local function push(line)
    head = head + 1
    buffer[(head % Config.BufferLines) + 1] = line
    captured = captured + 1
end

--- Read the buffer back in order, oldest first.
local function snapshot()
    local out, n = {}, math.min(head, Config.BufferLines)
    local start = head - n
    for i = 1, n do
        local v = buffer[((start + i) % Config.BufferLines) + 1]
        if v then out[#out + 1] = v end
    end
    return table.concat(out, '\n')
end

local function looksFatal(line)
    for _, pattern in ipairs(Config.Triggers) do
        if string.find(line, pattern) then return true end
    end
    return false
end

--- Send the buffer. `reason` is only for the local console.
local function send(reason)
    if not Config.SendEnabled then
        print(('[fivem-watchdog] would send now (%s) but Config.SendEnabled is false'):format(reason))
        return
    end
    -- Match the PREFIX, not one exact placeholder string.
    --
    -- This used to compare against 'REPLACE_WITH_INGEST_KEY' while config.lua
    -- shipped 'REPLACE_WITH_YOUR_KEY' — so the guard never fired, and a customer
    -- who forgot to paste their key sent the literal placeholder and got back a
    -- bare 401 with nothing explaining why. Any future placeholder wording is
    -- caught now, and the message says what to do rather than just refusing.
    if Config.Key == nil or Config.Key == '' or Config.Key:find('^REPLACE_WITH') then
        print('[fivem-watchdog] Config.Key is not set — refusing to send.')
        print('[fivem-watchdog] Paste the licence key you were given into Config.Key in config.lua, then restart this resource.')
        return
    end
    if Config.ServerName == nil or Config.ServerName == ''
       or Config.ServerName:find('^REPLACE_WITH') then
        -- Not fatal: a diagnosis with a placeholder name still helps, it is just
        -- unidentifiable in a Discord channel watching several servers.
        print('[fivem-watchdog] Config.ServerName is still a placeholder — your reports will be hard to identify.')
    end

    local now = os.time()
    if now - lastSendAt < Config.CooldownSeconds then
        return  -- inside cooldown; stay quiet, this is the normal case during a crash loop
    end
    lastSendAt = now

    local payload = json.encode({
        server = Config.ServerName,
        log    = snapshot(),
    })

    PerformHttpRequest(Config.Endpoint, function(status, _, _)
        if status == 202 then
            print(('[fivem-watchdog] sent (%s) — diagnosis will appear in your Discord if anything is recognised'):format(reason))
        else
            -- Never retry on failure. A crash loop plus retries is how you turn
            -- one incident into a flood.
            print(('[fivem-watchdog] send failed, HTTP %s (not retrying)'):format(tostring(status)))
        end
    end, 'POST', payload, {
        ['Content-Type'] = 'application/json',
        ['X-Watchdog-Key']     = Config.Key,
    })
end

-- ── capture ──────────────────────────────────────────────────────────────────
-- RegisterConsoleListener is the one API this resource depends on that is not
-- in FiveM's documented server-side function list. If it is missing, the resource
-- starts, captures nothing, and the status command will show 0 lines — which is
-- exactly what the capture-only step exists to find out.
if RegisterConsoleListener then
    RegisterConsoleListener(function(channel, message)
        if not message then return end
        for line in tostring(message):gmatch('[^\r\n]+') do
            if line ~= '' then
                push(line)
                if looksFatal(line) then
                    triggeredBy = line
                    send('trigger: ' .. line:sub(1, 80))
                end
            end
        end
    end)
    print('[FiveM Watchdog] console capture active - by Sector 5 Development')
else
    print('[fivem-watchdog] RegisterConsoleListener is NOT available — capture is impossible on this build')
end

-- ── console commands ─────────────────────────────────────────────────────────
-- Server console only (no player can invoke these).

RegisterCommand('watchdog', function(source)
    if source ~= 0 then return end
    print(('[fivem-watchdog] captured %d line(s) | buffer %d | sending %s | last trigger: %s')
        :format(captured,
                math.min(head, Config.BufferLines),
                Config.SendEnabled and 'ENABLED' or 'disabled (capture-only)',
                triggeredBy and triggeredBy:sub(1, 100) or 'none'))
end, true)

RegisterCommand('watchdogsend', function(source)
    if source ~= 0 then return end
    lastSendAt = 0  -- manual send bypasses the cooldown
    send('manual')
end, true)

RegisterCommand('watchdogtail', function(source, args)
    if source ~= 0 then return end
    local n = tonumber(args[1]) or 20
    local lines = {}
    for line in snapshot():gmatch('[^\n]+') do lines[#lines + 1] = line end
    print(('[fivem-watchdog] last %d of %d captured line(s):'):format(math.min(n, #lines), #lines))
    for i = math.max(1, #lines - n + 1), #lines do print('  ' .. lines[i]) end
end, true)

print(('[FiveM Watchdog by Sector 5 Development] started — sending %s, cooldown %ds, buffer %d lines')
    :format(Config.SendEnabled and 'ENABLED' or 'DISABLED (capture-only)',
            Config.CooldownSeconds, Config.BufferLines))
