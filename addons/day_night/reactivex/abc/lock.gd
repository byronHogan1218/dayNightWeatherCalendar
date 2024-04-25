class_name LockBase

## Interface of a Lock
## 
## Allows a thread to aquire and release it.

func lock():
	GDRx.exc.NotImplementedException.Throw()

func unlock():
	GDRx.exc.NotImplementedException.Throw()

func try_lock() -> bool:
	GDRx.exc.NotImplementedException.Throw()
	return false

func is_locking_thread() -> bool:
	GDRx.exc.NotImplementedException.Throw()
	return false

func _unlock_and_store_recursion_depth():
	GDRx.exc.NotImplementedException.Throw()

func _lock_and_restore_recursion_depth():
	GDRx.exc.NotImplementedException.Throw()
