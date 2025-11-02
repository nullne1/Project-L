extends Node

const UPGRADE_MENU = preload("res://Scenes/UI/LevelUI/upgrade_menu.tscn")

@onready var player: CharacterBody2D = %Player
@onready var upgrades:= {"Max Hearts": {"max_hearts": [1, 2]}, 
						 "Move Speed": {"ms": [5, 10]}, 
						 "Attack Speed": {"attacks_per_second": [10, 20]}, 
						 "Damage": {"dmg": [1, 3]}};

func _ready() -> void:
	player.level_up.connect(on_player_level_up);

func on_player_level_up() -> void:
	var upgrade_menu = UPGRADE_MENU.instantiate() as Control;
	var upgrade_names_list = upgrades.keys();
	var popped_upgrades: Array;
	for i in 3:
		var upgrade_button = upgrade_menu.find_child("Button" + str(i), true);
		# gets a key (upgrade name) from upgrade names, pops it into popped_upgrades, which is then appended to upgrade names list
		var upgrade_key = upgrade_names_list.pop_at(randi_range(0, upgrade_names_list.size() - 1));
		var upgrade_range = upgrades.get(upgrade_key).values().get(0);
		var amount = randi_range(upgrade_range.get(0), upgrade_range.get(1));
		upgrade_button.pressed.connect(on_upgrade_button_pressed.bind(upgrade_button, upgrade_key, amount));
		upgrade_button.text = "+" + str(amount) + " " + upgrade_key;
		popped_upgrades.append(upgrade_key);
	upgrade_names_list.append_array(popped_upgrades);
	player.add_child(upgrade_menu);
	get_tree().paused = true;

func on_upgrade_button_pressed(button: Button, upgrade_key: String, amount: int) -> void:
	var upgrade = upgrades.get(upgrade_key).keys().get(0);
	player.set(upgrade, player.get(upgrade) + amount);
	get_tree().paused = false;
