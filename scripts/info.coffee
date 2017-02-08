# Description:
#   gets sdslabs member's info from google doc
#   Type a partial name to get all matches
#
# Configuration:
#   INFO_SPREADSHEET_URL
#
# Commands:
#   hubot info <partial name> - Get information about a person

module.exports = (robot) ->
  robot.respond /(info|sdsinfo) (.+)$/i, (msg)  ->
    query = msg.match[2].toLowerCase()
    robot.http("https://docs.google.com/spreadsheets/d/1lD7wCg-vwr8TrlYg9v9FJwF7N99eS-fXTTD3Xa7J4oM/pub")
      .query({
        output: "csv"
      })
      .get() (err, res, body) ->
        result = parse body, query
        if not result 
          msg.send "I could not find a user matching `"+query.toString()+"`"
        else
          msg.send result.length+" user(s) found matching `"+query.toString()+"`"
          for user in result
            output = {
              "fallback": user.join '\t',
              "color": "#66464f",
              "pretext": "Info for "+query.toString(),
              "author_name": "",
              "author_link": "",
              "author_icon": "",
              "title": user[0],
              "title_link": "https://facebook.com/"+user[8],
              "text": "",
              "fields": [
                {
                  "title": "Mobile",
                  "value": "<tel:"+user[1]+"|"+user[1]+">",
                  "short": true
                },
                {
                  "title": "Email",
                  "value": "<mailto:"+user[2]+"|"+user[2]+">",
                  "short": true
                },
              ],
              "image_url": "",
              "thumb_url": "",
              "footer": user[4]+" "+user[5]+" ("+user[6]+")",
              "footer_icon": "",
              "ts": new Date(user[3]).getTime()
            }
            sendMessage output, msg


  sendMessage = (results, msg) ->
    robot.emit 'slack-attachment',
      message:
        room: msg.message.room
      content: results

parse = (json, query) ->
  result = []
  for line in json.toString().split '\n'
    y = line.toLowerCase().indexOf query
    if y != -1
      result.push line.split(',').map Function.prototype.call, String.prototype.trim
  if result != ""
    result
  else
    false


