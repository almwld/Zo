# 🌿 Garden Maze Escape: Infinite Odyssey
## دليل التشغيل والتثبيت الشامل - Complete Setup & Installation Guide

---

## 📋 محتويات المشروع - Project Contents

```
GardenMazeEscape/
├── project.godot                    ← إعدادات المحرك
├── export_presets/
│   └── android_lg_wing.preset       ← إعدادات تصدير Android
├── scenes/
│   ├── main_menu.tscn               ← الشاشة الرئيسية
│   ├── character_select.tscn        ← اختيار الشخصية
│   ├── stage_select.tscn            ← اختيار المرحلة
│   ├── gameplay.tscn                ← مشهد اللعب الرئيسي
│   ├── result_screen.tscn           ← شاشة النتيجة
│   └── settings.tscn                ← الإعدادات
├── scripts/
│   ├── player.gd                    ← تحكم اللاعب + القدرات الخاصة
│   ├── enemy.gd                     ← ذكاء العدو (10 أنواع)
│   ├── world_manager.gd             ← بناء المتاهة + تطبيق الثيم
│   ├── difficulty_curve.gd          ← منحنى الصعوبة (1000 مرحلة)
│   ├── maze_generator.gd            ← 5 خوارزميات توليد
│   ├── gem.gd                       ← الجواهر المضيئة
│   ├── exit_gate.gd                 ← بوابة الخروج
│   ├── save_system.gd               ← حفظ/تحميل البيانات
│   ├── achievement_system.gd        ← نظام الإنجازات
│   ├── ui_manager.gd                ← واجهة HUD + جمبستيك
│   ├── camera_controller.gd         ← كاميرا Third-Person
│   └── game_manager.gd              ← المتحكم المركزي (Autoload)
└── worlds/
    ├── world_01/ ... world_10/      ← موارد كل عالم
```

---

## 🔧 الخطوة 1: تحميل Godot 4.2 - Download Godot 4.2

### تنزيل المحرك
1. اذهب إلى: **https://godotengine.org/download**
2. اختر: **Godot Engine 4.2.x - Standard**
3. نظام التشغيل: **Windows 64-bit** أو **macOS** أو **Linux**
4. حجم التنزيل: ~80 MB
5. فك الضغط في أي مجلد

> ⚠️ يجب أن يكون الإصدار **4.2.x** تحديداً (ليس 4.0 أو 4.1 أو 4.3)

---

## 📱 الخطوة 2: إعداد تصدير Android

### 2.1 تنزيل Android SDK
```
1. ثبّت Android Studio من: https://developer.android.com/studio
2. افتح Android Studio → SDK Manager
3. ثبّت: Android SDK Platform 30 (Android 11)
4. ثبّت: Android SDK Build-Tools 30.x
5. ثبّت: NDK 23.x
```

### 2.2 ربط Android SDK بـ Godot
```
Godot → Editor → Editor Settings → Export → Android:
  Android SDK Path: [مسار Android/Sdk]
  NDK Path: [مسار Android/Sdk/ndk/23.x]
  Java SDK Path: [مسار JDK 17]
```

### 2.3 تفعيل Vulkan في Godot
```
Project → Project Settings → Rendering:
  Rendering Method: Forward+  ← للأجهزة القوية
  Rendering Method (Mobile): Mobile  ← للهاتف
```

### 2.4 إنشاء Keystore للتوقيع
```bash
keytool -genkey -v -keystore garden_maze.keystore \
        -alias garden_maze_key \
        -keyalg RSA -keysize 2048 \
        -validity 10000
```
ضع الـ keystore في مجلد المشروع وأضف مساره في export_preset.

---

## 🚀 الخطوة 3: فتح المشروع - Open Project

```
1. شغّل Godot 4.2
2. اضغط "Import"
3. اختر ملف: GardenMazeEscape/project.godot
4. اضغط "Import & Edit"
5. انتظر حتى يكتمل استيراد الموارد (~2 دقيقة)
```

---

## ⚙️ الخطوة 4: إعداد Autoload (ضروري!)

```
Project → Project Settings → Autoload → اضغط "+"

أضف هذه السكريبتات بالترتيب:
  Name: SaveSystem      Path: res://scripts/save_system.gd
  Name: GameManager     Path: res://scripts/game_manager.gd
  Name: AchievementSystem  Path: res://scripts/achievement_system.gd
```

