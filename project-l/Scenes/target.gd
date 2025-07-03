extends Area2D
@onready var player: CharacterBody2D = $"../Player"
@onready var idle_area: Area2D = $"../Player/IdleArea"
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _on_area_entered(area: Area2D) -> void:
	if (area == idle_area):
		player.sprite.play("idle" + player.last_direction);
		queue_free();
