extends Resource
class_name DayConfig

@export_category("Day Configuration")
## TODO: implement...Determines if the day will have a sunrise and/or sunset
@export var has_night: bool = true

@export_placeholder("Some Nickname") var day_name: String
@export_color_no_alpha() var day_color: Color
@export() var day_time_light_intensity: float = 10
@export_color_no_alpha() var night_color: Color
@export() var night_time_light_intensity: float
@export() var minimum_light_intensity: float
## How likely this day config is to be picked from the possible day configs in a scheduler. Higher value = more likely
@export_range(1,1000,1) var day_weight: int = 1

@export_group("Sunrise Time")
## Clamped between 0-23
@export_range(0,23) var sunrise_hour: int = 0 :
	set(value):
		sunrise_hour = clamp(value,0,23)
## Clamped between 0-59
@export_range(0,59) var sunrise_minute: int = 0 :
	set(value):
		sunrise_minute = clamp(value,0,59)
## Clamped between 0-59
@export_range(0,59) var sunrise_second: int = 0 :
	set(value):
		sunrise_second = clamp(value,0,59)
## Clamped between 0-999
@export_range(0,999) var sunrise_millisecond: int = 0 :
	set(value):
		sunrise_millisecond = clamp(value,0,999)

@export_group("Sunset Time")
## Clamped between sunrise_hour-23
@export_range(0,23) var sunset_hour: int = 0 :
	set(value):
		sunset_hour = clamp(value,sunrise_hour,23)
## Clamped between sunrise_minute-59
@export_range(0,59) var sunset_minute: int = 0 :
	set(value):
		var min_value: int = sunrise_minute if sunset_hour == sunrise_hour else 0
		sunset_minute = clamp(value,min_value,59)
## Clamped between sunrise_second-59
@export_range(0,59) var sunset_second: int = 0 :
	set(value):
		var min_value: int = sunrise_second if sunset_minute == sunrise_minute else 0
		sunset_second = clamp(value,min_value,59)
## Clamped between sunrise_millisecond-999
@export_range(0,999) var sunset_millisecond: int = 0 :
	set(value):
		var min_value: int = sunrise_millisecond if sunset_second == sunrise_second else 0
		sunset_millisecond = clamp(value,min_value,999)

@export_group("Day Periods")
@export var day_periods: Array[DayPeriodConfig] = []

func get_day_name() -> String:
	return day_name

func get_day_time_color() -> Color:
	return day_color

func get_night_time_color() -> Color:
	return night_color

func get_sunrise() -> Instant:
	return Instant.new(0,0,sunrise_hour,sunrise_minute,sunrise_second,sunrise_millisecond)

func get_sunrise_time() -> GameTime:
	return GameTime.create_from_time(get_sunrise())

func get_sunset() -> Instant:
	return Instant.new(0,0,sunset_hour,sunset_minute,sunset_second,sunset_millisecond)

func get_sunset_time() -> GameTime:
	return GameTime.create_from_time(get_sunset())

func save() -> String:
	return JSON.stringify({
		"day_name": day_name,
		"day_color": day_color,
		"day_time_light_intensity": day_time_light_intensity,
		"night_color": night_color,
		"night_time_light_intensity": night_time_light_intensity,
		"minimum_light_intensity": minimum_light_intensity,
		"has_night": has_night,# TODO might be removed
		"sunrise_hour": sunrise_hour,
		"sunrise_minute": sunrise_minute,
		"sunrise_second": sunrise_second,
		"sunrise_millisecond": sunrise_millisecond,
		"sunset_hour": sunset_hour,
		"sunset_minute": sunset_minute,
		"sunset_second": sunset_second,
		"sunset_millisecond": sunset_millisecond,
		"day_periods": day_periods.map(func(day_period_config: DayPeriodConfig): return day_period_config.save())
	})

func load_from_json(data_string: String) -> void:
	var data = JSON.parse_string(data_string)
	if not data is Dictionary:
		push_error("Invalid data type parsed from JSON! Expected: Dictionary - Got: " + str(typeof(data)))
		return
	day_name = data["day_name"]
	day_color = data["day_color"]
	night_color = data["night_color"]
	day_time_light_intensity = data["day_time_light_intensity"]
	night_time_light_intensity = data["night_time_light_intensity"]
	minimum_light_intensity = data["minimum_light_intensity"]
	has_night = data["has_night"]
	sunrise_hour = data["sunrise_hour"]
	sunrise_minute = data["sunrise_minute"]
	sunrise_second = data["sunrise_second"]
	sunrise_millisecond = data["sunrise_millisecond"]
	sunset_hour = data["sunset_hour"]
	sunset_minute = data["sunset_minute"]
	sunset_second = data["sunset_second"]
	sunset_millisecond = data["sunset_millisecond"]
	day_periods = []
	for day_config_string in data.get("day_configs", []):
		var new_day_period: DayPeriodConfig = DayPeriodConfig.new()
		new_day_period.load_from_json(day_config_string)
		day_periods.append(new_day_period)