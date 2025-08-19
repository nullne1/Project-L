extends Enemy

const ENEMY_ARROW = preload("res://Scenes/Enemies/enemy_arrow.tscn")

func draw_bow() -> void:
	var direction = position.angle_to_point(Vector2(player.position.x, player.position.y + 12));
	var arrow = ENEMY_ARROW.instantiate() as CharacterBody2D;
	attack_finished = false;
	arrow.enemy_to_hit = player;
	arrow.direction = direction;
	arrow.global_position = global_position;
	arrow.global_rotation = direction;
	get_parent().add_child(arrow);
	attack_speed_cd.start();

# spawn sword attack hitbox on frame 4 of attack
func _on_animated_sprite_2d_frame_changed() -> void:
	if (sprite.frame == 9 && (sprite.animation == "attack_u" 
						   || sprite.animation == "attack_l" 
						   || sprite.animation == "attack_d" 
						   || sprite.animation == "attack_r")): 
		draw_bow();
