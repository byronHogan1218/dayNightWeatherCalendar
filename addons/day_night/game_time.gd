class_name GameTime

var _epoch:int # in milliseconds

const MILLISECONDS_IN_DAY: int = 86400000
const DAY_DIVISOR: int = 86_400_000
const HOUR_DIVISOR: int = 3_600_000
const MINUTE_DIVISOR: int = 60_000
const SECOND_DIVISOR: int = 1000
const HOURS_IN_DAY: int = 24
const MINUTES_IN_HOUR: int = 60
const SECONDS_IN_MINUTE: int = 60
const MILLISECONDS_IN_SECOND: int = 1000
static var DAYS_IN_YEAR: int = -1
static var YEAR_DIVISOR: int = -1

var _year: int
var _day: int
var _hour: int
var _minute: int
var _second: int
var _millisecond: int

func _init(epoch:int):
	self._epoch = epoch
	var working_epoch: int = epoch
	self._year = working_epoch / YEAR_DIVISOR
	working_epoch -= self._year * YEAR_DIVISOR
	self._day = (working_epoch / DAY_DIVISOR)
	working_epoch -= self._day * DAY_DIVISOR
	self._hour =(working_epoch / HOUR_DIVISOR) % 24
	working_epoch -= self._hour * HOUR_DIVISOR
	self._minute = (working_epoch / MINUTE_DIVISOR) % 60
	working_epoch -= self._minute * MINUTE_DIVISOR
	self._second = (working_epoch / SECOND_DIVISOR) % 60
	working_epoch -= self._second * SECOND_DIVISOR
	self._millisecond = working_epoch

func add_unit(amount: int, unit: String) -> GameTime:
	if amount < 0:
		push_error("Cannot add invalid amount: " + str(amount))
		return null
	if (unit == TimeUnit.YEARS) or (unit == TimeUnit.YEAR):
		return GameTime.new(self.get_epoch() + (amount * YEAR_DIVISOR))
	if (unit == TimeUnit.DAYS) or (unit == TimeUnit.DAY):
		var number_of_years_to_add: int = floor(amount / GameTime.DAYS_IN_YEAR)
		var number_of_days_to_add: int = amount % GameTime.DAYS_IN_YEAR
		var new_date: GameTime = GameTime.new(self.get_epoch())
		if number_of_years_to_add > 0:
			new_date = new_date.add_unit(number_of_years_to_add, TimeUnit.YEARS)
		return GameTime.new(new_date.get_epoch() + (number_of_days_to_add * DAY_DIVISOR))
	if (unit == TimeUnit.HOURS) or (unit == TimeUnit.HOUR):
		var number_of_days_to_add: int = floor(amount / GameTime.HOURS_IN_DAY)
		var number_of_hours_to_add: int = amount % GameTime.HOURS_IN_DAY
		var new_date: GameTime = GameTime.new(self.get_epoch())
		if number_of_days_to_add > 0:
			new_date = new_date.add_unit(number_of_days_to_add, TimeUnit.DAYS)
		return GameTime.new(new_date.get_epoch() + (number_of_hours_to_add * HOUR_DIVISOR))
	if (unit == TimeUnit.MINUTES) or (unit == TimeUnit.MINUTE):
		var number_of_hours_to_add: int = floor(amount / GameTime.MINUTES_IN_HOUR)
		var number_of_minutes_to_add: int = amount % GameTime.MINUTES_IN_HOUR
		var new_date: GameTime = GameTime.new(self.get_epoch())
		if number_of_hours_to_add > 0:
			new_date = new_date.add_unit(number_of_hours_to_add, TimeUnit.HOURS)
		return GameTime.new(new_date.get_epoch() + (number_of_minutes_to_add * MINUTE_DIVISOR))
	if (unit == TimeUnit.SECONDS) or (unit == TimeUnit.SECOND):
		var number_of_minutes_to_add: int = floor(amount / GameTime.SECONDS_IN_MINUTE)
		var number_of_seconds_to_add: int = amount % GameTime.SECONDS_IN_MINUTE
		var new_date: GameTime = GameTime.new(self.get_epoch())
		if number_of_minutes_to_add > 0:
			new_date = new_date.add_unit(number_of_minutes_to_add, TimeUnit.MINUTES)
		return GameTime.new(new_date.get_epoch() + (number_of_seconds_to_add * SECOND_DIVISOR))
	if (unit == TimeUnit.MILLISECONDS) or (unit == TimeUnit.MILLISECOND):
		var number_of_seconds_to_add: int = floor(amount / GameTime.MILLISECONDS_IN_SECOND)
		var number_of_milliseconds_to_add: int = amount % GameTime.MILLISECONDS_IN_SECOND
		var new_date: GameTime = GameTime.new(self.get_epoch())
		if number_of_seconds_to_add > 0:
			new_date = new_date.add_unit(number_of_seconds_to_add, TimeUnit.SECONDS)
		return GameTime.new(new_date.get_epoch() + (number_of_milliseconds_to_add))
	push_error("Invalid unit: " + unit)
	return null

