extends HBoxContainer

onready var name_label := $NameLabel
onready var message_label := $MessageLabel

func add_message(name :String, message :String):
	name_label.text = name
	message_label.text = message
	
