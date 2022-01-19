extends HBoxContainer

onready var default_font_size = $ComboScore.get("custom_fonts/font").get_size()

func combo(combo):
	if (combo == 0):
		visible = false
		return
	
	$AnimationPlayer.stop(true)
	visible = true
	$ComboScore.text = String(combo)
	var font = $ComboScore.get("custom_fonts/font")
	font.set_size(min(default_font_size + combo, 64))
	$AnimationPlayer.play("Pop")