func subtract_unit(amount: int, unit: String) -> GameTime:
	if amount < 0:
		push_error("Cannot add invalid amount: " + str(amount))
		return null
	if (unit == TimeUnit.YEARS) or (unit == TimeUnit.YEAR):
		return GameTime.new(clampi(self.get_epoch() - (amount * YEAR_DIVISOR),0, self.get_epoch()))
	if (unit == TimeUnit.DAYS) or (unit == TimeUnit.DAY):
		var number_of_years_to_subtract: int = floor(amount / GameTime.DAYS_IN_YEAR)
		var number_of_days_to_subtract: int = amount % GameTime.DAYS_IN_YEAR
		var new_date: GameTime = GameTime.new(self.get_epoch())
		if number_of_years_to_subtract > 0:
			new_date = new_date.subtract_unit(number_of_years_to_subtract, TimeUnit.YEARS)
		return GameTime.new(clampi(new_date.get_epoch() - (number_of_days_to_subtract * DAY_DIVISOR),0, new_date.get_epoch()))
	if (unit == TimeUnit.HOURS) or (unit == TimeUnit.HOUR):
		var number_of_days_to_subtract: int = floor(amount / GameTime.HOURS_IN_DAY)
		var number_of_hours_to_subtract: int = amount % GameTime.HOURS_IN_DAY
		var new_date: GameTime = GameTime.new(self.get_epoch())
		if number_of_days_to_subtract > 0:
			new_date = new_date.subtract_unit(number_of_days_to_subtract, TimeUnit.DAYS)
		return GameTime.new(clampi(new_date.get_epoch() - (number_of_hours_to_subtract * HOUR_DIVISOR),0, new_date.get_epoch()))
	if (unit == TimeUnit.MINUTES) or (unit == TimeUnit.MINUTE):
		var number_of_hours_to_subtract: int = floor(amount / GameTime.MINUTES_IN_HOUR)
		var number_of_minutes_to_subtract: int = amount % GameTime.MINUTES_IN_HOUR
		var new_date: GameTime = GameTime.new(self.get_epoch())
		if number_of_hours_to_subtract > 0:
			new_date = new_date.subtract_unit(number_of_hours_to_subtract, TimeUnit.HOURS)
		return GameTime.new(clampi(new_date.get_epoch() - (number_of_minutes_to_subtract * MINUTE_DIVISOR),0, new_date.get_epoch()))
	if (unit == TimeUnit.SECONDS) or (unit == TimeUnit.SECOND):
		var number_of_minutes_to_subtract: int = floor(amount / GameTime.SECONDS_IN_MINUTE)
		var number_of_seconds_to_subtract: int = amount % GameTime.SECONDS_IN_MINUTE
		var new_date: GameTime = GameTime.new(self.get_epoch())
		if number_of_minutes_to_subtract > 0:
			new_date = new_date.subtract_unit(number_of_minutes_to_subtract, TimeUnit.MINUTES)
		return GameTime.new(clampi(new_date.get_epoch() - (number_of_seconds_to_subtract * SECOND_DIVISOR),0, new_date.get_epoch()))
	if (unit == TimeUnit.MILLISECONDS) or (unit == TimeUnit.MILLISECOND):
		var number_of_seconds_to_subtract: int = floor(amount / GameTime.MILLISECONDS_IN_SECOND)
		var number_of_milliseconds_to_subtract: int = amount % GameTime.MILLISECONDS_IN_SECOND
		var new_date: GameTime = GameTime.new(self.get_epoch())
		if number_of_seconds_to_subtract > 0:
			new_date = new_date.subtract_unit(number_of_seconds_to_subtract, TimeUnit.SECONDS)
		return GameTime.new(clampi(new_date.get_epoch() - (number_of_milliseconds_to_subtract),0, new_date.get_epoch()))
	push_error("Invalid unit: " + unit)
	return null

