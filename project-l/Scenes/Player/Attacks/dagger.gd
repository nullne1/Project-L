extends Projectile

signal add_player_xp;

@onready var dagger_icon: TextureProgressBar = $"../../Control/CanvasLayer/TextureRect/HBoxContainer/DaggerIcon"

func _init() -> void:
	speed = 260;

func _on_area_2d_body_entered(body: Node2D) -> void:
	if (body == tile_map):
		queue_free();
	elif (body == enemy_to_hit):
		queue_free();
		# enemy hit
		if (enemy_to_hit.hp - player.dmg > 0):
			enemy_to_hit.on_hit();
		# enemy death
		else:
			# connect signals for adding xp and enemy death on enemy death
			player.dagger_icon.value = player.dagger_icon.min_value;
			player.dagger_cd.stop();
			add_player_xp.connect(player.add_xp);
			add_player_xp.emit();
			enemy_to_hit.on_death();
		
			
			
	
		
