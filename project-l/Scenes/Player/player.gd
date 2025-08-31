extends CharacterBody2D

const ARROW_PATH = preload("res://Scenes/Player/arrow.tscn")
const TARGET_PATH = preload("res://Scenes/Player/target.tscn")
const HOVER_CURSOR = preload("res://Assets/UI/StoneCursorWenrexa/PNG/05.png")
const NORMAL_CURSOR = preload("res://Assets/UI/StoneCursorWenrexa/PNG/01.png")
const HEART = preload("res://Scenes/Player/heart.tscn")
const DAGGER = preload("res://Scenes/Player/dagger.tscn")
const STATUS_INDICATOR = preload("res://Scenes/UI/status_indicator.tscn")

@export var num_hearts: int;
@export var ms := 140;
@export var attacks_per_second := 2.5;
@export var level: int;
@export var xp: int;
@export var dmg := 20;

var hearts: Array;
var attack_speed: float;
var target := position;
var attacking: bool;
var rolling: bool;
var enemy: CharacterBody2D;
var target_arr = Array();
var roll_target: Vector2;
var roll_speed: float;
var last_direction: String;
var after_roll_auto_target: Area2D;
var after_roll_auto_move: bool;
var dead:= false;
var move_while_roll: bool;
var clicked_on_enemy: CharacterBody2D;
var throw_dagger_arr: Array = ["throw_dagger_u", "throw_dagger_l", "throw_dagger_d", "throw_dagger_r"];
var action_buffered

@onready var dodge_icon: TextureProgressBar = %DodgeIcon
@onready var heart_h_box_container: HBoxContainer = %HeartHBoxContainer
@onready var dagger_icon: TextureProgressBar = %DaggerIcon
@onready var level_progress: TextureProgressBar = %LevelProgress
@onready var mob_manager: Node = %MobManager

@onready var attack_speed_cd: Timer = $AttackSpeedCD
@onready var attack_animation: Timer = $AttackAnimation
@onready var i_time: Timer = $"I-time"
@onready var roll_cd: Timer = $RollCD
@onready var roll_duration: Timer = $RollDuration
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var dagger_cd: Timer = $DaggerCD

func _ready() -> void:
	# Sets animation, attack speed cooldown, and animation frames based on attacks per second
	attack_speed = 1.0 / attacks_per_second;
	attack_animation.wait_time = attack_speed / 2.5;
	attack_speed_cd.wait_time = attack_speed;
	sprite.sprite_frames.set_animation_speed("draw_l", attacks_per_second * 22);
	sprite.sprite_frames.set_animation_speed("draw_d", attacks_per_second * 22);
	sprite.sprite_frames.set_animation_speed("draw_r", attacks_per_second * 22);
	sprite.sprite_frames.set_animation_speed("draw_u", attacks_per_second * 22);
	
	roll_duration.wait_time = ms / 1000 + 0.25;
	roll_cd.wait_time = 2;
	roll_speed = ms / 24;
	dodge_icon.max_value = roll_cd.wait_time;
	dagger_icon.max_value = dagger_cd.wait_time;
	
	# hearts
	for i in num_hearts:
		var new_heart = HEART.instantiate() as TextureRect;
		heart_h_box_container.add_child(new_heart);
		hearts.append(new_heart);
	
func _physics_process(_delta: float) -> void:
	if (sprite.animation not in throw_dagger_arr):
			
		if (enemy && Input.is_action_pressed("attack") && attack_speed_cd.is_stopped() && !after_roll_auto_move):
			clicked_on_enemy = enemy;
			draw_bow();

		if ((Input.is_action_just_pressed("move") || Input.is_action_pressed("hold_move"))):
			if (rolling && !clicked_on_enemy):
				move_while_roll = true;
			move();

		if (Input.is_action_pressed("roll")):
			roll();
		
	if (enemy && Input.is_action_pressed("throw_dagger") && dagger_cd.is_stopped() && !after_roll_auto_move):
		clicked_on_enemy = enemy;
		throw_dagger();
		
	if (position.distance_to(target) > 3 && !move_while_roll && !rolling):
		move_and_slide();
		
	if (rolling):
		position += roll_target.normalized() * roll_speed;
		
	if (!roll_cd.is_stopped()):
		dodge_icon.value = dodge_icon.max_value - roll_cd.time_left;
	
	if (!dagger_cd.is_stopped()):
		dagger_icon.value = dagger_icon.max_value - dagger_cd.time_left;

	if (after_roll_auto_move && sprite.animation == "idle_u" 
							 || sprite.animation == "idle_l" 
							 || sprite.animation == "idle_d" 
							 || sprite.animation == "idle_r"):
		after_roll_auto_move = false;

func throw_dagger() -> void:
	if (target_arr.size() > 0 && target_arr.get(0)): target_arr.get(0).queue_free();
	velocity = Vector2(0, 0);
	dagger_cd.start();
	play_direction(enemy.position, "throw_dagger");
	#dagger_icon.value = 0;
	

func death() -> void:
	set_physics_process(false);
	dead = true;
	velocity = Vector2.ZERO;
	sprite.play("death");

