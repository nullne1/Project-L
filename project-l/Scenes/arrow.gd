extends CharacterBody2D

var pos : Vector2;
var rota : float;
var direction : float;
var speed = 800;
@onready var player: CharacterBody2D = $"../Player"
var enemyToHit: CharacterBody2D;
@onready var grass: TileMapLayer = $"../../Grass"

func ready() -> void:
	global_position = pos;
	global_rotation = rota;

func _physics_process(delta: float) -> void:
	velocity = Vector2(speed, 0).rotated(direction);
	move_and_slide();
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	var enemyToHit = player.getEnemyToHit();
	print(enemyToHit.name)
	print(body.name)
	if (body == grass):
		queue_free();
	elif (body == enemyToHit):
		queue_free();
		enemyToHit.hp -= 20;
		
