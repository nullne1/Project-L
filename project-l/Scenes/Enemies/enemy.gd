extends CharacterBody2D
class_name Enemy
signal death(enemy_node)

@export var hp := 100;
@export var ms := 100;
var dead := false;
var enemies: Array;

func _process(_delta: float) -> void:
	if (hp <= 0):
		death.emit(self);
