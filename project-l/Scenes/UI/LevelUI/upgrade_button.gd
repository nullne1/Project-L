extends Button

@onready var upgrade_manager: Node = $"../../../../../UpgradeManager"

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

func _on_pressed() -> void:
	get_parent().get_parent().get_parent().queue_free();
