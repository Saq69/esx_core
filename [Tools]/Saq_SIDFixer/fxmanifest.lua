fx_version 'cerulean'
game 'gta5'

author 'Saq'
description 'Fix Users with Null SID'
version '1.0.0'

server_scripts {
    'server.lua',
    '@mysql-async/lib/MySQL.lua' 
}

dependencies {
    'mysql-async'
}
