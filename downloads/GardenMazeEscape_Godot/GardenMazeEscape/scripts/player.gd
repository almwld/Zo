## player.gd
## متحكم اللاعب - يدير حركة الشخصيات الأربع وقدراتهم الخاصة
## Player Controller - manages all 4 characters and their special abilities

extends CharacterBody3D

# ============================
# ENUMS / التعدادات
# ============================
enum CharacterType { KNIGHT, WIZARD, PRINCESS, THIEF }
enum PlayerState { IDLE, WALKING, RUNNING, ABILITY_ACTIVE, STUNNED, DEAD }

# ============================
# EXPORTS / المتغيرات القابلة للتعديل في المحرر
# ============================
@export var character_type: CharacterType = CharacterType.KNIGHT
@export var base_speed: float = 5.0
@export var run_speed_multiplier: float = 1.5
@export var gravity: float = 20.0
@export var rotation_speed: float = 10.0

# ============================
# NODE REFERENCES / مراجع العقد
# ============================
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var ability_particles: GPUParticles3D = $AbilityParticles
@onready var footstep_audio: AudioStreamPlayer3D = $FootstepAudio
@onready var ability_audio: AudioStreamPlayer3D = $AbilityAudio
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var grass_interactor: Area3D = $GrassInteractor

# كاميرا المراقبة (SpringArm)
var camera_pivot: Node3D
var spring_arm: SpringArm3D
var camera_3d: Camera3D

# ============================
# GAMEPLAY VARIABLES / متغيرات اللعب
# ============================
var current_state: PlayerState = PlayerState.IDLE
var current_speed: float = 0.0
var ability_cooldown_remaining: float = 0.0
var ability_active: bool = false
var ability_duration_remaining: float = 0.0
var is_stunned: bool = false
var stun_timer: float = 0.0

# إحداثيات الشبكة للاعب
var grid_position: Vector2i = Vector2i.ZERO
var respawn_position: Vector3 = Vector3.ZERO

# حركة الجمبستيك الافتراضي
var joystick_direction: Vector2 = Vector2.ZERO

# إشارة الاصطدام
signal hit_by_enemy(player: CharacterBody3D)
signal gem_collected(points: int)
signal ability_used(char_type: int)
signal player_died

# ============================
# CHARACTER STATS / إحصائيات الشخصيات
# ============================
const CHARACTER_STATS := {
	CharacterType.KNIGHT: {
		"name": "الفارس الأخضر Sir Cedric",
		"speed": 5.5,
		"ability_name": "اندفاع السرعة",
		"ability_duration": 3.0,
		"ability_cooldown": 10.0,
		"color": Color(0.2, 0.6, 0.2),
		"ability_color": Color(0.0, 1.0, 0.0)
	},
	CharacterType.WIZARD: {
		"name": "الساحر الأزرق Archmage Zephyros",
		"speed": 4.5,
		"ability_name": "اختراق الجدار",
		"ability_duration": 8.0,
		"ability_cooldown": 15.0,
		"color": Color(0.1, 0.2, 0.8),
		"ability_color": Color(0.0, 0.5, 1.0)
	},
	CharacterType.PRINCESS: {
		"name": "الأميرة الذهبية Princess Elara",
		"speed": 5.0,
		"ability_name": "إبطاء الزمن",
		"ability_duration": 4.0,
		"ability_cooldown": 12.0,
		"color": Color(1.0, 0.85, 0.3),
		"ability_color": Color(1.0, 1.0, 0.0)
	},
	CharacterType.THIEF: {
		"name": "اللص الأسود Shadow Veil",
		"speed": 6.0,
		"ability_name": "رؤية المسار",
		"ability_duration": 5.0,
		"ability_cooldown": 8.0,
		"color": Color(0.1, 0.1, 0.1),
		"ability_color": Color(1.0, 0.8, 0.0)
	}
}

# ============================
# INITIALIZATION / التهيئة
# ============================
func _ready() -> void:
	_setup_character()
	_setup_camera()
	_setup_animation_tree()
	
	# تعيين موقع الولادة الأولي
	respawn_position = global_position

func _setup_character() -> void:
	var stats = CHARACTER_STATS[character_type]
	base_speed = stats["speed"]
	
	# تطبيق لون الشخصية على المادة
	if mesh_instance and mesh_instance.mesh:
		var mat = StandardMaterial3D.new()
		mat.albedo_color = stats["color"]
		mat.metallic = 0.5
		mat.roughness = 0.3
		# تأثير Subsurface Scattering للأميرة
		if character_type == CharacterType.PRINCESS:
			mat.subsurf_scatter_enabled = true
			mat.subsurf_scatter_strength = 0.3
		mesh_instance.material_override = mat
	
	print("[Player] Character initialized: " + stats["name"])

