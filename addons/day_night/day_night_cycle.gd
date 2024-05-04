extends Node

const _MIN_DAY_LENGTH: int = 3
const _FULL_DAY_PERCENTAGE: int = 1
const _MAX_DAY_LENGTH: int = 8640000 # 100 * an earth day length in seconds
const _MAX_TIME_MULTIPLIER: float = 100.0
## Higher the value, the slower the transition will be
const _AUTO_COLOR_TRANSTION: float = 0.5;
const _MAX_LIGHT_INTENSITY_POSSIBLE: float = 16.0

@export var sun: DirectionalLight3D
@export var day_lenth_in_seconds: int = 5 :
	get:
		return day_lenth_in_seconds
	set(value):
		day_lenth_in_seconds = clamp(value, _MIN_DAY_LENGTH, _MAX_DAY_LENGTH)
@export var days_in_year: int = 1
@export var start_year: int = 0
@export var start_day: int = 0
@export var start_hour: int = 0
@export var start_minute: int = 0
@export var start_second: int = 0
## The day schedule that will be used. This can be null.
@export var day_scheduler: DayScheduler
@export var default_day_config: DayConfig = DayConfig.new()
@export var show_debug_info: bool = false
@export_range(0.1, _MAX_TIME_MULTIPLIER) var default_time_speed_multiplier: float = 1.0


@onready var _on_day_change: Subject = Subject.new()
@onready var _on_year_change: Subject = Subject.new()
@onready var _on_night_time_start: Subject = Subject.new()
@onready var _on_day_time_start: Subject = Subject.new()
@onready var _on_time_paused: Subject = Subject.new()
@onready var _on_time_resumed: Subject = Subject.new()
@onready var _on_time_speed_change: Subject = Subject.new()
@onready var _on_time_speed_end: Subject = Subject.new()
@onready var _on_day_period_start: Subject = Subject.new()
@onready var _on_day_period_end: Subject = Subject.new()
@onready var _on_day_period_overwrite: Subject = Subject.new()
@onready var _on_weather_start: Subject = Subject.new()
@onready var _on_weather_end: Subject = Subject.new()
@onready var _on_day_config_change: Subject = Subject.new()
@onready var _on_day_scheduler_change: Subject = Subject.new()
@onready var _on_day_scheduler_finish: Subject = Subject.new()
@onready var on_day_change: Observable = _on_day_change.as_observable()
@onready var on_year_change: Observable = _on_year_change.as_observable()
@onready var on_night_time_start: Observable = _on_night_time_start.as_observable()
@onready var on_day_time_start: Observable = _on_day_time_start.as_observable()
@onready var on_time_paused: Observable = _on_time_paused.as_observable()
@onready var on_time_resumed: Observable = _on_time_resumed.as_observable()
@onready var on_time_speed_change: Observable = _on_time_speed_change.as_observable()
@onready var on_time_speed_end: Observable = _on_time_speed_end.as_observable()
@onready var on_day_period_start: Observable = _on_day_period_start.as_observable()
@onready var on_day_period_end: Observable = _on_day_period_end.as_observable()
@onready var on_day_period_overwrite: Observable = _on_day_period_overwrite.as_observable()
@onready var on_weather_start: Observable = _on_weather_start.as_observable()
@onready var on_weather_end: Observable = _on_weather_end.as_observable()
@onready var on_day_config_change: Observable = _on_day_config_change.as_observable()
@onready var on_day_scheduler_change: Observable = _on_day_scheduler_change.as_observable()
@onready var on_day_scheduler_finish: Observable = _on_day_scheduler_finish.as_observable()

var _percentage_through_day: float = 0
var _time_speed_multiplier: float = 1
var _time_to_stop_multiplier: GameTime = null
var _time_stopped: bool = false
var _current_date_at_start_of_day: GameTime
var _current_date_at_end_of_day: GameTime
var _sunrise_start_percentage: float
var _sunset_start_percentage: float
var _reminders: Dictionary = {}
var _repeating_reminders: Dictionary = {}
var _todays_reminders: Array[Variant] = []
var _reminder_index: int = 0
var _day_period_index: int = 0
var _has_day_periods: bool = false
var _active_period: DayPeriodConfig = null
var _active_weather: WeatherConfig = null
var _game_time_this_frame: GameTime
var _color_lerp_time: float = 0
var _day_config: DayConfig = null
var _sunrise_today: GameTime
var _sunset_today: GameTime
var _middle_of_day_time: GameTime
var _sunset_yesterday: GameTime
var _sunrise_tomorrow: GameTime
var _middle_of_night_begin: GameTime
var _middle_of_night_end: GameTime

