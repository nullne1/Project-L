extends Area2D

@onready var player: CharacterBody2D = $"../../User/Player"

func _on_body_entered(body: Node2D) -> void:
	if (body == player):
		queue_free();
		player.gain_heart();
