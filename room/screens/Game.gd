extends Node2D

#var Player = preload("res://actors/Player.tscn")

export (PackedScene) var map_scene
onready var map: Node2D = $Map
onready var players_node := $Players
#onready var camera := $Camera2D
#onready var original_camera_position: Vector2 = camera.global_position
var game_started := false
var game_over := false
var players_alive := {}
var players_setup := {}

signal game_started ()
signal player_dead (player_id)
signal game_over (player_id)
signal game_over_draw ()
signal clear_screen_ui()

var my_id
var another_id
		
func _ready():
	if GameState.game_type == "3x3":
		Game3o.connect("game_win", self, "_Game3_player_dead")
		Game3o.connect("game_draw", self, "_on_game_draw")
		Game3o.connect("clear_screen", self, "_clear_ui_screen")
		map_scene = preload("res://scenes/gamescene/online/3x3online/Game3O.tscn")
	elif GameState.game_type == "5x5":
		Game5o.connect("game_win", self, "_Game3_player_dead")
		Game5o.connect("game_draw", self, "_on_game_draw")
		Game5o.connect("clear_screen", self, "_clear_ui_screen")
		map_scene = preload("res://scenes/gamescene/online/5x5online/Game5O.tscn")
	elif GameState.game_type == "7x7_4":
		Game7aO.connect("game_win", self, "_Game3_player_dead")
		Game7aO.connect("game_draw", self, "_on_game_draw")
		Game7aO.connect("clear_screen", self, "_clear_ui_screen")
		map_scene = preload("res://scenes/gamescene/online/7x7_4online/Game7aO.tscn")
	elif GameState.game_type == "7x7_5":
		Game7bO.connect("game_win", self, "_Game3_player_dead")
		Game7bO.connect("game_draw", self, "_on_game_draw")
		Game7bO.connect("clear_screen", self, "_clear_ui_screen")
		map_scene = preload("res://scenes/gamescene/online/7x7_5online/Game7bO.tscn")
	else:
		print("Game Script GameState game_type is unknown")
	pass

func _get_custom_rpc_methods() -> Array:
	return [
		'_do_game_setup',
		'_finished_game_setup',
		'_do_game_start',
	]

func game_start(players: Dictionary) -> void:
	print("hello from Game script game_start")
	OnlineMatch.custom_rpc_sync(self, '_do_game_setup', [players])

# Initializes the game so that it is ready to really start.
func _do_game_setup(players: Dictionary) -> void:
	get_tree().set_pause(true)
	
	if game_started:
		game_stop()
	
	game_started = true
	game_over = false
	players_alive = players
	players_setup = players_alive
	
	reload_map()
	
	
	print("Connected")
	var my_id := OnlineMatch.get_network_unique_id()
	
	# Tell the host that we've finished setup.
	#OnlineMatch.custom_rpc_id_sync(self, 1, "_finished_game_setup", [my_id])
	_finished_game_setup(my_id)
# Records when each player has finished setup so we know when all players are ready.
func _finished_game_setup(player_id: int) -> void:
	print("hey fellow this is from finished game setup")
	OnlineMatch.custom_rpc_sync(self, "_do_game_start")

# Actually start the game on this client.
func _do_game_start() -> void:
	print("Hi from the do game start ")
	if map.has_method('map_start'):
		map.map_start()
		print("#########################################################3")
		if GameState.game_type == "3x3":
			if OnlineMatch.is_network_server():
				Game3o.iam = "x"
				Game3o.you = "o"
				Game3o.can_play = true
			else:
				Game3o.iam = "o"
				Game3o.you = "x"
			print("emitted map start from game")
		elif GameState.game_type == "5x5":
			if OnlineMatch.is_network_server():
				Game5o.iam = "x"
				Game5o.you = "o"
				Game5o.can_play = true
			else:
				Game5o.iam = "o"
				Game5o.you = "x"
			print("emitted map start from game")
		elif GameState.game_type == "7x7_4":
			if OnlineMatch.is_network_server():
				Game7aO.iam = "x"
				Game7aO.you = "o"
				Game7aO.can_play = true
			else:
				Game7aO.iam = "o"
				Game7aO.you = "x"
			print("emitted map start from game")
		elif GameState.game_type == "7x7_5":
			if OnlineMatch.is_network_server():
				Game7bO.iam = "x"
				Game7bO.you = "o"
				Game7bO.can_play = true
			else:
				Game7bO.iam = "o"
				Game7bO.you = "x"
			print("emitted map start from game")
	emit_signal("game_started")
	get_tree().set_pause(false)

