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
    elsif bits[0] == "major"
      cmd = 'play chord(' + bits[1] + ', :major)'
      puts 'Sending command: ' + cmd
      app.run(cmd)
    elsif bits[0] == "minor"
      cmd = 'play chord(' + bits[1] + ', :minor)'
      puts 'Sending command: ' + cmd
      app.run(cmd)
    else
      puts 'Sending command: ' + cmd
      app.run(cmd)
    end
  end
end

app = SonicPi.new

app.test_connection!

socket = PusherClient::Socket.new('cfbbdd53d88cd46a7deb',{
  :secret => 'b4430e80c82bc1b8b729'
})

socket.subscribe('presence-music', :user_id => 'the.server', :user_data => {:foo => 'bar'})

threads = []

socket['presence-music'].bind('client-do') do |data|
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

socket['presence-music'].bind('client-full_stop') do |data|
  puts "Stopping"
  for tid in threads
    Thread.kill(tid)
  end
  app.stop()
  threads = []
end

socket.connect
