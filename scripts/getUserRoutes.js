const fs = require('fs');
const { getName } = require('./taxinodes');
const parseLua = require('./parseLua');

module.exports = () => fs.readdirSync('./data')
        .filter(file => file.endsWith('.lua'))
        .map(file => parseLua(fs.readFileSync(`./data/${(file)}`, 'utf8')))
        .map(doc => {
            return Object.entries(doc)
            .map(([faction, flightpoints]) => {
                
                return Object.entries(flightpoints)
                .map(([startPoint, endPoints]) => {

                    return Object.entries(endPoints)
                    .map(([endPoint, duration]) =>({
                        route: `${getName(startPoint)} -> ${getName(endPoint)}`,
                        start: startPoint,
                        end: endPoint,
                        duration,
                        faction
                    }));
                }).flat();
            }).flat();
        }).flat();