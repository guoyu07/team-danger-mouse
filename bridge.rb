require 'json'
require 'pusher-client'
require 'sonic_pi'

def docmd(app, cmd)
  bits = cmd.split
  if bits[0] == "sleep"
    duration = bits[1].to_f
    puts 'Sleeping for: ' + bits[1]
    sleep(duration)
  else
    puts 'Sending command: ' + cmd
    app.run(cmd)
  end
end

def unquote(s)
  if s.chars.first == '"'
    s = s[1..-1]
  end
  if s.chars.last == '"'
    s = s[0..-2]
  end

  return s
end

app = SonicPi.new

app.test_connection!

socket = PusherClient::Socket.new('cfbbdd53d88cd46a7deb')

socket.subscribe('music')

socket['music'].bind('command') do |data|
  docmd(app, unquote(data))
end

socket['music'].bind('commands') do |data|
  for cmd in unquote(data).split(',')
    docmd(app,cmd)
  end
end

socket['music'].bind('full_stop') do |data|
  puts "Stopping"
  app.stop()
end

socket.connect
