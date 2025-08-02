extends Node2D

@export var Enemy = load("res://Scenes/Enemies/enemy.tscn");

@onready var player: CharacterBody2D = %Player
@onready var spawn_rate = $SpawnRate;

var enemy: CharacterBody2D;
var enemies := Array();
var hover := false;
var mouse_position: Vector2;
var enemy_for_player: CharacterBody2D;
var enemy_num := 0;
var rng = RandomNumberGenerator.new();
var pos : Vector2;
var distance_factor = 75;

func _ready() -> void:
	spawn_rate.wait_time = 500;

func spawn(spawnPos) -> void:
	enemy = Enemy.instantiate() as CharacterBody2D;
	add_child(enemy);
	enemy.global_position = spawnPos;
	enemies.append(enemy);
	var click_hitbox = enemy.find_child("ClickHitbox");
	click_hitbox.mouse_entered.connect(player._on_click_hitbox_mouse_entered.bind(enemy.get_path()));
	click_hitbox.mouse_exited.connect(player._on_click_hitbox_mouse_exited);

func _process(_delta: float) -> void:
	if (spawn_rate.is_stopped()):
		pos = player.position;
		var viewport = get_viewport().size / 2;
		var x : float;
		var y : float;
		match rng.randi_range(0, 3):
			# left spawn
			0:
				x = rng.randf_range(pos.x - viewport.x / 2 - 50, pos.x - viewport.x / 2 - distance_factor);
				y = rng.randf_range(pos.y - viewport.y / 2 - distance_factor, pos.y + viewport.y / 2 + distance_factor);
			# right spawn
			1:
				x = rng.randf_range(pos.x + viewport.x / 2 + distance_factor, pos.x + viewport.x / 2 + 50);
				y = rng.randf_range(pos.y - viewport.y / 2 - distance_factor, pos.y + viewport.y / 2 + distance_factor);
			# upper spawn
			2:
				x = rng.randf_range(pos.x - viewport.x / 2, pos.x + viewport.x / 2);
				y = rng.randf_range(pos.y + viewport.y / 2 + distance_factor, pos.y + viewport.y / 2 + 50);
			# lower spawn
			3:
				x = rng.randf_range(pos.x - viewport.x / 2, pos.x + viewport.x / 2);
				y = rng.randf_range(pos.y - viewport.y / 2 - distance_factor, pos.y - viewport.y / 2 - 50);
		spawn(Vector2(x, y));
		spawn_rate.start();
	
