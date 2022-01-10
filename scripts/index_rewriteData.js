const fs = require('fs');
const writeLua = require('./writeLua');
const parseLua = require('./parseLua');

// load the addon data from ../Data.lua
const addondata = parseLua(fs.readFileSync('../Data.lua', { encoding: 'utf8' }));

// format and write it again to ../Data.lua
writeLua(addondata);