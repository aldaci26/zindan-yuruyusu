extends RefCounted
## Shared deterministic combat formulas. Random rolls stay in the caller.

static func armor_reduction(armor: float, attacker_level: int) -> float:
	return clampf(armor / (armor + 30.0 + float(maxi(1, attacker_level)) * 4.0), 0.0, 0.75)

static func outgoing_damage(base: float, damage_bonus: float, variance: float, critical: bool, critical_multiplier: float = 1.8) -> int:
	var value := maxf(0.0, base) * clampf(variance, 0.0, 2.0) * (1.0 + clampf(damage_bonus, -0.9, 5.0))
	if critical:
		value *= clampf(critical_multiplier, 1.0, 5.0)
	return maxi(1, roundi(value))

static func incoming_damage(raw: float, armor: float, attacker_level: int, defensive_multiplier: float, blocked: bool) -> int:
	var value := maxf(0.0, raw) * (1.0 - armor_reduction(armor, attacker_level))
	value *= clampf(defensive_multiplier, 0.05, 3.0)
	if blocked:
		value *= 0.3
	return maxi(1, roundi(value))

static func combo_multiplier(combo_count: int) -> float:
	return 1.0 + minf(0.25, float(maxi(0, combo_count - 1)) * 0.025)

static func status_duration(base_seconds: float, resistance: float) -> float:
	return maxf(0.0, base_seconds) * (1.0 - clampf(resistance, 0.0, 0.9))

static func evade_chance(agility: float, level_difference: int = 0) -> float:
	return clampf(0.025 + maxf(0.0, agility) * 0.0015 - float(level_difference) * 0.01, 0.01, 0.22)

static func should_evade(roll_value: float, agility: float, level_difference: int = 0) -> bool:
	return clampf(roll_value, 0.0, 1.0) < evade_chance(agility, level_difference)

static func threat_score(damage_done: float, healing_done: float) -> float:
	return maxf(0.0, damage_done) + maxf(0.0, healing_done) * 0.5
