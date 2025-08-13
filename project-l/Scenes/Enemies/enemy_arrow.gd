extends CharacterBody2D

@onready var tile_map: TileMapLayer = $"../../Map/TileMapLayer"
@onready var area_2d: Area2D = $Area2D
@onready var player: CharacterBody2D = $"../../User/Player"

var pos : Vector2;
var rota : float;
var direction : float;
var speed = 400;
var enemy_to_hit: CharacterBody2D;

func ready() -> void:
	global_position = pos;
	global_rotation = rota;
	
func _physics_process(_delta: float) -> void:
	velocity = Vector2(speed, 0).rotated(direction);
	move_and_slide();
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if (body == tile_map):
		queue_free();
	elif (body == player):
		queue_free();
		player.lose_heart();
	
		