func set_unit(amount: int, unit: String, should_clamp: bool = false) -> GameTime:
	if amount < 0:
		push_error("Cannot set invalid amount: " + str(amount))
		return null
	if should_clamp:
		if (unit == TimeUnit.YEARS) or (unit == TimeUnit.YEAR):
			return GameTime.create_from_time(Instant.new(amount, get_day(), get_hour(), get_minute(), get_second(), get_millisecond()))
		if (unit == TimeUnit.DAYS) or (unit == TimeUnit.DAY):
			return GameTime.create_from_time(Instant.new(get_year(), clampi(amount,0,GameTime.DAYS_IN_YEAR), get_hour(), get_minute(), get_second(), get_millisecond()))
		if (unit == TimeUnit.HOURS) or (unit == TimeUnit.HOUR):
			return GameTime.create_from_time(Instant.new(get_year(), get_day(),  clampi(amount,0,GameTime.HOURS_IN_DAY), get_minute(), get_second(), get_millisecond()))
		if (unit == TimeUnit.MINUTES) or (unit == TimeUnit.MINUTE):
			return GameTime.create_from_time(Instant.new(get_year(), get_day(), get_hour(),  clampi(amount,0,GameTime.MINUTES_IN_HOUR), get_second(), get_millisecond()))
		if (unit == TimeUnit.SECONDS) or (unit == TimeUnit.SECOND):
			return GameTime.create_from_time(Instant.new(get_year(), get_day(), get_hour(), get_minute(), clampi(amount,0,GameTime.SECONDS_IN_MINUTE), get_millisecond()))
		if (unit == TimeUnit.MILLISECONDS) or (unit == TimeUnit.MILLISECOND):
			return GameTime.create_from_time(Instant.new(get_year(), get_day(), get_hour() , get_minute(), get_second(), clampi(amount,0,GameTime.MILLISECONDS_IN_SECOND)))
	else:
		if (unit == TimeUnit.YEARS) or (unit == TimeUnit.YEAR):
			return GameTime.create_from_time(Instant.new(amount, get_day(), get_hour(), get_minute(), get_second(), get_millisecond()))
		if (unit == TimeUnit.DAYS) or (unit == TimeUnit.DAY):
			return GameTime.create_from_time(Instant.new(get_year(), amount % GameTime.DAYS_IN_YEAR, get_hour(), get_minute(), get_second(), get_millisecond()))
		if (unit == TimeUnit.HOURS) or (unit == TimeUnit.HOUR):
			return GameTime.create_from_time(Instant.new(get_year(), get_day(),  amount % GameTime.HOURS_IN_DAY, get_minute(), get_second(), get_millisecond()))
		if (unit == TimeUnit.MINUTES) or (unit == TimeUnit.MINUTE):
			return GameTime.create_from_time(Instant.new(get_year(), get_day(), get_hour(),  amount % GameTime.MINUTES_IN_HOUR, get_second(), get_millisecond()))
		if (unit == TimeUnit.SECONDS) or (unit == TimeUnit.SECOND):
			return GameTime.create_from_time(Instant.new(get_year(), get_day(), get_hour(), get_minute(), amount % GameTime.SECONDS_IN_MINUTE, get_millisecond()))
		if (unit == TimeUnit.MILLISECONDS) or (unit == TimeUnit.MILLISECOND):
			return GameTime.create_from_time(Instant.new(get_year(), get_day(), get_hour() , get_minute(), get_second(), amount % GameTime.MILLISECONDS_IN_SECOND))

	push_error("Invalid unit: " + unit)
	return null



func is_same(other_time: GameTime, unit: String = TimeUnit.MILLISECOND) -> bool:
	if other_time == null:
		push_error("Cannot compare to null time")
		return false
	if (unit == TimeUnit.YEARS) or (unit == TimeUnit.YEAR):
		return self.get_year() == other_time.get_year()
	if (unit == TimeUnit.DAYS) or (unit == TimeUnit.DAY):
		return self.get_day() == other_time.get_day()
	if (unit == TimeUnit.HOURS) or (unit == TimeUnit.HOUR):
		return self.get_hour() == other_time.get_hour()
	if (unit == TimeUnit.MINUTES) or (unit == TimeUnit.MINUTE):
		return self.get_minute() == other_time.get_minute()
	if (unit == TimeUnit.SECONDS) or (unit == TimeUnit.SECOND):
		return self.get_second() == other_time.get_second()
	if (unit == TimeUnit.MILLISECONDS) or (unit == TimeUnit.MILLISECOND):
		return self.get_epoch() == other_time.get_epoch()
	push_error("Invalid unit: " + unit)
	return false

func is_today(today: GameTime) -> bool:
	return self.is_same(today, TimeUnit.DAYS)

