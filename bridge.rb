require 'json'
require 'pusher-client'
require 'sonic_pi'

def gencode(cmds, amp='')
  cs = ''
  for cmd in cmds
    if cs != ''
      cs += "\n"
    end

    if cmd.has_key?('amp')
      amp = ', amp: ' + cmd['amp'].to_s
    end

    c = ""
    if cmd.has_key?('sleep')
      c = 'sleep ' + cmd['sleep'].to_s
    elsif cmd.has_key?('play')
      c = 'play ' + cmd['play'].to_s + amp
    elsif cmd.has_key?('sample')
      c = 'sample ' + cmd['sample'] + amp
    elsif cmd.has_key?('major')
      c = 'play chord(' + cmd['major'].to_s + ', :major)' + amp
    elsif cmd.has_key?('minor')
      c = 'play chord(' + cmd['minor'].to_s + ', :minor)' + amp
    elsif cmd.has_key?('synth')
      if cmd.has_key?('command')
        c = 'with_synth ' + cmd['synth'] + " do\n" + gencode([cmd['command']], amp) + "\nend"
      end
    elsif cmd.has_key?('effect')
      if cmd.has_key?('command')
        c = 'with_fx ' + cmd['effect'] + " do\n" + gencode([cmd['command']], amp) + "\nend"
      end
    elsif cmd.has_key?('progn')
      c = gencode(cmd['progn'], amp)
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

socket = PusherClient::Socket.new('app key',{
  :secret => 'app secret'
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
