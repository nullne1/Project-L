extends CharacterBody2D

@onready var hp := 100;
@onready var player: CharacterBody2D = $"../../User/Player"
@onready var enemy_health_bar: TextureProgressBar = $EnemyHealthBar
const CHARGE_UP_ZOMBIE = preload("res://Assets/topdown_textures/charge_up_zombie.png")
const ATTACK_ZOMBIE = preload("res://Assets/topdown_textures/attack_zombie.png")

var ms := 200;
var in_range := false;

func _physics_process(delta: float) -> void:
	enemy_health_bar.value = hp;
	look_at(player.position);
	if (!in_range):
		velocity = (player.position - position).normalized() * ms;
	if (position.distance_to(player.position) > 3):
		move_and_collide(delta * velocity);
	if (hp <= 0):
		queue_free();

func _on_attack_range_body_entered(body: Node2D) -> void:
	if (body == player):
		get_child(0).texture = CHARGE_UP_ZOMBIE;
		in_range = true;
		velocity = Vector2(0, 0);