func lose_heart() -> void:
	if (hearts.back()):
		hearts.back().queue_free();
		hearts.pop_back();
	if (hearts.is_empty()): death();
	
func gain_heart() -> void:
	var new_heart = HEART.instantiate() as TextureRect;
	heart_h_box_container.add_child(new_heart);
	hearts.append(new_heart);

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

func draw_bow() -> void:
	if (target_arr.size() > 0 && target_arr.get(0)): target_arr.get(0).queue_free();
	velocity = Vector2(0, 0);
	play_direction(enemy.position, "draw");
	attack_animation.start();
	attack_speed_cd.start();

func roll() -> void:
	if (!roll_cd.is_stopped()): return;
	if (target_arr.size() > 0 && target_arr.get(0)):
		#print("distance from mouse: ", position.distance_to(target_arr.get(0).position));
		after_roll_auto_target = target_arr.get(0);
		after_roll_auto_move = true;
	
	dodge_icon.value = 0;
	collision_shape_2d.disabled = true;
	target_arr.clear()
	rolling = true;
	roll_cd.start()
	roll_duration.start();
	velocity = Vector2.ZERO;
	roll_target = get_local_mouse_position();
	target = get_global_mouse_position()
	play_direction(target, "dodge");

func move() -> void:
	# creates a target area to play "idle" when player enters that area
	if (target_arr.size() > 0):
		for n in range(target_arr.size()):
			var t = target_arr.pop_at(n);
			if (t):
				t.queue_free();
				
	if (after_roll_auto_move && after_roll_auto_target):
		after_roll_auto_move = false;
		after_roll_auto_target.queue_free();
		
	target = get_global_mouse_position();
	var target_area = TARGET_PATH.instantiate() as Area2D;
	get_parent().add_child(target_area);
	target_area.global_position = target;
	target_arr.append(target_area);
	
	navigation_agent_2d.target_position = target
	var dir = to_local(navigation_agent_2d.get_next_path_position()).normalized()
	velocity = dir * ms;
	
	if (!rolling):
		play_direction(target, "run");

func add_xp() -> void:
	xp += 10;
	level_progress.value += 10;
	var label = STATUS_INDICATOR.instantiate() as Label;
	label.text = "10xp";
	label.position = Vector2(position.x - 30, position.y - 30);
	get_parent().add_child(label);

func _on_click_hitbox_mouse_entered(enemy_node: CharacterBody2D):
	if (enemy != enemy_node):
		enemy = enemy_node;
		Input.set_custom_mouse_cursor(HOVER_CURSOR);
		
		
func _on_click_hitbox_mouse_exited(enemy_node: CharacterBody2D):
	if (enemy == enemy_node):
		enemy = null;
		Input.set_custom_mouse_cursor(NORMAL_CURSOR);
		
func _on_roll_duration_timeout() -> void:
	attack_speed_cd.stop();
	rolling = false;
	move_while_roll = false;
	if (after_roll_auto_move && after_roll_auto_target):
		var dir = to_local(navigation_agent_2d.get_next_path_position()).normalized();
		velocity = dir * ms;
		play_direction(after_roll_auto_target.position, "run");
	collision_shape_2d.disabled = false;

func _on_animated_sprite_2d_animation_finished() -> void:
	if (sprite.animation == "death"):
		get_tree().paused = true;
	else:
		pass
		sprite.play("idle" + last_direction);

func _on_animated_sprite_2d_frame_changed() -> void:
	if (sprite && sprite.frame == 8 && (sprite.animation == "draw_u" 
									 || sprite.animation == "draw_l" 
									 || sprite.animation == "draw_d" 
									 || sprite.animation == "draw_r")):
		var direction = position.angle_to_point(clicked_on_enemy.position);
		var arrow = ARROW_PATH.instantiate() as CharacterBody2D;
		arrow.enemy_to_hit = clicked_on_enemy;
		arrow.direction = direction;
		arrow.global_position = global_position;
		arrow.global_rotation = direction;
		get_parent().add_child(arrow);
	elif (sprite && sprite.frame == 5 && (sprite.animation == "throw_dagger_u" 
									   || sprite.animation == "throw_dagger_l" 
									   || sprite.animation == "throw_dagger_d" 
									   || sprite.animation == "throw_dagger_r")):
		var direction = position.angle_to_point(clicked_on_enemy.position);
		var dagger = DAGGER.instantiate() as CharacterBody2D;
		dagger.enemy_to_hit = clicked_on_enemy;
		dagger.direction = direction;
		dagger.global_position = global_position;
		dagger.global_rotation = direction;
		get_parent().add_child(dagger);

#func on_enemy_death(dead_enemy_path):
	#last_dead_enemy = dead_enemy_path;
	
func _on_roll_cd_timeout() -> void:
	dodge_icon.value = dodge_icon.min_value;

func _on_dagger_cd_timeout() -> void:
	dagger_icon.value = dagger_icon.min_value;

func _on_level_progress_value_changed(value: float) -> void:
	if (value == 100):
		level += 1;
