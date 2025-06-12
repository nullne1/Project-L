extends CharacterBody2D

const CHARGE_UP_ZOMBIE = preload("res://Assets/topdown_textures/charge_up_zombie.png")
const ATTACK_ZOMBIE = preload("res://Assets/topdown_textures/attack_zombie.png")
const SWORD_SLASH = preload("res://Scenes/sword_slash.tscn")

@onready var hp := 100;
@onready var player: CharacterBody2D = $"../../User/Player"
@onready var sprite: Sprite2D = $Sprite2D
@onready var enemy_health_bar: TextureProgressBar = %EnemyHealthBar

var ms := 200;
var in_range := false;

func _ready() -> void:
	await get_tree().create_timer(2).timeout;

func _physics_process(delta: float) -> void:
	enemy_health_bar.rotation = 0;
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
		sprite.texture = CHARGE_UP_ZOMBIE;
		var attack = SWORD_SLASH.instantiate() as StaticBody2D;
		add_child(attack);
		in_range = true;
		velocity = Vector2(0, 0);
