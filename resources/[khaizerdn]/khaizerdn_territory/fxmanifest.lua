fx_version 'cerulean'
game 'gta5'
lua54 'yes'

description 'QBOX - Fallout Hacking with Blip Customization'
author 'YourName'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

dependencies {
    'ox_lib',
    'fallouthacking'
}
