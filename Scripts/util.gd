class_name Util
extends Resource

# Dictionary helpers
func get_largest_dict_value(dict : Dictionary) -> String:
	var current_max = -999999
	var largest_key
	for key in dict:
		var val = dict[key]
		if val > current_max:
			current_max = val
			largest_key = key

	return largest_key


func get_smallest_dict_value(dict : Dictionary) -> String:
	var current_min = 999999
	var smallest_key
	for key in dict:
		var val = dict[key]
		if val < current_min:
			current_min = val
			smallest_key = key

	return smallest_key


func add_dictionary_values(dict : Dictionary) -> float:
	var total = 0
	for key in dict:
		var value = dict[key]
		if value is float:
			total += value
	
	return total
