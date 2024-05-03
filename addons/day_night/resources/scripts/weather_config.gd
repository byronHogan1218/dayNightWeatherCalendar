extends Resource
class_name WeatherConfig

@export_category("Weather Configuration")

## The path to the node that contains the weather condition if picked and triggered
@export var weather_condition: NodePath

## How likely this weather conditon is to be picked from the possible weather conditions. Higher value = more likely
@export_range(0,1000,1) var weather_weight: int = 1
## If picked, how likely this weather condition is to trigger. Higher value = more likely
@export_range(0,1,0.01) var weather_chance: float = 1

@export_group("Weather Lighting")
## The day time lighting color that will be used if this weather condition is picked and triggered
@export_color_no_alpha() var day_time_weather_color: Color
## The light intensity during the day that will be used if this weather condition is picked and triggered
@export_range(0,16,.01) var day_time_light_intensity: float = 2
## The day time lighting color that will be used if this weather condition is picked and triggered
@export_color_no_alpha() var night_time_weather_color: Color
## The light intensity during the night that will be used if this weather condition is picked and triggered
@export_range(0,16,.01) var night_time_light_intensity: float = .8
## The the lowest the light intensity can be if this weather condition is picked and triggered
@export_range(0,16,.01) var minimum_light_intensity: float = .1


func should_trigger() -> bool:
	return randf() < weather_chance