func _setup_camera() -> void:
	## إعداد كاميرا Third-Person مع SpringArm
	camera_pivot = Node3D.new()
	camera_pivot.name = "CameraPivot"
	add_child(camera_pivot)
	
	spring_arm = SpringArm3D.new()
	spring_arm.name = "SpringArm3D"
	spring_arm.spring_length = 8.0
	spring_arm.margin = 0.3
	spring_arm.rotation_degrees = Vector3(-35, 0, 0)  # ميل 35 درجة
	camera_pivot.add_child(spring_arm)
	
	camera_3d = Camera3D.new()
	camera_3d.name = "Camera3D"
	camera_3d.fov = 70.0
	spring_arm.add_child(camera_3d)
	camera_3d.make_current()

func _setup_animation_tree() -> void:
	## إعداد شجرة الأنيماشن
	if animation_tree:
		animation_tree.active = true
		_set_animation_parameter("blend_position", Vector2.ZERO)

# ============================
# PHYSICS UPDATE / التحديث الفيزيائي
# ============================
func _physics_process(delta: float) -> void:
	if current_state == PlayerState.DEAD:
		return
	
	_handle_stun_timer(delta)
	_handle_ability_cooldown(delta)
	_apply_gravity(delta)
	
	if not is_stunned:
		_handle_movement(delta)
	
	_handle_animation()
	move_and_slide()
	
	# تحديث موقع الشبكة
	_update_grid_position()

func _handle_movement(delta: float) -> void:
	## معالجة الحركة من الجمبستيك
	var input_dir = joystick_direction
	
	if input_dir.length() < 0.1:
		# توقف تدريجي
		velocity.x = lerp(velocity.x, 0.0, delta * 8.0)
		velocity.z = lerp(velocity.z, 0.0, delta * 8.0)
		current_state = PlayerState.IDLE
		return
	
	input_dir = input_dir.normalized()
	
	# تحديد السرعة
	current_speed = _get_current_speed()
	
	# حساب اتجاه الحركة نسبةً للكاميرا
	var cam_basis = camera_pivot.global_basis
	var move_dir = (cam_basis.x * input_dir.x + cam_basis.z * input_dir.y).normalized()
	move_dir.y = 0.0
	
	# تطبيق السرعة
	velocity.x = move_dir.x * current_speed
	velocity.z = move_dir.z * current_speed
	
	# تدوير الشخصية نحو اتجاه الحركة
	if move_dir.length() > 0.01:
		var target_rotation = atan2(move_dir.x, move_dir.z)
		rotation.y = lerp_angle(rotation.y, target_rotation, delta * rotation_speed)
	
	current_state = PlayerState.WALKING if current_speed <= base_speed else PlayerState.RUNNING

func _get_current_speed() -> float:
	## حساب السرعة الحالية بناءً على الحالة والقدرة
	var speed = base_speed
	
	# تأثير قدرة الفارس (زيادة السرعة)
	if character_type == CharacterType.KNIGHT and ability_active:
		speed *= 1.5
	
	return speed

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = -0.5  # ثبات على الأرض

func _handle_stun_timer(delta: float) -> void:
	if is_stunned:
		stun_timer -= delta
		if stun_timer <= 0.0:
			is_stunned = false
			current_state = PlayerState.IDLE

func _handle_ability_cooldown(delta: float) -> void:
	## تقليل مؤقتات الانتظار
	if ability_cooldown_remaining > 0.0:
		ability_cooldown_remaining -= delta
	
	if ability_active:
		ability_duration_remaining -= delta
		if ability_duration_remaining <= 0.0:
			_deactivate_ability()

func _update_grid_position() -> void:
	grid_position = Vector2i(
		int(global_position.x / 4.0),
		int(global_position.z / 4.0)
	)

# ============================
# SPECIAL ABILITIES / القدرات الخاصة
# ============================

func activate_ability() -> bool:
	## تفعيل القدرة الخاصة للشخصية
	if ability_cooldown_remaining > 0.0 or ability_active:
		return false
	
	var stats = CHARACTER_STATS[character_type]
	ability_active = true
	ability_duration_remaining = stats["ability_duration"]
	ability_cooldown_remaining = stats["ability_cooldown"] + stats["ability_duration"]
	
	match character_type:
		CharacterType.KNIGHT:
			_ability_knight()
		CharacterType.WIZARD:
			_ability_wizard()
		CharacterType.PRINCESS:
			_ability_princess()
		CharacterType.THIEF:
			_ability_thief()
	
	# تشغيل المؤثرات البصرية
	if ability_particles:
		ability_particles.emitting = true
	if ability_audio:
		ability_audio.play()
	
	emit_signal("ability_used", character_type)
	return true

