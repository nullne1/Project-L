extends Area2D
@onready var player: CharacterBody2D = $"../Player"

func _on_body_entered(body: Node2D) -> void:
	if (body == player):
		player.sprite.play("idle" + player.last_direction);
		queue_free();
