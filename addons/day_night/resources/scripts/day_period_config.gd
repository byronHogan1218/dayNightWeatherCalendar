extends Resource
class_name DayPeriodConfig

@export_category("Day Period Configuration")

@export_placeholder("Event Name") var period_name: String

@export_group("Period Lighting")
## The lighting color that will be used at day
@export_color_no_alpha() var day_time_period_color: Color
## The peak light intensity during the day
@export_range(0,16,.01) var day_time_light_intensity: float = 2
## The lighting color that will be used at night
@export_color_no_alpha() var night_time_period_color: Color
## The peak light intensity during the night
@export_range(0,16,.01) var night_time_light_intensity: float = .8
## The the lowest the light intensity can be
@export_range(0,16,.01) var minimum_light_intensity: float = .1


@export_group("Start Time")
## Clamped between 0-23
@export_range(0,23) var start_hour: int = 0 :
	set(value):
		start_hour = clamp(value,0,23)
## Clamped between 0-59
@export_range(0,59) var start_minute: int = 0 :
	set(value):
		start_minute = clamp(value,0,59)
## Clamped between 0-59
@export_range(0,59) var start_second: int = 0 :
	set(value):
		start_second = clamp(value,0,59)
## Clamped between 0-999
@export_range(0,999) var start_millisecond: int = 0 :
	set(value):
		start_millisecond = clamp(value,0,999)

@export_group("Length of Time")
## Clamped between 0-23
@export_range(0,23) var length_hour: int = 0 :
	set(value):
		length_hour = clamp(value,0,23)
## Clamped between 0-59
@export_range(0,59) var length_minute: int = 0 :
	set(value):
		length_minute = clamp(value,0,59)
## Clamped between 0-59
@export_range(0,59) var length_second: int = 0 :
	set(value):
		length_second = clamp(value,0,59)
## Clamped between 0-999
@export_range(0,999) var length_millisecond: int = 0 :
	set(value):
		length_millisecond = clamp(value,0,999)

@export_group("Weather Conditions")
@export var weather_conditions: Array[WeatherConfig] = []

func get_period_name() -> String:
	return period_name

func get_start(year: int, day: int) -> Instant:
	return Instant.new(year,day,start_hour,start_minute,start_second,start_millisecond)

func get_start_time(year: int, day: int) -> GameTime:
	return GameTime.create_from_time(get_start(year,day))

func get_duration(start_year: int, start_day: int) -> Duration:
	return Duration.create_from_length(get_start(start_year,start_day),0,0,length_hour,length_minute,length_second,length_millisecond)

func get_end(start_year: int, start_day: int) -> Instant:
	return get_duration(start_year,start_day).get_end().to_instant()

func get_end_time(start_year: int, start_day: int) -> GameTime:
	return get_duration(start_year,start_day).get_end()

func has_weather() -> bool:
	return weather_conditions.size() > 0

func pick_weather() -> WeatherConfig:
	if has_weather():
		return _pick_weighted_element(weather_conditions)
	return null

func save() -> String:
	return JSON.stringify({
		"period_name": period_name,
		"day_time_period_color": day_time_period_color.to_html(),
		"night_time_period_color": night_time_period_color.to_html(),
		"day_time_light_intensity": day_time_light_intensity,
		"night_time_light_intensity": night_time_light_intensity,
		"minimum_light_intensity": minimum_light_intensity,
		"start_hour": start_hour,
		"start_minute": start_minute,
		"start_second": start_second,
		"start_millisecond": start_millisecond,
		"length_hour": length_hour,
		"length_minute": length_minute,
		"length_second": length_second,
		"length_millisecond": length_millisecond,
		"weather_conditions": weather_conditions.map(func(weather_config: WeatherConfig): return weather_config.save())
	})

func load_from_json(data_string: String) -> void:
	var data = JSON.parse_string(data_string)
	if not data is Dictionary:
		push_error("Invalid data type parsed from JSON! Expected: Dictionary - Got: " + str(typeof(data)))
		return
	period_name = data.get("period_name", "")
	day_time_period_color = Color.from_string(data.get("day_time_period_color"), Color.WHITE)
	night_time_period_color = Color.from_string(data.get("night_time_period_color"), Color.STEEL_BLUE)
	day_time_light_intensity = data.get("day_time_light_intensity", 1.0)
	night_time_light_intensity = data.get("night_time_light_intensity", 1.0)
	minimum_light_intensity = data.get("minimum_light_intensity", 0.0)
	start_hour = data.get("start_hour", 0)
	start_minute = data.get("start_minute", 0)
	start_second = data.get("start_second", 0)
	start_millisecond = data.get("start_millisecond", 0)
	length_hour = data.get("length_hour", 0)
	length_minute = data.get("length_minute", 0)
	length_second = data.get("length_second", 0)
	length_millisecond = data.get("length_millisecond", 0)
	weather_conditions = []
	for weather_config_string in data.get("weather_conditions", []):
		var weather_config: WeatherConfig = WeatherConfig.new()
		weather_config.load_from_json(weather_config_string)
		weather_conditions.append(weather_config)


func _pick_weighted_element(weather_configs: Array[WeatherConfig])-> WeatherConfig:
	var total_weight: int = 0
	for weather_config in weather_configs:
		total_weight += weather_config.weather_weight

	var random_value: int = randi_range(0,total_weight)

	var current_weight: int = 0

	for weather_config_index in range(weather_configs.size()):
		current_weight += weather_configs[weather_config_index].weather_weight
		if random_value <= current_weight:
			return weather_configs[weather_config_index]

	# If random_value exceeds all weights (unlikely), return the last element
	return weather_configs[weather_configs.size() - 1]
