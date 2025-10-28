extends AnimatedSprite2D

var loops := 0;

func _on_animation_looped() -> void:
	if loops == 2:
		queue_free()
	loops += 1;