var _yesterday: DayConfig

var _is_day: bool = false

#var rng := RandomNumberGenerator.new()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if show_debug_info:
		on_day_period_overwrite.subscribe(func(information: Dictionary): print("Day Period Overwriten. Old period: " + information.get("old_period").period_name + " - New period: " + information.get("new_period").period_name)).dispose_with(self)
	if default_day_config == null:
		push_error("No default day config set!")
		get_tree().quit()
	#if DayNightCycle._instance == null:
		#DayNightCycle._instance = self  # Set instance on first creation
	#else:
		#push_error("DayNightCycle singleton already exists!")
		#return
	#print("Day Night Cycle Ready: ", rng.randi() )

	GameTime.DAYS_IN_YEAR = days_in_year
#	const YEAR_DIVISOR: int = 31_536_000_000
	GameTime.YEAR_DIVISOR = GameTime.DAYS_IN_YEAR * GameTime.DAY_DIVISOR

	if day_scheduler == null:
		set_day_config(default_day_config)
	else:
		set_day_config(day_scheduler.get_current_day_config())
	set_time(GameTime.create_from_time(Instant.new(start_year, start_day, start_hour, start_minute, start_second, 0)), false)
	#print(_current_date_at_start_of_day.add_unit(13, TimeUnit.HOURS).get_time_as_string())
	var o = create_reminder(_current_date_at_start_of_day.add_unit(13, TimeUnit.HOURS), true)
	var o2 = create_reminder(_current_date_at_start_of_day.add_unit(12, TimeUnit.HOURS), true)
	var o3 = create_reminder(_current_date_at_start_of_day.add_unit(14, TimeUnit.HOURS), true)

	on_day_change \
		.subscribe(func(newTime: GameTime): _populate_reminders(newTime)).dispose_with(self)
	on_day_period_start \
		.subscribe(func(period: DayPeriodConfig): print("Starting Day Period: " + period.period_name + " at time: " + _game_time_this_frame.get_date_time_as_string())).dispose_with(self)
	on_day_period_end \
		.subscribe(func(period: DayPeriodConfig): print("Ending Day Period: " + period.period_name + " at time: " + _game_time_this_frame.get_date_time_as_string())).dispose_with(self)

	#GDRx.start_periodic_timer(0.1).subscribe(func(i): print("Interval time: " + get_time().get_date_as_string() + " - " + get_time().get_time_as_string(), " - percentage through day: ", percentage_through_day)).dispose_with(self)

	on_day_change.subscribe(func(time: GameTime): print("subscribing new day game time: ", time.get_date_as_string() )).dispose_with(self)

	on_time_speed_end.subscribe(func(time: GameTime): print("warp ends at time: ", time.get_date_as_string(), " - ", time.get_time_as_string() )).dispose_with(self)
	o.subscribe(func(is_time: bool): print("Reminder that is is 13 hours at the time: " + _game_time_this_frame.get_time_as_string())).dispose_with(self)
	o2.subscribe(func(is_time: bool): print("Reminder that is is 12 hours at the time: " + _game_time_this_frame.get_time_as_string())).dispose_with(self)
	o3.subscribe(func(is_time: bool): print("Reminder that is is 14 hours at the time: " + _game_time_this_frame.get_time_as_string())).dispose_with(self)
#	on_year_change.as_observable() \
#		.filter(func(newTime: GameTime): return newTime !=null)  \
#		.subscribe(func(newTime: GameTime): print("The year has changed: " + newTime.get_date_as_string() + " - " + newTime.get_time_as_string())).dispose_with(self)
#	on_day_time_start.as_observable().filter(func(newTime: GameTime): return newTime !=null).subscribe(func(time): print("day time start: " + time.get_date_as_string() + " - " + time.get_time_as_string())).dispose_with(self)
#	on_night_time_start.as_observable().filter(func(newTime: GameTime): return newTime !=null).subscribe(func(time): print("night time start: " + time.get_date_as_string() + " - " + time.get_time_as_string())).dispose_with(self)
	print("setting time this frame to: " + _game_time_this_frame.get_date_as_string() + " - " + _game_time_this_frame.get_time_as_string())
	alter_time_speed(80, _game_time_this_frame.add_unit(20,TimeUnit.DAY))
	# sort day periods
	if (_day_config != null) && (_day_config.day_periods != null):
		_has_day_periods = true
		_day_config.day_periods.sort_custom(func(a, b): return a.start_time < b.start_time)

