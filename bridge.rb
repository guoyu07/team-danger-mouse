require 'json'
require 'pusher-client'
require 'sonic_pi'

app = SonicPi.new

app.test_connection!

socket = PusherClient::Socket.new('cfbbdd53d88cd46a7deb')

socket.subscribe('music')

socket['music'].bind('command') do |data|
  data = JSON.parse(data)
  puts 'Sending command: ' + data['command']
  app.run(data['command'])
end

socket['music'].bind('full_stop') do |data|
  puts "Stopping"
  app.stop()
end

socket.connect
