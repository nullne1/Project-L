class_name Enemy
extends CharacterBody2D
signal death(enemy_node)

const HEART_DROP = preload("res://Scenes/Pickups/heart_drop.tscn")
const STATUS_INDICATOR = preload("res://Scenes/UI/status_indicator.tscn")
var hp := 100;
@export var ms := 100;

var dead := false;
var enemies: Array;
var in_range := false;
var last_direction: String;
var attack_finished: bool = true;
var level: int;

@onready var player: CharacterBody2D = $"../../User/Player"
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_speed_cd: Timer = $AttackSpeedCD
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var click_collision_shape_2d: CollisionPolygon2D = $ClickHitbox/CollisionPolygon2D
@onready var enemy_health_bar: TextureProgressBar = %EnemyHealthBar

func _ready() -> void:
	attack_speed_cd.wait_time = 1;
	hp += level * 20;
	enemy_health_bar.max_value = hp;
	enemy_health_bar.value = enemy_health_bar.max_value;

func _physics_process(_delta: float) -> void:
	# keeps attacking if player in range
	if (in_range && attack_speed_cd.is_stopped()):
		attack_finished = false;
		play_direction_attack(player.position, "attack");
		
	if (in_range):
		velocity = Vector2.ZERO;
	elif (position.distance_to(player.position) > 3 && attack_finished):
		var dir = to_local(navigation_agent_2d.get_next_path_position()).normalized()
		velocity = dir * ms;
		play_direction(player.position, "walk");
		move_and_slide();

func play_direction(direction_target: Vector2, animation: String) -> void:
	var angle := rad_to_deg(position.angle_to_point(direction_target));
	if (angle > -120 && angle < -60):
		sprite.play(animation + "_u");
		last_direction = "_u"
	elif (angle < -120 && angle > -180 || angle < 180 && angle > 120):
		sprite.play(animation + "_l");
		last_direction = "_l"
	elif (angle < 120 && angle > 60):
		sprite.play(animation + "_d");
		last_direction = "_d"
	elif (angle < 60 && angle > 0 || angle < 0 && angle > -60):
		sprite.play(animation + "_r");
		last_direction = "_r"

func play_direction_attack(direction_target: Vector2, animation: String) -> void:
	var angle := rad_to_deg(position.angle_to_point(direction_target));
	if (angle > -150 && angle < -30):
		sprite.play(animation + "_u");
		last_direction = "_u"
	elif (angle < -150 && angle > -180 || angle < 180 && angle > 150):
		sprite.play(animation + "_l");
		last_direction = "_l"
	elif (angle < 150 && angle > 30):
		sprite.play(animation + "_d");
		last_direction = "_d"
	elif (angle < 30 && angle > 0 || angle < 0 && angle > -30):
		sprite.play(animation + "_r");
		last_direction = "_r"

func on_hit() -> void:
	var player_dmg = player.dmg;
	enemy_health_bar.value -= player_dmg;
	hp -= player_dmg;
	var label = STATUS_INDICATOR.instantiate() as Label;
	label.text = str(player_dmg);
	label.position = Vector2(position.x - 30, position.y - 30);
	get_parent().add_child(label);
	
func on_death() -> void:
	var player_dmg = player.dmg;
	hp -= player_dmg;
	var label = STATUS_INDICATOR.instantiate() as Label;
	label.text = str(player_dmg);
	label.position = Vector2(position.x - 30, position.y - 30);
	get_parent().add_child(label);
	
	enemy_health_bar.queue_free();
	death.emit(self);
	click_collision_shape_2d.set_deferred("disabled", true);
	collision_shape_2d.set_deferred("disabled", true);
	set_physics_process(false);
	sprite.play("death");
	dead = true;
	if (randi() % 2 == 1):
		var heart = HEART_DROP.instantiate() as Area2D;
		heart.global_position = Vector2(position.x + 3, position.y - 15);
		get_parent().call_deferred("add_child", heart);

func _on_attack_range_body_entered(body: Node2D) -> void:
	if (!dead && body == player && attack_speed_cd.is_stopped()):
		attack_finished = false;
		play_direction_attack(player.position, "attack");
		in_range = true;
	elif (body == player):
		in_range = true;

func _on_attack_range_body_exited(body: Node2D) -> void:
	if (body == player):
		in_range = false;

func _on_animated_sprite_2d_animation_finished() -> void:
	if (sprite.animation == "attack_u" 
	 || sprite.animation == "attack_l" 
	 || sprite.animation == "attack_d" 
	 || sprite.animation == "attack_r"): 
		sprite.play("idle" + last_direction)
		attack_finished = true;

func _on_nav_timer_timeout() -> void:
	navigation_agent_2d.target_position = player.global_position;
