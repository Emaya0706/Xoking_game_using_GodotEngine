extends WindowDialog

func _on_create_button_pressed():
	popup(Rect2(28,219,553,620))
	
	pass # Repla	popup(Rect2(4,278,598,672))ce with function body.


var path1 = "res://room_match/scenes/room_match_fixing.tscn"


#--------------------------------------------------------------------------
var item_name = " "
#--------------------------------------------------------------------------
var align_name = " "
#--------------------------------------------------------------------------


var id1 = " 3x3"
var id2 = " 5x5"
var id3 = " 7x7"
#---------------------------------------------------
var al1 = " 3x3"
var al2 = " 4x4"
var al3 = " 5x5"
#--------------------------------------------------------------------------

func _ready():
	$mp/board.get_popup().add_item(id1)
	$mp/board.get_popup().add_item(id2)
	$mp/board.get_popup().add_item(id3)
#--------------------------------------------------------------------------
	
	$mp1/align.get_popup().add_item(al1)
	$mp1/align.get_popup().add_item(al2)
	$mp1/align.get_popup().add_item(al3)
	
#--------------------------------------------------------------------------
	
	$mp/board.get_popup().connect("id_pressed",self,"_on_item_pressed")
	$mp1/align.get_popup().connect("id_pressed",self,"_on_align_pressed")
pass

#--------------------------------------------------------------------------

func _on_item_pressed(id):
	item_name = $mp/board.get_popup().get_item_text(id)
	if item_name == id1:
		$mp1/align.set_item_disabled(1, true)
		$mp1/align.set_item_disabled(2, true)
		$mp1/align.set_item_disabled(0, false)
	elif item_name == id2:
		 $mp1/align.set_item_disabled(2, true)
		 $mp1/align.set_item_disabled(1, false)
		 $mp1/align.set_item_disabled(0, false)
	elif item_name == id3:
		 $mp1/align.set_item_disabled(0, true)
		 $mp1/align.set_item_disabled(1, false)
		 $mp1/align.set_item_disabled(2, false)
		
	pass

#--------------------------------------------------------------------------

func _on_align_pressed(id):
	align_name = $mp1/align.get_popup().get_item_text(id)
	pass

#--------------------------------------------------------------------------

func _on_next_pressed():
	if (item_name == id1) and (align_name == al1):
		print("iam 3")
		get_tree().change_scene(path1)
	elif (item_name == id2) and (align_name == al1):
		print("iam5_3")
		get_tree().change_scene(path1)
	elif (item_name == id2) and (align_name == al2):
		print("iam5_4")
		get_tree().change_scene(path1)
	elif (item_name == id3) and (align_name == al2):
		print("iam7_4")
		get_tree().change_scene(path1)
	elif (item_name == id3) and (align_name == al3):
		print("iam7_5")
		get_tree().change_scene(path1)
		pass # Replace with function body.
	
#-------------------------------------------------------------------------------------
