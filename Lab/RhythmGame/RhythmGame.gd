extends Node2D

@onready var midi_player := $MidiPlayer
@onready var midi_queue := $MidiQueue
@onready var asp := $AudioStreamPlayer

var note_scene := preload("res://Lab/RhythmGame/Note.tscn")

var lane_y_positions := [100, 200, 300] # Adjust for your lanes
var hit_zone := 200
var spawn_x := 600
var lead_time := 1.5

var notes = []
var main_started := false

var delta_sum := 0.0

func _ready():
	midi_queue.note.connect(my_note_callback)
	midi_player.link_audio_stream_player([asp])
	midi_queue.play()

func my_note_callback(event, track):
	if (event['subtype'] == MIDI_MESSAGE_NOTE_ON):
		var queue_time = delta_sum + lead_time
		notes.append({ "hit_time": queue_time, "lane": (track % 3 - 1), "note": event['note'] })
	elif (event['subtype'] == MIDI_MESSAGE_NOTE_OFF):
		pass
	
func _process(delta) -> void:
	delta_sum += delta
	
	if delta_sum >= lead_time and not asp.playing:
		midi_player.play()
		
	#var song_time = midi_player.get_current_time()
	for i in range(notes.size()-1, -1, -1):
		var note = notes[i]
		if note.hit_time <= delta_sum + lead_time:
			spawn_note(note)
			notes.remove_at(i)

func spawn_note(data) -> void:
	var note = note_scene.instantiate()
	note.lane = data.lane
	note.position = Vector2(spawn_x, lane_y_positions[note.lane])
	note.speed = float(spawn_x - hit_zone) / lead_time
	add_child(note)
