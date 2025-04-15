fx_version 'cerulean'
game 'gta5'

author 'khaizerdn'
description 'QBCore HTML Notification System'
version '1.0.1'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/styles.css',
    'html/script.js',
    'html/sounds/notify.mp3'
}

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

dependencies {
    'qb-core'
}

exports {
    'ShowNotification',
    'ShowAdvancedNotification',
    'ShowHelpNotification',
    'ClearHelpNotification'
}