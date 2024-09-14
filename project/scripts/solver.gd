extends Node2D

@onready var calculator: Node2D = %Calculator

func solve(a: float, b: float, c: float, d: float) -> Array:
	var results = solver(a, b, c, d)
	if results.size() > 0:
		print("Solvable:")
		for expression in results:
			print(expression)
		print(results.size())
		return results
	else:
		print("Not solvable")
		return []

# Helper function to generate all unique permutations of numbers
func permute(lst):
	if lst.size() <= 1:
		return [lst]
	var perms = []
	for i in range(lst.size()):
		var elem = lst[i]
		var rest = lst.slice(0, i) + lst.slice(i + 1)
		for perm in permute(rest):
			# Avoid adding permutations that are identical due to identical elements
			if [elem] + perm not in perms:
				perms.append([elem] + perm)
	return perms

func solver(a: float, b: float, c: float, d: float) -> Array:
	var numbers = [a, b, c, d]
	var operators = ['+', '-', '×', '÷']
	var expressions = []
	var results = []
	var unique_results = {}  # Dictionary to store unique results with their canonical forms

	# Generate all possible expressions with given numbers and operators
	for num_perm in permute(numbers):
		for op1 in operators:
			for op2 in operators:
				for op3 in operators:
					# Avoid invalid operations (e.g., division by zero)
					if op1 == '÷' and num_perm[1] == 0:
						continue
					if op2 == '÷' and num_perm[2] == 0:
						continue
					if op3 == '÷' and num_perm[3] == 0:
						continue

					# Basic expression (a op b) op (c op d)
					expressions.append('( %s %s %s ) %s ( %s %s %s )' % [str(num_perm[0]), op1, str(num_perm[1]), op2, str(num_perm[2]), op3, str(num_perm[3])])
					
					# Group first three numbers ((a op b) op c) op d
					expressions.append('( ( %s %s %s ) %s %s ) %s %s' % [str(num_perm[0]), op1, str(num_perm[1]), op2, str(num_perm[2]), op3, str(num_perm[3])])
					
					# Group last three numbers (a op (b op c)) op d
					expressions.append('( %s %s ( %s %s %s ) ) %s %s' % [str(num_perm[0]), op1, str(num_perm[1]), op2, str(num_perm[2]), op3, str(num_perm[3])])
					
					# Group first two and last two ((a op b) op (c op d))
					expressions.append('( ( %s %s %s ) %s ( %s %s %s ) )' % [str(num_perm[0]), op1, str(num_perm[1]), op2, str(num_perm[2]), op3, str(num_perm[3])])
					
					# Group last three and first one a op ((b op c) op d)
					expressions.append('%s %s ( ( %s %s %s ) %s %s )' % [str(num_perm[0]), op1, str(num_perm[1]), op2, str(num_perm[2]), op3, str(num_perm[3])])
					
					# Grouping first one with the remaining three
					expressions.append('%s %s ( %s %s ( %s %s %s ) )' % [str(num_perm[0]), op1, str(num_perm[1]), op2, str(num_perm[2]), op3, str(num_perm[3])])
	
	for expression in expressions:
		# Split the expression into components (numbers, operators, parentheses)
		var components = Array(expression.split(" ", true))
	
		# Convert components to the correct format, with number tiles and integers
		var formatted_expression = components.map(func(component):
			if component.is_valid_float():
				return ['number', int(component)]  # Instantiate a number tile with the int value
			else:
				return [null, component]  # Keep operators and parentheses as strings
		)
		
		# Evaluate the formatted expression using the calculator
		var result = calculator.evaluate_actions(formatted_expression)
		if result == 24:
			var canonical_form = canonicalize_expression(formatted_expression)
			if canonical_form not in unique_results:
				unique_results[canonical_form] = expression
				results.append(expression)
	
	return results

func canonicalize_expression(expression: Array) -> String:
	var numbers = []
	var operators = []
	
	for item in expression:
		if item[0] == 'number':
			numbers.append(item[1])
		elif item[1] != null and item[1] != '(' and item[1] != ')':
			operators.append(item[1])
	
	# Sort the numbers and operators to achieve a canonical form
	numbers.sort()
	operators.sort()
	
	return str(numbers) + str(operators)
