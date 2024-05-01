extends Resource
class_name WeatherConfig

@export_category("Weather Configuration")

## The path to the node that contains the weather condition if picked and triggered
@export var weather_condition: NodePath
## The color that will be used if this weather condition is picked and triggered
@export_color_no_alpha() var weather_color: Color
## How likely this weather conditon is to be picked from the possible weather conditions. Higher value = more likely
@export_range(0,1000,1) var weather_weight: int = 1
## If picked, how likely this weather condition is to trigger. Higher value = more likely
@export_range(0,1,0.01) var weather_chance: float = 1

func should_trigger() -> bool:
	return randf() < weather_chance