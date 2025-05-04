fx_version 'adamant'

game 'gta5'

description 'Estlandia Elevators'

version '1.0.0'

lua54 'yes'

shared_script '@ox_lib/init.lua'

client_scripts {
  'config.lua',
  'client.lua',
}


escrow_ignore {
  'client.lua',
  'config.lua'
  }


