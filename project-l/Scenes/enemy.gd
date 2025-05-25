extends CharacterBody2D

@onready var hp := 100;
var ms := 200;
@onready var player: CharacterBody2D = $"../../User/Player"
@onready var enemy_health_bar: TextureProgressBar = $EnemyHealthBar
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


func _physics_process(delta: float) -> void:
	enemy_health_bar.value = hp;
	look_at(player.position);
	velocity = (player.position - position).normalized() * ms;
	if (position.distance_to(player.position) > 3):
		move_and_collide(delta * velocity);
	if (hp <= 0):
		queue_free();