func is_after(other_time: GameTime) -> bool:
	if other_time == null:
		push_error("Cannot compare to null time")
		return false
	return self.get_epoch() > other_time.get_epoch()

func is_after_or_same(other_time: GameTime, unit: String = TimeUnit.MILLISECOND) -> bool:
	if other_time == null:
		push_error("Cannot compare to null time")
		return false
	return self.is_after(other_time) or self.is_same(other_time, unit)

func is_before(other_time: GameTime) -> bool:
	if other_time == null:
		push_error("Cannot compare to null time")
		return false
	return self.get_epoch() < other_time.get_epoch()

func is_before_or_same(other_time: GameTime, unit: String = TimeUnit.MILLISECOND) -> bool:
	if other_time == null:
		push_error("Cannot compare to null time")
		return false
	return self.is_before(other_time) or self.is_same(other_time, unit)


func set_time(time: Instant) -> GameTime:
	return  GameTime.new(time.get_epoch())

func get_year() -> int:
	return _year

func get_epoch() -> int:
	return _epoch

func get_millisecond() -> int:
	return _second

func get_second() -> int:
	return _second

func get_minute() -> int:
	return _minute

func get_hour() -> int:
	return _hour

func get_day() -> int:
	return _day

func to_instant() -> Instant:
	return Instant.new(self.get_year(), self.get_day(), self.get_hour(), self.get_minute(), self.get_second(), self.get_millisecond())

func get_time_as_string() -> String:
	return str(get_hour()) + ":" + str(get_minute()) + ":" + str(get_second()) + ":" + str(get_millisecond())

func get_date_as_string() -> String:
	return str(get_year()) + "-" + str(get_day())

func get_date_time_as_string() -> String:
	return get_date_as_string() + " - " + get_time_as_string()

static func is_in_range(time: GameTime, start: GameTime, end: GameTime) -> bool:
	if (start == null) or (end == null):
		push_error("Invalid time range: Must speficy start and end time")
		return false
	if start == null:
		push_error("Invalid time range: Must speficy start time")
		return false
	if end == null:
		push_error("Invalid time range: Must speficy end time")
		return false
	if start.is_after(end):
		push_error("Invalid time range: Start time must be before end time")
		return false
	return time.is_after_or_same(start) && time.is_before_or_same(end)

static func random_time_in_range(start: GameTime, end: GameTime) -> GameTime:
	if (start == null) or (end == null):
		push_error("Invalid time range: Must speficy start and end time")
		return null
	if start == null:
		push_error("Invalid time range: Must speficy start time")
		return null
	if end == null:
		push_error("Invalid time range: Must speficy end time")
		return null
	if start.is_after(end):
		push_error("Invalid time range: Start time must be before end time")
		return null
	var max_epoch: int = end.get_epoch() - start.get_epoch()
	var random: int = randi_range(0, max_epoch)
	return GameTime.new(start.get_epoch() + random)

static func create_from_time(time: Instant) -> GameTime:
	return GameTime.new(time.get_year() * YEAR_DIVISOR + time.get_day() * DAY_DIVISOR + time.get_hour() * HOUR_DIVISOR + time.get_minute() * MINUTE_DIVISOR + time.get_second() * SECOND_DIVISOR + time.get_millisecond())

static func lerp_time(time1: GameTime, time2: GameTime, weight: float) -> GameTime:
	return GameTime.new(GameTime.lerp(time1, time2, weight))

static func lerp(time1: GameTime, time2: GameTime, weight: float) -> float:
	var a_epoch: int = time1.get_epoch()
	var b_epoch: int = time2.get_epoch()
	return lerp(a_epoch, b_epoch, weight)

static func percent_between(current_time: GameTime, start_time: GameTime, end_time: GameTime) -> float:
	if not GameTime.is_in_range(current_time, start_time, end_time):
		push_error("Cannot get percentage of time outside of range. Current " + current_time.get_date_time_as_string() + " - A: " + start_time.get_date_time_as_string() + " - B: " + end_time.get_date_time_as_string())
		return 0
	var current: int = current_time.get_epoch()
	var start: int = start_time.get_epoch()
	var end: int = end_time.get_epoch()
	var percent_range: int = end - start
	if percent_range == 0:
		return 0.0  # Handle zero range case (avoid division by zero)

	return clampf(float(current - start) / float(percent_range),0,1)

static func inverted_percent_between(current_time: GameTime, start_time: GameTime, end_time: GameTime) -> float:
	var percent: float = percent_between(current_time, start_time, end_time)
	return 1.0 - percent