---

## 📂 الخطوة 5: إعداد Scenes

### 5.1 إنشاء مشهد Character Select
```
1. New Scene → 3D Scene
2. Rename root: "CharacterSelect"
3. Attach Script: scenes/character_select.gd
4. أضف Camera3D
5. أضف CanvasLayer مع UI elements
6. Save: scenes/character_select.tscn
```

### 5.2 إعداد مشهد Gameplay
```
1. افتح: scenes/gameplay.tscn
2. تأكد من:
   - WorldManager node → script: scripts/world_manager.gd
   - Player node → script: scripts/player.gd
   - UIManager node → script: scripts/ui_manager.gd
3. أضف NavigationRegion3D للـ WorldManager
```

### 5.3 إعداد NavigationRegion3D
```
In WorldManager:
  - أضف NavigationRegion3D
  - Bake Navigation Mesh بعد بناء المتاهة
  - أو استخدم: NavigationServer3D.map_force_update()
```

---

## 🎨 الخطوة 6: إضافة الأصول - Adding Assets

### النماذج ثلاثية الأبعاد (Models)
اللعبة تعمل بدون نماذج حقيقية (تستخدم Primitive Shapes). لإضافة نماذج حقيقية:

```
1. احصل على نماذج .glb من:
   - Sketchfab.com (مجانية ومدفوعة)
   - Kenney.nl (مجانية)
   - Poly.pizza (مجانية)
   
2. ضع الملفات في: GardenMazeEscape/models/
   - knight.glb    (الفارس)
   - wizard.glb    (الساحر)
   - princess.glb  (الأميرة)
   - thief.glb     (اللص)
   - enemy_*.glb   (لكل عدو)
   - gem.glb       (الجوهرة)

3. في player.gd، غيّر:
   # قبل (Primitive):
   var capsule = CapsuleMesh.new()
   
   # بعد (نموذج حقيقي):
   var model = preload("res://models/knight.glb").instantiate()
   $MeshInstance3D.add_child(model)
```

### الأنسجة (Textures) - PBR
```
ضع الأنسجة في textures/:
  - [name]_albedo.jpg    ← اللون الأساسي
  - [name]_normal.jpg    ← النتوءات والتفاصيل
  - [name]_roughness.jpg ← الخشونة/اللمعان
  - [name]_ao.jpg        ← الظلال المحيطة

في السكريبت:
  var mat = StandardMaterial3D.new()
  mat.albedo_texture = preload("res://textures/tree_bark_albedo.jpg")
  mat.normal_enabled = true
  mat.normal_texture = preload("res://textures/tree_bark_normal.jpg")
  mat.roughness_texture = preload("res://textures/tree_bark_roughness.jpg")
  mat.ao_enabled = true
  mat.ao_texture = preload("res://textures/tree_bark_ao.jpg")
```

### الأصوات (Audio)
```
ضع ملفات الصوت في audio/:
  - background_music.ogg   ← موسيقى الخلفية
  - footsteps.ogg
  - gem_collect.ogg
  - ability_activate.ogg
  - enemy_roar.ogg
  - victory.ogg
  - failure.ogg

يجب أن تكون بصيغة .ogg (مجانية)
يمكن تحويلها من .mp3 باستخدام: https://cloudconvert.com
```

---

## 📊 الخطوة 7: ضبط الجودة - Quality Settings

### إعدادات الجودة في project.godot

#### 🔴 جودة منخفضة (50+ FPS على Adreno 618)
```
rendering/lights_and_shadows/directional_shadow/size=1024
rendering/global_illumination/sdfgi/enabled=false
rendering/environment/volumetric_fog/volume_size=32
rendering/anti_aliasing/quality/msaa_3d=0
rendering/anti_aliasing/quality/use_taa=false
```

#### 🟡 جودة متوسطة (45+ FPS على Adreno 620)
```
rendering/lights_and_shadows/directional_shadow/size=2048
rendering/global_illumination/sdfgi/enabled=true
rendering/global_illumination/sdfgi/frames_to_converge=3
rendering/environment/volumetric_fog/volume_size=64
rendering/anti_aliasing/quality/msaa_3d=1
```

