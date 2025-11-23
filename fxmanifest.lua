author "Moritz"
description "KL4M3R Handcuffs, umgeschrieben zu Kabelbindern"
version '1.3'

client_script {
    "Config.lua",
    "client.lua",
}

server_scripts {
    "Config.lua",
    "server.lua",
}
shared_script '@ox_lib/init.lua'
shared_script '@es_extended/imports.lua'

fx_version "bodacious"
games {"gta5"}
lua54 'yes'


