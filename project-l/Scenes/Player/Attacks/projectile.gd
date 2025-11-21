class_name Projectile

extends CharacterBody2D

@onready var tile_map: TileMapLayer = $"../../Map/TileMapLayer"
@onready var area_2d: Area2D = $Area2D
@onready var player: CharacterBody2D = $"../Player"

var pos : Vector2;
var rota : float;
var direction : float;
var speed = 400;
var enemy_to_hit: CharacterBody2D;
var pierce:= 0;
var enemies_pierced:= 0;
var hit:= false;

func ready() -> void:
	global_position = pos;
	global_rotation = rota;
	
func _physics_process(_delta: float) -> void:
	velocity = Vector2(speed, 0).rotated(direction);
	move_and_slide();
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	print(pierce)
	if (body == tile_map):
		queue_free();
	elif (body == enemy_to_hit):
		hit = true;
		enemies_pierced += 1;
		if (pierce < enemies_pierced):
			queue_free();
		# enemy hit
		if (enemy_to_hit.hp - player.dmg > 0):
			enemy_to_hit.on_hit();
		# enemy death
		else:
			enemy_to_hit.on_death();
	# projectile continues after it hits target if there's pierce
	elif (body is Enemy && hit):
		enemies_pierced += 1;
		if (pierce < enemies_pierced):
			queue_free();
		# enemy hit
		if (body.hp - player.dmg > 0):
			body.on_hit();
		# enemy death
		else:
			body.on_death();
		
