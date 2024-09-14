extends Node2D


func evaluate_actions(valid_actions: Array, add_tile_callback = null, update_answer_label_callback = null):
	var operand_stack = []  # Stack to hold numbers and intermediate results
	var operator_stack = []  # Stack to hold operators and parentheses

	var i = 0
	while i < valid_actions.size():
		
		var tile_reference = valid_actions[i][0]
		var value = valid_actions[i][1]
		
		# Call the provided callback function to add a new tile
		if add_tile_callback:
			add_tile_callback.call(valid_actions[i])
		
		if tile_reference is number_tile or str(tile_reference) == 'number':
			operand_stack.append(value)
			
		
			
		elif str(value) == '(':
			operator_stack.append(value)

		elif str(value) == ')':
			# Pop from stacks and evaluate until '(' is found
			while operator_stack.size() > 0 and operator_stack[-1] != '(':
				if operand_stack.size() < 2:
					return  # Incomplete expression, defer evaluation
				operand_stack.append(apply_operator(operator_stack.pop_back(), operand_stack.pop_back(), operand_stack.pop_back()))
			operator_stack.pop_back()  # Remove '('
			
		elif str(value) in ['+', '-', '×', '÷']:
			# Pop from stack and evaluate based on operator precedence
			while operator_stack.size() > 0 and precedence(operator_stack[-1]) >= precedence(value):
				if operand_stack.size() < 2:
					return  # Incomplete expression, defer evaluation
				operand_stack.append(apply_operator(operator_stack.pop_back(), operand_stack.pop_back(), operand_stack.pop_back()))
			operator_stack.append(value)
		i += 1

	# Automatically close any unclosed parentheses
	while operator_stack.size() > 0:
		if operator_stack[-1] == '(':
			operator_stack.pop_back()  # Remove the unclosed '('
		else:
			if operand_stack.size() < 2:
				return  # Incomplete expression, defer evaluation
			operand_stack.append(apply_operator(operator_stack.pop_back(), operand_stack.pop_back(), operand_stack.pop_back()))

	# Final evaluation of the remaining operators in the stack
	while operator_stack.size() > 0:
		if operand_stack.size() < 2:
			return  # Incomplete expression, defer evaluation
		operand_stack.append(apply_operator(operator_stack.pop_back(), operand_stack.pop_back(), operand_stack.pop_back()))

	# The last element in operand_stack should be the result
	if operand_stack.size() > 0:
		var answer = operand_stack.pop_back()
		# You can decide how to handle the result, such as returning it or printing it
		if update_answer_label_callback:
			update_answer_label_callback.call(answer)
		return answer
#

		
func apply_operator(operator: String, b: float, a: float) -> float:
	if operator == '+':
		return a + b
	elif operator == '-':
		return a - b
	elif operator == '×':
		return a * b
	elif operator == '÷':
		return a / b
	return 0.0

func precedence(operator: String) -> int:
	if operator in ['+', '-']:
		return 1
	elif operator in ['×', '÷']:
		return 2
	return 0
