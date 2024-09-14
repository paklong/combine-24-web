extends Node2D

#region Select all children
const NUMBER_TILE = preload("res://scenes/number_tile.tscn")
const OPERATOR_TILE = preload("res://scenes/operator_tile.tscn")

@onready var answer_bar: PanelContainer = %AnswerBar
@onready var answer_bar_container: HBoxContainer = $AnswerBar/AnswerBarContainer

@onready var number_row: PanelContainer = %NumberRow
@onready var operator_row: PanelContainer = %OperatorRow

@onready var number_tile_1: PanelContainer = $NumberRow/HBoxContainer/NumberTile1
@onready var number_tile_2: PanelContainer = $NumberRow/HBoxContainer/NumberTile2
@onready var number_tile_3: PanelContainer = $NumberRow/HBoxContainer/NumberTile3
@onready var number_tile_4: PanelContainer = $NumberRow/HBoxContainer/NumberTile4

@onready var operator_tile_plus: operator_tile = $OperatorRow/VBoxContainer/HBoxContainer/OperatorTilePlus
@onready var operator_tile_minus: operator_tile = $OperatorRow/VBoxContainer/HBoxContainer/OperatorTileMinus
@onready var operator_tile_multiply: operator_tile = $OperatorRow/VBoxContainer/HBoxContainer/OperatorTileMultiply
@onready var operator_tile_division: operator_tile = $OperatorRow/VBoxContainer/HBoxContainer/OperatorTileDivision
@onready var operator_tile_open: operator_tile = $OperatorRow/VBoxContainer/HBoxContainer2/OperatorTileOpen
@onready var operator_tile_ans: operator_tile = $OperatorRow/VBoxContainer/HBoxContainer2/OperatorTileAns
@onready var operator_tile_inverse: operator_tile = $OperatorRow/VBoxContainer/HBoxContainer2/OperatorTileInverse
@onready var operator_tile_closed: operator_tile = $OperatorRow/VBoxContainer/HBoxContainer2/OperatorTileClosed


@onready var calculator: Node2D = %Calculator
@onready var solver: Node2D = %Solver
@onready var get_answer: Button = %GetAnswer


@onready var answer_label: RichTextLabel = %AnswerLabel
@onready var reset_image: Sprite2D = $AnswerBar/ResetImage
@onready var reset_button: Button = $AnswerBar/ResetImage/ResetButton


@onready var number_tiles := [
	number_tile_1,
	number_tile_2,
	number_tile_3,
	number_tile_4
]

@onready var operator_tiles := {
	operator_tile_plus: '+',
	operator_tile_minus: '-',
	operator_tile_multiply: '×',
	operator_tile_division: '÷',
	operator_tile_open: '(',
	operator_tile_closed: ')',
	operator_tile_inverse: 'Inv',
	operator_tile_ans: 'Ans'
}

#endregion

var actions := []
var valid_actions := []
var available_number := 4
var answer = 0.0

func _ready() -> void:
	for _number_tile in number_tiles:
		_number_tile.number_tile_press.connect(_on_tile_press)
	
	for _operator_tile in operator_tiles:
		_operator_tile.update_operator(operator_tiles[_operator_tile])
		_operator_tile.operator_tile_press.connect(_on_tile_press)
		
	answer_bar.reset_button_pressed.connect(_on_answer_bar_reset_button_pressed)
	
	get_answer.pressed.connect(_on_get_answer_pressed)
	
	number_row.get_random_tiles()
	answer_bar.clear_answer_bar()
	
	reset_image.position = Vector2(470, 530)
	reset_image.scale = Vector2(0.35, 0.35)

func _on_tile_press(tile_reference, value):
	print ('Tile pressed: %s' % str(value))
	add_to_actions(tile_reference, value)

func _on_answer_bar_reset_button_pressed():
	answer_bar.clear_answer_bar()
	number_row.enable_all_tiles()
	actions = []
	valid_actions = []
	answer = 0.0	
	answer_bar.change_answer_bar_color_to_default()
	update_answer_label(answer)

func _on_get_answer_pressed():
	var _number_tiles =  (number_tiles.map(func(x) : return x.number))
	solver.solve(_number_tiles[0], _number_tiles[1], _number_tiles[2], _number_tiles[3])

