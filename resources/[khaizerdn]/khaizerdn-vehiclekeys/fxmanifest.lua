fx_version 'cerulean'
game 'gta5'

author 'Your Name'
description 'A vehicle key system using ox_inventory, with key items and lock/unlock functionality'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

dependencies {
    'ox_lib',
    'ox_inventory',
    'qbx_core' -- Adjust if using a different framework
}

lua54 'yes'