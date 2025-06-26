fx_version 'cerulean'
game 'gta5'

description 'Black Market Script'
author 'PulseScripts'
version '1.0.4'

description 'Black Market Script by PulseScripts https://discord.gg/72Y7WKsP9M'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_script 'client/main.lua'
server_script 'server/main.lua'

dependencies {
    'ox_lib',
}

lua54 'yes'

ui_page 'web/index.html'

files {
    'web/*'
}