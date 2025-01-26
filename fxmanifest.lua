fx_version 'cerulean'
game 'gta5'
lua54 'yes'
name 'drfx-clothingbag'
description 'Clothing Bag For DrFx Store'
author 'DrFx'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_scripts {
    'client/*.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua',
}