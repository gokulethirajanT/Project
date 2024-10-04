/* 
1. Use the inquirer npm package to get user input.
2. Use the qr-image npm package to turn the user entered URL into a QR code image.
3. Create a txt file to save the user input using the native fs node module.
*/

import inquirer from 'inquirer';
import qr from 'qr-image';
import fs from 'fs'

inquirer
  .prompt([{
    message: "Please enter the URL: ",
    name: "URL",
  }
     
  ])
  .then((answers) => {
       var url = answers.URL;
       var qr_png = qr.image( url, { type: 'png' });
       qr_png.pipe(fs.createWriteStream('qrcode.png'));
       fs.writeFile("URL.txt", url, (err) => {
    if (err) throw err;;
  });


  })
  .catch((error) => {
    console.error("An error occurred:", error); // Handle errors
  });