#### 🟢 جودة عالية (30+ FPS على Adreno 620)
```
rendering/lights_and_shadows/directional_shadow/size=4096
rendering/global_illumination/sdfgi/enabled=true
rendering/global_illumination/sdfgi/frames_to_converge=5
rendering/environment/volumetric_fog/volume_size=128
rendering/anti_aliasing/quality/msaa_3d=2
rendering/anti_aliasing/quality/use_taa=true
```

### الضبط الديناميكي في اللعبة
في game_manager.gd استخدم الدالة:
```gdscript
GameManager.apply_graphics_quality(0)  # منخفض
GameManager.apply_graphics_quality(1)  # متوسط
GameManager.apply_graphics_quality(2)  # عالي
```

---

## 📤 الخطوة 8: تصدير APK - Export APK

### 8.1 من داخل Godot
```
Project → Export → Android (android_lg_wing.preset)

إعدادات مهمة:
  ✅ Architecture: arm64-v8a (فقط)
  ✅ Screen Orientation: Portrait
  ✅ Immersive Mode: ON
  ✅ Permissions: VIBRATE, WAKE_LOCK, WRITE_EXTERNAL_STORAGE
  ✅ Vulkan Support: ON

اضغط: "Export Project" → GardenMazeEscape.apk
```

### 8.2 تثبيت APK على الهاتف
```bash
# عبر ADB (الكمبيوتر):
adb install GardenMazeEscape.apk

# يدوياً:
1. انقل الـ APK للهاتف عبر USB
2. هاتفك: الإعدادات → الأمان → مصادر غير معروفة → تفعيل
3. افتح مدير الملفات → ابحث عن الـ APK → ثبّت
```

---

## 🎮 الخطوة 9: التحكم داخل اللعبة

```
📱 الشاشة التحسية (Touch):
  ┌─────────────────────────────────┐
  │ [Timer]  [Score]   [MiniMap]   │
  │          [Gems]                │
  │                                │
  │                                │
  │                                │
  │  [Joystick]        [Ability]   │
  └─────────────────────────────────┘

🎮 أو عبر لوحة المفاتيح (للاختبار):
  WASD / Arrow Keys = الحركة
  Space             = القدرة الخاصة
  Escape            = إيقاف مؤقت
```

---

## 🔑 الخطوة 10: الشيفرات السرية - Cheat Codes

```
ادخل للإعدادات → شيفرة مخفية:
SPRING100  ← فتح أول 100 مرحلة
AUTUMN200  ← فتح 200 مرحلة
ICE300     ← فتح 300 مرحلة
DESERT400  ← فتح 400 مرحلة
DARK500    ← فتح 500 مرحلة
FIRE600    ← فتح 600 مرحلة
OCEAN700   ← فتح 700 مرحلة
DREAM800   ← فتح 800 مرحلة
CHAOS900   ← فتح 900 مرحلة
VOID1000   ← فتح 1000 مرحلة
ALLMAZE999 ← فتح جميع المراحل
```

---

## 🐛 حل المشكلات الشائعة - Troubleshooting

### مشكلة: "Script not found"
```
تأكد من أن مسارات السكريبتات صحيحة:
  scripts/player.gd → res://scripts/player.gd
  
في الـ .tscn:
  script = ExtResource("path/to/script.gd")
```

### مشكلة: "NavigationAgent3D can't find path"
```
1. تأكد من وجود NavigationRegion3D في المشهد
2. بعد بناء المتاهة:
   NavigationServer3D.map_force_update(get_world_3d().navigation_map)
3. أو اضغط: Scene → Bake NavigationMesh
```

### مشكلة: اللعبة تعمل ببطء على الهاتف
```
1. خفّض جودة الرسوميات: GameManager.apply_graphics_quality(0)
2. عطّل SDFGI: env.sdfgi_enabled = false
3. خفّض حجم الظلال: 1024
4. قلّل عدد الجزيئات: particles.amount /= 2
5. عطّل Volumetric Fog: env.volumetric_fog_enabled = false
```

### مشكلة: Vulkan لا يعمل
```
الهاتف لا يدعم Vulkan → سيتحول تلقائياً لـ OpenGL
في project.godot:
  rendering/renderer/rendering_method.mobile="mobile"
  (هذا يستخدم Vulkan Mobile وهو أخف)
```

