extends CharacterBody2D
@onready var mob_manager: Node2D = %MobManager
@onready var player_health_bar: TextureProgressBar = %PlayerHealthBar
@onready var dodge_icon: TextureProgressBar = %DodgeIcon
#test
@onready var attack_speed_cd: Timer = $AttackSpeedCD
@onready var attack_animation: Timer = $AttackAnimation
@onready var enemies = mob_manager.enemies;
@onready var i_time: Timer = $"I-time"
@onready var roll_cd: Timer = $RollCD
@onready var roll_duration: Timer = $RollDuration
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var rotation_character: CharacterBody2D = $RotationCharacter
@onready var sprite: AnimatedSprite2D = $Archer

const ARROW_PATH = preload("res://Scenes/arrow.tscn");
const TARGET_PATH = preload("res://Scenes/target.tscn");
const hover_cursor = preload("res://Assets/UI/StoneCursorWenrexa/PNG/05.png");
const normal_cursor = preload("res://Assets/UI/StoneCursorWenrexa/PNG/01.png");

var health := 100;
var ms := 175;
var attacks_per_second: float;
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

func _ready() -> void:
	# Sets animation, attack speed cooldown, and animation frames based on attacks per second
	attacks_per_second = 2.5;
	attack_speed = 1.0 / attacks_per_second;
	attack_animation.wait_time = attack_speed / 2.5;
	attack_speed_cd.wait_time = attack_speed;
	sprite.sprite_frames.set_animation_speed("draw_u", attacks_per_second * 22);
	sprite.sprite_frames.set_animation_speed("draw_l", attacks_per_second * 22);
	sprite.sprite_frames.set_animation_speed("draw_d", attacks_per_second * 22);
	sprite.sprite_frames.set_animation_speed("draw_r", attacks_per_second * 22);
	
	roll_duration.wait_time = ms / 1000.0 + 0.25;
	roll_cd.wait_time = 1;
	roll_speed = ms / 24.0;
	dodge_icon.max_value = roll_cd.wait_time;
	
func _physics_process(delta: float) -> void:
	attacking = !attack_animation.is_stopped();
	if (hovering_enemy && enemy && Input.is_action_pressed("attack") && attack_speed_cd.is_stopped()):
		draw_bow();

	if ((Input.is_action_just_pressed("move") || Input.is_action_pressed("hold_move")) && !rolling):
		if (attacking):
			cancelled = true;
		move();

	if (Input.is_action_pressed("roll")):
		if (attacking):
			cancelled = true;
		roll();
		
	if (position.distance_to(target) > 3):
		kinematic_collision = move_and_collide(velocity * delta);
		
	# check for collision
	if (kinematic_collision && kinematic_collision.get_collider()):
		#sprite.play("idle");
		pass
		
	if (rolling):
		position += roll_target.normalized() * roll_speed;
		
	if (!roll_cd.is_stopped()):
		dodge_icon.value = dodge_icon.max_value - roll_cd.time_left;
	# abilities
	# enemy colliding
	#for i in get_slide_collision_count():
		#var collision = get_slide_collision(i)
		#velocity = Vector2(0, 0);
		#if (collision.get_collider() in enemies && i_time.time_left == 0):
			#player_health_bar.value -= 0;
			#health -= 0;
			#i_time.start()
	# death
	if (health <= 0):
		sprite.play("death");
	
	#if (hovered_enemies.size() > 2):
		#for en in hovered_enemies:
			#if (en):
				#en.find_child("Sprite2D").texture = normal_texture;

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
		
func roll() -> void:
	if (!roll_cd.is_stopped()): return;
	if (target_arr.size() > 0 && target_arr.get(0)): target_arr.get(0).queue_free();
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
	
func draw_bow() -> void:
	if (target_arr.size() > 0 && target_arr.get(0)): target_arr.get(0).queue_free();
	cancelled = false;
	play_direction(enemy.position, "draw");
	attack_animation.start();
	attack_speed_cd.start();
	velocity = Vector2(0, 0);

func move() -> void:
	# creates a target area to play "idle" when player enters that area
	if (target_arr.size() > 0):
		for n in range(target_arr.size()):
			var t = target_arr.pop_at(n);
			if (t):
				t.queue_free();
	
	target = get_global_mouse_position();
	var target_area = TARGET_PATH.instantiate() as Area2D;
	get_parent().add_child(target_area);
	target_area.global_position = target;
	target_arr.append(target_area);
	
	velocity = (target - position).normalized() * ms;
	
	play_direction(target, "run");

func _on_click_hitbox_mouse_entered(enemyNodePath : NodePath):
	enemy = get_node(enemyNodePath);
	hovering_enemy = true;
	Input.set_custom_mouse_cursor(hover_cursor)
	hovered_enemies.append(enemy);
	## normal case where you hover and unhover
	#if (hovered_enemies.size() == 1):
		#enemy.get_child(0).texture = hovered_texture;
	## case where user mouse enters enemy through another enemy
	#elif (hovered_enemies.size() == 2):
		#enemy.get_child(0).texture = hovered_texture;
		#if (hovered_enemies.get(0)):
			#hovered_enemies.get(0).get_child(0).texture == normal_texture;

func _on_click_hitbox_mouse_exited():
	if (hovered_enemies.size() > 1):
		hovering_enemy = true;
	else:
		hovering_enemy = false;
		Input.set_custom_mouse_cursor(normal_cursor);
	hovered_enemies.clear();
	#var prev_enemy = hovered_enemies.pop_at(0);
	## hovered enemy through 2 other enemies
	#if (hovered_enemies.size() == 2):
		#hovering_enemy = true;
		#var prev_prev_enemy = hovered_enemies.pop_at(0);
		#if (enemy):
			#enemy.get_child(0).texture = hovered_texture;
		#if (prev_enemy):
			#prev_enemy.get_child(0).texture = normal_texture;
		#if (prev_prev_enemy):
			#prev_prev_enemy.get_child(0).texture = normal_texture;
	## hovered enemy though another enemy
	#if (hovered_enemies.size() == 1):
		#hovering_enemy = true;
		#if (enemy):
			#enemy.get_child(0).texture = hovered_texture;
		#if (prev_enemy):
			#prev_enemy.get_child(0).texture = normal_texture;
	#else:
		#if (enemy):
			#enemy.get_child(0).texture = normal_texture;
	
func _on_roll_duration_timeout() -> void:
	collision_shape_2d.disabled = false;
	rolling = false;
	
func _on_archer_animation_finished() -> void:
	# plays idle animation in the direction of the last animation
	if (sprite.animation == "death"):
		get_tree().paused = true;
	else:
		sprite.play("idle" + last_direction);

func _on_attack_animation_timeout() -> void:
	# attack can be cancelled by inputting another action
	if (cancelled): attack_speed_cd.stop();
	# creates projectile after animation finishes and if not cancelled

func _on_archer_frame_changed() -> void:
	if (sprite.frame == 10 && enemy && (sprite.animation == "draw_u" || sprite.animation == "draw_l" || sprite.animation == "draw_d" || sprite.animation == "draw_r")):
		arrow = ARROW_PATH.instantiate();
		arrow.enemy_to_hit = enemy;
		rotation_character.look_at(enemy.position);
		arrow.direction = rotation_character.rotation;
		arrow.global_position = global_position;
		arrow.global_rotation = rotation_character.global_rotation;
		get_parent().add_child(arrow);