func clear_console(num):
	for i in range(num):
		print("")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	if not _time_stopped:
		_percentage_through_day += (delta / day_lenth_in_seconds) * _time_speed_multiplier;
		_send_potential_reminders()
		# Needs to make sure the percentage never goes over 1, so handle day end first
		if _percentage_through_day >= 1:
			handle_day_end();
	_game_time_this_frame = calculate_game_time_for_frame()
	_handle_time_speed()
	_update_day_state()

	if sun != null:
		var rotation: Vector3 = get_sun_rotation()
		sun.rotation.x = deg_to_rad(rotation.x)
		sun.rotation.y = deg_to_rad(rotation.y)
		sun.set_color(get_light_color(delta))
		sun.light_energy = calculate_light_intesity()

func _handle_time_speed():
	if (_time_to_stop_multiplier != null) && (_game_time_this_frame.is_after_or_same(_time_to_stop_multiplier)):
		_time_to_stop_multiplier = null
		_on_time_speed_end.on_next(_game_time_this_frame)
		alter_time_speed(default_time_speed_multiplier)

func _update_day_state(should_trigger_events: bool = true):
	if _game_time_this_frame != null && _game_time_this_frame.get_hour() == 5 && _sunrise_today != null && _sunrise_today.get_hour() == 5:
		var f =""
	# TODO something wrong with is day
	if (_percentage_through_day < _sunset_start_percentage) && (_percentage_through_day > _sunrise_start_percentage):
		if not _is_day:
			# Just turned day
			_color_lerp_time = 0
			_is_day = true
			if should_trigger_events:
				_on_day_time_start.on_next(GameTime.new(_game_time_this_frame.get_epoch()))
		else:
			var delete_me
			#it has been day
			# DO NOTHING FOR NOW
	else:
		#test
		if _is_day:
			# just turned night
			_color_lerp_time = 0
			_is_day = false
			if should_trigger_events:
				_on_night_time_start.on_next(GameTime.new(_game_time_this_frame.get_epoch()))
		else:
			var delete_me
			# it has been night
			# DO NOTHING FOR NOW

	if _has_day_periods:
		if (_day_period_index < _day_config.day_periods.size()) && _game_time_this_frame.is_after_or_same(_day_config.day_periods[_day_period_index].get_start_time(_game_time_this_frame.get_year(), _game_time_this_frame.get_day())):
			_on_day_period_start.on_next(_day_config.day_periods[_day_period_index])
			_color_lerp_time = 0
			if _active_period != null:
				if _active_weather != null:
					_on_weather_end.on_next(_active_weather)
					_active_weather = null
				_on_day_period_overwrite.on_next({"old_period": _active_period, "new_period": _day_config.day_periods[_day_period_index]})
			_active_period = _day_config.day_periods[_day_period_index]
			if _active_period.has_weather():
				var possible_weather: WeatherConfig = _active_period.pick_weather()
				if (possible_weather != null) && possible_weather.should_trigger():
					_active_weather = possible_weather
					_on_weather_start.on_next(_active_weather)
			_day_period_index =  _day_period_index + 1
	if _active_period != null:
		if _game_time_this_frame.is_after_or_same(_active_period.get_end_time(_game_time_this_frame.get_year(), _game_time_this_frame.get_day())):
			if _active_weather != null:
					_on_weather_end.on_next(_active_weather)
					_active_weather = null
			_on_day_period_end.on_next(_active_period)
			_active_period = null
			_color_lerp_time = 0

