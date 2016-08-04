# team-danger-mouse

## auth

- Use https://www.barrucadu.co.uk/dangermouse/ as the auth end point

## bridge

- Install some gems: `gem install pusher-client sonic-pi-cli`
- Get sonic-pi: http://sonic-pi.net/
- Start the sonic-pi server (on OSX run `ruby /Applications/Sonic Pi.app/app/server/bin/sonic-pi-server.rb`)
- Start the bridge: `ruby bridge.rb`

Send `do` events to app `cfbbdd53d88cd46a7deb` in MT1 in the channel `music` of the form:

```json
{ 'commands': 'comma,separated,commands'
, 'repeat':   'forever' OR int
}
```

The `full_stop` event stops synthesis.

Commands are:

- `play <note>`: play that note, notes are MIDI note numbers or names (`:e3`).
- `sample <sample>`: play that sample. See SAMPLES.md for a list.
- `sleep <float>`: sleep for that many seconds.
- `major <note>`: play that major chord.
- `minor <note>`: play that minor chord.
