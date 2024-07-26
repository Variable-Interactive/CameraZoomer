extends Node

var camera_preview: Node2D
var slider_new: ValueSlider
var slider_old: VSlider

# This script acts as a setup for the extension
func _enter_tree() -> void:
	camera_preview = ExtensionsApi.general.get_global().camera_preview
	var container: VBoxContainer = ExtensionsApi.general.get_global().canvas_preview_container.get_child(0)
	slider_new = ExtensionsApi.general.create_value_slider()
	slider_new.custom_minimum_size.y = 25
	slider_new.step = 0.01
	slider_new.allow_greater = true
	container.add_child(slider_new)
	slider_new.min_value = snappedf(100.0 * camera_preview.zoom_out_max.x, 0.01)
	slider_new.max_value = snappedf(100.0 * camera_preview.zoom_in_max.x, 0.01)
	slider_new.value = snappedf(100 * camera_preview.zoom.x, 0.01)
	slider_new.prefix = "zoom"
	slider_new.suffix = "%"
	slider_old = container.find_child("PreviewZoomSlider")
	if slider_old:
		slider_old.get_parent().visible = false
	slider_new.get_parent().move_child(slider_new, 0)
	slider_new.value_changed.connect(change_zoom)
	camera_preview.zoom_changed.connect(_zoom_changed)


func change_zoom(value: float) -> void:  # Extension is being uninstalled or disabled
	camera_preview.zoom_changed.disconnect(_zoom_changed)
	var zoom = snappedf(value /(100.0), 0.01)
	camera_preview.zoom = Vector2(zoom, zoom)
	camera_preview.zoom_changed.connect(_zoom_changed)


func _zoom_changed():
	slider_new.value_changed.disconnect(change_zoom)
	slider_new.value = snappedf(100 * camera_preview.zoom.x, 0.01)
	slider_new.value_changed.connect(change_zoom)


func _exit_tree() -> void:
	if slider_old:
		slider_old.get_parent().visible = true
	slider_new.queue_free()
