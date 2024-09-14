extends PanelContainer

class_name operator_tile
signal operator_tile_press(tile, operator : String)

@onready var v_box_container: VBoxContainer = %VBoxContainer
@onready var rich_text_label: RichTextLabel = %RichTextLabel
@onready var button: Button = %Button
@onready var audio_stream_player_2d: AudioStreamPlayer2D = %AudioStreamPlayer2D
@onready var cover: ColorRect = $Cover

const MI_SFX_24 = preload("res://assets/sound effects/coloralpha/MI_SFX 24.wav")

var operator := '+'

func _ready() -> void:
	button.pressed.connect(_on_button_pressed)
	audio_stream_player_2d.stream = MI_SFX_24
	rich_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD

func _on_button_pressed():
	audio_stream_player_2d.play()
	#print ('Operator pressed: %s' % operator)
	operator_tile_press.emit(self, operator)

func update_operator(new_operator : String):
	operator = new_operator
	if new_operator == 'Ans':
		rich_text_label.text = '[font_size=50][center]%s[/center][/font_size]' % '(...)'
	elif new_operator == 'Inv':
		rich_text_label.text = '[font_size=40][center]%s[/center][/font_size]' % '1/x​'
	elif new_operator in ['(', ')']:
		rich_text_label.text = '[font_size=40][center]%s[/center][/font_size]' % operator
	else:
		rich_text_label.text = '[font_size=50][center]%s[/center][/font_size]' % operator
	
func disable_button():
	button.hide()

func disable_tile():
	cover.show()

func enable_tile():
	cover.hide()
