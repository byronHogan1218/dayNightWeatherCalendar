extends Node

@onready var date_label: Label = $Date
@onready var time_label: Label = $Time
@onready var time_multiplier_label: Label = $TimeMultiplier
@onready var day_night = get_node("DayNightCycle")

#func _ready():
	#day_night = get_node("DayNightCycle")
	#day_night.get_time_speed_multiplier()

#var day_night_cycle: Node = DayNightCycle.get_instance()

func _process(delta: float) -> void:
	date_label.text = "Year: " +  str(day_night.get_time_this_frame().get_year()) + " / Day: " + str(day_night.get_time_this_frame().get_day())
	time_label.text = day_night.get_time_this_frame().get_time_as_string()
	time_multiplier_label.text = str(day_night.get_time_speed_multiplier())
	#time_label.text = day_night.get_time_this_frame().get_time_as_string()
	
	#print(day_night_cycle.get_time().get_time_as_string())
