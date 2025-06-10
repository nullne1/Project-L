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
@onready var rotation_character: CharacterBody2D = $CharacterBody2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

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
var on_roll_position: Vector2
var rolled = false;
var attack_speed: float = 1.0 / 2.5;
var kinematic_collision: KinematicCollision2D;
var target_arr = Array();

signal attack;

func _ready() -> void:
	attack_speed_cd.wait_time = attack_speed;
	roll_duration.wait_time = 0.2;
	roll_cd.wait_time = 1;
	
func _physics_process(delta: float) -> void:
	attacking = !attack_animation.is_stopped();
	
	if (hovering_enemy && enemy && Input.is_action_just_pressed("attack") && attack_speed_cd.is_stopped()):
		shoot();

	if (Input.is_action_pressed("move") && (roll_duration.time_left < 0.1 || !rolling)):
		target = get_global_mouse_position();
		move(target);

	if (Input.is_action_just_pressed("roll")):
		roll();
		
	if (position.distance_to(target) > 3 && !attacking):
		kinematic_collision = move_and_collide(velocity * delta);
		
	if (velocity == Vector2(0, 0) || kinematic_collision && kinematic_collision.get_collider()):
		sprite.play("idle");
	
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
	
func roll() -> void:
	if (!roll_cd.is_stopped()):
		return;
	target = get_global_mouse_position();
	print(position.angle_to(target))
	if (target.distance_to(position) > 150):
		collision_shape_2d.disabled = true;
		rolled = true;
		roll_cd.start()
		rolling = true;
		velocity = (target - position).normalized() * (ms + 700);
		roll_duration.start();
	else:
		rolled = false;
	
func shoot() -> void:
	emit_signal("attack");
	var local_target = get_local_mouse_position();
	if (local_target.x <= 0):
		sprite.flip_h = true;
	else:
		sprite.flip_h = false;
	rotation_character.look_at(enemy.position);
	var projectile = projectile_path.instantiate();
	projectile.enemy_to_hit = enemy;
	projectile.direction = rotation_character.rotation;
	projectile.global_position = global_position;
	projectile.global_rotation = rotation_character.global_rotation;
	get_parent().add_child(projectile);
	attack_animation.start();
	attack_speed_cd.start();
	velocity = Vector2(0, 0);

func move(target) -> void:
	# Creates a target area to play "idle" when player enters that area
	if (target_arr.size() > 0):
		for t in target_arr:
			if (t):
				t.queue_free();
	var target_area = target_path.instantiate() as Area2D;
	get_parent().add_child(target_area);
	target_area.global_position = target;
	target_arr.append(target_area);
	
	velocity = (target - position).normalized() * ms;
	rolled = false;
	var local_target = get_local_mouse_position();
	if (local_target.x <= 0):
		sprite.flip_h = true;
	else:
		sprite.flip_h = false;
	sprite.play("run");

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
		enemy.get_child(0).texture = normal_texture;
	
func _on_roll_duration_timeout() -> void:
	rolling = false;
	collision_shape_2d.disabled = false;
	if (rolled):
		velocity = (target - position).normalized() * ms;
