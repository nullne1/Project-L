extends Control

#const HEART = preload("res://Scenes/heart.tscn")
#
#var hearts: Array;
#var num_hearts := 3;
#
#func _ready() -> void:
	#for i in num_hearts:
		#var new_heart = HEART.instantiate() as TextureRect;
		#find_child("CanvasLayer").find_child("HeartHBoxContainer").add_child(new_heart);
		#hearts.append(new_heart);
#
#func lose_heart() -> void:
	#if (hearts.back()): hearts.back().queue_free();
#
#func gain_heart() -> void:
	#pass
