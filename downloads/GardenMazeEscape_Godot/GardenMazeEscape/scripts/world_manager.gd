## world_manager.gd
## مدير العوالم - يُنشئ ويدير جميع المراحل الـ 1000
## World Manager - creates and manages all 1000 levels

extends Node

# ============================
# REFERENCES / المراجع
# ============================
@onready var maze_generator: MazeGenerator = $MazeGenerator
var current_config: DifficultyCurve.LevelConfig
var current_level_id: int = 1

# مراجع عناصر المشهد
var maze_root: Node3D
var walls_container: Node3D
var floor_container: Node3D
var gems_container: Node3D
var environment_node: WorldEnvironment
var directional_light: DirectionalLight3D
var sky_particles: GPUParticles3D

# الأصول (Prefabs/Scenes)
var wall_tree_scenes := {}  # مشاهد الأشجار لكل عالم
var gem_scene: PackedScene
var exit_gate_scene: PackedScene
var enemy_scene: PackedScene

# ============================
# SIGNALS / الإشارات
# ============================
signal level_setup_complete(config: DifficultyCurve.LevelConfig)
signal world_changed(world_id: int)

# ============================
# WORLD THEME DATA / بيانات ثيمات العوالم
# ============================
const WORLD_DATA := {
	1: {
		"name": "حديقة الربيع",
		"name_en": "Spring Garden",
		"wall_color": Color(0.6, 0.9, 0.5),
		"floor_color": Color(0.3, 0.7, 0.2),
		"sky_top_color": Color(0.4, 0.6, 1.0),
		"sky_horizon_color": Color(0.8, 0.9, 1.0),
		"fog_color": Color(0.9, 1.0, 0.9),
		"sun_color": Color(1.0, 0.95, 0.8),
		"sun_energy": 1.5,
		"bloom": 0.5,
		"particles": "spring_petals",
		"music": "bgm_spring"
	},
	2: {
		"name": "غابة الخريف",
		"name_en": "Autumn Forest",
		"wall_color": Color(0.8, 0.4, 0.1),
		"floor_color": Color(0.6, 0.3, 0.1),
		"sky_top_color": Color(0.5, 0.4, 0.3),
		"sky_horizon_color": Color(1.0, 0.6, 0.2),
		"fog_color": Color(0.8, 0.5, 0.2),
		"sun_color": Color(1.0, 0.7, 0.3),
		"sun_energy": 1.2,
		"bloom": 0.4,
		"particles": "autumn_leaves",
		"music": "bgm_autumn"
	},
	3: {
		"name": "مملكة الجليد",
		"name_en": "Ice Kingdom",
		"wall_color": Color(0.8, 0.9, 1.0),
		"floor_color": Color(0.9, 0.95, 1.0),
		"sky_top_color": Color(0.2, 0.3, 0.6),
		"sky_horizon_color": Color(0.7, 0.85, 1.0),
		"fog_color": Color(0.8, 0.9, 1.0),
		"sun_color": Color(0.8, 0.9, 1.0),
		"sun_energy": 0.8,
		"bloom": 0.8,
		"particles": "snow_flakes",
		"music": "bgm_ice"
	},
	4: {
		"name": "صحراء الرمال",
		"name_en": "Sand Desert",
		"wall_color": Color(0.9, 0.7, 0.2),
		"floor_color": Color(0.95, 0.8, 0.4),
		"sky_top_color": Color(0.3, 0.5, 1.0),
		"sky_horizon_color": Color(1.0, 0.85, 0.5),
		"fog_color": Color(1.0, 0.9, 0.6),
		"sun_color": Color(1.0, 0.9, 0.5),
		"sun_energy": 2.0,
		"bloom": 0.3,
		"particles": "sand_dust",
		"music": "bgm_desert"
	},
	5: {
		"name": "غابة الظلام",
		"name_en": "Dark Forest",
		"wall_color": Color(0.1, 0.05, 0.1),
		"floor_color": Color(0.15, 0.1, 0.1),
		"sky_top_color": Color(0.0, 0.0, 0.1),
		"sky_horizon_color": Color(0.1, 0.0, 0.2),
		"fog_color": Color(0.05, 0.0, 0.1),
		"sun_color": Color(0.3, 0.0, 0.5),
		"sun_energy": 0.2,
		"bloom": 1.5,
		"particles": "dark_spores",
		"music": "bgm_dark"
	},
	6: {
		"name": "أرض النار",
		"name_en": "Fire Land",
		"wall_color": Color(0.3, 0.05, 0.0),
		"floor_color": Color(0.8, 0.2, 0.0),
		"sky_top_color": Color(0.2, 0.0, 0.0),
		"sky_horizon_color": Color(1.0, 0.3, 0.0),
		"fog_color": Color(0.6, 0.1, 0.0),
		"sun_color": Color(1.0, 0.4, 0.0),
		"sun_energy": 3.0,
		"bloom": 1.0,
		"particles": "fire_embers",
		"music": "bgm_fire"
	},
	7: {
		"name": "أتلانتس الغارقة",
		"name_en": "Sunken Atlantis",
		"wall_color": Color(0.1, 0.5, 0.4),
		"floor_color": Color(0.2, 0.4, 0.5),
		"sky_top_color": Color(0.0, 0.2, 0.5),
		"sky_horizon_color": Color(0.0, 0.5, 0.6),
		"fog_color": Color(0.0, 0.4, 0.5),
		"sun_color": Color(0.3, 0.8, 0.9),
		"sun_energy": 0.6,
		"bloom": 0.6,
		"particles": "bubbles",
		"music": "bgm_ocean"
	},
	8: {
		"name": "عالم الأحلام",
		"name_en": "Dream World",
		"wall_color": Color(0.5, 0.2, 0.8),
		"floor_color": Color(0.3, 0.1, 0.6),
		"sky_top_color": Color(0.1, 0.0, 0.3),
		"sky_horizon_color": Color(0.5, 0.0, 0.8),
		"fog_color": Color(0.3, 0.0, 0.5),
		"sun_color": Color(0.8, 0.3, 1.0),
		"sun_energy": 1.0,
		"bloom": 2.0,
		"particles": "dream_stars",
		"music": "bgm_dream"
	},
	9: {
		"name": "عالم الفوضى",
		"name_en": "Chaos World",
		"wall_color": Color(randf(), randf(), randf()),
		"floor_color": Color(randf(), randf(), randf()),
		"sky_top_color": Color(randf_range(0.0, 0.5), randf_range(0.0, 0.5), randf_range(0.0, 0.5)),
		"sky_horizon_color": Color(randf(), randf(), randf()),
		"fog_color": Color(randf(), randf(), randf()),
		"sun_color": Color(1.0, 1.0, 1.0),
		"sun_energy": randf_range(0.5, 3.0),
		"bloom": randf_range(0.3, 2.0),
		"particles": "chaos_mix",
		"music": "bgm_chaos"
	},
	10: {
		"name": "عالم الفراغ",
		"name_en": "The Void",
		"wall_color": Color(0.0, 0.0, 0.0),
		"floor_color": Color(0.05, 0.0, 0.1),
		"sky_top_color": Color(0.0, 0.0, 0.0),
		"sky_horizon_color": Color(0.1, 0.0, 0.2),
		"fog_color": Color(0.0, 0.0, 0.05),
		"sun_color": Color(0.5, 0.0, 1.0),
		"sun_energy": 0.3,
		"bloom": 3.0,
		"particles": "void_particles",
		"music": "bgm_void"
	}
}

