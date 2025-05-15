extends CharacterBody2D

var health := 100;
var ms := 350;
var target := position;
var hover: bool;
@onready var mob_manager: Node2D = %MobManager
@onready var attack_speed_cd: Timer = $AttackSpeedCD
@onready var attack_animation: Timer = $AttackAnimation
var attacking: bool;
var enemy: CharacterBody2D;
@onready var attackSpeed = attack_speed_cd.wait_time;
@onready var enemies = mob_manager.enemies;
@onready var i_time: Timer = $"I-time"
@onready var player_health_bar: TextureProgressBar = %PlayerHealthBar
@onready var roll_cd: Timer = $RollCD
@onready var roll_duration: Timer = $RollDuration
var projectile_path = preload("res://Scenes/arrow.tscn");
var enemyToHit: CharacterBody2D;
var rolling: bool;
var doingAction: bool;
var gitTest;
var gitTest1;

signal attack;

func _ready() -> void:
	print(projectile_path)
	attack_speed_cd.wait_time = 0.5;
	roll_duration.wait_time = 0.2;
	
func _physics_process(delta: float) -> void:
	attacking = !attack_animation.is_stopped();

	if (hover && enemy && Input.is_action_pressed("attack") && attack_speed_cd.is_stopped()):
		shoot();

	if (Input.is_action_just_pressed("move") && (roll_duration.time_left < 0.1 || !rolling)):
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
	rolling = true;
	target = get_global_mouse_position();
	if (!attacking):
		look_at(target);
	print(target - position)
	velocity = (target - position).normalized() * (ms + 500);
	roll_duration.start();

func shoot() -> void:
	emit_signal("attack");
	enemyToHit = enemy;
	look_at(enemy.position);
	var projectile = projectile_path.instantiate();
	projectile.direction = rotation;
	projectile.global_position = global_position;
	projectile.global_rotation = global_rotation;
	get_parent().add_child(projectile);
	attack_animation.start();
	attack_speed_cd.start();
	velocity = Vector2(0, 0);

func move() -> void:
	target = get_global_mouse_position();
	if (!attacking):
		look_at(target);
	velocity = (target - position).normalized() * ms;

func _on_enemy_mouse_entered(enemyNodePath : NodePath) -> void:
	enemy = get_node(enemyNodePath);
	hover = true;

func _on_enemy_mouse_exited() -> void:
	hover = false;
	
func getEnemyToHit() -> CharacterBody2D:
	return enemyToHit;
	
func _on_roll_duration_timeout() -> void:
	rolling = false;
	velocity = (target - position).normalized() * ms;
