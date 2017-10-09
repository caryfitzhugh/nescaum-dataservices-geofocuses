const fs = require('fs');
const glob = require( 'glob');
const _ = require('lodash');
const basins_file = process.argv[2];
let basins = JSON.parse(fs.readFileSync(basins_file));
let files = glob.sync(process.argv[3]);

files.forEach((filename) => {
  let contents = JSON.parse(fs.readFileSync(filename));
  let name = (contents.uid || contents.name).replace(/Basin/,'').trim();

  let new_basin = _.find(basins.features, (basin) => {
    return basin.properties.NAME.toUpperCase() ===
      name.toUpperCase();
  });
  if (!new_basin) {
    console.log("err...", name);
  } else {
    contents.geom = new_basin
    fs.writeFileSync(filename, JSON.stringify(contents), 'utf8');
    console.log('found');
  }
});
