extends RefCounted
## Spawn budgets and simulation throttling for low-power devices.

const MAX_TEMP_ADDS_PER_BOSS := 8
const FAR_AI_DISTANCE := 62.0
const FAR_AI_INTERVAL := 0.24

static func respawn_delay(base_delay: float, level: int, is_boss: bool, is_temp: bool) -> float:
	if is_temp:
		return INF
	if is_boss:
		return maxf(90.0, base_delay)
	return maxf(18.0, base_delay + float(maxi(0, level - 1)) * 0.8)

static func can_respawn(elapsed: float, delay: float, distance_to_player: float, safe_distance: float, is_temp: bool) -> bool:
	return not is_temp and elapsed >= delay and distance_to_player >= safe_distance

static func should_throttle(distance_to_player: float, is_boss: bool, is_temp: bool) -> bool:
	return not is_boss and not is_temp and distance_to_player > FAR_AI_DISTANCE

static func can_spawn_add(mobs: Array, owner, limit: int = MAX_TEMP_ADDS_PER_BOSS) -> bool:
	var count := 0
	for mob in mobs:
		if mob != null and not mob.dead and mob.temp and mob.owner_m == owner:
			count += 1
	return count < maxi(0, limit)

static func population_budget(map_name: String, player_level: int) -> int:
	var base := 30
	match map_name:
		"swamp": base = 26
		"mine": base = 18
	return clampi(base + int(maxi(0, player_level - 10) / 5), 12, 36)

static func is_spawn_position_safe(position: Vector2, player_position: Vector2, obstacles: Array, min_player_distance: float = 18.0) -> bool:
	if position.distance_to(player_position) < maxf(1.0, min_player_distance):
		return false
	for obstacle in obstacles:
		if typeof(obstacle) != TYPE_VECTOR3:
			continue
		var center := Vector2(obstacle.x, obstacle.y)
		if position.distance_to(center) < obstacle.z + 1.5:
			return false
	return true

static func is_rare_spawn(roll_value: float, player_level: int) -> bool:
	var chance := clampf(0.02 + float(maxi(0, player_level - 1)) * 0.0005, 0.02, 0.035)
	return clampf(roll_value, 0.0, 1.0) < chance

static func rare_hp_multiplier() -> float:
	return 2.2

static func rare_damage_multiplier() -> float:
	return 1.2

static func rare_reward_multiplier() -> float:
	return 1.8
