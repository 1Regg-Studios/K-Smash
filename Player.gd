extends Actor

func _physics_process(delta: float) -> void:
	var direction:= Input.get_vector("Move_Left","Move_Right", "Move_Forward", "Move_Back")
	velocity = direction * speed
	super(delta)
	
8
