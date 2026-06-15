## gem.gd
## الجوهرة - سلوك الجواهر القابلة للجمع
## Gem - collectible gem behavior with visual effects

extends Area3D

# ============================
# EXPORTS / متغيرات المحرر
# ============================
@export var rotation_speed: float = 2.0
@export var bob_speed: float = 1.5
@export var bob_height: float = 0.3
@export var attraction_radius: float = 1.5  # مدى الجذب نحو اللاعب

# ============================
# NODE REFERENCES / مراجع العقد
# ============================
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var sparkle_particles: GPUParticles3D = $SparkleParticles
@onready var glow_light: OmniLight3D = $GlowLight
@onready var collect_audio: AudioStreamPlayer3D = $CollectAudio
@onready var orbit_particles: GPUParticles3D = $OrbitParticles

# ============================
# STATE / الحالة
# ============================
var is_collected: bool = false
var gem_color: Color = Color(0.8, 0.3, 1.0)
var world_id: int = 1
var base_y: float = 0.8
var time_offset: float = 0.0  # لتفادي تزامن الجواهر
var player_nearby: CharacterBody3D = null

# ============================
# SIGNALS / الإشارات
# ============================
signal collected(gem: Area3D)

# ============================
# INITIALIZATION / التهيئة
# ============================
func _ready() -> void:
	time_offset = randf() * TAU
	base_y = position.y
	
	# الاستجابة لدخول الجسم
	body_entered.connect(_on_body_entered)
	
	_apply_gem_material()
	_setup_particles()

func setup(color: Color, world: int) -> void:
	## إعداد الجوهرة من WorldManager
	gem_color = color
	world_id = world
	
	if is_inside_tree():
		_apply_gem_material()
		_setup_particles()

func _apply_gem_material() -> void:
	if not mesh_instance:
		return
	
	var mat := StandardMaterial3D.new()
	mat.albedo_color = gem_color
	mat.metallic = 0.9
	mat.roughness = 0.0
	mat.emission_enabled = true
	mat.emission = gem_color
	mat.emission_energy_multiplier = 2.0
	
	# انعكاس البيئة على الجوهرة
	mat.metallic_specular = 1.0
	
	# الشفافية الخفيفة
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color.a = 0.9
	
	# Subsurface Scattering لمظهر كريستالي
	mat.subsurf_scatter_enabled = true
	mat.subsurf_scatter_strength = 0.5
	mat.subsurf_scatter_transmittance_enabled = true
	mat.subsurf_scatter_transmittance_color = gem_color
	
	mesh_instance.material_override = mat
	
	# إعداد الضوء المحيط
	if glow_light:
		glow_light.light_color = gem_color
		glow_light.light_energy = 2.0
		glow_light.omni_range = 2.0

func _setup_particles() -> void:
	## إعداد جزيئات التألق
	if sparkle_particles:
		var pm := ParticleProcessMaterial.new()
		pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
		pm.emission_sphere_radius = 0.3
		pm.initial_velocity_min = 0.5
		pm.initial_velocity_max = 1.5
		pm.gravity = Vector3(0, -0.5, 0)
		pm.scale_min = 0.02
		pm.scale_max = 0.08
		pm.color = gem_color
		pm.lifetime_randomness = 0.5
		
		sparkle_particles.process_material = pm
		sparkle_particles.amount = 20
		sparkle_particles.lifetime = 1.0
		
		# شبكة الجزيئات
		var sphere_mesh := SphereMesh.new()
		sphere_mesh.radius = 0.04
		sphere_mesh.height = 0.08
		sparkle_particles.draw_pass_1 = sphere_mesh
		sparkle_particles.emitting = true
	
	# جزيئات المدار
	if orbit_particles:
		var pm2 := ParticleProcessMaterial.new()
		pm2.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_RING
		pm2.emission_ring_axis = Vector3.UP
		pm2.emission_ring_radius = 0.5
		pm2.emission_ring_inner_radius = 0.4
		pm2.initial_velocity_min = 0.3
		pm2.initial_velocity_max = 0.6
		pm2.gravity = Vector3.ZERO
		pm2.color = gem_color * 0.7
		pm2.scale_min = 0.03
		pm2.scale_max = 0.06
		
		orbit_particles.process_material = pm2
		orbit_particles.amount = 15
		orbit_particles.lifetime = 2.0
		orbit_particles.emitting = true

# ============================
# ANIMATION LOOP / حلقة الأنيماشن
# ============================
func _process(delta: float) -> void:
	if is_collected:
		return
	
	var time = Time.get_ticks_msec() / 1000.0 + time_offset
	
	# التدوير حول المحور Y
	rotation.y += rotation_speed * delta
	
	# الحركة العلوية والسفلية (Bob)
	position.y = base_y + sin(time * bob_speed) * bob_height
	
	# نبض الضوء
	if glow_light:
		glow_light.light_energy = 1.5 + sin(time * 3.0) * 0.5
	
	# جذب اللاعب القريب (تأثير بصري فقط)
	_check_player_attraction(delta)

func _check_player_attraction(delta: float) -> void:
	## سحب خفيف نحو اللاعب عند الاقتراب
	if player_nearby and not is_collected:
		var dir = (player_nearby.global_position - global_position)
		dir.y = 0
		if dir.length() < attraction_radius:
			global_position += dir.normalized() * 2.0 * delta

# ============================
# COLLECTION / الجمع
# ============================
func _on_body_entered(body: Node3D) -> void:
	if is_collected:
		return
	
	if body is CharacterBody3D and body.has_method("on_enemy_hit"):
		# هذه شخصية لاعب
		_collect(body)

func _collect(collector: CharacterBody3D) -> void:
	is_collected = true
	
	# إيقاف الجزيئات والضوء
	if sparkle_particles:
		sparkle_particles.emitting = false
	if orbit_particles:
		orbit_particles.emitting = false
	
	# تشغيل صوت الجمع
	if collect_audio:
		collect_audio.play()
	
	# تأثير انفجار بصري
	_play_collect_effect()
	
	# إعلام GameManager
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.collect_gem()
	
	emit_signal("collected", self)
	
	# الانتظار حتى ينتهي الصوت ثم الحذف
	await get_tree().create_timer(0.5).timeout
	queue_free()

func _play_collect_effect() -> void:
	## تأثير بصري عند الجمع
	# إخفاء الشبكة
	if mesh_instance:
		mesh_instance.visible = false
	
	# انفجار جزيئات
	var burst := GPUParticles3D.new()
	get_parent().add_child(burst)
	burst.global_position = global_position
	burst.one_shot = true
	burst.amount = 50
	burst.lifetime = 0.8
	burst.emitting = true
	
	var pm := ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_POINT
	pm.initial_velocity_min = 2.0
	pm.initial_velocity_max = 5.0
	pm.gravity = Vector3(0, -3.0, 0)
	pm.scale_min = 0.05
	pm.scale_max = 0.15
	pm.color = gem_color
	pm.color_ramp = _create_fade_gradient()
	burst.process_material = pm
	
	# حذف تأثير الانفجار بعد انتهائه
	await get_tree().create_timer(1.0).timeout
	burst.queue_free()

func _create_fade_gradient() -> Gradient:
	var grad := Gradient.new()
	grad.add_point(0.0, gem_color)
	grad.add_point(1.0, Color(gem_color.r, gem_color.g, gem_color.b, 0.0))
	return grad
