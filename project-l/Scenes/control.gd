extends Control

const HEART = preload("res://Scenes/heart.tscn")

var hearts: Array;
var num_hearts := 3;
var heart_position := Vector2.ZERO;

func _ready() -> void:
	for i in num_hearts:
		var new_heart = HEART.instantiate() as TextureRect;
		find_child("CanvasLayer").add_child(new_heart);
		new_heart.position = heart_position;
		heart_position.x += 64;
		hearts.append(new_heart);

func gain_heart() -> void:
	pass
