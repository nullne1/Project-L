extends Node

const SWORD_SKELETON = preload("res://Scenes/Enemies/sword_skeleton.tscn")
const ARCHER_SKELETON = preload("res://Scenes/Enemies/archer_skeleton.tscn")

@onready var player: CharacterBody2D = %Player;
@onready var spawn_rate = $SpawnRate;
@onready var game_time: Timer = $GameTime
@onready var wave_cd: Timer = $WaveCD

var enemies := Array();
var hover := false;
var mouse_position: Vector2;
var enemy_for_player: CharacterBody2D;
var enemy_num := 0;
var rng = RandomNumberGenerator.new();
var distance_factor = 75;
var max_enemies = 10;
var time: float;

var waves_data: Dictionary;
var wave_num:= 1;

func _ready() -> void:
	spawn_rate.wait_time = 2;
	waves_data = {
		"wave1": {
			"num_sword": 5,
			"num_archer": 0,
			"level": 1
		},
		"wave2": {
			"num_sword": 0,
			"num_archer": 5,
			"level": 2
		},
		"wave3": {
			"num_sword": 3,
			"num_archer": 3,
			"level": 3
		},
		"wave4": {
			"num_sword": 8,
			"num_archer": 2,
			"level": 4
		},
		"wave5": {
			"num_sword": 0,
			"num_archer": 7,
			"level": 5
		},
		"wave6": {
			"num_sword": 8,
			"num_archer": 8,
			"level": 6
		},
	}
	
func _process(_delta: float) -> void:
	if (wave_cd.is_stopped() && enemies.is_empty()):
		spawn_wave()
		wave_cd.start();
	
func spawn_wave() -> void:
	for i in waves_data.get("wave" + str(wave_num)).get("num_sword"):
		spawn(SWORD_SKELETON, waves_data.get("wave" + str(wave_num)).get("level"));
	for i in waves_data.get("wave" + str(wave_num)).get("num_archer"):
		spawn(ARCHER_SKELETON, waves_data.get("wave" + str(wave_num)).get("level"));
	wave_num += 1;
	
func spawn(enemy_type: PackedScene, level: int) -> void:
	var enemy := enemy_type.instantiate() as CharacterBody2D;
	enemy.level = level;
	enemy.global_position = get_spawn();
	add_child(enemy);
	enemies.append(enemy);
	enemy.enemies = enemies;
	enemy.death.connect(_on_enemy_death);
	var click_hitbox = enemy.find_child("ClickHitbox");
	click_hitbox.mouse_entered.connect(player._on_click_hitbox_mouse_entered.bind(enemy));
	click_hitbox.mouse_exited.connect(player._on_click_hitbox_mouse_exited.bind(enemy));


func get_spawn() -> Vector2:
	var x : float;
	var y : float;
	var pos := player.position;
	var viewport = get_viewport().size / 2;
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
			
	return Vector2(x, y);

func _on_enemy_death(enemy_node):
	enemies.erase(enemy_node);
	
func _on_game_time_timeout() -> void:
	pass
	#print(enemies);
