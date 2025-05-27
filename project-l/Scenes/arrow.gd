extends CharacterBody2D

var pos : Vector2;
var rota : float;
var direction : float;
var speed = 800;
@onready var player: CharacterBody2D = $"../Player"
var enemyToHit: CharacterBody2D;
@onready var grass: TileMapLayer = $"../../Grass"
@onready var area_2d: Area2D = $Area2D

func ready() -> void:
	global_position = pos;
	global_rotation = rota;

func _physics_process(delta: float) -> void:
	velocity = Vector2(speed, 0).rotated(direction);
	move_and_slide();
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	var enemyToHit = player.getEnemyToHit();
	print(enemyToHit)
	if (body == grass):
		queue_free();
	elif (body == enemyToHit):
		queue_free();
		enemyToHit.hp -= 20;
		
