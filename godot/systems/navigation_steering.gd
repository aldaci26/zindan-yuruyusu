extends RefCounted
## Lightweight local avoidance; intentionally does not require a baked NavigationMesh.

static func separation_vector(origin: Vector2, neighbors: Array, radius: float = 2.2) -> Vector2:
	var result := Vector2.ZERO
	var safe_radius := maxf(0.1, radius)
	for point in neighbors:
		if typeof(point) != TYPE_VECTOR2:
			continue
		var offset: Vector2 = origin - point
		var distance := offset.length()
		if distance > 0.001 and distance < safe_radius:
			result += offset.normalized() * ((safe_radius - distance) / safe_radius)
	return result.limit_length(1.0)

static func blend_direction(target_direction: Vector2, separation: Vector2, weight: float = 0.65) -> Vector2:
	if target_direction.length_squared() <= 0.0001:
		return separation.normalized()
	return (target_direction.normalized() + separation * clampf(weight, 0.0, 1.0)).normalized()

static func melee_approach_point(target: Vector2, unit_id: int, desired_radius: float) -> Vector2:
	var angle := float(unit_id) * 2.3999632297
	return target + Vector2(cos(angle), sin(angle)) * maxf(0.5, desired_radius)

static func ranged_move_direction(origin: Vector2, target: Vector2, preferred_distance: float) -> Vector2:
	var offset := target - origin
	var distance := offset.length()
	if distance <= 0.001:
		return Vector2.ZERO
	if distance < maxf(1.0, preferred_distance * 0.58):
		return -offset.normalized()
	if distance > maxf(1.0, preferred_distance - 2.0):
		return offset.normalized()
	return Vector2.ZERO
