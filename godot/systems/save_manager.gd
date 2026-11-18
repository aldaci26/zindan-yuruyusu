extends RefCounted
## Versioned, validated save envelopes with automatic backup.

const CURRENT_VERSION := 2
const DEFAULT_PATH := "user://cuce_save.json"
const BACKUP_SUFFIX := ".bak"

static func encode(payload: Dictionary) -> String:
	return JSON.stringify({
		"format": "cuce-save",
		"version": CURRENT_VERSION,
		"saved_at": Time.get_datetime_string_from_system(true),
		"payload": payload
	})

static func decode_text(source: String) -> Dictionary:
	var parsed = JSON.parse_string(source)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {"ok": false, "error": "Save root is not a dictionary."}
	if parsed.get("format", "") == "cuce-save":
		var version := int(parsed.get("version", 0))
		if version < 1 or version > CURRENT_VERSION or typeof(parsed.get("payload")) != TYPE_DICTIONARY:
			return {"ok": false, "error": "Unsupported or malformed save version."}
		return {"ok": true, "version": version, "data": parsed["payload"], "migrated": version < CURRENT_VERSION}
	# Legacy v1 files stored the payload directly at the root.
	if parsed.has("x") and parsed.has("lvl") and parsed.has("inv"):
		return {"ok": true, "version": 1, "data": parsed, "migrated": true}
	return {"ok": false, "error": "Save signature or required fields are missing."}

static func write(path: String, payload: Dictionary) -> Dictionary:
	var absolute := ProjectSettings.globalize_path(path)
	var backup := absolute + BACKUP_SUFFIX
	if FileAccess.file_exists(path):
		if FileAccess.file_exists(backup):
			DirAccess.remove_absolute(backup)
		var copy_error := DirAccess.copy_absolute(absolute, backup)
		if copy_error != OK:
			push_warning("SaveManager: backup could not be created (%s)." % error_string(copy_error))
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return {"ok": false, "error": error_string(FileAccess.get_open_error())}
	file.store_string(encode(payload))
	file.flush()
	file.close()
	return {"ok": true, "version": CURRENT_VERSION}

static func read(path: String) -> Dictionary:
	if FileAccess.file_exists(path):
		var file := FileAccess.open(path, FileAccess.READ)
		if file != null:
			var result := decode_text(file.get_as_text())
			if result.ok:
				result["used_backup"] = false
				return result
	var backup_path := path + BACKUP_SUFFIX
	if FileAccess.file_exists(backup_path):
		var backup := FileAccess.open(backup_path, FileAccess.READ)
		if backup != null:
			var recovered := decode_text(backup.get_as_text())
			if recovered.ok:
				recovered["used_backup"] = true
				return recovered
	return {"ok": false, "error": "No valid primary or backup save found."}

static func delete_path(path: String) -> bool:
	var absolute := ProjectSettings.globalize_path(path)
	var backup := absolute + BACKUP_SUFFIX
	var had_file := FileAccess.file_exists(path) or FileAccess.file_exists(path + BACKUP_SUFFIX)
	if FileAccess.file_exists(path):
		var primary_error := DirAccess.remove_absolute(absolute)
		if primary_error != OK:
			return false
	if FileAccess.file_exists(path + BACKUP_SUFFIX):
		var backup_error := DirAccess.remove_absolute(backup)
		if backup_error != OK:
			return false
	return had_file
