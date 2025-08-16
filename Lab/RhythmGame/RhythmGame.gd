extends Node2D

@onready var asp := $AudioStreamPlayer

var note_scene := preload("res://Lab/RhythmGame/Note.tscn")
var virus_2 := preload("res://Lab/Scenes/VirusCutscene2.tscn")

var hit_zone := 56
var spawn_x := 600
var lead_time := 1.5

var total_notes := 0.0
var missed_notes := 0.0
var combo := 0

var notes = []
var notes2 = []
var finished := false

var delta_sum := 0.0

var min_note := 48
var max_note := 87

var min_y := 160
var max_y := 256

var game_started = false
var played = false

func _ready():
	Dialogic.connect("timeline_ended", timeline_ended)
	Dialogic.connect("signal_event", signal_event)
	notes = load_notes()
	total_notes = notes.size()
	
	set_process(false)
	$Player.set_physics_process(false)
	$AnimationPlayer.play("intro")

	#var min_note = INF
	#var max_note = -INF

	#for n in notes:
	#	var pitch = n["note"]
	#	if pitch < min_note:
	#		min_note = pitch
	#	if pitch > max_note:
	#		max_note = pitch

	#print("Min note:", min_note, " Max note:", max_note)
	
	
	
	#midi_player.link_audio_stream_player([asp])
	#midi_queue.play()

func signal_event(parameter: String) -> void:
	$Mint.play()

func map_note_to_y(note: int) -> float:
	var normalized = float(note - min_note) / float(max_note - min_note)
	return lerp(min_y, max_y, normalized)

func my_note_callback(event, track):
	if (event['subtype'] == MIDI_MESSAGE_NOTE_ON):
		var queue_time = delta_sum + lead_time
		print(track)
		notes.append({ "hit_time": queue_time, "lane": (track % 3 - 1), "note": event['note'] })
		notes2.append({ "hit_time": queue_time, "lane": (track % 3 - 1), "note": event['note'] })
	elif (event['subtype'] == MIDI_MESSAGE_NOTE_OFF):
		pass
	
func _process(delta) -> void:
	delta_sum += delta
	$UI/Accuracy.text = "%0.2f%%" % ((float(total_notes - missed_notes) / total_notes) * 100)
	$UI/Combo.text = str(combo) + "x"
	$UI/LevelTracker.value = (((total_notes - float(notes.size())) / total_notes) * 100)
	
	if delta_sum >= lead_time and not asp.playing and not finished and not played:
		asp.play()
		played = true
		start_disc_rotation()
		#midi_player.play()
		
	#var song_time = midi_player.get_current_time()
	for i in range(notes.size()-1, -1, -1):
		var note = notes[i]
		if note.hit_time <= delta_sum + lead_time:
			spawn_note(note)
			notes.remove_at(i)
func start_disc_rotation() -> void:
	var tween = create_tween().set_loops()
	tween.tween_property($Disc, "rotation", TAU, 5) # TAU = 2*PI radians
	tween.tween_property($Disc, "rotation", 0, 0)   # snap back instantly

func spawn_note(data) -> void:
	var note := note_scene.instantiate()
	note.lane = data.lane
	note.position = Vector2(spawn_x, map_note_to_y(data.note))
	note.speed = float(spawn_x - hit_zone) / lead_time
	note.note_missed.connect(note_missed)	
	add_child(note)
	
func note_missed() -> void:
	combo = 0
	missed_notes += 1
	$UI/HealthTracker.value -= 1
	if $UI/HealthTracker.value == 0:
		$Player.set_physics_process(false)
		set_process(false)
		$YouLose.visible = true
		await get_tree().create_timer(1.0).timeout
		transitionToNextLevel()

func onMidiQueue_finished() -> void:
	print("Finished!")
	finished = true
	var note_data = preload("res://Lab/RhythmGame/Pattern/NoteData.gd").new()
	note_data.notes = notes2.duplicate() # Copy the notes array
	var path = "res://Lab/RhythmGame/Pattern/Final.tres"

	var err = ResourceSaver.save(note_data, path)
	if err == OK:
		print("Notes exported successfully to ", path)
	else:
		print("Failed to save notes: ", err)


func load_notes() -> Array[Variant]:
	var file := ResourceLoader.load("res://Lab/RhythmGame/Pattern/Final.tres")
	return file.notes

func onPlayer_noteHit() -> void:
	combo += 1
	$UI/HealthTracker.value += 1


func onAudioStreamPlayer_finished() -> void:
	$Player/AnimatedSprite2D.animation = "close"
	$Player.set_physics_process(false)
	
	if float($UI/Accuracy.text) >= 75.00:
		$YouWon.visible = true
		Dialogic.VAR.secondGameWon = true
	else:
		$YouLose.visible = false
		Dialogic.VAR.secondGameWon = false
	
	transitionToNextLevel()

func transitionToNextLevel() -> void:
	await get_tree().create_timer(2.0).timeout
	SceneManager.transitionToScene(virus_2)

func onAnimationPlayer_animationFinished(anim_name: StringName) -> void:
	if anim_name == "intro":
		Dialogic.start("rhythm_game")
	if anim_name == "tutorial":
		game_started = true
		set_process(true)

func timeline_ended() -> void:
	var tween = create_tween()
	tween.tween_property($Crow, "position", Vector2(300, -10), 1.0)
	$Player.set_physics_process(true)
	$AnimationPlayer.play("tutorial")
