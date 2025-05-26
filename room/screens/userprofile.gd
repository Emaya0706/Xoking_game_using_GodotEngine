extends Control
onready var nickname : LineEdit = $nickname/LineEdit
onready var character_class : LineEdit = $username2/LineEdit
onready var dob: LineEdit = $dob/LineEdit
onready var notification : Label = $ConfirmationDialog/notification
onready var gender : OptionButton = $gender/LineEdit
onready var confirmation : ConfirmationDialog = $profile/ConfirmationDialog

var new_profile := false
var information_sent := false
var profile := {
	"nickname": {},
	"character_class": {},
	"gender": {},
	"dob": {}
	
} setget set_profile

#func _on_ConfirmButton_pressed() 
func _on_conifrm_pressed() -> void:
	if nickname.text.empty() : #or character_class.text.empty() or or :
		confirmation.popup(Rect2(104,330,395,420))
		notification.text = "Please, enter your name"
	elif character_class.text.empty() :
		confirmation.popup(Rect2(104,330,395,420))
		notification.text = "please, enter your username"
	elif gender.text.empty() :
		confirmation.popup(Rect2(104,330,395,420))
		notification.text = "please, select your gender"
	elif dob.text.empty() :
		confirmation.popup(Rect2(104,330,395,420))
		notification.text = "please, enter your D.O.B"
		#return
	profile.nickname = { "stringValue": nickname.text }
	profile.character_class = { "stringValue": character_class.text }
	profile.gender = { "stringValue": gender.text }  
	profile.dob = { "stringValue": dob.text}
	
	match new_profile:
		true:
			pass
			#Firebase.save_document("users?documentId=%s" % Firebase.user_info.id, profile, http)
		false:
			pass
			#Firebase.update_document("users/%s" % Firebase.user_info.id, profile, http)
	information_sent = true

func set_profile(value: Dictionary) -> void:
	profile = value
	nickname.text = profile.nickname.stringValue
	character_class.text = profile.character_class.stringValue
	gender.text = profile.gender.stringValue
	dob.text = profile.dob.stringValue
