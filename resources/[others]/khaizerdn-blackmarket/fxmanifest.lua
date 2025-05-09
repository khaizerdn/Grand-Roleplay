fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Your Name'
description 'Black Market with Configurable Ped and ox_inventory Shop'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}

dependencies {
    'ox_inventory',
    'ox_target',
    'ox_lib'
}