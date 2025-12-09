extends CanvasLayer

@onready var speaker_label: Label = $DialogContainer/TextContainer/SpeakerName
@onready var text_label: Label = $DialogContainer/TextContainer/DialogText
@onready var portrait: TextureRect = $DialogContainer/Portrait

func display_line(line_data: Dictionary):
	print("Показываем реплику: ", line_data)
	
	text_label.text = line_data.get("text", "")
	
	#используем имя из json, если есть
	if line_data.has("speaker"):
		speaker_label.text = line_data.get("speaker", "")
	else:
		speaker_label.text = ""
	
	#портрет
	if line_data.has("portrait"):
		var texture = load(line_data.portrait)
		if texture:
			portrait.texture = texture
	show()