func handle_day_end():
	_yesterday = _day_config
	var old_date = GameTime.new(_current_date_at_start_of_day.get_epoch())
	_current_date_at_start_of_day = _current_date_at_start_of_day.add_unit(1, TimeUnit.DAY)
	_current_date_at_end_of_day = _current_date_at_start_of_day.set_time(Instant.new(
		_current_date_at_start_of_day.get_year(),
		_current_date_at_start_of_day.get_day(),
		23,
		59,
		59,
		999
	))
	_on_day_change.on_next(_current_date_at_start_of_day)
	_day_period_index = 0
	if not _current_date_at_start_of_day.is_same(old_date, TimeUnit.YEARS):
		_on_year_change.on_next(_current_date_at_start_of_day)
	if(day_scheduler != null):
		set_day_config(day_scheduler.advance_and_get_next_day_config())
		if day_scheduler.is_done():
			_on_day_scheduler_finish.on_next(day_scheduler)
			day_scheduler = null
	else:
		if _day_config.get_instance_id() != default_day_config.get_instance_id():
			set_day_config(default_day_config)

	_percentage_through_day -= _FULL_DAY_PERCENTAGE
	_sunrise_start_percentage = _calculate_percent_of_day_by_time(GameTime.create_from_time(_day_config.get_sunrise()))
	_sunset_start_percentage = _calculate_percent_of_day_by_time(GameTime.create_from_time(_day_config.get_sunset()))

	_game_time_this_frame = calculate_game_time_for_frame()
	_calculate_milestone_times()
	if _percentage_through_day >= _FULL_DAY_PERCENTAGE:
		handle_day_end()

func stop_time() -> void:
	if !_time_stopped:
		_on_time_paused.on_next(_time_stopped)
	_time_stopped = true


func start_time() -> void:
	if _time_stopped:
		_on_time_resumed.on_next(_time_stopped)
	_time_stopped = false

func set_day_config(config: DayConfig) -> void:
	if (_day_config != null) && (config.get_instance_id() == _day_config.get_instance_id()):
		return
	_color_lerp_time = 0
	_day_config = config
	_on_day_config_change.on_next(_day_config)

func set_new_scheduler(scheduler: DayScheduler, overwrite_day_config: bool = false) -> void:
	day_scheduler = scheduler
	_on_day_scheduler_change.on_next(day_scheduler)
	if overwrite_day_config:
		set_day_config(day_scheduler.get_current_day_config())

