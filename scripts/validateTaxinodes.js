const taxinodes = require('./taxinodes');

const nodes = new Set();
Object.keys(taxinodes).forEach((hash) => {
    if(nodes.has(hash)) {
        console.log(`Duplicate hash`);
        console.log(taxinodes[name], hash, ' - ', taxinodes.get(hash));
    }
    nodes.add(hash);
});