const fs = require('fs');
const { format } = require('lua-json');

function writeLua(data) {
    const dataLua = format(data, {
        spaces: 2,
    });
    
    fs.writeFileSync(`../Data.lua`, dataLua.replace('return ', 'FTCData = '), { encoding: 'utf8' })
}

module.exports = writeLua;