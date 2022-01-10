const fs = require('fs');
const parseLua = require('./parseLua');
const getUserRoutes = require('./getUserRoutes');

// load the addon data from ../Data.lua
const addondata = parseLua(fs.readFileSync('../Data.lua', { encoding: 'utf8' }));

// load userdata from data/FlightTimerClassic-*.lua
const routes = getUserRoutes();
const routemap = new Map();
const newdata = {};

routes.filter(({start, end, duration, faction}) => {
    return typeof addondata[faction][start]?.[end] === 'number' ?
            Math.abs(duration - addondata[faction][start][end]) > 2
        : true;
})
.forEach(route => {
    if(!routemap.get(route.route)) {
        routemap.set(route.route, []);
    }
    routemap.get(route.route).push(route);
});

routemap.forEach((routes, id) => {

    const { start, end, duration, faction } = routes[0];

    const known = typeof addondata[faction][start]?.[end] !== 'undefined';

    // unknown route with only one measurement
    if(!known && routes.length === 1) {
        newdata[faction] = newdata[faction] || {};
        newdata[faction][start] = duration;
    } else {
        console.log('what to do?');
        console.log(id);
        console.log(routes.map(r => r.duration));
        if(known) console.log(addondata[faction][start][end]);
    }
});




// filter out unwanted data
// - not in the list of points
// - olready in FTC and diff <= 2 
/*
routes
        .map((endPoints, startPoint) => endPoints.map((duration, endPoint) => {
            
            console.log(startPoint, endPoint, duration);
            }))
        .flat()
        .filter((route) => {
            console.log(route);
            return addondata[route.start]?.[route.end] && addondata[route.start][route.end] >= 2;
        })
        .forEach(route => {
            if(!routemap.get(route.route)) {
                routemap.set(route.route, []);
            }
            
            routemap.get(route.route).push(route);
        });
        

//routemap.forEach(console.log);

// 

// 


// 

// find new data 

// 

function createRoute() {

}
*/
