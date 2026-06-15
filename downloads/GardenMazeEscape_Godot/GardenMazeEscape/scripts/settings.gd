## settings.gd
## شاشة الإعدادات - Settings Screen

extends CanvasLayer

@onready var graphics_option: OptionButton = $Panel/VBox/GraphicsOption
@onready var music_slider: HSlider = $Panel/VBox/MusicSlider
@onready var sfx_slider: HSlider = $Panel/VBox/SFXSlider
@onready var vibration_check: CheckBox = $Panel/VBox/VibrationCheck
@onready var show_fps_check: CheckBox = $Panel/VBox/ShowFPSCheck
@onready var back_button: Button = $Panel/VBox/BackButton
@onready var reset_button: Button = $Panel/VBox/ResetButton
@onready var fps_label: Label = $FPSLabel

var save_system: Node
var game_manager: Node

func _ready() -> void:
	save_system = get_node_or_null("/root/SaveSystem")
	game_manager = get_node_or_null("/root/GameManager")
	
	_setup_options()
	_load_settings()
	_connect_signals()

func _setup_options() -> void:
	if graphics_option:
		graphics_option.add_item("منخفض - Low (50+ FPS)")
		graphics_option.add_item("متوسط - Medium (45+ FPS)")
		graphics_option.add_item("عالي - High (30+ FPS)")

func _load_settings() -> void:
	if not save_system:
		return
	
	var s = save_system.settings
	if graphics_option: graphics_option.selected = s.get("graphics_quality", 2)
	if music_slider: music_slider.value = s.get("music_volume", 0.8) * 100
	if sfx_slider: sfx_slider.value = s.get("sfx_volume", 1.0) * 100
	if vibration_check: vibration_check.button_pressed = s.get("vibration", true)
	if show_fps_check: show_fps_check.button_pressed = s.get("show_fps", false)

func _connect_signals() -> void:
	if graphics_option:
		graphics_option.item_selected.connect(func(idx):
			if save_system: save_system.set_setting("graphics_quality", idx)
			if game_manager: game_manager.apply_graphics_quality(idx)
		)
	if music_slider:
		music_slider.value_changed.connect(func(val):
			if save_system: save_system.set_setting("music_volume", val / 100.0)
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(val / 100.0))
		)
	if sfx_slider:
		sfx_slider.value_changed.connect(func(val):
			if save_system: save_system.set_setting("sfx_volume", val / 100.0)
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(val / 100.0))
		)
	if vibration_check:
		vibration_check.toggled.connect(func(on):
			if save_system: save_system.set_setting("vibration", on)
		)
	if show_fps_check:
		show_fps_check.toggled.connect(func(on):
			if save_system: save_system.set_setting("show_fps", on)
			if fps_label: fps_label.visible = on
		)
	if back_button:
		back_button.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/main_menu.tscn"))
	if reset_button:
		reset_button.pressed.connect(_on_reset_pressed)

func _process(_delta: float) -> void:
	if fps_label and fps_label.visible:
		fps_label.text = "FPS: %d" % Engine.get_frames_per_second()

func _on_reset_pressed() -> void:
	## تأكيد إعادة الضبط
	var dialog = AcceptDialog.new()
	dialog.title = "تحذير"
	dialog.dialog_text = "هل تريد حذف جميع بيانات اللعب؟\nلا يمكن التراجع عن هذا الإجراء!"
	dialog.confirmed.connect(func():
		if save_system: save_system.reset_all_data()
		_load_settings()
	)
	add_child(dialog)
	dialog.popup_centered()

# ============================================================
## gameplay_scene_controller.gd - ملحق: يُضاف لمشهد gameplay.tscn
## Gameplay Scene Controller - اللاصق الذي يربط كل الأنظمة
# ============================================================

## هذا الكود يوضع كسكريبت إضافي على Node3D الجذر في gameplay.tscn
## أو يُضاف لـ game_manager.gd كـ _process إضافي

