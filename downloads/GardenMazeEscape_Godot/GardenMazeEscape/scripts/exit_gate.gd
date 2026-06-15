## exit_gate.gd
## بوابة الخروج - تكتشف وصول اللاعب وتُطلق إشارة الفوز
## Exit Gate - detects player arrival and triggers win signal

extends Area3D

# ============================
# NODE REFERENCES / مراجع العقد
# ============================
@onready var gate_mesh: MeshInstance3D = $GateMesh
@onready var gate_light: OmniLight3D = $GateLight
@onready var gate_particles: GPUParticles3D = $GateParticles
@onready var gate_audio: AudioStreamPlayer3D = $GateAudio
@onready var portal_animation: AnimationPlayer = $AnimationPlayer

# ============================
# STATE / الحالة
# ============================
var is_active: bool = true
var pulse_time: float = 0.0
var gate_color: Color = Color(1.0, 0.8, 0.0)

# ============================
# INITIALIZATION / التهيئة
# ============================
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_setup_gate_visuals()
	_start_idle_animation()

func setup(color: Color) -> void:
	gate_color = color
	_setup_gate_visuals()

func _setup_gate_visuals() -> void:
	if gate_mesh:
		var mat := StandardMaterial3D.new()
		mat.albedo_color = gate_color
		mat.emission_enabled = true
		mat.emission = gate_color
		mat.emission_energy_multiplier = 4.0
		mat.metallic = 0.8
		mat.roughness = 0.1
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.albedo_color.a = 0.85
		gate_mesh.material_override = mat
	
	if gate_light:
		gate_light.light_color = gate_color
		gate_light.light_energy = 5.0
		gate_light.omni_range = 6.0
	
	if gate_particles:
		var pm := ParticleProcessMaterial.new()
		pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_RING
		pm.emission_ring_axis = Vector3.UP
		pm.emission_ring_radius = 1.0
		pm.emission_ring_inner_radius = 0.8
		pm.initial_velocity_min = 1.0
		pm.initial_velocity_max = 3.0
		pm.gravity = Vector3.UP * 2.0
		pm.color = gate_color
		pm.scale_min = 0.05
		pm.scale_max = 0.2
		gate_particles.process_material = pm
		gate_particles.amount = 60
		gate_particles.emitting = true

func _start_idle_animation() -> void:
	## حركة نبض للبوابة
	var tween = get_tree().create_tween()
	tween.set_loops()
	tween.tween_property(gate_light, "light_energy", 8.0, 0.8)
	tween.tween_property(gate_light, "light_energy", 3.0, 0.8)

# ============================
# PROCESS / المعالجة
# ============================
func _process(delta: float) -> void:
	if not is_active:
		return
	
	pulse_time += delta
	
	# دوران البوابة
	if gate_mesh:
		gate_mesh.rotation.y = pulse_time * 0.5

# ============================
# PLAYER DETECTION / اكتشاف اللاعب
# ============================
func _on_body_entered(body: Node3D) -> void:
	if not is_active:
		return
	
	if body is CharacterBody3D and body.has_method("on_enemy_hit"):
		_trigger_win()

func _trigger_win() -> void:
	is_active = false
	
	# تشغيل صوت النصر
	if gate_audio:
		gate_audio.play()
	
	# تأثير بصري ضخم
	_play_win_effect()
	
	# إعلام GameManager بالفوز
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.on_player_reached_exit()

func _play_win_effect() -> void:
	## تأثير بصري عند الوصول للبوابة
	var burst := GPUParticles3D.new()
	get_parent().add_child(burst)
	burst.global_position = global_position
	burst.one_shot = true
	burst.amount = 200
	burst.lifetime = 2.0
	burst.emitting = true
	
	var pm := ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	pm.emission_sphere_radius = 2.0
	pm.initial_velocity_min = 3.0
	pm.initial_velocity_max = 8.0
	pm.gravity = Vector3(0, 2.0, 0)
	pm.scale_min = 0.1
	pm.scale_max = 0.4
	pm.color = gate_color
	burst.process_material = pm
	
	await get_tree().create_timer(2.0).timeout
	burst.queue_free()
