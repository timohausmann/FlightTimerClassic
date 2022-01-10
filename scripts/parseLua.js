const { parse } = require('lua-json');

module.exports = function parseLua(code) {
    const parts = code.split(' = ');
    parts.shift();
    return parse('return ' + parts.join(' = ').split('FTCConfig')[0]);
}