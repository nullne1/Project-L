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
var zombieNum := 0;
var rng = RandomNumberGenerator.new();
var x : int;
var y : int;
var pos : Vector2;
var viewport : Vector2;
@onready var spawn_rate: Timer = $SpawnRate

func _ready() -> void:
	pass

func spawn(zombie, n, spawnPos) -> void:
	zombie = Enemy.instantiate() as CharacterBody2D;
	add_child(zombie);
	zombie.global_position = spawnPos;
	enemies.append(zombie);
	zombie.mouse_entered.connect(player._on_enemy_mouse_entered.bind(zombie.get_path()));
	zombie.mouse_exited.connect(player._on_enemy_mouse_exited);

func _process(delta: float) -> void:
	if (spawn_rate.is_stopped()):
		pos = player.position;
		viewport = get_viewport().size;
		match rng.randi_range(0, 3):
			0:
				x = rng.randi_range(pos.x - viewport.x / 2 - 50, pos.x - viewport.x / 2);
				y = rng.randi_range(pos.y - viewport.y / 2 - 50, pos.y + viewport.y / 2 + 50);
			1:
				x = rng.randi_range(pos.x + viewport.x / 2, pos.x + viewport.x / 2 + 50);
				y = rng.randi_range(pos.y - viewport.y / 2 - 50, pos.y + viewport.y / 2 + 50);
			2:
				x = rng.randi_range(pos.x - viewport.x / 2, pos.x + viewport.x / 2);
				y = rng.randi_range(pos.y + viewport.y / 2, pos.y + viewport.y / 2 + 50);
			3:
				x = rng.randi_range(pos.x - viewport.x / 2, pos.x + viewport.x / 2);
				y = rng.randi_range(pos.y - viewport.y / 2, pos.y - viewport.y / 2 - 50);
		spawn(zombie, zombieNum, Vector2(x, y));
		spawn_rate.start();
	
