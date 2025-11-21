extends Node

const UPGRADE_MENU = preload("res://Scenes/UI/LevelUI/upgrade_menu.tscn")

@onready var player: CharacterBody2D = %Player
@onready var stat_upgrades:= {"Max Hearts": {"max_hearts": [1, 2]}, 
						 "Attack Speed": {"attacks_per_second": [10, 20]}, 
						 "Attack Damage": {"dmg": [1, 3]},
						 "Move Speed": {"ms": [2, 5]}};

@export var possible_upgrades: Array[BaseProjectileStrategy] = [];

func _ready() -> void:
	print(possible_upgrades.get(0))
	player.level_up.connect(on_player_level_up);

func on_player_level_up() -> void:
	var upgrade_menu = UPGRADE_MENU.instantiate() as Control;
	for i in 3:
		var upgrade_button = upgrade_menu.find_child("Button" + str(i), true);
		var upgrade = possible_upgrades.get(randi_range(0, possible_upgrades.size() - 1));
		upgrade_button.pressed.connect(on_upgrade_button_pressed.bind(upgrade_button, upgrade));
		upgrade_button.text = upgrade.text;
	player.add_child(upgrade_menu);
	get_tree().paused = true;
	#var upgrade_names_list = stat_upgrades.keys();
	#var popped_upgrades: Array;
	#for i in 3:
		#var upgrade_button = upgrade_menu.find_child("Button" + str(i), true);
		## gets a key (upgrade name) from upgrade names, pops it into popped_upgrades, which is then appended to upgrade names list
		#var upgrade_key = upgrade_names_list.pop_at(randi_range(0, upgrade_names_list.size() - 1));
		#var upgrade_range = stat_upgrades.get(upgrade_key).values().get(0);
		#var amount = randi_range(upgrade_range.get(0), upgrade_range.get(1));
		#upgrade_button.pressed.connect(on_upgrade_button_pressed.bind(upgrade_button, upgrade_key, amount));
		#upgrade_button.text = "+" + str(amount) + " " + upgrade_key;
		#popped_upgrades.append(upgrade_key);
	#upgrade_names_list.append_array(popped_upgrades);

func on_upgrade_button_pressed(button: Button, upgrade: BaseProjectileStrategy) -> void:
	player.upgrades.append(upgrade);
	get_tree().paused = false;
