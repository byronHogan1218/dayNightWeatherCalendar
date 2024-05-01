class_name TimeUnit

const YEARS: String = "years"
const YEAR: String = "year"
const DAYS: String = "days"
const DAY: String = "day"
const HOURS: String = "hours"
const HOUR: String = "hour"
const MINUTES: String = "minutes"
const MINUTE: String = "minute"
const SECONDS: String = "seconds"
const SECOND: String = "second"
const MILLISECONDS: String = "milliseconds"
const MILLISECOND: String = "millisecond"

#func _to_string() -> String:
	#match unit:
		#TimeUnit.YEARS:
			#return "years"
		#TimeUnit.YEAR:
			#return "year"
		#TimeUnit.DAYS:
			#return "days"
		#TimeUnit.DAY:
			#return "day"
		#TimeUnit.HOURS:
			#return "hours"
		#TimeUnit.HOUR:
			#return "hour"
		#TimeUnit.MINUTES:
			#return "minutes"
		#TimeUnit.MINUTE:
			#return "minute"
		#TimeUnit.SECONDS:
			#return "seconds"
		#TimeUnit.SECOND:
			#return "second"
		#TimeUnit.MILLISECONDS:
			#return "milliseconds"
		#TimeUnit.MILLISECOND:
			#return "millisecond"
		#_:
			#push_error("Invalid time unit: unknown unit")
			#return ""
