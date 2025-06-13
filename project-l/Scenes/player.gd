extends CharacterBody2D

@onready var mob_manager: Node2D = %MobManager
@onready var player_health_bar: TextureProgressBar = %PlayerHealthBar

@onready var attack_speed_cd: Timer = $AttackSpeedCD
@onready var attack_animation: Timer = $AttackAnimation
@onready var enemies = mob_manager.enemies;
@onready var i_time: Timer = $"I-time"
@onready var roll_cd: Timer = $RollCD
@onready var roll_duration: Timer = $RollDuration
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var rotation_character: CharacterBody2D = $RotationCharacter
@onready var sprite: AnimatedSprite2D = $Archer

var hovered_texture = preload("res://Assets/topdown_textures/hovered_zombie.png");
var normal_texture = preload("res://Assets/topdown_textures/zombie.png");
var projectile_path = preload("res://Scenes/arrow.tscn");
var target_path = preload("res://Scenes/target.tscn");

var health := 100;
var ms := 300;
var target := position;
var hovering_enemy: bool;
var attacking: bool;
var rolling: bool;
var doing_action: bool;
var enemy: CharacterBody2D;
var enemy_to_hit: CharacterBody2D;
var hovered_enemies: Array = [];
var attack_speed: float = 1.0 / 2.5;
var kinematic_collision: KinematicCollision2D;
var target_arr = Array();
var roll_target: Vector2;
var roll_speed: float;
var last_direction: String;
var cancelled: bool;

signal attack;

func _ready() -> void:
	attack_speed_cd.wait_time = attack_speed;
	roll_duration.wait_time = 0.27;
	roll_cd.wait_time = 1;
	roll_speed = 12.5;
	
func _physics_process(delta: float) -> void:
	attacking = !attack_animation.is_stopped();
	if (hovering_enemy && enemy && Input.is_action_just_pressed("attack") && attack_speed_cd.is_stopped()):
		draw();

	if (Input.is_action_pressed("move") && (!rolling)):
		if (attacking):
			cancelled = true;
		move();

	if (Input.is_action_just_pressed("roll")):
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
		queue_free()
	
	if (hovered_enemies.size() > 2):
		for en in hovered_enemies:
			if (en):
				en.find_child("Sprite2D").texture = normal_texture;

func play_direction(target, animation) -> void:
	var angle := rad_to_deg(position.angle_to_point(target));
	# up
	if (angle > -120 && angle < -60):
		sprite.play(animation + "_u");
		last_direction = "_u"
	# left
	elif (angle < -120 && angle > -180 || angle < 180 && angle > 120):
		sprite.play(animation + "_l");
		last_direction = "_l"
	# down
	elif (angle < 120 && angle > 60):
		sprite.play(animation + "_d");
		last_direction = "_d"
	# right
	elif (angle < 60 && angle > 0 || angle < 0 && angle > -60):
		sprite.play(animation + "_r");
		last_direction = "_r"
	
		

func roll() -> void:
	if (!roll_cd.is_stopped()):
		return;
	rolling = true;
	roll_cd.start()
	roll_duration.start();
	velocity = Vector2.ZERO;
	roll_target = get_local_mouse_position();
	target = get_global_mouse_position()
	play_direction(target, "dodge");
	#sprite.play("rolling");
	#flip
		
	# remove previous target area2Ds
	#if (target_arr.size() > 0):
		#for t in target_arr:
			#if (t):
				#t.queue_free();
	#
	#if (target.distance_to(position) > 150):
		# creates a target area to play "idle" when player enters that area
		#target = get_global_mouse_position();
		#var target_area = target_path.instantiate() as Area2D;
		#get_parent().add_child(target_area);
		#target_area.global_position = target;
		#target_arr.append(target_area);
		#
		#rolled = true;
		#rolling = true;
		#velocity = (target - position).normalized() * (ms + 700);
		#roll_cd.start()
		#roll_duration.start();
		#sprite.play("rolling");
	#else:
		#rolled = false;
	# flip
	
	
func draw() -> void:
	cancelled = false;
	emit_signal("attack");
	play_direction(enemy.position, "draw");
	# uses rotation character to set projectile's rotation
	rotation_character.look_at(enemy.position);
	attack_animation.start();
	attack_speed_cd.start();
	velocity = Vector2(0, 0);

func move() -> void:
	# creates a target area to play "idle" when player enters that area
	if (target_arr.size() > 0):
		for t in target_arr:
			if (t):
				t.queue_free();
	var target_area = target_path.instantiate() as Area2D;
	get_parent().add_child(target_area);
	target_area.global_position = target;
	target_arr.append(target_area);
	
	target = get_global_mouse_position();
	velocity = (target - position).normalized() * ms;
	
	play_direction(target, "run");

func _on_click_hitbox_mouse_entered(enemyNodePath : NodePath):
	enemy = get_node(enemyNodePath);
	hovering_enemy = true;
	hovered_enemies.append(enemy);
	# normal case where you hover and unhover
	if (hovered_enemies.size() == 1):
		enemy.get_child(0).texture = hovered_texture;
	# case where user mouse enters enemy through another enemy
	elif (hovered_enemies.size() == 2):
		enemy.get_child(0).texture = hovered_texture;
		if (hovered_enemies.get(0)):
			hovered_enemies.get(0).get_child(0).texture == normal_texture;

func _on_click_hitbox_mouse_exited():
	hovering_enemy = false;
	var prev_enemy = hovered_enemies.pop_at(0);
	# hovered enemy through 2 other enemies
	if (hovered_enemies.size() == 2):
		hovering_enemy = true;
		var prev_prev_enemy = hovered_enemies.pop_at(0);
		if (enemy):
			enemy.get_child(0).texture = hovered_texture;
		if (prev_enemy):
			prev_enemy.get_child(0).texture = normal_texture;
		if (prev_prev_enemy):
			prev_prev_enemy.get_child(0).texture = normal_texture;
	# hovered enemy though another enemy
	if (hovered_enemies.size() == 1):
		hovering_enemy = true;
		if (enemy):
			enemy.get_child(0).texture = hovered_texture;
		if (prev_enemy):
			prev_enemy.get_child(0).texture = normal_texture;
	else:
		if (enemy):
			enemy.get_child(0).texture = normal_texture;
	
func _on_roll_duration_timeout() -> void:
	rolling = false;
	
func _on_archer_animation_finished() -> void:
	if (sprite.animation == "dodge" + "_u" || sprite.animation == "dodge" + "_l" || sprite.animation == "dodge" + "_d" || sprite.animation == "dodge" + "_r"): 
		sprite.play("idle" + last_direction);

#var local_target = get_local_mouse_position();
	#if (local_target.x <= 0):
		#sprite.flip_h = true;
	#else:
		#sprite.flip_h = false;


func _on_attack_animation_timeout() -> void:
	if (cancelled):
		attack_speed_cd.stop();
		return;
	var projectile = projectile_path.instantiate();
	projectile.enemy_to_hit = enemy;
	projectile.direction = rotation_character.rotation;
	projectile.global_position = global_position;
	projectile.global_rotation = rotation_character.global_rotation;
	get_parent().add_child(projectile);