# ============================
# INITIALIZATION / التهيئة
# ============================
func _ready() -> void:
	_load_asset_references()

func _load_asset_references() -> void:
	gem_scene = load("res://scenes/gem.tscn") if ResourceLoader.exists("res://scenes/gem.tscn") else null
	exit_gate_scene = load("res://scenes/exit_gate.tscn") if ResourceLoader.exists("res://scenes/exit_gate.tscn") else null
	enemy_scene = load("res://scenes/enemy.tscn") if ResourceLoader.exists("res://scenes/enemy.tscn") else null

# ============================
# MAIN SETUP FUNCTION / الدالة الرئيسية للإعداد
# ============================
func setup_level(level_id: int, scene_root: Node3D) -> void:
	## الدالة الرئيسية: إعداد مرحلة كاملة
	current_level_id = level_id
	current_config = DifficultyCurve.get_level_config(level_id)
	
	print("[WorldManager] Setting up level %d (World %d)" % [level_id, current_config.world_id])
	
	# تنظيف المشهد السابق
	_clear_level(scene_root)
	
	# إنشاء الحاويات
	maze_root = Node3D.new()
	maze_root.name = "MazeRoot"
	scene_root.add_child(maze_root)
	
	walls_container = Node3D.new()
	walls_container.name = "Walls"
	maze_root.add_child(walls_container)
	
	floor_container = Node3D.new()
	floor_container.name = "Floor"
	maze_root.add_child(floor_container)
	
	gems_container = Node3D.new()
	gems_container.name = "Gems"
	maze_root.add_child(gems_container)
	
	# توليد المتاهة
	var seed_val = level_id * 12345  # نفس المتاهة دائماً لنفس المرحلة
	var grid = maze_generator.generate(
		current_config.maze_width,
		current_config.maze_height,
		current_config.maze_algorithm,
		seed_val
	)
	
	# بناء المتاهة ثلاثية الأبعاد
	_build_maze_geometry(grid)
	_place_floor(grid)
	_place_gems(grid)
	_place_exit_gate(grid)
	_place_enemy(grid)
	
	# تطبيق ثيم العالم
	_apply_world_theme(scene_root)
	
	emit_signal("level_setup_complete", current_config)
	print("[WorldManager] Level %d ready!" % level_id)

