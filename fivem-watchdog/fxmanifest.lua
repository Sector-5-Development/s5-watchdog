fx_version 'cerulean'
game 'gta5'

name 'fivem-watchdog'
author 'Sector 5 Development'
description 'FiveM Watchdog by Sector 5 Development - captures server console output and sends it for crash diagnosis when something fatal appears.'
version '1.0.0'

-- Server-side only. Nothing runs on players' machines, nothing is streamed,
-- no exports, no events, no database. It reads console output and, when
-- enabled, makes one outbound HTTPS request.
server_scripts {
    'config.lua',
    'server.lua',
}
