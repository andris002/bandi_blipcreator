fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Bandi'

client_script 'client.lua'
server_script 'server.lua'

shared_script 'config.lua'
shared_script '@ox_lib/init.lua'
shared_script 'blipdata.lua'

ui_page 'ui/index.html'
files {
    'blips.json',
    'ui/*.*'
}