func _clear_level(root: Node3D) -> void:
	for child in root.get_children():
		if child.name in ["MazeRoot", "WorldEnvironment_Dynamic", "Sun"]:
			child.queue_free()

# ============================
# MAZE GEOMETRY BUILDER / بناء هندسة المتاهة
# ============================
func _build_maze_geometry(grid: Array) -> void:
	## بناء جدران المتاهة بالأشجار/الأعمدة
	const CELL_SIZE := 4.0
	const WALL_HEIGHT := 4.0
	
	var world_theme = WORLD_DATA[current_config.world_id]
	
	for x in range(current_config.maze_width):
		for y in range(current_config.maze_height):
			var cell = grid[x][y]
			var world_pos = Vector3(x * CELL_SIZE, 0, y * CELL_SIZE)
			
			# جدار شمالي
			if cell & MazeGenerator.WALL_NORTH and y == 0:
				_place_wall(world_pos + Vector3(0, 0, -CELL_SIZE * 0.5), 
							Vector3(CELL_SIZE, WALL_HEIGHT, 0.8), world_theme)
			
			# جدار شرقي
			if cell & MazeGenerator.WALL_EAST:
				_place_wall(world_pos + Vector3(CELL_SIZE * 0.5, 0, 0),
							Vector3(0.8, WALL_HEIGHT, CELL_SIZE), world_theme)
			
			# جدار جنوبي
			if cell & MazeGenerator.WALL_SOUTH:
				_place_wall(world_pos + Vector3(0, 0, CELL_SIZE * 0.5),
							Vector3(CELL_SIZE, WALL_HEIGHT, 0.8), world_theme)
			
			# جدار غربي
			if cell & MazeGenerator.WALL_WEST and x == 0:
				_place_wall(world_pos + Vector3(-CELL_SIZE * 0.5, 0, 0),
							Vector3(0.8, WALL_HEIGHT, CELL_SIZE), world_theme)

func _place_wall(position: Vector3, size: Vector3, theme: Dictionary) -> void:
	## وضع جدار (شجرة أو عمود حسب الثيم)
	var static_body := StaticBody3D.new()
	static_body.collision_layer = 1
	
	var mesh_inst := MeshInstance3D.new()
	var mesh: Mesh
	
	# اختيار شكل الجدار حسب العالم
	match current_config.world_id:
		1, 2:  # أشجار
			mesh = _create_tree_mesh(size, theme)
		3:  # أعمدة جليدية
			mesh = _create_ice_pillar_mesh(size, theme)
		4:  # صخور رمالية
			mesh = _create_sandstone_mesh(size, theme)
		5:  # أشجار ميتة
			mesh = _create_dead_tree_mesh(size, theme)
		6:  # صخور حمم
			mesh = _create_lava_rock_mesh(size, theme)
		7:  # أعمدة مرجانية
			mesh = _create_coral_mesh(size, theme)
		8:  # أشجار ضوئية
			mesh = _create_light_tree_mesh(size, theme)
		9, 10:  # أشكال مختلطة
			mesh = _create_void_wall_mesh(size, theme)
		_:
			mesh = BoxMesh.new()
			(mesh as BoxMesh).size = size
	
	mesh_inst.mesh = mesh
	
	# مادة PBR
	var mat := StandardMaterial3D.new()
	mat.albedo_color = theme["wall_color"]
	mat.roughness = 0.7 + randf_range(-0.1, 0.1)
	mat.metallic = 0.1
	
	# إضافة Normal Map وهمية (ستُستبدل بنسيج حقيقي)
	mat.normal_enabled = true
	mat.normal_scale = 1.5
	
	# إضافة Ambient Occlusion
	mat.ao_enabled = true
	
	mesh_inst.material_override = mat
	
	# Collision Shape
	var col_shape := CollisionShape3D.new()
	var box_shape := BoxShape3D.new()
	box_shape.size = size
	col_shape.shape = box_shape
	
	static_body.add_child(mesh_inst)
	static_body.add_child(col_shape)
	static_body.position = position
	
	# إضافة حركة أوراق (للأشجار فقط)
	if current_config.world_id in [1, 2]:
		_add_leaf_animation(mesh_inst)
	
	walls_container.add_child(static_body)

