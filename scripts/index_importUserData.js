const fs = require('fs');
const parseLua = require('./parseLua');
const getUserRoutes = require('./getUserRoutes');
const writeLua = require('./writeLua');
const { mergeDeep } = require('./mergeDeep');

// load the addon data from ../Data.lua
const addondata = parseLua(fs.readFileSync('../Data.lua', { encoding: 'utf8' }));

// load userdata from data/FlightTimerClassic-*.lua
const routes = getUserRoutes();
const routemap = new Map();

// filter relevant data: unknown routes or routes that differ more than 2 seconds
routes.filter(({start, end, duration, faction}) => {
    return typeof addondata[faction][start]?.[end] === 'number' ?
            Math.abs(duration - addondata[faction][start][end]) > 2
        : true;
})
// collect all data in a map per route
.forEach(route => {
    if(!routemap.get(route.route)) {
        routemap.set(route.route, []);
    }
    routemap.get(route.route).push(route);
});

// collect new validated data
const newdata = {};
routemap.forEach((routes, id) => {

    console.log('')
    console.log('+++', id, '+++');

    const { start, end, faction, file } = routes[0];
    const known = typeof addondata[faction][start]?.[end] !== 'undefined';
    if(!known) console.log('NEW ROUTE!', [file]);

    for(let route of routes) {
        const { start, end, duration, faction } = route;
    
        // unknown route with only one measurement
        if(!known && routes.length === 1) {
            newdata[faction] = newdata[faction] || {};
            newdata[faction][start] = newdata[faction][start] || {};
            newdata[faction][start][end] = duration;
        } else {
            console.log('what to do? Existing value:', addondata[faction][start]?.[end]);
            console.log('User values:', routes.map(r => [r.file, r.duration]));
        }
    }
});

//write to file
writeLua(mergeDeep(addondata, newdata));