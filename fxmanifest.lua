fx_version 'cerulean'
game 'gta5'

name 'qb-blackmarket'
description 'Sistema de Mercado Negro Avançado para QBCore/QBox'
author 'Seu Nome'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/script.js',
    'html/style.css',
    'html/tablet.png'
}

dependencies {
    'qb-core',
    'ox_lib',
    'ox_inventory'
}
