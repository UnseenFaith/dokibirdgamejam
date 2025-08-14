extends Node2D

@onready var midi_player := $MidiPlayer
@onready var midi_queue := $MidiQueue
@onready var asp := $AudioStreamPlayer

var note_scene := preload("res://Lab/RhythmGame/Note.tscn")

var lane_y_positions := [100, 200, 300, 400, 500] # Adjust for your lanes
var hit_zone := 200
var spawn_x := 600
var lead_time := 1.5

var total_notes = 0.0
var missed_notes = 0.0
var combo = 0

var notes = []
var notes2 = []
var finished := false

var delta_sum := 0.0

func _ready():
	notes = load_notes()
	total_notes = notes.size()
	
	#midi_player.link_audio_stream_player([asp])
	#midi_queue.play()

func my_note_callback(event, track):
	if (event['subtype'] == MIDI_MESSAGE_NOTE_ON):
		var queue_time = delta_sum + lead_time
		notes.append({ "hit_time": queue_time, "lane": (track % 3 - 1), "note": event['note'] })
		notes2.append({ "hit_time": queue_time, "lane": (track % 3 - 1), "note": event['note'] })
	elif (event['subtype'] == MIDI_MESSAGE_NOTE_OFF):
		pass
	
func _process(delta) -> void:
	delta_sum += delta
	$CanvasLayer/Accuracy.text = "%0.2f%%" % ((float(total_notes - missed_notes) / total_notes) * 100)
	$CanvasLayer/Combo.text = str(combo) + "x"
	$CanvasLayer/LevelTracker.value = (((total_notes - float(notes.size())) / total_notes) * 100)
	
	if delta_sum >= lead_time and not asp.playing and not finished:
		asp.play()
		pass
		#midi_player.play()
		
	#var song_time = midi_player.get_current_time()
	for i in range(notes.size()-1, -1, -1):
		var note = notes[i]
		if note.hit_time <= delta_sum + lead_time:
			spawn_note(note)
			notes.remove_at(i)

func spawn_note(data) -> void:
	var note := note_scene.instantiate()
	note.lane = data.lane
	note.position = Vector2(spawn_x, lane_y_positions[1])
	note.speed = float(spawn_x - hit_zone) / lead_time
	note.note_missed.connect(note_missed)
	add_child(note)
	
func note_missed() -> void:
	combo = 0
	missed_notes += 1
	$CanvasLayer/HealthTracker.value -= 1
	if $CanvasLayer/HealthTracker.value == 0:
		print("Game Over")

func onMidiQueue_finished() -> void:
	print("Finished!")
	finished = true
	var note_data = preload("res://Lab/RhythmGame/Pattern/NoteData.gd").new()
	note_data.notes = notes2.duplicate() # Copy the notes array
	var path = "res://Lab/RhythmGame/Pattern/Test.tres"

	var err = ResourceSaver.save(note_data, path)
	if err == OK:
		print("Notes exported successfully to ", path)
	else:
		print("Failed to save notes: ", err)


func load_notes() -> Array[Variant]:
	var file := ResourceLoader.load("res://Lab/RhythmGame/Pattern/Test.tres")
	return file.notes

func onPlayer_noteHit() -> void:
	combo += 1
	$CanvasLayer/HealthTracker.value += 1