func _calculate_milestone_times() -> void:
	if day_scheduler != null:
		var yesterday_sunset: GameTime
		if _yesterday != null:
			yesterday_sunset = _yesterday.get_sunset_time().set_unit(_game_time_this_frame.get_year(), TimeUnit.YEAR, true).set_unit(_game_time_this_frame.get_day(), TimeUnit.DAY, true).subtract_unit(1, TimeUnit.DAY)
		else:
			if day_scheduler.should_repeat:
				yesterday_sunset = day_scheduler.get_previous_day_config().get_sunset_time().set_unit(_game_time_this_frame.get_year(), TimeUnit.YEAR, true).set_unit(_game_time_this_frame.get_day(), TimeUnit.DAY, true).subtract_unit(1, TimeUnit.DAY)
			else:
				# We default to the default day config is the scheduler does not repeat
				yesterday_sunset = default_day_config.get_sunset_time().set_unit(_game_time_this_frame.get_year(), TimeUnit.YEAR, true).set_unit(_game_time_this_frame.get_day(), TimeUnit.DAY, true).subtract_unit(1, TimeUnit.DAY)
		var tomorrow_sunrise: GameTime
		if day_scheduler.is_done():
			# We default to the default day config if the scheduler is done
			tomorrow_sunrise = default_day_config.get_sunrise_time().set_unit(_game_time_this_frame.get_year(), TimeUnit.YEAR, true).set_unit(_game_time_this_frame.get_day(), TimeUnit.DAY, true).add_unit(1, TimeUnit.DAY)
		else:
			tomorrow_sunrise = day_scheduler.get_next_day_config().get_sunrise_time().set_unit(_game_time_this_frame.get_year(), TimeUnit.YEAR, true).set_unit(_game_time_this_frame.get_day(), TimeUnit.DAY, true).add_unit(1, TimeUnit.DAY)
		_sunset_yesterday = yesterday_sunset
		_sunrise_tomorrow = tomorrow_sunrise
		_sunrise_today = day_scheduler.get_current_day_config().get_sunrise_time().set_unit(_game_time_this_frame.get_year(), TimeUnit.YEAR, true).set_unit(_game_time_this_frame.get_day(), TimeUnit.DAY, true)
		_sunset_today = day_scheduler.get_current_day_config().get_sunset_time().set_unit(_game_time_this_frame.get_year(), TimeUnit.YEAR, true).set_unit(_game_time_this_frame.get_day(), TimeUnit.DAY, true)
		_middle_of_day_time = GameTime.new((_sunrise_today.get_epoch() + _sunset_today.get_epoch()) / 2)
		_middle_of_night_begin = GameTime.new((_sunset_yesterday.get_epoch() + _sunrise_today.get_epoch()) / 2)
		_middle_of_night_end = GameTime.new((_sunset_today.get_epoch() + _sunrise_tomorrow.get_epoch()) / 2)
		return
	# We need to calculate based off of the set day config
	var yesterday_sunset: GameTime
	if _yesterday != null:
		yesterday_sunset = _yesterday.get_sunset_time().set_unit(_game_time_this_frame.get_year(), TimeUnit.YEAR, true).set_unit(_game_time_this_frame.get_day(), TimeUnit.DAY, true).subtract_unit(1, TimeUnit.DAY)
	else:
		yesterday_sunset = _day_config.get_sunset_time().set_unit(_game_time_this_frame.get_year(), TimeUnit.YEAR, true).set_unit(_game_time_this_frame.get_day(), TimeUnit.DAY, true).subtract_unit(1, TimeUnit.DAY)
	_sunset_yesterday = yesterday_sunset
	_sunrise_tomorrow = _day_config.get_sunrise_time().set_unit(_game_time_this_frame.get_year(), TimeUnit.YEAR, true).set_unit(_game_time_this_frame.get_day(), TimeUnit.DAY, true).add_unit(1, TimeUnit.DAY)
	_sunrise_today = _day_config.get_sunrise_time().set_unit(_game_time_this_frame.get_year(), TimeUnit.YEAR, true).set_unit(_game_time_this_frame.get_day(), TimeUnit.DAY, true)
	_sunset_today = _day_config.get_sunset_time().set_unit(_game_time_this_frame.get_year(), TimeUnit.YEAR, true).set_unit(_game_time_this_frame.get_day(), TimeUnit.DAY, true)
	_middle_of_day_time = GameTime.new((_sunrise_today.get_epoch() + _sunset_today.get_epoch()) / 2)
	_middle_of_night_begin = GameTime.new((_sunset_yesterday.get_epoch() + _sunrise_today.get_epoch()) / 2)
	_middle_of_night_end = GameTime.new((_sunset_today.get_epoch() + _sunrise_tomorrow.get_epoch()) / 2)

func set_time(time: GameTime, should_trigger_events: bool = true) -> void:
	if should_trigger_events:
		# TODO: trigger events for how much time has passed
		_on_day_change.on_next(time)
	_current_date_at_start_of_day = time.set_time(Instant.new(
		time.get_year(),
		time.get_day(),
		0,
		0,
		0,
		0
	))
	_current_date_at_end_of_day = time.set_time(Instant.new(
		time.get_year(),
		time.get_day(),
		23,
		59,
		59,
		999
	))

	_percentage_through_day = _calculate_percent_of_day_by_time(time)
	_sunrise_start_percentage = _calculate_percent_of_day_by_time(GameTime.create_from_time(_day_config.get_sunrise()))
	_sunset_start_percentage = _calculate_percent_of_day_by_time(GameTime.create_from_time(_day_config.get_sunset()))
	_update_day_state(should_trigger_events)
	_populate_reminders(_current_date_at_start_of_day)
	_is_day = (_percentage_through_day >= _sunrise_start_percentage) && (_percentage_through_day < _sunset_start_percentage)
	_game_time_this_frame = calculate_game_time_for_frame()
	_calculate_milestone_times()

	if sun:
		var rotation: Vector3 = get_sun_rotation()
		sun.rotation.x = deg_to_rad(rotation.x)
		sun.rotation.y = deg_to_rad(rotation.y)
		sun.set_color(get_light_color(0,true))
		sun.light_energy = calculate_light_intesity()

func _calculate_percent_of_day_by_time(time: GameTime) -> float:
	var milliseconds_passed: int = time.get_epoch() - _current_date_at_start_of_day.get_epoch()
	var percentage: float = float(milliseconds_passed) / float(GameTime.MILLISECONDS_IN_DAY)
	while percentage < 0:
		percentage = 1 + percentage
	return percentage

