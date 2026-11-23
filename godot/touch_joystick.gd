extends Control
## Shared on-screen joystick for touch devices and narrow web viewports.

var vector := Vector2.ZERO
var _touch_index := -1
var _mouse_down := false

func _ready() -> void:
	custom_minimum_size = Vector2(144, 144)
	size = custom_minimum_size
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 30
	queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and _touch_index == -1 and Rect2(Vector2.ZERO, size).has_point(event.position):
			_touch_index = event.index
			_update_vector(event.position)
			accept_event()
		elif not event.pressed and event.index == _touch_index:
			_touch_index = -1
			_reset_vector()
			accept_event()
	elif event is InputEventScreenDrag and event.index == _touch_index:
		_update_vector(event.position)
		accept_event()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and Rect2(Vector2.ZERO, size).has_point(event.position):
			_mouse_down = true
			_update_vector(event.position)
			accept_event()
		elif not event.pressed and _mouse_down:
			_mouse_down = false
			_reset_vector()
			accept_event()
	elif event is InputEventMouseMotion and _mouse_down:
		_update_vector(event.position)
		accept_event()

func _update_vector(pos: Vector2) -> void:
	var radius := minf(size.x, size.y) * 0.36
	vector = ((pos - size * 0.5) / radius).limit_length(1.0)
	if vector.length() < 0.12:
		vector = Vector2.ZERO
	queue_redraw()

func _reset_vector() -> void:
	vector = Vector2.ZERO
	queue_redraw()

func _draw() -> void:
	var center := size * 0.5
	var radius := minf(size.x, size.y) * 0.36
	draw_circle(center, radius + 5.0, Color(0.02, 0.03, 0.04, 0.42))
	draw_circle(center, radius, Color(0.12, 0.15, 0.18, 0.62))
	draw_arc(center, radius, 0.0, TAU, 48, Color(0.82, 0.72, 0.52, 0.85), 2.0, true)
	draw_circle(center + vector * radius, radius * 0.42, Color(0.78, 0.68, 0.48, 0.9))
	draw_arc(center + vector * radius, radius * 0.42, 0.0, TAU, 32, Color(1.0, 0.91, 0.72, 0.95), 2.0, true)
