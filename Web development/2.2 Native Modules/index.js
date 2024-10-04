const fs = require("fs");

/*fs.writeFile("message.txt", "Hello From RKI", (err) => {
    if (err) throw err;
    console.log('The file has been saved!');
  });
  */ 
/* fs.writeFile(file, data[, options], callback) */ 

fs.readFile('./message.txt', 'utf-8', (err,data) => {
    if (err) throw err;
    console.log(data);
  });