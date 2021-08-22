extends Control

var vector_start = []
var vector_end = []
var vector_width = []
var vector_color = []


func _draw():
	for v in vector_start.size():
		draw_line(vector_start[v], vector_end[v], vector_color[v], vector_width[v])
	clear()

func clear():
	vector_start = []
	vector_end = []
	vector_width = []
	vector_color = []


func add_vector(start, end, width, color):
	vector_start.append(start)
	vector_end.append(end)
	vector_width.append(width)
	vector_color.append(color)
