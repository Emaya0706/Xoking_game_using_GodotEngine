extends WindowDialog



func _on_join_pressed():
	popup(Rect2(36,422,531,470))
	pass # Replace with function body.


func _on_create_button_pressed():
	get_tree().change_scene("res://room_match/scenes/room_match_fixing.tscn")
	pass # Replace with function body.
