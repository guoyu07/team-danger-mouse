require 'json'
require 'pusher-client'
require 'sonic_pi'

def gencode(cmds)
  cs = ''
  for cmd in cmds
    if cs != ''
      cs += "\n"
    end

    c = ""
    if cmd.has_key?('sleep')
      c = 'sleep ' + cmd['sleep'].to_s
    elsif cmd.has_key?('play')
      c = 'play ' + cmd['play']
    elsif cmd.has_key?('sample')
      c = 'sample ' + cmd['sample']
    elsif cmd.has_key?('major')
      c = 'play chord(' + cmd['major'] + ', :major)'
    elsif cmd.has_key?('minor')
      c = 'play chord(' + cmd['minor'] + ', :minor)'
    elsif cmd.has_key?('synth')
      c = 'with_synth ' + cmd['synth'] + " do\n" + tocmd(cmd['command']) + "\nend"
    elsif cmd.has_key?('effect')
      c = 'with_fx ' + cmd['effect'] + " do\n" + tocmd(cmd['command']) + "\nend"
    elsif cmd.has_key?('progn')
      c = gencode(cmd['progn'])
    elsif cmd.has_key?('raw')
      c = cmd['raw']
    end

    if cmd.has_key?('repeat')
      if cmd['repeat'] == 'forever' then
        c = "loop do\n" + c + "\nend"
      else
        c = cmd['repeat'].to_s + ".times do\n" + c + "\nend"
      end
    end

    cs += c
  end

  return cs
end

app = SonicPi.new

app.test_connection!

socket = PusherClient::Socket.new('cfbbdd53d88cd46a7deb',{
  :secret => 'b4430e80c82bc1b8b729'
})

socket.subscribe('presence-music', :user_id => 'the.server', :user_data => {:foo => 'bar'})


threads = []

socket['presence-music'].bind('client-do') do |data|
  cmds = JSON.parse(data)

  if cmds.is_a?(Array)
    c = gencode(cmds)
    puts 'Sending code: `' + c + '`'
    app.run(c)
  end
end

socket['presence-music'].bind('client-full_stop') do |data|
  puts "Stopping"
  app.stop()
end

socket.connect
