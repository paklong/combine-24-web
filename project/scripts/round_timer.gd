extends Node2D

@onready var progress_bar: ProgressBar = %ProgressBar
@onready var timer: Timer = %Timer

func _ready() -> void:
	timer.timeout.connect(_on_timer_timout)
	start_round(1)
	
func _on_timer_timout():
	timer.stop()
	
func _process(_delta: float) -> void:
	if !timer.is_stopped():
		update_progress_bar()

func reset_progress_bar():
	progress_bar.value = 100

func start_round(level):
	print ('Starting round, level : ' + str(level))

	timer.wait_time = 61 - level
	timer.start()
	
func update_progress_bar():
	progress_bar.value = timer.time_left * (100.0 / timer.wait_time)

# level 1 : 100
# level 2 : 60
