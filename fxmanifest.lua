fx_version 'cerulean'
use_experimental_fxv2_oal 'yes'
game 'gta5'
lua54 'yes'

description 'nass_carplay'
author 'Nass#1411'
version '1.1.0'

server_scripts { 'server/*.lua' }

client_scripts { 'client/*.lua' }

ui_page 'html/index.html'
files { 
  "html/*",
}

dependencies {
	'xsound',
}
