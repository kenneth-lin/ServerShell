var fs = require('fs');
var youtubedl = require('youtube-dl');

const argv = process.argv;
const url = argv[1];
if(!!url) {
    console.log("Url is null");
    return 1;
}
const  path_at = !!argv[2]?argv[2]:"/var/home/html/youtube/";

var video = youtubedl(url,
  // Optional arguments passed to youtube-dl.
  ['--format=18'],
  // Additional options can be given for calling `child_process.execFile()`.
  { cwd: __dirname });
 var file_name = 'dump';
// Will be called when the download starts.
video.on('info', function(info) {
  console.log('Download started');
  console.log('filename: ' + info.filename);
  file_name = info.filename + '.mp4';
  console.log('size: ' + info.size);
});

const download_to = path_at + file_name;
video.pipe(fs.createWriteStream(download_to));