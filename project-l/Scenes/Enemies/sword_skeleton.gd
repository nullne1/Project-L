extends Enemy

const SWORD_SLASH_PATH = preload("res://Scenes/Enemies/sword_slash.tscn")

var sword_slash: Area2D;

#func _ready() -> void:
	#sprite.animation_finished.connect(_on_animation_sprite_2d_animation_finished);

func sword_attack() -> void:
	sword_slash = SWORD_SLASH_PATH.instantiate();
	add_child(sword_slash);
	sword_slash.rotation_degrees = rad_to_deg(get_angle_to(player.collision_shape_2d.global_position)) - 90;
	sword_slash.global_position = global_position;
	attack_speed_cd.start();

# spawn sword attack hitbox on frame 4 of attack
func _on_animated_sprite_2d_frame_changed() -> void:
	if (sprite.frame == 4 && (sprite.animation == "attack_u" 
						   || sprite.animation == "attack_l" 
						   || sprite.animation == "attack_d" 
						   || sprite.animation == "attack_r")): 
		sword_attack();
	elif (sprite.frame == 5 && (sprite.animation == "attack_u" 
							 || sprite.animation == "attack_l" 
							 || sprite.animation == "attack_d" 
							 || sprite.animation == "attack_r")):
		sword_slash.find_child("CollisionShape2D").queue_free();
		sword_slash.queue_free();

#func _on_animation_sprite_2d_animation_finished() -> void:
	#print(sprite.animation)
	#if (sprite.animation == "attack_u" 
	  #|| sprite.animation == "attack_l" 
	  #|| sprite.animation == "attack_d" 
	  #|| sprite.animation == "attack_r"): 
		#print("hello")
		#sword_slash.find_child("CollisionShape2D").queue_free();
		#sword_slash.queue_free();
