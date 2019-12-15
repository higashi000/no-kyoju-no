require 'http'
require 'json'
require 'eventmachine'
require 'faye/websocket'

token = "YOUR TOKEN"
userID = "TARGET USER ID"
reactionName = "EMOJI NAME"

response = HTTP.post("https://slack.com/api/rtm.start", params: {
    token: token
    })

rtmRes = JSON.parse(response.body)
rtmWs = rtmRes['url']
addReaction = "https://slack.com/api/reactions.add"

EM.run do
  ws = Faye::WebSocket::Client.new(rtmWs)

  ws.on :open do
   p [:open]
  end

  ws.on :message do |event|
    data = JSON.parse(event.data)

    if data['user'] == userID and data['text'] != nil
      slackRes = HTTP.post(addReaction, params: {
          token: token,
          channel: data['channel'],
          name: reactionName,
          timestamp: data['ts']
          })

      res = JSON.parse(slackRes.body)
      p res['ok']
    end
  end

  ws.on :close do
    p [:close, event.code]
    ws = nil
    EM.stop
  end
end
