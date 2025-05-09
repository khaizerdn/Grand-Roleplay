fx_version 'cerulean'
game 'gta5'

author 'YourNameHere'
description 'Custom addon vehicle for FiveM'
version '1.0.0'

-- Meta files
files {
    'data/carcols.meta',
    'data/carvariations.meta',
    'data/dlctext.meta',
    'data/handling.meta',
    'data/vehicles.meta',
    'data/vehiclelayouts.meta'
}

-- Associate data files with their respective types
data_file 'HANDLING_FILE'            'data/handling.meta'
data_file 'VEHICLE_METADATA_FILE'    'data/vehicles.meta'
data_file 'CARCOLS_FILE'             'data/carcols.meta'
data_file 'VEHICLE_VARIATION_FILE'   'data/carvariations.meta'
data_file 'DLCTEXT_FILE'             'data/dlctext.meta'
data_file 'VEHICLE_LAYOUTS_FILE'      'data/vehiclelayouts.meta'

-- Stream folder (optional): place your .yft/.ytd models here
-- No need to list stream files explicitly
