extends Resource
class_name NoteData
# Make sure to enable resource export hints in Godot if you want.

@export var notes := []  # Each element is a dictionary: { "hit_time": float, "note": int }