func calculate_game_time_for_frame() -> GameTime:
	var milliseconds_so_far: int = _percentage_through_day * GameTime.MILLISECONDS_IN_DAY
	return GameTime.new(_current_date_at_start_of_day.get_epoch() + milliseconds_so_far)

func get_time_this_frame() -> GameTime:
	return _game_time_this_frame

func get_time_speed_multiplier() -> float:
	return _time_speed_multiplier


func get_light_color(delta: float, immediate: bool = false) -> Color:
	if (_color_lerp_time > 1):
		return sun.get_color();
	_color_lerp_time += delta / (day_lenth_in_seconds * _AUTO_COLOR_TRANSTION)
	var new_color: Color
	if _active_weather != null:
		new_color = _active_weather.day_time_weather_color if _is_day else _active_weather.night_time_weather_color
	elif _active_period != null:
		new_color = _active_period.day_time_period_color if _is_day else _active_period.night_time_period_color
	else:
		new_color = _day_config.get_day_time_color() if _is_day else _day_config.get_night_time_color()

	if immediate:
		_color_lerp_time=2
		return new_color
	else:
		return lerp(sun.get_color(), new_color, _color_lerp_time) as Color


func calculate_light_intesity() -> float:
	var intensity: float
	var min_intensity: float
	if _active_weather != null:
		intensity = _active_weather.day_time_light_intensity if _is_day else _active_weather.night_time_light_intensity
		min_intensity = _active_weather.minimum_light_intensity
	elif _active_period != null:
		intensity = _active_period.day_time_light_intensity if _is_day else _active_period.night_time_light_intensity
		min_intensity = _active_period.minimum_light_intensity
	else:
		intensity = _day_config.day_time_light_intensity if _is_day else _day_config.night_time_light_intensity
		min_intensity = _day_config.minimum_light_intensity
	return clampf(intensity * _get_light_intensity_percentage(), min_intensity, _MAX_LIGHT_INTENSITY_POSSIBLE)

func _get_light_intensity_percentage() -> float:
	if _is_day:
		if _game_time_this_frame.is_before(_middle_of_day_time):
			return GameTime.percent_between(_game_time_this_frame, _sunrise_today, _middle_of_day_time)
		else:
			return GameTime.inverted_percent_between(_game_time_this_frame, _middle_of_day_time, _sunset_today)
	else:
		if _game_time_this_frame.is_before(_sunrise_today):
			# We transitioned to night after midnight, se we should use yesterdays values
			if _game_time_this_frame.is_before(_middle_of_night_begin):
				return GameTime.percent_between(_game_time_this_frame, _sunset_yesterday, _middle_of_night_begin, "am,bm")
			else:
				return GameTime.inverted_percent_between(_game_time_this_frame, _middle_of_night_begin, _sunset_today, "am,am")
		else:
			# We are night before midnight, so we should use todays values
			if _game_time_this_frame.is_before(_middle_of_night_end):
				return GameTime.percent_between(_game_time_this_frame, _sunset_today, _middle_of_night_end, str(_day_config.get_sunrise_time().get_hour())+"-"+str(_game_time_this_frame.get_hour()) + "-" + str(_is_day))
			else:
				return GameTime.inverted_percent_between(_game_time_this_frame, _middle_of_night_end, _sunrise_tomorrow, "bm,am")

func get_sun_rotation() -> Vector3:
	var angle: float

	if (_is_day):
		# If it is the day, calculate from 0-180 for time
		var percentage: float = (_percentage_through_day - _sunrise_start_percentage) / (_sunset_start_percentage - _sunrise_start_percentage)
		angle = lerp(0, 180, percentage)
	else:
		var percentage: float
		# If it is the night, calculate from 180-360 for time
		if (_percentage_through_day >= _sunset_start_percentage):
			# Before the 24th hour
			var current: float = (_percentage_through_day - _sunset_start_percentage)
			var total: float = ((_sunrise_start_percentage + _FULL_DAY_PERCENTAGE) - _sunset_start_percentage)
			percentage =  current / total
		else:
			# TODO this will need to be a "get tomorrow" functionality instead of same day config when different days are possible
			# Still night but after the 24th hour
			var current: float = _percentage_through_day + float(_FULL_DAY_PERCENTAGE) - _sunset_start_percentage
			var total: float = float(_FULL_DAY_PERCENTAGE) + _sunrise_start_percentage - _sunset_start_percentage
			percentage = (current / total)
		angle = lerp(180, 360, percentage)

	# The x axis needs to be offset by 180 to get the correct angle
	return Vector3(angle + 180, angle, 0)

