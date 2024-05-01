extends Resource
class_name DayPeriodConfig

@export_category("Day Period Configuration")

@export_placeholder("Event Name") var period_name: String

@export_color_no_alpha() var period_color: Color
#@export() var weather_condition: Node = null

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

func get_period_color() -> Color:
	return period_color

func get_start() -> Instant:
	return Instant.new(0,0,start_hour,start_minute,start_second,start_millisecond)

func get_start_time() -> GameTime:
	return GameTime.create_from_time(get_start())

func get_duration() -> Duration:
	return Duration.create_from_length(get_start(),0,0,length_hour,length_minute,length_second,length_millisecond)

func get_end() -> Instant:
	return get_duration().get_end().to_instant()

func get_end_time() -> GameTime:
	return get_duration().get_end()

func has_weather() -> bool:
	return weather_conditions.size() > 0

func pick_weather() -> WeatherConfig:
	if has_weather():
		return pick_weighted_element(weather_conditions)
	return null


func pick_weighted_element(weather_configs: Array[WeatherConfig])-> WeatherConfig:
	var total_weight: int = 0
	for weather_config in weather_configs:
		total_weight += weather_config.weather_weight

	var random_value: int = randi_range(0,total_weight)

	var current_weight: int = 0

	for weather_config in range(weather_configs.size()):
		current_weight += weather_configs[weather_config].weather_weight
		if random_value <= current_weight:
			return weather_configs[weather_config]

	# If random_value exceeds all weights (unlikely), return the last element
	return weather_configs[weather_configs.size() - 1]