func _create_tree_mesh(size: Vector3, theme: Dictionary) -> Mesh:
	## إنشاء شبكة شجرة مبسطة (Capsule)
	var mesh := CapsuleMesh.new()
	mesh.radius = size.x * 0.3
	mesh.height = size.y
	return mesh

func _create_ice_pillar_mesh(size: Vector3, theme: Dictionary) -> Mesh:
	var mesh := CylinderMesh.new()
	mesh.top_radius = size.x * 0.2
	mesh.bottom_radius = size.x * 0.35
	mesh.height = size.y
	return mesh

func _create_sandstone_mesh(size: Vector3, theme: Dictionary) -> Mesh:
	var mesh := BoxMesh.new()
	mesh.size = size
	return mesh

func _create_dead_tree_mesh(size: Vector3, theme: Dictionary) -> Mesh:
	var mesh := CylinderMesh.new()
	mesh.top_radius = size.x * 0.1
	mesh.bottom_radius = size.x * 0.25
	mesh.height = size.y
	return mesh

func _create_lava_rock_mesh(size: Vector3, theme: Dictionary) -> Mesh:
	var mesh := SphereMesh.new()
	mesh.radius = size.x * 0.4
	mesh.height = size.y * 0.9
	return mesh

func _create_coral_mesh(size: Vector3, theme: Dictionary) -> Mesh:
	var mesh := CapsuleMesh.new()
	mesh.radius = size.x * 0.25
	mesh.height = size.y
	return mesh

func _create_light_tree_mesh(size: Vector3, theme: Dictionary) -> Mesh:
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.0
	mesh.bottom_radius = size.x * 0.3
	mesh.height = size.y
	return mesh

func _create_void_wall_mesh(size: Vector3, theme: Dictionary) -> Mesh:
	var mesh := BoxMesh.new()
	mesh.size = size
	return mesh

func _add_leaf_animation(mesh: MeshInstance3D) -> void:
	## إضافة حركة أوراق بسيطة باستخدام Animation
	pass  # سيُنفَّذ عبر Shader في الملف الحقيقي

# ============================
# FLOOR PLACEMENT / وضع الأرضية
# ============================
func _place_floor(grid: Array) -> void:
	const CELL_SIZE := 4.0
	var world_theme = WORLD_DATA[current_config.world_id]
	
	# أرضية واحدة كبيرة بدلاً من خلية لكل خلية (أفضل للأداء)
	var floor_mesh_inst := MeshInstance3D.new()
	var plane_mesh := PlaneMesh.new()
	plane_mesh.size = Vector2(
		current_config.maze_width * CELL_SIZE,
		current_config.maze_height * CELL_SIZE
	)
	plane_mesh.subdivide_width = 20
	plane_mesh.subdivide_depth = 20
	
	floor_mesh_inst.mesh = plane_mesh
	
	var floor_mat := StandardMaterial3D.new()
	floor_mat.albedo_color = world_theme["floor_color"]
	floor_mat.roughness = 0.85
	floor_mat.metallic = 0.0
	floor_mat.ao_enabled = true
	
	# انعكاس الرطوبة للعالم 3 (الجليد)
	if current_config.world_id == 3:
		floor_mat.roughness = 0.1
		floor_mat.metallic = 0.5
	
	floor_mesh_inst.material_override = floor_mat
	floor_mesh_inst.position = Vector3(
		(current_config.maze_width * CELL_SIZE) / 2.0,
		0.0,
		(current_config.maze_height * CELL_SIZE) / 2.0
	)
	
	var floor_body := StaticBody3D.new()
	var floor_col := CollisionShape3D.new()
	var floor_shape := BoxShape3D.new()
	floor_shape.size = Vector3(
		current_config.maze_width * CELL_SIZE,
		0.1,
		current_config.maze_height * CELL_SIZE
	)
	floor_col.shape = floor_shape
	
	floor_body.add_child(floor_mesh_inst)
	floor_body.add_child(floor_col)
	floor_body.collision_layer = 1
	
	floor_container.add_child(floor_body)

