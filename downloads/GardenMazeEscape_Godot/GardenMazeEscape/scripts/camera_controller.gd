## camera_controller.gd
## متحكم الكاميرا - Third-Person مع تجنب الاصطدامات
## Camera Controller - Third-Person with SpringArm collision avoidance

extends Node3D

# ============================
# EXPORTS / متغيرات المحرر
# ============================
@export var spring_length: float = 8.0
@export var min_spring_length: float = 2.0
@export var vertical_angle: float = -35.0    # درجة الميل
@export var follow_speed: float = 8.0
@export var rotation_speed: float = 120.0    # سرعة الدوران اليدوي

# ============================
# NODE REFERENCES / مراجع العقد
# ============================
@onready var spring_arm: SpringArm3D = $SpringArm3D
@onready var camera: Camera3D = $SpringArm3D/Camera3D

# ============================
# STATE / الحالة
# ============================
var target: Node3D = null
var current_yaw: float = 0.0
var target_yaw: float = 0.0
var shake_offset: Vector3 = Vector3.ZERO

# ============================
# INITIALIZATION / التهيئة
# ============================
func _ready() -> void:
	if spring_arm:
		spring_arm.spring_length = spring_length
		spring_arm.margin = 0.3
		spring_arm.rotation_degrees.x = vertical_angle
	
	if camera:
		camera.fov = 70.0
		camera.near = 0.1
		camera.far = 200.0

func set_target(node: Node3D) -> void:
	target = node
	if target:
		global_position = target.global_position
		current_yaw = target.rotation.y

# ============================
# PROCESS / المعالجة
# ============================
func _process(delta: float) -> void:
	if not target:
		return
	
	# تتبع اللاعب بنعومة
	var target_pos = target.global_position + Vector3(0, 1.0, 0)
	global_position = global_position.lerp(target_pos, follow_speed * delta)
	
	# تدوير الكاميرا مع اللاعب تدريجياً
	var target_rot = target.rotation.y
	current_yaw = lerp_angle(current_yaw, target_rot, delta * 5.0)
	rotation.y = current_yaw
	
	# تطبيق اهتزاز الكاميرا
	if camera and shake_offset.length() > 0.001:
		camera.position = camera.position.lerp(shake_offset, delta * 20.0)
		shake_offset = shake_offset.lerp(Vector3.ZERO, delta * 15.0)

func apply_shake(intensity: float) -> void:
	shake_offset = Vector3(
		randf_range(-intensity, intensity),
		randf_range(-intensity, intensity),
		0.0
	)

func get_camera_forward() -> Vector3:
	if camera:
		return -camera.global_basis.z
	return Vector3.FORWARD

func get_camera_right() -> Vector3:
	if camera:
		return camera.global_basis.x
	return Vector3.RIGHT
