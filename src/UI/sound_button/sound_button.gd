extends TextureButton

const MASTER_BUS := "Master"


func _ready() -> void:
	button_pressed = AudioServer.is_bus_mute(AudioServer.get_bus_index(MASTER_BUS))


func _toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(AudioServer.get_bus_index(MASTER_BUS), toggled_on)
