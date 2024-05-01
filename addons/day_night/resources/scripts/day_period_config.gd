extends Resource
class_name DayPeriodConfig

@export_category("Day Configuration")
## Determines if the day will have a sunrise and/or sunset
@export var has_night: bool = true

@export_placeholder("Some Nickname") var day_name: String

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

func get_sunrise() -> Instant:
	return Instant.new(0,0,sunrise_hour,sunrise_minute,sunrise_second,sunrise_millisecond)

func get_sunset() -> Instant:
	return Instant.new(0,0,sunset_hour,sunset_minute,sunset_second,sunset_millisecond)
