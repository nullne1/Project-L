class_name PierceProjectileStrategy
extends BaseProjectileStrategy

var text = "+1 Arrow Pierce";

func apply_upgrade(projectile: Projectile):
	projectile.pierce += 1;