func game_stop() -> void:
	if map.has_method('map_stop'):
		map.map_stop()
	
	game_started = false
	players_setup.clear()
	players_alive.clear()
	

func reload_map() -> void:
	print("Hi from Game script reload_map")
	var map_index = map.get_index()
	remove_child(map)
	map.queue_free()
	
	map = map_scene.instance()
	map.name = 'Map'
	add_child(map)
	move_child(map, map_index)
	print("Hello reload_map() completed")
	#var map_rect = map.get_map_rect()
	#camera.global_position = original_camera_position
	#camera.limit_left = map_rect.position.x
	#camera.limit_top = map_rect.position.y
	#camera.limit_right = map_rect.position.x + map_rect.size.x

func kill_player(player_id) -> void:
	var player_node = players_node.get_node(str(player_id))
	if player_node:
		if player_node.has_method("die"):
			player_node.die()
		else:
			# If there is no die method, we do the most important things it
			# would have done.
			player_node.queue_free()
			_on_player_dead(player_id)

func _Game3_player_dead():
	print("From Game player dead")
	print(Game3o.win_letter)
	print(Game3o.iam)
	print(Game3o.you)
	my_id = OnlineMatch.get_network_unique_id()
	if my_id == 1:
		another_id = 2
	elif my_id == 2:
		another_id = 1
	else:
		print("Hey my id is different than this 1 and 2")
	if GameState.game_type == "3x3":
		if Game3o.win_letter == Game3o.iam:
			print("hey this is iam")
			print(Game3o.iam)
			#emit_signal("game_win", another_id)
			_on_player_dead(another_id)
		elif Game3o.win_letter == Game3o.you:
			print("hey this is you ")
			print(Game3o.you)
			_on_player_dead(my_id)
		#	emit_signal("game_win", my_id)
		elif Game3o.win_letter == "Draw":
			emit_signal("game_over_draw")
	elif GameState.game_type == "5x5":
		if Game5o.win_letter == Game5o.iam:
			print("hey this is iam")
			print(Game5o.iam)
			#emit_signal("game_win", another_id)
			_on_player_dead(another_id)
		elif Game5o.win_letter == Game5o.you:
			print("hey this is you ")
			print(Game5o.you)
			_on_player_dead(my_id)
		#	emit_signal("game_win", my_id)
		elif Game5o.win_letter == "Draw":
			emit_signal("game_over_draw")
	elif GameState.game_type == "7x7_4":
		if Game7aO.win_letter == Game7aO.iam:
			print("hey this is iam")
			print(Game7aO.iam)
			#emit_signal("game_win", another_id)
			_on_player_dead(another_id)
		elif Game7aO.win_letter == Game7aO.you:
			print("hey this is you ")
			print(Game7aO.you)
			_on_player_dead(my_id)
		#	emit_signal("game_win", my_id)
		elif Game7aO.win_letter == "Draw":
			emit_signal("game_over_draw")
	elif GameState.game_type == "7x7_5":
		if Game7bO.win_letter == Game7bO.iam:
			print("hey this is iam")
			print(Game7bO.iam)
			#emit_signal("game_win", another_id)
			_on_player_dead(another_id)
		elif Game7bO.win_letter == Game7bO.you:
			print("hey this is you ")
			print(Game7bO.you)
			_on_player_dead(my_id)
		#	emit_signal("game_win", my_id)
		elif Game7bO.win_letter == "Draw":
			emit_signal("game_over_draw")
		
func _on_game_draw():
	print("on Game game draw")
	emit_signal("game_over_draw")

func _clear_ui_screen():
	print("------------clear from Game-----")
	emit_signal("clear_screen_ui")
	pass
func _on_player_dead(player_id) -> void:
	emit_signal("player_dead", player_id)
	
	players_alive.erase(player_id)
	if not game_over and players_alive.size() == 1:
		game_over = true
		var player_keys = players_alive.keys()
		emit_signal("game_over", player_keys[0])
