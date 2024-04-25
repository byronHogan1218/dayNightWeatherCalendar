class_name GameTime

var _epoch:int # in milliseconds

const MILLISECONDS_IN_DAY: int = 86400000
const YEAR_DIVISOR: int = 31_536_000_000
const DAY_DIVISOR: int = 86_400_000
const HOUR_DIVISOR: int = 3_600_000
const MINUTE_DIVISOR: int = 60_000
const SECOND_DIVISOR: int = 1000
const HOURS_IN_DAY: int = 24
const MINUTES_IN_HOUR: int = 60
const SECONDS_IN_MINUTE: int = 60
const MILLISECONDS_IN_SECOND: int = 1000
static var DAYS_IN_YEAR: int = -1

var _year: int
var _day: int
var _hour: int
var _minute: int
var _second: int
var _millisecond: int

func _init(epoch:int):
	self._epoch = epoch
#	self._second = floor(epoch / SECOND_DIVISOR) % 60
#	self._minute = floor(epoch / MINUTE_DIVISOR) % 60
#	self._hour = floor(epoch / HOUR_DIVISOR) % 24
#	self._day = floor(epoch / DAY_DIVISOR) % 365
#	self._year = floor(epoch / YEAR_DIVISOR)
	var working_epoch: int = epoch
	self._year = working_epoch / YEAR_DIVISOR
	working_epoch -= self._year * YEAR_DIVISOR
	self._day = (working_epoch / DAY_DIVISOR) % 365
	working_epoch -= self._day * DAY_DIVISOR
	self._hour =(working_epoch / HOUR_DIVISOR) % 24
	working_epoch -= self._hour * HOUR_DIVISOR
	self._minute = (working_epoch / MINUTE_DIVISOR) % 60
	working_epoch -= self._minute * MINUTE_DIVISOR
	self._second = (working_epoch / SECOND_DIVISOR) % 60
	working_epoch -= self._second * SECOND_DIVISOR
	self._millisecond = working_epoch

func add_unit(amount: int, unit: String) -> GameTime:
	if amount <= 0:
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

func get_time_as_string() -> String:
	return str(get_hour()) + ":" + str(get_minute()) + ":" + str(get_second()) + ":" + str(get_millisecond())

func get_date_as_string() -> String:
	return str(get_year()) + "-" + str(get_day())

#static func create_from_time(year:int, days: int, hours: int, minutes: int, seconds: int, milliseconds: int) -> GameTime:
static func create_from_time(time: Instant) -> GameTime:
	return GameTime.new(time.get_year() * YEAR_DIVISOR + time.get_day() * DAY_DIVISOR + time.get_hour() * HOUR_DIVISOR + time.get_minute() * MINUTE_DIVISOR + time.get_second() * SECOND_DIVISOR + time.get_millisecond())

static func create_from_game_time(game_time: GameTime, year:int = -1, days: int =-1, hours: int =-1, minutes: int =-1, seconds: int =-1) -> GameTime:
	var year_to_set: int = year if year >= 0 else game_time.get_year()
	var days_to_set: int = days if days >= 0 else game_time.get_day()
	var hours_to_set: int = hours if hours >= 0 else game_time.get_hour()
	var minutes_to_set: int = minutes if minutes >= 0 else game_time.get_minute()
	var seconds_to_set: int = seconds if seconds >= 0 else game_time.get_second()
	return GameTime.new((year_to_set * YEAR_DIVISOR) + (days_to_set * DAY_DIVISOR) + (hours_to_set * HOUR_DIVISOR) + (minutes_to_set * MINUTE_DIVISOR) + seconds_to_set)
