extends Area2D

signal Hit_outer_signal
signal Hit_inner_signal
signal Hit_bullseye_signal
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	monitoring = true


func _on_area_entered(area: Area2D) -> void:
	emit_signal("Hit_outer_signal")

func _on_inner_top_area_entered(area: Area2D) -> void:
	emit_signal("Hit_inner_signal")

func _on_bullseye_area_entered(area: Area2D) -> void:
	emit_signal("Hit_bullseye_signal")

func _on_inner_bottom_area_entered(area: Area2D) -> void:
	emit_signal("Hit_inner_signal")

func _on_outerbottom_area_entered(area: Area2D) -> void:
		emit_signal("Hit_outer_signal")