# ============================
# GEM PLACEMENT / وضع الجواهر
# ============================
func _place_gems(grid: Array) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = current_level_id * 54321
	const CELL_SIZE := 4.0
	
	var placed := 0
	var attempts := 0
	
	while placed < current_config.gem_count and attempts < 1000:
		attempts += 1
		var gx = rng.randi() % current_config.maze_width
		var gy = rng.randi() % current_config.maze_height
		
		# لا توضع في الزاوية الأولى (مكان اللاعب)
		if gx == 0 and gy == 0:
			continue
		
		var gem_pos = Vector3(gx * CELL_SIZE + CELL_SIZE / 2, 0.8, gy * CELL_SIZE + CELL_SIZE / 2)
		
		if gem_scene:
			var gem = gem_scene.instantiate()
			gem.position = gem_pos
			if gem.has_method("setup"):
				gem.setup(current_config.gem_color, current_config.world_id)
			gems_container.add_child(gem)
		else:
			# جوهرة مؤقتة بدون مشهد
			_create_temp_gem(gem_pos)
		
		placed += 1

func _create_temp_gem(pos: Vector3) -> void:
	## جوهرة مؤقتة (Placeholder)
	var area := Area3D.new()
	var mesh := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.25
	sphere.height = 0.5
	mesh.mesh = sphere
	
	var mat := StandardMaterial3D.new()
	mat.albedo_color = current_config.gem_color
	mat.emission_enabled = true
	mat.emission = current_config.gem_color
	mat.emission_energy_multiplier = 2.0
	mat.metallic = 0.9
	mat.roughness = 0.0
	mesh.material_override = mat
	
	var col := CollisionShape3D.new()
	var sphere_shape := SphereShape3D.new()
	sphere_shape.radius = 0.3
	col.shape = sphere_shape
	
	area.add_child(mesh)
	area.add_child(col)
	area.collision_layer = 4
	area.position = pos
	
	# تدوير الجوهرة
	var tween = get_tree().create_tween()
	tween.set_loops()
	tween.tween_property(area, "rotation:y", TAU, 2.0)
	
	gems_container.add_child(area)

# ============================
# EXIT GATE / بوابة الخروج
# ============================
func _place_exit_gate(grid: Array) -> void:
	## وضع بوابة الخروج في الركن المقابل للبداية
	const CELL_SIZE := 4.0
	var exit_x = current_config.maze_width - 1
	var exit_y = current_config.maze_height - 1
	
	var exit_pos = Vector3(exit_x * CELL_SIZE, 0, exit_y * CELL_SIZE)
	
	if exit_gate_scene:
		var gate = exit_gate_scene.instantiate()
		gate.position = exit_pos
		maze_root.add_child(gate)
	else:
		_create_temp_exit(exit_pos)

func _create_temp_exit(pos: Vector3) -> void:
	## بوابة مؤقتة
	var area := Area3D.new()
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(1.5, 3.0, 0.3)
	mesh.mesh = box
	
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.8, 0.0)
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.8, 0.0)
	mat.emission_energy_multiplier = 3.0
	mesh.material_override = mat
	
	var col := CollisionShape3D.new()
	var box_shape := BoxShape3D.new()
	box_shape.size = Vector3(1.5, 3.0, 0.3)
	col.shape = box_shape
	
	area.add_child(mesh)
	area.add_child(col)
	area.collision_layer = 8
	area.position = pos + Vector3(0, 1.5, 0)
	
	# ضوء البوابة
	var light := OmniLight3D.new()
	light.light_color = Color(1.0, 0.8, 0.0)
	light.light_energy = 3.0
	light.omni_range = 4.0
	area.add_child(light)
	
	maze_root.add_child(area)

