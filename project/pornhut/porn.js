var fs = require('fs');
const pornhub = require('pornnhub');

// const argv = process.argv;
// const url = argv[1];
// if(!!url) {
//     console.log("Url is null");
//     return 1;
// }
// const  path_at = !!argv[2]?argv[2]:"/var/home/html/porn/";
const url = "https://www.pornhub.com/view_video.php?viewkey=ph5b9c8a0605120"

pornhub(url, 'title').then(res => {
    console.log(res);
    // => { data: 'Hot kissing scene' }
  });

pornhub(url, 'high').then(res => {
    console.log(res);
  });