func add_to_actions(tile_reference, value):
	actions.append([tile_reference, value])
	
	print ('actions :' + str(actions.map(func(x): return x[1])))
	process_action()
	

func process_action():
	valid_actions.clear()
	answer_bar.clear_answer_bar()
	available_number = 4
	var last_valid_action = null
	
	for action in actions:
		var tile_reference = action[0]
		var value = action[1]
		
		if is_valid_action(last_valid_action, value):
			
			if str(value) == 'Ans':
				valid_actions.insert(0, [operator_tile_open, '('])
				valid_actions.append([operator_tile_closed, ')'])
				last_valid_action = ')'
			
			elif str(value) == 'Inv':
				# Close all open parentheses first
				var open_parentheses = 0
				for _action in valid_actions:
					if str(_action[1]) == '(':
						open_parentheses += 1
					elif str(_action[1]) == ')':
						open_parentheses -= 1

				# Add closing parentheses for any unclosed open parentheses
				for i in range(open_parentheses):
					valid_actions.append([operator_tile_closed, ')'])

				# Now insert the "Inv" operation
				valid_actions.insert(0, [operator_tile_open, '('])
				valid_actions.insert(0, [operator_tile_division, '÷'])
				valid_actions.insert(0, ['number', 1])
				valid_actions.append([operator_tile_closed, ')'])
				last_valid_action = ')'


			else:
				valid_actions.append(action)
				if tile_reference is number_tile:
					tile_reference.disable_tile()
					available_number -= 1
					
				last_valid_action = value

	print ('valid_actions :' + str(valid_actions.map(func(x): return x[1])))
	evaluate_actions()

func is_valid_action(last_action, current_action) -> bool:
	# Check number validity
	if is_number(current_action):
		return last_action == null or last_action in ['(', '+', '-', '×', '÷']
	# Check operator validity
	if is_operator(current_action):
		return last_action != null and not is_operator(last_action) and str(last_action) != '(' and available_number > 0
	# Check opening parenthesis validity
	if current_action == '(':
		return last_action == null or last_action in ['(', '+', '-', '×', '÷'] and available_number > 0

	# Check closing parenthesis validity
	if current_action == ')':
		return last_action != null and (is_number(last_action) or str(last_action) == ')') and has_matching_open_parenthesis()

	# Special actions: 'Ans' 'Inv'
	if current_action in ['Ans', 'Inv']:
		return last_action != null  and not is_operator(last_action) and available_number > 0 and str(last_action) != '(' # Ensure there's something to evaluate


	return false

func is_number(value) -> bool:
	return typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT

func is_operator(value) -> bool:
	return value in ['+', '-', '×', '÷']

func has_matching_open_parenthesis() -> bool:
	var open_count = 0
	var close_count = 0
	for action in valid_actions:
		if str(action[1]) == '(':
			open_count += 1
		elif str(action[1]) == ')':
			close_count += 1
	return open_count > close_count

		
func add_new_tile(action, start=false):
	
	var tile = null
	var tile_reference = action[0]
	var value = action[1]
	if tile_reference is number_tile or str(tile_reference) == 'number':
		tile = NUMBER_TILE.instantiate()  # Or use the appropriate node type
		answer_bar_container.add_child(tile)
		tile.update_number(value)
		tile.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
	elif tile_reference is operator_tile:
		tile = OPERATOR_TILE.instantiate()  # Or use the appropriate node type
		answer_bar_container.add_child(tile)
		if start:
			answer_bar_container.move_child(tile, 0)
		tile.update_operator(value)
		tile.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
	tile.disable_button()

func evaluate_actions():
	answer = calculator.evaluate_actions(valid_actions, add_new_tile, update_answer_label)
	if answer == 24 and available_number == 0:
		answer_bar.change_answer_bar_color_to_green()
	else:
		answer_bar.change_answer_bar_color_to_default()
	
func update_answer_label(_answer):
	if _answer == int(_answer):
		answer_label.text = '[center][font_size=100]%d' % int(_answer)
	else:
		answer_label.text = '[center][font_size=100]%.2f' % _answer
	
	if actions.size() == 0:
		answer_label.text = ''
