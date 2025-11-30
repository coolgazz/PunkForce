extends State


func Update():
	if Dialogic.current_timeline == null:
		Transitioned.emit(self, "idle")
