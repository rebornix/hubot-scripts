module.exports = (robot) ->

  { spawn } = require 'child_process'  
  readabilitytoken = ""
  kindleaddress = ""

  robot.hear /save (.*)/i, (res) ->
    res.send "Start to extract content from url"
    url = res.match[1]
    bookmark = url.indexOf("#")
    if bookmark > 0
      url = url.substring(0, bookmark)

    robot.http("https://www.readability.com/api/content/v1/parser?url=" + url + "&token="+readabilitytoken)
      .get() (err, resp, body) ->
        data = JSON.parse body
        fs = require('fs');
        title = 'Hulk bot'
        now = new Date
        if data.title?
          title = data.title

        tmpfile = "~/tmp/" + now.getDay() + "-" + now.getHours() + "-" + now.getMinutes() + "-" + title.replace(/[^A-Za-z0-9]+/g,'-').toLowerCase() + ".html"
        if not data.content?
          res.send "Content undefined."
          return
        res.send "start to save content to local disk"
        fs.writeFile tmpfile, "<html><body>"+data.content+"</body></html>", (err) -> 
          if err
            res.send err
          
          res.send "start to send " + title + " to kindle with file: " + tmpfile
          doing = spawn '/bin/bash', ['-c', "echo 'convert' | mail -s '" + title+"' -A " + tmpfile + " " + kindleaddress], {stdio: 'inherit'}
          res.send "finished."
