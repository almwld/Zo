## main_menu.gd
## الشاشة الرئيسية - Main Menu Screen

extends Node3D

# ============================
# NODE REFERENCES / مراجع العقد
# ============================
@onready var start_button: Button = $UI/MenuPanel/VBox/StartButton
@onready var char_select_button: Button = $UI/MenuPanel/VBox/CharSelectButton
@onready var high_scores_button: Button = $UI/MenuPanel/VBox/HighScoresButton
@onready var settings_button: Button = $UI/MenuPanel/VBox/SettingsButton
@onready var exit_button: Button = $UI/MenuPanel/VBox/ExitButton
@onready var title_label: Label = $UI/TitleLabel
@onready var rotating_maze: Node3D = $RotatingMaze
@onready var background_music: AudioStreamPlayer = $BackgroundMusic
@onready var version_label: Label = $UI/VersionLabel

# ============================
# ANIMATION / الأنيماشن
# ============================
var rotation_speed: float = 0.3
var title_animation_time: float = 0.0

# ============================
# INITIALIZATION / التهيئة
# ============================
func _ready() -> void:
	_connect_buttons()
	_setup_background()
	_animate_title_entrance()
	
	if background_music:
		background_music.play()
	
	if version_label:
		version_label.text = "v1.0.0 | Garden Maze Escape: Infinite Odyssey"
	
	print("[MainMenu] Ready / الشاشة الرئيسية جاهزة")

func _connect_buttons() -> void:
	if start_button:
		start_button.pressed.connect(_on_start_pressed)
	if char_select_button:
		char_select_button.pressed.connect(_on_char_select_pressed)
	if high_scores_button:
		high_scores_button.pressed.connect(_on_high_scores_pressed)
	if settings_button:
		settings_button.pressed.connect(_on_settings_pressed)
	if exit_button:
		exit_button.pressed.connect(_on_exit_pressed)
	
	# تأثير التحويم على الأزرار
	for btn in [start_button, char_select_button, high_scores_button, settings_button, exit_button]:
		if btn:
			btn.mouse_entered.connect(func(): _on_button_hover(btn))
			btn.mouse_exited.connect(func(): _on_button_unhover(btn))

func _setup_background() -> void:
	## إنشاء متاهة خلفية تدور ببطء
	if rotating_maze:
		var mini_gen := MazeGenerator.new()
		add_child(mini_gen)
		var grid = mini_gen.generate(15, 15, DifficultyCurve.MazeAlgorithm.RECURSIVE_BACKTRACKER, 42)
		_build_mini_maze(grid)
	
	# كاميرا الخلفية
	var cam := Camera3D.new()
	cam.position = Vector3(30, 40, 30)
	cam.look_at(Vector3(30, 0, 30))
	cam.fov = 60.0
	add_child(cam)
	cam.make_current()

func _build_mini_maze(grid: Array) -> void:
	## بناء متاهة مصغرة للخلفية
	var wall_material := StandardMaterial3D.new()
	wall_material.albedo_color = Color(0.3, 0.7, 0.3)
	wall_material.roughness = 0.7
	
	for x in range(15):
		for y in range(15):
			var cell = grid[x][y]
			var pos_3d = Vector3(x * 4, 0, y * 4)
			
			if cell & MazeGenerator.WALL_EAST:
				var wall := MeshInstance3D.new()
				var box := BoxMesh.new()
				box.size = Vector3(0.4, 2.0, 4.0)
				wall.mesh = box
				wall.material_override = wall_material
				wall.position = pos_3d + Vector3(2, 1, 0)
				rotating_maze.add_child(wall)

func _animate_title_entrance() -> void:
	if not title_label:
		return
	
	title_label.modulate.a = 0.0
	title_label.position.y -= 50
	
	var tween = get_tree().create_tween()
	tween.tween_property(title_label, "modulate:a", 1.0, 1.0)
	tween.parallel().tween_property(title_label, "position:y", title_label.position.y + 50, 0.8)

# ============================
# PROCESS / المعالجة
# ============================
func _process(delta: float) -> void:
	title_animation_time += delta
	
	# تدوير المتاهة الخلفية
	if rotating_maze:
		rotating_maze.rotation.y += rotation_speed * delta
	
	# تأثير عنوان نابض
	if title_label:
		var scale_val = 1.0 + sin(title_animation_time * 2.0) * 0.02
		title_label.scale = Vector2(scale_val, scale_val)

# ============================
# BUTTON HANDLERS / معالجات الأزرار
# ============================
func _on_start_pressed() -> void:
	_button_press_effect(start_button)
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		var save = get_node_or_null("/root/SaveSystem")
		var last_level = 1
		if save:
			last_level = save.global_stats.get("highest_level_reached", 1)
		gm.start_level(last_level)
	else:
		get_tree().change_scene_to_file("res://scenes/gameplay.tscn")

func _on_char_select_pressed() -> void:
	_button_press_effect(char_select_button)
	get_tree().change_scene_to_file("res://scenes/character_select.tscn")

func _on_high_scores_pressed() -> void:
	_button_press_effect(high_scores_button)
	get_tree().change_scene_to_file("res://scenes/high_scores.tscn")

func _on_settings_pressed() -> void:
	_button_press_effect(settings_button)
	get_tree().change_scene_to_file("res://scenes/settings.tscn")

func _on_exit_pressed() -> void:
	_button_press_effect(exit_button)
	await get_tree().create_timer(0.3).timeout
	get_tree().quit()

func _on_button_hover(btn: Button) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(btn, "scale", Vector2(1.1, 1.1), 0.1)

func _on_button_unhover(btn: Button) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.1)

func _button_press_effect(btn: Button) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(btn, "scale", Vector2(0.95, 0.95), 0.08)
	tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.08)