# ============================
# ENEMY PLACEMENT / وضع العدو
# ============================
func _place_enemy(grid: Array) -> void:
	const CELL_SIZE := 4.0
	
	# موقع عشوائي في وسط المتاهة
	var ex = current_config.maze_width / 2 + randi_range(-3, 3)
	var ey = current_config.maze_height / 2 + randi_range(-3, 3)
	var enemy_pos = Vector3(ex * CELL_SIZE, 0, ey * CELL_SIZE)
	
	if enemy_scene:
		var enemy = enemy_scene.instantiate()
		enemy.position = enemy_pos
		if enemy.has_method("set_speed_multiplier"):
			enemy.set_speed_multiplier(current_config.enemy_speed_mult)
		_setup_enemy_patrol_points(enemy, grid)
		maze_root.add_child(enemy)
	
	# أعداء إضافية في المراحل المتأخرة
	for i in range(current_config.extra_enemies):
		var add_x = randi_range(5, current_config.maze_width - 5)
		var add_y = randi_range(5, current_config.maze_height - 5)
		var add_pos = Vector3(add_x * CELL_SIZE, 0, add_y * CELL_SIZE)
		
		if enemy_scene:
			var extra_enemy = enemy_scene.instantiate()
			extra_enemy.position = add_pos
			if extra_enemy.has_method("set_speed_multiplier"):
				extra_enemy.set_speed_multiplier(current_config.enemy_speed_mult * 0.8)
			_setup_enemy_patrol_points(extra_enemy, grid)
			maze_root.add_child(extra_enemy)

func _setup_enemy_patrol_points(enemy: Node, grid: Array) -> void:
	## تعيين 8 نقاط دوريات عشوائية للعدو
	const CELL_SIZE := 4.0
	var points: Array[Vector3] = []
	
	for i in range(8):
		var px = randi() % current_config.maze_width
		var py = randi() % current_config.maze_height
		points.append(Vector3(px * CELL_SIZE, 0, py * CELL_SIZE))
	
	if enemy.has_method("setup_patrol_points"):
		enemy.setup_patrol_points(points)

# ============================
# WORLD THEME APPLICATION / تطبيق ثيم العالم
# ============================
func _apply_world_theme(scene_root: Node3D) -> void:
	var theme = WORLD_DATA[current_config.world_id]
	
	_setup_environment(scene_root, theme)
	_setup_directional_light(scene_root, theme)
	_setup_particles(scene_root, theme)

func _setup_environment(root: Node3D, theme: Dictionary) -> void:
	## إعداد WorldEnvironment
	var we := WorldEnvironment.new()
	we.name = "WorldEnvironment_Dynamic"
	
	var env := Environment.new()
	
	# السماء
	var sky := Sky.new()
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = theme["sky_top_color"]
	sky_mat.sky_horizon_color = theme["sky_horizon_color"]
	sky_mat.sky_energy_multiplier = theme["sun_energy"]
	sky.sky_material = sky_mat
	env.sky = sky
	env.background_mode = Environment.BG_SKY
	
	# Ambient Light
	env.ambient_light_color = theme.get("fog_color", Color.WHITE)
	env.ambient_light_energy = 0.3
	
	# Fog
	env.fog_enabled = true
	env.fog_light_color = theme["fog_color"]
	env.fog_density = current_config.fog_density
	env.fog_aerial_perspective = 0.5
	env.volumetric_fog_enabled = true
	env.volumetric_fog_density = current_config.fog_density * 0.1
	
	# SDFGI (Indirect Lighting) - قد يُعطَّل في الأجهزة الضعيفة
	env.sdfgi_enabled = true
	env.sdfgi_use_occlusion = true
	
	# Glow / Bloom
	env.glow_enabled = true
	env.glow_intensity = theme["bloom"]
	env.glow_bloom = theme["bloom"] * 0.3
	env.glow_hdr_threshold = 1.0
	
	# Tone Mapping
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.tonemap_exposure = 1.0
	env.tonemap_white = 6.0
	
	# SSAO
	env.ssao_enabled = true
	env.ssao_radius = 1.0
	env.ssao_intensity = 2.0
	
	# SSR (Screen Space Reflections) للعالمين 3 و7
	if current_config.world_id in [3, 7]:
		env.ssr_enabled = true
		env.ssr_max_steps = 64
		env.ssr_fade_in = 0.15
		env.ssr_fade_out = 2.0
		env.ssr_depth_tolerance = 0.2
	
	we.environment = env
	root.add_child(we)

