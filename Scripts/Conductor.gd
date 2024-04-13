extends AudioStreamPlayer

@export var bpm = 100
@export var measures = 4

#tracking beat and song position
var song_position: float = 0.0
var song_position_in_beats = 1
var sec_per_beat : float = 60.0 / bpm
var last_reported_beat = 0
var beats_before_start = 0
var measure = 1

#determining how close to the beat an event is
var closest = 0
var time_off_beat : float = 0.0

signal beat(position)
signal measure_sig(position)

func _ready():
	sec_per_beat = 60.0 / bpm


