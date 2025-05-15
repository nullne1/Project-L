extends Node2D

@export var Enemy = load("res://Scenes/enemy.tscn");
var zombie: CharacterBody2D;
var enemies := Array();
var hover := false;
var mousePosition: Vector2;
@onready var player: CharacterBody2D = $"../User/Player"
var enemyX: float;
var enemyY: float;
var enemyForPlayer: CharacterBody2D;

func _ready() -> void:
	for n in 15:
		spawn(zombie, n);

func spawn(zombie, n) -> void:
	zombie = Enemy.instantiate() as CharacterBody2D;
	add_child(zombie);
	zombie.global_position = Vector2(0, n * 10);
	enemies.append(zombie);
	zombie.mouse_entered.connect(player._on_enemy_mouse_entered.bind(zombie.get_path()));
	zombie.mouse_exited.connect(player._on_enemy_mouse_exited);

	
	
	
