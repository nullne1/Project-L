extends Node2D

@onready var player: CharacterBody2D = %Player
@export var Enemy = load("res://Scenes/enemy.tscn");
var enemy: CharacterBody2D;
var enemies := Array();
var hover := false;
var mouse_position: Vector2;
var enemy_for_player: CharacterBody2D;
var enemy_num := 0;
var rng = RandomNumberGenerator.new();
var x : int;
var y : int;
var pos : Vector2;
var viewport : Vector2;
@export var spawn_rate: Timer;
var distance_factor = 75;

func _ready() -> void:
	spawn_rate.wait_time = 1;

func spawn(enemy, n, spawnPos) -> void:
	enemy = Enemy.instantiate() as CharacterBody2D;
	add_child(enemy);
	enemy.global_position = spawnPos;
	enemies.append(enemy);
	var click_hitbox = enemy.get_child(5);
	click_hitbox.mouse_entered.connect(player._on_click_hitbox_mouse_entered.bind(enemy.get_path()));
	click_hitbox.mouse_exited.connect(player._on_click_hitbox_mouse_exited);

func _process(delta: float) -> void:
	if (spawn_rate.is_stopped()):
		pos = player.position;
		viewport = get_viewport().size;
		match rng.randi_range(0, 3):
			# left spawn
			0:
				x = rng.randi_range(pos.x - viewport.x / 2 - 50, pos.x - viewport.x / 2 - distance_factor);
				y = rng.randi_range(pos.y - viewport.y / 2 - distance_factor, pos.y + viewport.y / 2 + distance_factor);
			# right spawn
			1:
				x = rng.randi_range(pos.x + viewport.x / 2 + distance_factor, pos.x + viewport.x / 2 + 50);
				y = rng.randi_range(pos.y - viewport.y / 2 - distance_factor, pos.y + viewport.y / 2 + distance_factor);
			# upper spawn
			2:
				x = rng.randi_range(pos.x - viewport.x / 2, pos.x + viewport.x / 2);
				y = rng.randi_range(pos.y + viewport.y / 2 + distance_factor, pos.y + viewport.y / 2 + 50);
			# lower spawn
			3:
				x = rng.randi_range(pos.x - viewport.x / 2, pos.x + viewport.x / 2);
				y = rng.randi_range(pos.y - viewport.y / 2 - distance_factor, pos.y - viewport.y / 2 - 50);
		spawn(enemy, enemy_num, Vector2(x, y));
		spawn_rate.start();
	
