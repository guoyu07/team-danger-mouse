# team-danger-mouse

## Set-up

- Create an app and enable client events.
- Set the app credentials and auth endpoint in `bridge.rb`, `auth.py`, and the instruments (there are placeholders).

## Running

### auth

- Install some packages: `pip install flask flask-cors pusher`
- Start the server: `python auth.py`

### bridge

- Install some gems: `gem install pusher-client sonic-pi-cli`
- Get sonic-pi: http://sonic-pi.net/
- Start the sonic-pi server (on OSX run `ruby /Applications/Sonic Pi.app/app/server/bin/sonic-pi-server.rb`)
- Start the bridge: `ruby bridge.rb`

Send `client-do` events to app `30bde1096db2be8e7f53` in MT1 in the channel `presence-music` where the data
is a list of commands. The `client-full_stop` event stops synthesis.

Commands are:

- `{'play': '<note>'}`: play that note, notes are MIDI note numbers or names (`:e3`).
- `{'sample': '<sample>'}`: play that sample. See the cheatsheets.
- `{'sleep': <float>}`: sleep for that many seconds.
- `{'major': '<note>'}`: play that major chord.
- `{'minor': '<note>'}`: play that minor chord.
- `{'synth': '<synth>, 'command': <command>}`: run that command with those effects. See the cheatsheets.
- `{'effect': '<effect>', 'command': <command>}`: run that command with that effect. See the cheatsheets.
- `{'progn': [<command>]}`: run the commands in sequence.
- `{'raw': '<code>'}`: execute the given code verbatim in the Sonic Pi process.

Any command can be given a `repeat` parameter, which can be `"forever"` or an int. All commands other than
`sleep` and `raw` can be given an `amp` parameter: 0 is silent, 1 is normal volume; `synth`, `effect`, and
`progn` pass on the `amp` to its subcommands (although if they have an `amp` of their own it takes precedence).

**Warning:** The `raw` command allows arbitrary code execution on the machine running Sonic Pi! You probably
shouldn't expose that to the public Internet.