func save() -> Dictionary:
	# TODO implement. Return a string or something that when given to load will restore the state
	return {}

func load() -> Dictionary:
	# TODO restor the state from the string or whatever that save produces
	return {}

func create_reminder(time: GameTime, repeating: bool = false) -> Observable:
	var observable: Subject = Subject.new()
	if repeating:
		if not _repeating_reminders.has(time.get_date_as_string()):
			_repeating_reminders[time.get_date_as_string()] = []
		_repeating_reminders[time.get_date_as_string()].append({"observable": observable, "time": time})
	else:
		if not _reminders.has(time.get_date_as_string()):
			_reminders[time.get_date_as_string()] = []
		_reminders[time.get_date_as_string()].append({"observable": observable, "time": time})

	# If the reminder is for today and is after now, we need to add it to the list of reminders for today
	if time.is_today(_game_time_this_frame) and time.is_after(_game_time_this_frame):
		if repeating:
			var new_time: GameTime = time.add_unit(1, TimeUnit.DAY)
			if not _repeating_reminders.has(new_time.get_date_as_string()):
				_repeating_reminders[new_time.get_date_as_string()] = []
			_repeating_reminders[new_time.get_date_as_string()].append({"observable": observable, "time": new_time})
		_todays_reminders.append({"observable": observable, "time": time})
		_todays_reminders.sort_custom(func(a, b): return a.time.get_epoch() < b.time.get_epoch())
		_reminder_index = 0
		while _todays_reminders[_reminder_index].time.is_before(_game_time_this_frame):
			_reminder_index += 1
		
	return observable.as_observable()

func alter_time_speed(time_multiplier: float, time_to_stop_at: GameTime = null)-> void:
	if time_multiplier < 0.1:
		push_error("Invalid time multiplier: " + str(time_multiplier))
		return
	if time_multiplier > _MAX_TIME_MULTIPLIER:
		push_error("Cannot multiply time speed beyond: " + str(_MAX_TIME_MULTIPLIER))
		return
	if time_to_stop_at != null:
		if(time_to_stop_at.is_before_or_same(_game_time_this_frame)):
			push_error("Must set time to stop at a time after the current time: Current Time[ " + _game_time_this_frame.get_date_as_string()+ " | " + _game_time_this_frame.get_time_as_string() + " ] - Time to stop at [ " + time_to_stop_at.get_date_as_string()+ " | " + time_to_stop_at.get_time_as_string() + " ]")
			return
		_time_to_stop_multiplier = time_to_stop_at
		print ("Setting time to stop at: " + time_to_stop_at.get_date_as_string() + " - " + time_to_stop_at.get_time_as_string())
	_on_time_speed_change.on_next(time_multiplier)
	_time_speed_multiplier = time_multiplier

func reset_default_time_speed() -> void:
	alter_time_speed(default_time_speed_multiplier)

func _populate_reminders(time: GameTime) -> void:
	_todays_reminders.clear()
	_reminder_index=0
	if _reminders.has(time.get_date_as_string()):
		for reminder in _reminders[time.get_date_as_string()]:
			_todays_reminders.append(reminder)
		#_reminders.erase(time.get_date_as_string())
	if _repeating_reminders.has(time.get_date_as_string()):
		for reminder in _repeating_reminders[time.get_date_as_string()]:
			_todays_reminders.append(reminder)
			var new_time = reminder.time.add_unit(1, TimeUnit.DAY)
			if not _repeating_reminders.has(new_time.get_date_as_string()):
				_repeating_reminders[new_time.get_date_as_string()] = []
			_repeating_reminders[new_time.get_date_as_string()].append({"observable": reminder.observable, "time": new_time})
		#_repeating_reminders.erase(time.get_date_as_string())
	_todays_reminders.sort_custom(func(a, b): return a.time.get_epoch() < b.time.get_epoch())

func _send_potential_reminders() -> void:
	if (_todays_reminders.size() > 0) and (_reminder_index < _todays_reminders.size()):
		if _todays_reminders[_reminder_index].time.is_before(_game_time_this_frame):
			_todays_reminders[_reminder_index].observable.on_next(true)
			_reminder_index += 1
