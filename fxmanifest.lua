fx_version 'cerulean'
game 'gta5'

description 'Black Market Script'
author 'PulseScripts'
version '1.0.0'

description 'Black Market Script by PulseScripts https://discord.gg/72Y7WKsP9M'

shared_script 'config.lua'
client_script 'client.lua'
server_script 'server.lua'

lua54 'yes'

ui_page 'web/index.html'

files {
    'web/*'
}