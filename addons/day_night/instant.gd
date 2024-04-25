class_name Instant

var _epoch:int
var _year: int
var _day: int
var _hour: int
var _minute: int
var _second: int
var _millisecond: int

func _init(year: int, days: int, hours: int, minutes: int, seconds: int, milliseconds: int):
	self._year = year
	self._day = days
	self._hour = hours
	self._minute = minutes
	self._second = seconds
	self._millisecond = milliseconds
	var year_milliseconds: int = self._year * GameTime.YEAR_DIVISOR
	var days_milliseconds: int = self._day * GameTime.DAY_DIVISOR
	var hours_milliseconds: int = self._hour * GameTime.HOUR_DIVISOR
	var minutes_milliseconds: int = self._minute * GameTime.MINUTE_DIVISOR
	var seconds_milliseconds: int = self._second * GameTime.SECOND_DIVISOR

	self._epoch = year_milliseconds + days_milliseconds + hours_milliseconds + minutes_milliseconds + seconds_milliseconds + milliseconds

func get_epoch() -> int:
	return self._epoch

func get_year() -> int:
	return self._year

func get_day() -> int:
	return self._day

func get_hour() -> int:
	return self._hour

func get_minute() -> int:
	return self._minute

func get_second() -> int:
	return self._second

func get_millisecond() -> int:
	return self._millisecond


