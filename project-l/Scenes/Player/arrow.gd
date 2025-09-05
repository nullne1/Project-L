extends Projectile
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if (body == tile_map):
		queue_free();
	elif (body == enemy_to_hit):
		queue_free();
		if (enemy_to_hit.hp - player.dmg >= player.dmg):
			hit_enemy_to_hit.connect(enemy_to_hit.on_hit);
			hit_enemy_to_hit.emit();
		else:
			enemy_to_hit_death.connect(enemy_to_hit.on_death);
			enemy_to_hit_death.emit();
			
			
	
		
