extends CharacterBody2D
@onready var mob_manager: Node2D = %MobManager
@onready var dodge_icon: TextureProgressBar = %DodgeIcon

@onready var attack_speed_cd: Timer = $AttackSpeedCD
@onready var attack_animation: Timer = $AttackAnimation
@onready var enemies = mob_manager.enemies;
@onready var i_time: Timer = $"I-time"
@onready var roll_cd: Timer = $RollCD
@onready var roll_duration: Timer = $RollDuration
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var heart_h_box_container: HBoxContainer = %HeartHBoxContainer

const ARROW_PATH = preload("res://Scenes/Player/arrow.tscn");
const TARGET_PATH = preload("res://Scenes/Player/target.tscn");
const hover_cursor = preload("res://Assets/UI/StoneCursorWenrexa/PNG/05.png");
const normal_cursor = preload("res://Assets/UI/StoneCursorWenrexa/PNG/01.png");
const HEART = preload("res://Scenes/Player/heart.tscn");

@export var num_hearts := 3;
@export var ms := 140;
@export var attacks_per_second: float;
var attack_speed: float;
var target := position;
var hovering_enemy: bool;
var attacking: bool;
var rolling: bool;
var doing_action: bool;
var enemy: CharacterBody2D;
var enemy_to_hit: CharacterBody2D;
var hovered_enemies: Array = [];
var kinematic_collision: KinematicCollision2D;
var target_arr = Array();
var roll_target: Vector2;
var roll_speed: float;
var last_direction: String;
var cancelled: bool;
var changed_target: bool;
var arrow: CharacterBody2D;
var after_roll_auto_target: Area2D;
var after_roll_auto_move: bool;
var hearts: Array;
var dead:= false;
var direction;
var move_while_roll: bool;

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
	roll_cd.wait_time = 4;
	roll_speed = ms / 24;
	dodge_icon.max_value = roll_cd.wait_time;
	
	# hearts
	for i in num_hearts:
		var new_heart = HEART.instantiate() as TextureRect;
		heart_h_box_container.add_child(new_heart);
		hearts.append(new_heart);
	
	
func _physics_process(_delta: float) -> void:
	if (!dead && hovering_enemy && enemy && Input.is_action_pressed("attack") && attack_speed_cd.is_stopped()):
		draw_bow();

	if (!dead && (Input.is_action_just_pressed("move") || Input.is_action_pressed("hold_move"))):
		if (!attack_animation.is_stopped()):
			cancelled = true;
		if (rolling):
			move_while_roll = true;
		move();

	if (!dead && Input.is_action_pressed("roll")):
		if (!attack_animation.is_stopped()):
			cancelled = true;
		roll();
		
	if (position.distance_to(target) > 3 && !move_while_roll):
		move_and_slide();
		
	if (rolling):
		position += roll_target.normalized() * roll_speed;
		
	if (!roll_cd.is_stopped()):
		dodge_icon.value = dodge_icon.max_value - roll_cd.time_left;

	if (after_roll_auto_move && sprite.animation == "idle_u" || sprite.animation == "idle_l" || sprite.animation == "idle_d" || sprite.animation == "idle_r"):
		#velocity = Vector2.ZERO;
		after_roll_auto_move = false;
	
	# abilities
	
	# death

func death() -> void:
	dead = true;
	velocity = Vector2.ZERO;
	sprite.play("death");

func lose_heart() -> void:
	if (hearts.back()):
		hearts.back().queue_free();
		hearts.pop_back();
	else: death();
	
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
	cancelled = false;
	play_direction(enemy.position, "draw");
	attack_animation.start();
	attack_speed_cd.start();
	velocity = Vector2(0, 0);

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
		after_roll_auto_target.queue_free();
	target = get_global_mouse_position();
	var target_area = TARGET_PATH.instantiate() as Area2D;
	get_parent().add_child(target_area);
	target_area.global_position = target;
	target_arr.append(target_area);
	navigation_agent_2d.target_position = target
	var dir = to_local(navigation_agent_2d.get_next_path_position()).normalized()
	velocity = dir * ms;
	#velocity = (target - position).normalized() * ms;
	
	play_direction(target, "run");

func _on_click_hitbox_mouse_entered(enemyNodePath : NodePath):
	enemy = get_node(enemyNodePath);
	hovering_enemy = true;
	Input.set_custom_mouse_cursor(hover_cursor)
	hovered_enemies.append(enemy);

func _on_click_hitbox_mouse_exited():
	if (hovered_enemies.size() > 1):
		hovering_enemy = true;
	else:
		hovering_enemy = false;
		Input.set_custom_mouse_cursor(normal_cursor);
	hovered_enemies.clear();
	
func _on_roll_duration_timeout() -> void:
	move_while_roll = false;
	if (after_roll_auto_move && after_roll_auto_target && !move_while_roll):
		var dir = to_local(navigation_agent_2d.get_next_path_position()).normalized();
		velocity = dir * ms;
		play_direction(after_roll_auto_target.position, "run");
	collision_shape_2d.disabled = false;
	rolling = false;
	
func _on_archer_animation_finished() -> void:
	if (sprite.animation == "death"):
		get_tree().paused = true;
	else:
		sprite.play("idle" + last_direction);

func _on_attack_animation_timeout() -> void:
	# attack can be cancelled by inputting another action
	if (cancelled): attack_speed_cd.stop();
	# creates projectile after animation finishes and if not cancelled
	
func _on_archer_frame_changed() -> void:
	if (sprite.frame == 8 && enemy && (sprite.animation == "draw_u" || sprite.animation == "draw_l" || sprite.animation == "draw_d" || sprite.animation == "draw_r")):
		direction = position.angle_to_point(enemy.position);
		arrow = ARROW_PATH.instantiate();
		arrow.enemy_to_hit = enemy;
		arrow.direction = direction;
		arrow.global_position = global_position;
		arrow.global_rotation = direction;
		get_parent().add_child(arrow);
