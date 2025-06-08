fx_version 'cerulean'
game "rdr3"
rdr3_warning "I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships."
lua54 'yes'
author "Mack-phil Original By adnanberandai"

shared_scripts {
    'config.lua',
	'@ox_lib/init.lua',
}

client_scripts {
    'client/*.lua',
}

server_scripts {
    'server/*.lua'
}

dependencies {
    'rsg-core',
    'rsg-target',
	'ox_lib',
}