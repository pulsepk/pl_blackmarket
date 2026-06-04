fx_version 'cerulean'
game 'gta5'

author 'PulseScripts - pulsescripts.com'
version '1.2.0'

description 'Black Market Script by PulseScripts https://discord.gg/72Y7WKsP9M'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua'
}

client_script 'client/main.lua'

server_scripts {
    'server/main.lua',
    'server/location.lua'
}

dependencies {
    'ox_lib',
    'pl_lib',
}

lua54 'yes'

ui_page 'web/index.html'

files {
    'web/*'
}
