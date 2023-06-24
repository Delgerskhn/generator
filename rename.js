const fs = require('fs');
const path = require('path');

const directoryPath = './_templates/golang/new/project'; // Replace with the actual directory path

function processFilesInDirectory(dirPath) {
  // Read the files in the directory
  fs.readdir(dirPath, (err, files) => {
    if (err) {
      console.error('Error reading directory:', err);
      return;
    }

    files.forEach(file => {
      const filePath = path.join(dirPath, file);

      // Check if it's a directory
      fs.stat(filePath, (err, stats) => {
        if (err) {
          console.error('Error accessing file/directory:', err);
          return;
        }

        if (stats.isDirectory()) {
          // Recursively process files in the subdirectory
          processFilesInDirectory(filePath);
        } else {
          // Read the file contents
          fs.readFile(filePath, 'utf8', (err, data) => {
            if (err) {
              console.error('Error reading file:', err);
              return;
            }

            // Add the three lines at the header
            const modifiedData =
              '---\nto: "<%= path ? `${path}/form.tsx` : `${cwd}/src/auth/pages/register/form.tsx` %>"\n---\n' +
              data;

            // Write the modified contents back to the file
            const renamedFilePath = filePath.replace(/\.[^.]+$/, '.ejs.t');
            fs.writeFile(renamedFilePath, modifiedData, 'utf8', err => {
              if (err) {
                console.error('Error writing file:', err);
                return;
              }

              console.log('File processed:', renamedFilePath);
            });
          });
        }
      });
    });
  });
}

processFilesInDirectory(directoryPath);