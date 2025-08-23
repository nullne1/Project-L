extends CharacterBody2D

signal enemy_to_hit_death;
signal hit_enemy_to_hit;
signal add_player_xp;

@onready var tile_map: TileMapLayer = $"../../Map/TileMapLayer"
@onready var area_2d: Area2D = $Area2D
@onready var player: CharacterBody2D = $"../Player"
@onready var dagger_icon: TextureProgressBar = $"../../Control/CanvasLayer/TextureRect/HBoxContainer/DaggerIcon"

var pos : Vector2;
var rota : float;
var direction : float;
var speed = 450;
var enemy_to_hit: CharacterBody2D;


func ready() -> void:
	global_position = pos;
	global_rotation = rota;
	enemy_to_hit_death.connect(enemy_to_hit.on_death);
	hit_enemy_to_hit.connect(enemy_to_hit.on_hit);
	
func _physics_process(_delta: float) -> void:
	velocity = Vector2(speed, 0).rotated(direction);
	move_and_slide();
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if (body == tile_map):
		queue_free();
	elif (body == enemy_to_hit):
		queue_free();
		if (enemy_to_hit.hp - 20 >= 20):
			hit_enemy_to_hit.connect(enemy_to_hit.on_hit);
			hit_enemy_to_hit.emit();
		else:
			player.dagger_icon.value = player.dagger_icon.min_value;
			player.dagger_cd.stop();
			add_player_xp.connect(player.add_xp);
			add_player_xp.emit();
			enemy_to_hit_death.connect(enemy_to_hit.on_death);
			enemy_to_hit_death.emit();
			
			
	
		
