extends Node2D

onready var game = $Game
onready var ui_layer: UILayer = $UILayer
onready var ready_screen = $UILayer/Screens/ReadyScreen
#onready var music := $Music

var players := {}

var players_ready := {}
var players_score := {}

var match_started := false

func _ready() -> void:
	OnlineMatch.connect("error", self, "_on_OnlineMatch_error")
	OnlineMatch.connect("disconnected", self, "_on_OnlineMatch_disconnected")
	OnlineMatch.connect("player_status_changed", self, "_on_OnlineMatch_player_status_changed")
	OnlineMatch.connect("player_left", self, "_on_OnlineMatch_player_left")
	#randomize()
	#music.play_random()

func _get_custom_rpc_methods() -> Array:
	return [
		'player_ready',
		'show_winner',
		'show_draw'
	]

#####
# UI callbacks
#####

func _on_UILayer_change_screen(name: String, _screen) -> void:
	if name != 'ReadyScreen':
		if match_started:
			match_started = false
			#music.play_random()

func _on_UILayer_back_button() -> void:
	ui_layer.hide_message()
	stop_game()
	
	if GameState.online_play:
		OnlineMatch.leave()
	get_tree().change_scene("res://scenes/UIscene/main.tscn")

func _on_ReadyScreen_ready_pressed() -> void:
	print("Hello i am  from main ready button pressed")
	OnlineMatch.custom_rpc_sync(self, "player_ready", [OnlineMatch.get_my_session_id()])

#####
# OnlineMatch callbacks
#####

func _on_OnlineMatch_error(message: String):
	if message != '':
		ui_layer.show_message(message)
	ui_layer.show_screen("MatchScreen")

func _on_OnlineMatch_disconnected():
	#_on_OnlineMatch_error("Disconnected from host")
	_on_OnlineMatch_error('')

func _on_OnlineMatch_player_left(player) -> void:
	ui_layer.show_message(player.username + " has left")
	
	game.kill_player(player.peer_id)
	
	players.erase(player.peer_id)
	players_ready.erase(player.peer_id)


func _on_OnlineMatch_player_status_changed(player, status) -> void:
	if status == OnlineMatch.PlayerStatus.CONNECTED:
		if OnlineMatch.is_network_server():
			# Tell this new player about all the other players that are already ready.
			for session_id in players_ready:
				OnlineMatch.custom_rpc_id(self, player.peer_id, "player_ready", [session_id])

#####
# Gameplay methods and callbacks
#####
func hide():
	ui_layer.hide_all_screen()
	
func player_ready(session_id: String) -> void:
	ready_screen.set_status(session_id, "READY!")
	print("Hi from Main script player_ready")
	if OnlineMatch.is_network_server() and not players_ready.has(session_id):
		players_ready[session_id] = true
		if players_ready.size() == OnlineMatch.players.size():
			if OnlineMatch.match_state != OnlineMatch.MatchState.PLAYING:
				OnlineMatch.start_playing()
				#print("why you irritating me")
				#OnlineMatch.custom_rpc_sync(self, 'start_game')
			start_game()


func start_game() -> void:
	ui_layer.hide_all_screen()
	ui_layer.hide_screen()
	print("Hi from Main start game")
	players = OnlineMatch.get_player_names_by_peer_id()
	game.game_start(players)

func stop_game() -> void:
	OnlineMatch.leave()
	
	players.clear()
	players_ready.clear()
	players_score.clear()
	
	game.game_stop()

func restart_game() -> void:
	stop_game()
	start_game()

func _on_Game_game_started() -> void:
	print("it is working")
	ui_layer.hide_all_screen()
	ui_layer.hide_screen()
	ui_layer.hide_all()
	ui_layer.show_back_button()
	
	if not match_started:
		match_started = true
		#music.play_random()

func _on_Game_player_dead(player_id: int) -> void:
	if GameState.online_play:
		var my_id = OnlineMatch.get_network_unique_id()
		if player_id == my_id:
			ui_layer.show_message("You lose!")

func _on_Game_game_over(player_id: int) -> void:
	players_ready.clear()

	if OnlineMatch.is_network_server():
		if not players_score.has(player_id):
			players_score[player_id] = 1
		else:
			players_score[player_id] += 1
		
		var player_session_id = OnlineMatch.get_session_id(player_id)
		var is_match: bool = players_score[player_id] >= 3
		print(players[player_id])
		OnlineMatch.custom_rpc_sync(self, "show_winner", [players[player_id], player_session_id, players_score[player_id], is_match])
		

func _on_Game_game_over_draw():
	players_ready.clear()
	if OnlineMatch.is_network_server():
		OnlineMatch.custom_rpc_sync(self, "show_draw")
	pass # Replace with function body.
	

func update_wins_leaderboard() -> void:
	if not Online.nakama_session or Online.nakama_session.is_expired():
		# If our session has expired, then wait until a new session is setup.
		yield(Online, "session_connected")
	
	Online.nakama_client.write_leaderboard_record_async(Online.nakama_session, 'fish_game_wins', 1)

func show_winner(name: String, session_id: String = '', score: int = 0, is_match: bool = false) -> void:
	print("show winner custom rpc is working just well")
	if is_match:
		ui_layer.show_message(name + " WINS THE WHOLE MATCH!")
		var t = Timer.new()
		t.set_wait_time(3)
		t.set_one_shot(true)
		self.add_child(t)
		t.start()
		yield(t, "timeout")
		get_tree().change_scene("res://scenes/UIscene/main.tscn")
	else:
		ui_layer.show_message(name + " wins this round!")
	
	yield(get_tree().create_timer(2.0), "timeout")
	if not game.game_started:
		return
	if is_match:
		stop_game()
		if session_id == OnlineMatch.my_session_id:
			update_wins_leaderboard()
		ui_layer.show_screen("MatchScreen")
	else:
		ready_screen.hide_match_id()
		ready_screen.reset_status("Waiting...")
		ready_screen.set_score(session_id, score)
		print("game rady screen")
		#get_tree().get_root().get_child()
		ui_layer.hide_message()
		ui_layer.show_screen("ReadyScreen")



func show_draw(is_match: bool = false) -> void:
	if is_match:
		ui_layer.show_message(name + " WINS THE WHOLE MATCH!")
	else:
		ui_layer.show_message("Match Drawn")
	
	yield(get_tree().create_timer(2.0), "timeout")
	if not game.game_started:
		return
	if is_match:
		stop_game()
	else:
		ready_screen.hide_match_id()
		ready_screen.reset_status("Waiting...")
		#ready_screen.set_score(session_id, score)
		print("game rady screen")
		ui_layer.hide_message()
		ui_layer.show_screen("ReadyScreen")


func _on_Game_clear_screen():
	print("----------------------hide all screen--------------")
	ui_layer.hide_all_screen()
	pass # Replace with function body.

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().change_scene("res://scenes/UIscene/main.tscn")
