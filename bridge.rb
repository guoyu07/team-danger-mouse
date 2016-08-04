require 'json'
require 'pusher-client'
require 'sonic_pi'

def docmds(app, cmds)
  for cmd in cmds
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
end

app = SonicPi.new

app.test_connection!

socket = PusherClient::Socket.new('cfbbdd53d88cd46a7deb')

socket.subscribe('music')

threads = []

socket['music'].bind('do') do |data|
  threads << Thread.new {
    data = JSON.parse(data)
    ntimes = 1

    if data.has_key?('repeat')
      if data['repeat'] == 'forever' then
        ntimes = -1
      else
        ntimes = data['repeat'].to_i
      end
    end

    if data.has_key?('commands')
      cmds = data['commands'].split(',')
      if ntimes == -1
        while true
          docmds(app, cmds)
        end
      else
        ntimes.times do
          docmds(app, cmds)
        end
      end
    end
  }
end

socket['music'].bind('full_stop') do |data|
  puts "Stopping"
  for tid in threads
    Thread.kill(tid)
  end
  app.stop()
  threads = []
end

socket.connect