func _ability_knight() -> void:
	## الفارس: زيادة السرعة 50% لمدة 3 ثوانٍ
	print("[Ability] Knight Dash activated / قدرة الفارس مفعلة")
	# السرعة تُحسب في _get_current_speed()
	# إضافة تأثير ذيل بصري
	_spawn_speed_trail()

func _ability_wizard() -> void:
	## الساحر: اختراق جدار واحد
	print("[Ability] Wizard Phase activated / قدرة الساحر مفعلة")
	# تعطيل الاصطدام بالأشجار مؤقتاً
	collision_shape.disabled = true
	set_collision_mask_value(1, false)  # إيقاف layer 1 (الجدران)

func _ability_princess() -> void:
	## الأميرة: إبطاء الزمن بنسبة 60%
	print("[Ability] Princess Slow Time activated / قدرة الأميرة مفعلة")
	Engine.time_scale = 0.4  # 40% من السرعة العادية (إبطاء 60%)
	# اللاعب يتحرك بسرعة طبيعية عبر تعديل حركته
	base_speed /= 0.4  # تعويض إبطاء الزمن

func _ability_thief() -> void:
	## اللص: رؤية أقصر طريق للخروج
	print("[Ability] Thief Path Vision activated / قدرة اللص مفعلة")
	# إرسال إشارة للـ GameManager لرسم المسار
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.show_path_to_exit(grid_position)

func _deactivate_ability() -> void:
	ability_active = false
	ability_particles.emitting = false
	
	match character_type:
		CharacterType.WIZARD:
			collision_shape.disabled = false
			set_collision_mask_value(1, true)
		CharacterType.PRINCESS:
			Engine.time_scale = 1.0
			base_speed = CHARACTER_STATS[CharacterType.PRINCESS]["speed"]

func get_ability_cooldown_percent() -> float:
	var stats = CHARACTER_STATS[character_type]
	var total = stats["ability_cooldown"] + stats["ability_duration"]
	return 1.0 - (ability_cooldown_remaining / total)

# ============================
# ENEMY HIT / الاصطدام بالعدو
# ============================

func on_enemy_hit() -> void:
	## تنفيذ الاصطدام بالعدو
	if is_stunned or current_state == PlayerState.DEAD:
		return
	
	is_stunned = true
	stun_timer = 1.0
	current_state = PlayerState.STUNNED
	
	# إعادة للموقع الأصلي
	global_position = respawn_position
	velocity = Vector3.ZERO
	
	emit_signal("hit_by_enemy", self)
	
	# إيقاف قدرة الساحر إذا كانت مفعلة
	if ability_active:
		_deactivate_ability()

# ============================
# ANIMATION / الأنيماشن
# ============================

func _handle_animation() -> void:
	if not animation_tree:
		return
	
	match current_state:
		PlayerState.IDLE:
			_set_animation_parameter("blend_position", Vector2.ZERO)
		PlayerState.WALKING:
			var blend = joystick_direction.normalized() * 0.5
			_set_animation_parameter("blend_position", blend)
		PlayerState.RUNNING:
			_set_animation_parameter("blend_position", joystick_direction.normalized())
		PlayerState.STUNNED:
			_set_animation_parameter("blend_position", Vector2.ZERO)

func _set_animation_parameter(param: String, value) -> void:
	if animation_tree:
		animation_tree.set("parameters/locomotion/" + param, value)

# ============================
# VISUAL EFFECTS / المؤثرات البصرية
# ============================

func _spawn_speed_trail() -> void:
	## إنشاء ذيل حركة للفارس
	var trail = GPUParticles3D.new()
	add_child(trail)
	trail.amount = 20
	trail.lifetime = 0.3
	trail.emitting = true
	# حذف الذيل بعد انتهاء القدرة
	await get_tree().create_timer(CHARACTER_STATS[CharacterType.KNIGHT]["ability_duration"]).timeout
	trail.queue_free()

# ============================
# JOYSTICK INPUT / إدخال الجمبستيك
# ============================

func set_joystick_direction(direction: Vector2) -> void:
	## يُستدعى من واجهة المستخدم
	joystick_direction = direction

# ============================
# GETTERS / الحاصلات
# ============================

func get_character_name() -> String:
	return CHARACTER_STATS[character_type]["name"]

func get_ability_name() -> String:
	return CHARACTER_STATS[character_type]["ability_name"]

func is_ability_ready() -> bool:
	return ability_cooldown_remaining <= 0.0 and not ability_active