func _setup_directional_light(root: Node3D, theme: Dictionary) -> void:
	## إعداد الضوء الشمسي
	var sun := DirectionalLight3D.new()
	sun.name = "Sun"
	sun.light_color = theme["sun_color"]
	sun.light_energy = theme["sun_energy"]
	sun.shadow_enabled = true
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS
	sun.directional_shadow_max_distance = 100.0
	sun.shadow_blur = 1.0
	
	# زاوية الشمس حسب العالم
	var sun_angle := -45.0
	if current_config.world_id == 5:  # غابة الظلام
		sun_angle = -10.0
	elif current_config.world_id == 6:  # أرض النار
		sun_angle = -60.0
	
	sun.rotation_degrees = Vector3(sun_angle, 45, 0)
	
	# Volumetric Light
	sun.light_volumetric_fog_energy = 0.3
	
	root.add_child(sun)

func _setup_particles(root: Node3D, theme: Dictionary) -> void:
	## إعداد جزيئات البيئة
	var particles := GPUParticles3D.new()
	particles.name = "EnvironmentParticles"
	particles.amount = _get_particle_count(theme["particles"])
	
	var pm := ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pm.emission_box_extents = Vector3(
		current_config.maze_width * 2.0,
		5.0,
		current_config.maze_height * 2.0
	)
	pm.gravity = _get_particle_gravity(theme["particles"])
	pm.initial_velocity_min = 0.2
	pm.initial_velocity_max = 0.8
	pm.scale_min = 0.05
	pm.scale_max = 0.2
	pm.color = _get_particle_color(theme["particles"])
	
	particles.process_material = pm
	particles.draw_pass_1 = SphereMesh.new()
	
	# موضع المركز
	particles.position = Vector3(
		current_config.maze_width * 2.0,
		3.0,
		current_config.maze_height * 2.0
	)
	
	root.add_child(particles)

func _get_particle_count(particle_type: String) -> int:
	match particle_type:
		"spring_petals": return 200
		"autumn_leaves": return 150
		"snow_flakes": return 300
		"sand_dust": return 100
		"dark_spores": return 80
		"fire_embers": return 120
		"bubbles": return 200
		"dream_stars": return 500
		"void_particles": return 300
		_: return 100

func _get_particle_gravity(particle_type: String) -> Vector3:
	match particle_type:
		"snow_flakes": return Vector3(0.3, -1.0, 0.1)
		"fire_embers": return Vector3(0.2, 0.5, 0.1)  # يرتفع
		"bubbles": return Vector3(0.0, 1.0, 0.0)  # يرتفع
		"dream_stars": return Vector3(0.0, 0.0, 0.0)  # طافي
		_: return Vector3(0.1, -0.3, 0.2)

func _get_particle_color(particle_type: String) -> Color:
	match particle_type:
		"spring_petals": return Color(1.0, 0.7, 0.8, 0.8)
		"autumn_leaves": return Color(1.0, 0.4, 0.1, 0.9)
		"snow_flakes": return Color(1.0, 1.0, 1.0, 0.7)
		"sand_dust": return Color(1.0, 0.8, 0.4, 0.3)
		"dark_spores": return Color(0.3, 0.0, 0.5, 0.5)
		"fire_embers": return Color(1.0, 0.5, 0.0, 0.8)
		"bubbles": return Color(0.5, 0.9, 1.0, 0.4)
		"dream_stars": return Color(0.8, 0.5, 1.0, 0.6)
		"void_particles": return Color(0.5, 0.0, 1.0, 0.5)
		_: return Color(1.0, 1.0, 1.0, 0.5)

# ============================
# GETTERS / الحاصلات
# ============================
func get_start_position() -> Vector3:
	return Vector3(2.0, 0.5, 2.0)  # خلية (0,0) مع ارتفاع

func get_current_config() -> DifficultyCurve.LevelConfig:
	return current_config
