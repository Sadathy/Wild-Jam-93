extends Node

# AudioManager
# ------------
#
# Music is handled as pairs of synced tracks (TRACK_AMBIENT and TRACK_BATTLE).
# Both tracks loop simulataneously and we crossfade between them.
#
# Sound Effects (SFX) can be "one-shot" or looped until stopped.
# The maximum number of SFX played at once is controlled by CHANNELS.
#
# Usage:
#	AudioManager.play_music(AudioManager.Music.NOVA)
#	AudioManager.play(preload("res://Assets/Audio/sfx.ogg"))
#	AudioManager.play_looping(preload("res://Assets/Audio/loop.ogg"), "engine")
#	AudioManager.stop_looping("engine")
#	AudioManager.set_music(AudioManager.Track.BATTLE)
#


# Configuration
# -------------
const CHANNELS := 16
const DEFAULT_CROSSFADE_DURATION := 1.5
const DEFAULT_FADE_DURATION := 0.0


@export var volume_master := 1.0
@export var volume_sfx := 1.0
@export var volume_music := 1.0


# Internal state tracking
# -----------------------
var _sfx_pool: Array[AudioStreamPlayer] = []
var _sfx_pool_idx: int = 0

var _looping: Dictionary = {}

var _music_tracks: Array[AudioStreamPlayer] = []
var _active_track: int = 0
enum Track {AMBIENT, BATTLE}
enum Music {NOVA, LAGRANGE, FISSION}

var _crossfade_tween: Tween



func _ready() -> void:
	_build_sfx_pool()
	_build_music_players()



# Music
# -----

# Load and play music by identifier.
# Calls load_music(), see below for behaviour.
func play_music(music: int) -> void:
	var track_a: String
	var track_b: String
	
	match music:
		Music.NOVA:
			track_a = "res://Assets/Audio/Nova_ambient.ogg"
			track_b = "res://Assets/Audio/Nova_battle.ogg"
		Music.LAGRANGE:
			track_a = "res://Assets/Audio/Lagrange_ambient.ogg"
			track_b = "res://Assets/Audio/Lagrange_battle.ogg"
		Music.FISSION:
			track_a = "res://Assets/Audio/Fission_ambient.ogg"
			track_b = "res://Assets/Audio/Fission_battle.ogg"
		_:
			return
	
	load_music(load(track_a), load(track_b))


# Load ambient / battle music for a level and begin playing them in sync.
# Stream A will begin playing at full volume, while stream B will be silent.
func load_music(stream_a: AudioStream, stream_b: AudioStream) -> void:
	if _crossfade_tween:
		_crossfade_tween.kill()
	
	_music_tracks[0].stream = stream_a
	_music_tracks[1].stream = stream_b
	
	_music_tracks[0].play()
	_music_tracks[1].play()
	
	_music_tracks[0].volume_db = linear_to_db(volume_music)
	_music_tracks[1].volume_db = -80.0
	
	_active_track = 0


# Crossfade to the given track over duration (seconds).
func set_music(track_index: int, duration: float = DEFAULT_CROSSFADE_DURATION) -> void:
	if track_index == _active_track or (track_index < Track.AMBIENT or track_index > Track.BATTLE):
		# ugly error checking - do nothing if we select the currently playing track
		# and ignore anything else.
		return
	
	var incoming := _music_tracks[track_index]
	var outgoing := _music_tracks[_active_track]
	
	if _crossfade_tween:
		_crossfade_tween.kill()
	
	# Use a tween for crossfading audio since it handles doing things over time nicely.
	_crossfade_tween = create_tween()
	_crossfade_tween.set_parallel(true)
	
	# Custom crossfade curve that should match perceived loudness over time.
	_crossfade_tween.tween_method(
		func(t: float):
			outgoing.volume_db = linear_to_db(cos(t * PI / 2) * volume_music)
			incoming.volume_db = linear_to_db(sin(t * PI / 2) * volume_music),
		0.0, 1.0, duration
	)
	
	# Set the new active track once the tween has finished.
	_crossfade_tween.finished.connect(func(): _active_track = track_index)


# Pause both music tracks.
func pause_music() -> void:
	for track in _music_tracks:
		track.stream_paused = true


# Resume both music tracks.
func resume_music() -> void:
	for track in _music_tracks:
		track.stream_paused = false


# Stop both music tracks immediately (no fade).
func stop_music() -> void:
	if _crossfade_tween:
		_crossfade_tween.kill()
	
	for track in _music_tracks:
		track.stop()



