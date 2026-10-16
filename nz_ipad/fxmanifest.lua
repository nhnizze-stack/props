fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'nz-ipad'
author 'Helsingborg Roleplay'
description 'iPad Pro (Space Black / Silver) som handprop: använd föremålet i ox_inventory för att hålla den, använd igen (eller X) för att lägga undan. Byggs från C:\\Mlo Creation\\IPAD_build'
version '1.0.0'

client_script 'client.lua'

files {
    'stream/nz_ipad.ytyp',
    'icons/*.png',   -- föremålsikoner (ox_inventory)
}

data_file 'DLC_ITYP_REQUEST' 'stream/nz_ipad.ytyp'
