extends CharacterBody2D

const SWORD_SLASH_PATH = preload("res://Scenes/Enemies/sword_slash.tscn")

@onready var hp := 100;
@onready var player: CharacterBody2D = $"../../User/Player"
@onready var asprite: Sprite2D = $Sprite2D
@onready var enemy_health_bar: TextureProgressBar = %EnemyHealthBar
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_speed_cd: Timer = $AttackSpeedCD
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D

@export var ms := 100;
var in_range := false;
var last_direction: String;
var attack_finished: bool = true;
var sword_slash_area: Area2D;

func _ready() -> void:
	attack_speed_cd.wait_time = 1;

func _physics_process(_delta: float) -> void:
	enemy_health_bar.value = hp;
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
		
	if (hp <= 0):
		queue_free();

func sword_attack() -> void:
	sword_slash_area = SWORD_SLASH_PATH.instantiate();
	add_child(sword_slash_area);
	sword_slash_area.rotation_degrees = rad_to_deg(get_angle_to(player.collision_shape_2d.global_position)) - 90;
	sword_slash_area.global_position = global_position;
	attack_speed_cd.start();
	
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

func _on_attack_range_body_entered(body: Node2D) -> void:
	if (body == player && attack_speed_cd.is_stopped()):
		attack_finished = false;
		play_direction_attack(player.position, "attack");
		in_range = true;
	elif (body == player):
		in_range = true;

func _on_attack_range_body_exited(body: Node2D) -> void:
	if (body == player):
		in_range = false;
	
func _on_animated_sprite_2d_animation_finished() -> void:
	if (sprite.animation == "attack_u" || sprite.animation == "attack_l" || sprite.animation == "attack_d" || sprite.animation == "attack_r"): 
		sprite.play("idle" + last_direction)
		sword_slash_area.find_child("CollisionShape2D").queue_free();
		sword_slash_area.queue_free();
		attack_finished = true;

# spawn sword attack hitbox on frame 4 of attack
func _on_animated_sprite_2d_frame_changed() -> void:
	if (sprite.frame == 4 && (sprite.animation == "attack_u" || sprite.animation == "attack_l" || sprite.animation == "attack_d" || sprite.animation == "attack_r")): 
		sword_attack();

func _on_nav_timer_timeout() -> void:
	navigation_agent_2d.target_position = player.global_position;
