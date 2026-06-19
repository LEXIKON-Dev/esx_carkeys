fx_version 'cerulean'
game 'gta5'

author 'LEXIKON'
description 'ESX carkeys - Carkeys Steal Menu'
version '1.0.0'

shared_scripts {
    'config.lua',
    'locale/de.lua',
    'locale/en.lua',
    'locale/dan.lua',
    'locale/init.lua',
}

client_scripts {
    'client/main.lua',
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server/main.lua',
}

dependencies {
    'es_extended',
}