### مشكلة: الجمبستيك لا يستجيب
```
تأكد من:
  1. UIManager.joystick_moved متصل بـ player.set_joystick_direction
  2. CanvasLayer.layer = 1 (فوق المشهد ثلاثي الأبعاد)
  3. Control.mouse_filter = MOUSE_FILTER_PASS (للحاوية)
```

---

## 🔄 استبدال النماذج المؤقتة بنماذج حقيقية

### الخطوات:
```gdscript
## في player.gd - استبدال Capsule بـ glTF:
func _setup_character() -> void:
    # 1. احذف MeshInstance3D الحالي
    if mesh_instance:
        mesh_instance.queue_free()
    
    # 2. حمّل النموذج الحقيقي
    var char_names := ["knight", "wizard", "princess", "thief"]
    var model_path = "res://models/" + char_names[character_type] + ".glb"
    
    if ResourceLoader.exists(model_path):
        var model_scene = load(model_path)
        var model = model_scene.instantiate()
        add_child(model)
        
        # 3. ابحث عن AnimationPlayer في النموذج
        animation_player = model.find_child("AnimationPlayer")
        
        # 4. أعد ضبط CollisionShape حسب حجم النموذج
        var aabb = model.get_aabb()
        var col = collision_shape.shape as CapsuleShape3D
        col.radius = aabb.size.x * 0.5
        col.height = aabb.size.y
    else:
        print("Model not found, using placeholder: " + model_path)
        # استخدام النموذج المؤقت
        var mesh_inst = MeshInstance3D.new()
        var capsule = CapsuleMesh.new()
        mesh_inst.mesh = capsule
        add_child(mesh_inst)
```

---

## 📱 مواصفات الهاتف المستهدف - Target Device Specs

```
الجهاز: LG Wing (F100N) / أي هاتف بـ Snapdragon 765G
النظام: Android 11 (API 30)
المعالج: Qualcomm SM7250 Snapdragon 765G
GPU: Adreno 620
الذاكرة: 8 GB RAM
الشاشة: 1080 × 2460 pixels

الأداء المتوقع:
  جودة عالية:  35-45 FPS
  جودة متوسطة: 45-55 FPS
  جودة منخفضة: 55-60 FPS
```

---

## 📦 تحسين حجم APK - APK Size Optimization

### الهدف: أقل من 500 MB

```
1. ضغط الأنسجة:
   Import → Texture → Compress → VRAM Compressed (ETC2/ASTC)
   جودة: 0.7 (بدلاً من 1.0)

2. ضغط الصوت:
   Import → Audio → Compress → .ogg (جودة 0.6)
   
3. حذف الموارد غير المستخدمة:
   Project → Tools → Remove Unused Assets
   
4. تفعيل PCK Compression:
   Export → Resources → Enable PCK Compression
   
5. استخدام Texture Atlas:
   دمج أنسجة UI في Atlas واحد

حجم تقريبي:
  Core Engine: 50 MB
  Scripts: 0.5 MB  
  Scenes: 5 MB
  Audio (compressed): 50-80 MB
  Textures (compressed): 100-200 MB
  Total: ~200-300 MB ✅
```

---

## 🌐 الإنتاج النهائي - Final Production Checklist

```
□ تعمل جميع المراحل من 1 إلى 1000
□ الحفظ والتحميل يعمل (SharedPreferences عبر ConfigFile)
□ الأداء ≥ 50 FPS على Snapdragon 765G
□ حجم APK < 500 MB
□ جميع الأزرار تعمل
□ الجمبستيك يستجيب بسلاسة
□ الميني ماب يعرض المواقع الصحيحة
□ الشيفرات السرية تعمل
□ الإنجازات تُحفظ
□ تغيير الجودة يُطبَّق فوراً
□ الكاميرا تتجنب الجدران
□ العدو يطارد اللاعب بشكل صحيح
□ قدرة الساحر تخترق الجدران
□ قدرة الأميرة تُبطئ الزمن
□ قدرة اللص تُظهر المسار
□ قدرة الفارس تزيد السرعة
```

---

## 📞 الدعم الفني

للأسئلة التقنية حول Godot:
- **المنتدى الرسمي:** https://forum.godotengine.org
- **التوثيق:** https://docs.godotengine.org/en/4.2
- **Discord:** https://discord.gg/godotengine

---

*تم إنشاء هذا المشروع بـ Godot 4.2 + GDScript*
*Garden Maze Escape: Infinite Odyssey © 2024*
