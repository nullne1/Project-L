extends Projectile

signal add_player_xp;

@onready var dagger_icon: TextureProgressBar = $"../../Control/CanvasLayer/TextureRect/HBoxContainer/DaggerIcon"

func ready() -> void:
	global_position = pos;
	global_rotation = rota;
	enemy_to_hit_death.connect(enemy_to_hit.on_death);
	hit_enemy_to_hit.connect(enemy_to_hit.on_hit);
	
func _physics_process(_delta: float) -> void:
	velocity = Vector2(speed, 0).rotated(direction);
	move_and_slide();
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if (body == tile_map):
		queue_free();
	elif (body == enemy_to_hit):
		queue_free();
		if (enemy_to_hit.hp - player.dmg >= player.dmg):
			hit_enemy_to_hit.connect(enemy_to_hit.on_hit);
			hit_enemy_to_hit.emit();
		else:
			player.dagger_icon.value = player.dagger_icon.min_value;
			player.dagger_cd.stop();
			add_player_xp.connect(player.add_xp);
			add_player_xp.emit();
			enemy_to_hit_death.connect(enemy_to_hit.on_death);
			enemy_to_hit_death.emit();
		
			
			
	
		