# SFX
# ---

# Play a "one-shot" sound (effects, UI sound, etc.).
# Returns the AudioStreamPlayer.
func play(stream: AudioStream, volume_db: float = 1.0) -> AudioStreamPlayer:
	var player := _sfx_pool[_sfx_pool_idx]
	_sfx_pool_idx = (_sfx_pool_idx + 1) % CHANNELS
	
	player.stream = stream
	player.volume_db = volume_db * linear_to_db(volume_sfx)
	player.play()
	return player


# Play a looping sound with string identifier. Use for sounds that should loop until stopped.
# Calling this again with the same key will restart the sound.
# Fades in with a duration, if passed.
# Returns the AudioStreamPlayer.
func play_looping(stream: AudioStream, key: String, fade_in: float = DEFAULT_FADE_DURATION, volume_db: float = 1.0) -> AudioStreamPlayer:
	if _looping.has(key) and _looping.has(key+"_tween"):
		# We are trying to start a sound in the process of stopping -
		# kill the tween and set volume, then exit.
		_looping[key+"_tween"].kill()
		_looping.erase(key+"_tween")
		_looping[key].volume_db = linear_to_db(volume_db * volume_sfx)
		return
	
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.bus = "SFX"
	player.volume_db = 0.0
	player.autoplay = false
	add_child(player)
	player.play()
	
	_looping[key] = player
	
	# Optional fade behaviour
	_looping[key+"_tween"] = create_tween()
	
	# Fade volume to volume_db over fade_in
	_looping[key+"_tween"].tween_method(
		func(t: float):
			_looping[key].volume_db = linear_to_db(sin(t * PI / 2) * volume_sfx),
		0.0, volume_db, fade_in
	)
	
	# Clear up after ourselves when done
	_looping[key+"_tween"].finished.connect(func(): _looping.erase(key+"_tween"))
	
	return player


# Stop a sound from looping, given its identifier.
# Optionally fade the sound out if passed a duration.
func stop_looping(key: String, fade_out: float = DEFAULT_FADE_DURATION) -> void:
	if _looping.has(key):
		if _looping.has(key+"_tween"):
			# Gracefully end current tween if it exists
			_looping[key+"_tween"].kill()
		
		_looping[key+"_tween"] = create_tween()
		
		# Fade volume to 0 over fade_out
		_looping[key+"_tween"].tween_method(
			func(t: float):
				_looping[key].volume_db = linear_to_db(sin(t * PI / 2) * volume_sfx),
			db_to_linear(_looping[key].volume_db), 0.0, fade_out
		)
		
		# Stop the player and clean up once tween finishes
		_looping[key+"_tween"].finished.connect(func():
			var player = _looping[key]
			player.stop()
			player.queue_free()
			_looping.erase(key)
			_looping.erase(key+"_tween")
		)


# Stop all looping sounds (panic switch / probably will need this at some point).
func stop_all_looping() -> void:
	for key in _looping.keys():
		stop_looping(key)



# Volume Control
# --------------

# Set master volume (0.0 - 1.0)
func set_master_volume(linear: float) -> void:
	volume_master = clampf(linear, 0.0, 1.0)
	var bus_idx := AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_linear(bus_idx, volume_master)
	_play_click_on_bus("Master")


# Set music volume (0.0 - 1.0)
func set_music_volume(linear: float) -> void:
	volume_music = clampf(linear, 0.0, 1.0)
	var bus_idx := AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_linear(bus_idx, volume_music)
	_play_click_on_bus("Music")


# Set SFX volume (0.0 - 1.0)
func set_sfx_volume(linear: float) -> void:
	volume_sfx = clampf(linear, 0.0, 1.0)
	var bus_idx := AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_linear(bus_idx, volume_sfx)
	_play_click_on_bus("SFX")



# Helper functions
# ----------------

# Create players for sfx.
func _build_sfx_pool() -> void:
	for i in CHANNELS:
		var p := AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		_sfx_pool.append(p)


# Create players for music.
func _build_music_players() -> void:
	for i in 2:
		var p := AudioStreamPlayer.new()
		p.bus = "Music"
		add_child(p)
		_music_tracks.append(p)


# Play a test click sound on a bus
func _play_click_on_bus(bus_name: String) -> void:
	var p := AudioStreamPlayer.new()
	add_child(p)
	p.stream = load("res://Assets/Audio/obsydianx/cursor_style_2.wav")
	p.bus = bus_name
	p.finished.connect(p.queue_free)
	p.play()
