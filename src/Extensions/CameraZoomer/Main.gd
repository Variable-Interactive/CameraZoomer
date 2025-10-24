extends Node

var preview_camera: Node2D
var slider_new: TextureProgressBar
var slider_old: VSlider
var api: Node

# This script acts as a setup for the extension
func _enter_tree() -> void:
	api = get_node_or_null("/root/ExtensionsApi")
	if api:
		for camera in get_tree().get_nodes_in_group("CanvasCameras"):
			if camera.name == "CameraPreview":
				preview_camera = camera
				if preview_camera.owner.name == "Canvas Preview":
					var container: VBoxContainer = preview_camera.owner.get_child(0)
					slider_new = api.general.create_value_slider()
					slider_new.custom_minimum_size.y = 25
					slider_new.step = 0.01
					slider_new.allow_greater = true
					container.add_child(slider_new)
					slider_new.min_value = snappedf(100.0 * preview_camera.zoom_out_max.x, 0.01)
					slider_new.max_value = snappedf(100.0 * preview_camera.zoom_in_max.x, 0.01)
					slider_new.value = snappedf(100 * preview_camera.zoom.x, 0.01)
					slider_new.prefix = "zoom"
					slider_new.suffix = "%"
					slider_old = container.find_child("PreviewZoomSlider")
					if slider_old:
						slider_old.get_parent().visible = false
					slider_new.get_parent().move_child(slider_new, 0)
					slider_new.value_changed.connect(change_zoom)
					preview_camera.zoom_changed.connect(_zoom_changed)


func change_zoom(value: float) -> void:  # Extension is being uninstalled or disabled
	preview_camera.zoom_changed.disconnect(_zoom_changed)
	var zoom = snappedf(value /(100.0), 0.01)
	preview_camera.zoom = Vector2(zoom, zoom)
	preview_camera.zoom_changed.connect(_zoom_changed)


func _zoom_changed():
	slider_new.value_changed.disconnect(change_zoom)
	slider_new.value = snappedf(100 * preview_camera.zoom.x, 0.01)
	slider_new.value_changed.connect(change_zoom)


func _exit_tree() -> void:
	if slider_new:
		if slider_old:
			slider_old.get_parent().visible = true
		slider_new.queue_free()
