extends Label

var speed := 1;
@onready var timer: Timer = $Timer


func _ready() -> void:
	pass

func _physics_process(_delta: float) -> void:
	if (timer.is_stopped()):
		queue_free()
	position -= Vector2(0, 1) * speed;