## يمكن إنشاء ملف منفصل: scripts/gameplay_controller.gd

const GAMEPLAY_CODE = """
extends Node3D
## gameplay_controller.gd - المتحكم في مشهد اللعب

@onready var world_manager: Node = $WorldManager
@onready var player: CharacterBody3D = $Player
@onready var ui_manager: CanvasLayer = $UIManager
@onready var camera_controller: Node3D = $CameraController

var game_manager: Node
var enemies: Array = []
var gems: Array = []
var update_minimap_timer: float = 0.0
const MINIMAP_UPDATE_INTERVAL := 0.1

func _ready() -> void:
	game_manager = get_node_or_null(\"/root/GameManager\")
	
	if not game_manager:
		push_error(\"[Gameplay] GameManager not found!\")
		return
	
	# تسجيل الإشارات
	game_manager.current_player = player
	game_manager.world_manager_node = world_manager
	game_manager.ui_manager_node = ui_manager
	
	# إعداد المرحلة
	var level_id = game_manager.current_level
	world_manager.setup_level(level_id, self)
	world_manager.level_setup_complete.connect(_on_level_ready)
	
	# ربط الكاميرا باللاعب
	camera_controller.set_target(player)
	
	# ربط إشارة الجمبستيك
	if ui_manager:
		ui_manager.joystick_moved.connect(player.set_joystick_direction)
		ui_manager.ability_button_pressed.connect(player.activate_ability)

func _on_level_ready(config: DifficultyCurve.LevelConfig) -> void:
	# تحديث UI
	if ui_manager:
		ui_manager.world_config = config
	
	# وضع اللاعب في نقطة البداية
	var start = world_manager.get_start_position()
	player.global_position = start
	player.respawn_position = start
	
	# جمع مراجع الجواهر والأعداء
	_collect_scene_refs()
	
	# بدء اللعب بعد تأخير بسيط (تحميل)
	await get_tree().create_timer(0.5).timeout
	game_manager.begin_playing()

func _collect_scene_refs() -> void:
	enemies.clear()
	gems.clear()
	for child in get_children():
		if child.has_method(\"setup_patrol_points\"):
			enemies.append(child)
			child.player_caught.connect(game_manager.on_player_caught_by_enemy)
		if child.has_method(\"setup\") and child is Area3D:
			gems.append(child)

func _process(delta: float) -> void:
	# تحديث القدرة UI
	if ui_manager and player:
		ui_manager.update_ability_cooldown(player.get_ability_cooldown_percent())
	
	# تحديث الميني ماب
	update_minimap_timer -= delta
	if update_minimap_timer <= 0.0:
		update_minimap_timer = MINIMAP_UPDATE_INTERVAL
		_update_minimap()
	
	# تقارب الكاميرا من الجدران -> ضباب الشاشة
	_update_wall_vignette()

func _update_minimap() -> void:
	if not ui_manager or not player or not world_manager:
		return
	
	var config = world_manager.get_current_config()
	if not config:
		return
	
	var enemy_positions = enemies.filter(func(e): return is_instance_valid(e)).map(
		func(e): return e.global_position
	)
	
	var gem_positions = gems.filter(func(g): return is_instance_valid(g)).map(
		func(g): return g.global_position
	)
	
	ui_manager.update_minimap(
		player.global_position, 
		enemy_positions, 
		gem_positions,
		config.maze_width, 
		config.maze_height
	)

func _update_wall_vignette() -> void:
	if not player or not ui_manager:
		return
	# قياس قرب اللاعب من جدران (مبسط)
	var space = get_world_3d().direct_space_state
	var params = PhysicsRayQueryParameters3D.create(
		player.global_position, 
		player.global_position + Vector3(1.5, 0, 0)
	)
	var result = space.intersect_ray(params)
	ui_manager.update_fog_vignette(1.0 if result else 0.0)
"""
