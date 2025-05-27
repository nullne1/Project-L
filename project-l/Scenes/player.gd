extends CharacterBody2D

var health := 100;
var ms := 350;
var target := position;
var hovering_enemy: bool;
@onready var mob_manager: Node2D = %MobManager
@onready var attack_speed_cd: Timer = $AttackSpeedCD
@onready var attack_animation: Timer = $AttackAnimation
var attacking: bool;
var enemy: CharacterBody2D;
@onready var enemies = mob_manager.enemies;
@onready var i_time: Timer = $"I-time"
@onready var player_health_bar: TextureProgressBar = %PlayerHealthBar
@onready var roll_cd: Timer = $RollCD
@onready var roll_duration: Timer = $RollDuration
var projectile_path = preload("res://Scenes/arrow.tscn");
var enemy_to_hit: CharacterBody2D;
var rolling: bool;
var doing_action: bool;
var hovered_texture = preload("res://Assets/topdown_textures/hoveredZombie.png");
var normal_texture = preload("res://Assets/topdown_textures/zombie.png");
var hovered_enemies: Array = [];
var on_roll_position: Vector2
var rolled = false;
var attack_speed: float = 1.0 / 2.5;

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
		move();

	if (Input.is_action_just_pressed("roll")):
		roll();
		
	if (position.distance_to(target) > 3 && !attacking):
		move_and_slide();
	# abilities
	# enemy colliding
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		velocity = Vector2(0, 0);
		if (collision.get_collider() in enemies && i_time.time_left == 0):
			player_health_bar.value -= 0;
			health -= 0;
			i_time.start()
	# death
	if (health <= 0):
		queue_free()
	
func roll() -> void:
	if (!roll_cd.is_stopped()):
		return;
	target = get_global_mouse_position();
	if (target.distance_to(position) > 150):
		rolled = true;
		if (!attacking):
			look_at(target);
		roll_cd.start()
		rolling = true;
		velocity = (target - position).normalized() * (ms + 500);
		roll_duration.start();
	else:
		rolled = false;

func shoot() -> void:
	emit_signal("attack");
	enemy_to_hit = enemy;
	look_at(enemy.position);
	var projectile = projectile_path.instantiate();
	projectile.direction = rotation;
	projectile.global_position = global_position;
	projectile.global_rotation = global_rotation;
	get_parent().add_child(projectile);
	attack_animation.start();
	attack_speed_cd.wait_time = 1/4;
	attack_speed_cd.start();
	velocity = Vector2(0, 0);

func move() -> void:
	rolled = false;
	target = get_global_mouse_position();
	if (!attacking):
		look_at(target);
	velocity = (target - position).normalized() * ms;

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
		enemy.get_child(0).texture = hovered_texture;
		if (prev_enemy):
			prev_enemy.get_child(0).texture = normal_texture;
		if (prev_prev_enemy):
			prev_prev_enemy.get_child(0).texture = normal_texture;
	# hovered enemy though another enemy
	if (hovered_enemies.size() == 1):
		hovering_enemy = true;
		enemy.get_child(0).texture = hovered_texture;
		if (prev_enemy):
			prev_enemy.get_child(0).texture = normal_texture;
	else:
		enemy.get_child(0).texture = normal_texture;
	
func getEnemyToHit() -> CharacterBody2D:
	return enemy;
	
func _on_roll_duration_timeout() -> void:
	rolling = false;
	if (rolled):
		velocity = (target - position).normalized() * ms;

#func _on_enemy_mouse_entered(enemyNodePath : NodePath) -> void:
	#enemy = get_node(enemyNodePath);
	#hovering_enemy = true;
	#var prevHoveredEnemy = hovered_stack.pop_front()
	#if (prevHoveredEnemy == null):
		#enemy.get_child(0).texture = hovered_texture;
		#hovered_stack.push_front(enemy);	
	#else:
		#prevHoveredEnemy.get_child(0).texture = normal_texture;
	#
#func _on_enemy_mouse_exited() -> void:
	#hovering_enemy = false;
	#if (enemy):
		#enemy.get_child(0).texture = normal_texture;
		#hovered_stack.pop_front();
