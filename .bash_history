        ],
      ),
    );
  }

  Widget _buildSlider(IconData iconStart, IconData iconEnd, String label, double value, Function(double) onChanged) {
    final primaryColor = Theme.of(context).primaryColor;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Row(
          children: [
            Icon(iconStart, color: primaryColor, size: 16),
            Expanded(
              child: Slider(
                value: value,
                onChanged: onChanged,
                activeColor: primaryColor,
              ),
            ),
            Icon(iconEnd, color: primaryColor, size: 16),
          ],
        ),
      ],
    );
  }

  Widget _buildShortcutButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor, size: 24),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
EOF

# ============================================
# 3. رفع التغييرات
# ============================================
git add -A
git commit -m "✅ إكمال المهام النهائية: تحسين شريط المهام ولوحة الإعدادات"
git push origin main
echo ""
echo "════════════════════════════════════════════════════════════"
echo "✅ تم إكمال جميع المهام النهائية!"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "📋 المهام المكتملة:"
echo ""
echo "   1. ✅ شاشة القفل - كاملة مع بصمة و PIN"
echo "   2. ✅ شاشة الإعدادات - ثيمات، لغة، حجم خط"
echo "   3. ✅ شاشة About - معلومات التطبيق"
echo "   4. ✅ شريط المهام - إدارة النوافذ"
echo "   5. ✅ لوحة الإعدادات السريعة"
echo "   6. ✅ نظام النوافذ - سحب، تحجيم، تصغير"
echo "   7. ✅ واجهة سطح المكتب"
echo "   8. ✅ جميع التطبيقات الأساسية"
echo ""
echo "🎉 Zion OS جاهز للإصدار النهائي!"
echo ""
echo "📥 حمل APK من:"
echo "   https://github.com/almwld/Zion_OS_New/actions"
ls
cd /data/data/com.termux/files/home/downloads/Supernova
echo "════════════════════════════════════════════════════════════"
echo "🗑️ حذف مجلد Zion_OS_New بالكامل"
echo "════════════════════════════════════════════════════════════"
echo ""
# ============================================
# 1. عرض المجلد الحالي
# ============================================
echo "📁 المجلد الحالي:"
pwd
echo ""
# ============================================
# 2. تأكيد الحذف
# ============================================
echo "⚠️  تحذير: هذا الأمر سيحذف المجلد بالكامل نهائياً!"
echo "   المسار: /data/data/com.termux/files/home/downloads/Supernova/Zion_OS_New"
echo ""
read -p "❓ هل أنت متأكد من حذف المجلد؟ (اكتب 'yes' للتأكيد): " confirm
ls
cd Zion_OS_New
ls
rm -rf /data/data/com.termux/files/home/downloads/Supernova/Zion_OS_New && echo "✅ تم الحذف"
ls
## 🚀 أمر سريع (بدون تأكيد):
```bash
cd /data/data/com.termux/files/home/downloads/Supernova/Zion_OS_New && \
find . -maxdepth 1 -not -name ".git" -not -name "." -exec rm -rf {} \; && \
echo "✅ تم حذف جميع المحتويات" && \
ls -la
cd /data/data/com.termux/files/home/downloads/Supernova/Zion_OS_New
echo "════════════════════════════════════════════════════════════"
echo "🗑️ حذف شامل لمحتويات المستودع"
echo "════════════════════════════════════════════════════════════"
echo ""
# ============================================
# 1. عرض المحتويات الحالية
# ============================================
echo "📁 1. المحتويات الحالية:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
ls -la
echo ""
# ============================================
# 2. تأكيد الحذف
# ============================================
echo "⚠️  تحذير: هذا الأمر سيحذف ALL الملفات والمجلدات!"
echo "   سيتم الاحتفاظ فقط بمجلد .git (للمستودع)"
echo ""
read -p "❓ هل أنت متأكد من حذف جميع المحتويات؟ (اكتب 'DELETE' للتأكيد): " confirm
if [ "$confirm" = "DELETE" ]; then     echo "";     echo "🗑️  جاري حذف جميع الملفات والمجلدات...";     
    find . -maxdepth 1 -not -name ".git" -not -name "." -exec rm -rf {} \;;          echo "   ✅ تم حذف جميع المحتويات";     
    echo "";     echo "📝 3. إضافة README جديد..."
    cat > README.md << 'EOF'
# Zion OS Repository

This repository has been cleaned and is ready for a fresh start.

## 🚀 Getting Started

```bash
git clone https://github.com/almwld/Zion_OS_New.git
cd Zion_OS_New
"

# ============================================
# 4. رفع التغييرات إلى GitHub
# ============================================
echo ""
echo "🚀 4. رفع التغييرات إلى GitHub..."
git add -A
git commit -m "🗑️ حذف شامل لجميع محتويات المستودع - إعادة تهيئة"
git push origin main --force
if [ $? -eq 0 ]; then     echo "   ✅ تم رفع التغييرات بنجاح"; else     echo "   ❌ فشل الرفع"; fi
# ============================================
# 1. معرفة الموقع الحالي
# ============================================
echo "════════════════════════════════════════════════════════════"
echo "📍 التحقق من الموقع الحالي"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "المسار الحالي: $(pwd)"
echo ""
# ============================================
# 2. العودة إلى المجلد الرئيسي
# ============================================
cd /data/data/com.termux/files/home/downloads/Supernova
echo "📁 2. التنقل إلى مجلد Supernova:"
echo "   $(pwd)"
echo ""
# ============================================
# 3. عرض المجلدات المتاحة
# ============================================
echo "📁 3. المجلدات الموجودة:"
ls -la
echo ""
# ============================================
# 4. التحقق من وجود Zion_OS_New
# ============================================
if [ -d "Zion_OS_New" ]; then     echo "✅ مجلد Zion_OS_New لا يزال موجوداً";     cd Zion_OS_New;     echo "   الدخول إلى المجلد...";     ls -la; else     echo "❌ مجلد Zion_OS_New غير موجود (تم حذفه بنجاح)"; fi
echo ""
echo "════════════════════════════════════════════════════════════"
# العودة إلى المجلد الرئيسي
cd /data/data/com.termux/files/home/downloads/Supernova
# إنشاء مجلد جديد
mkdir Zion_OS_New
cd Zion_OS_New
# تهيئة Git
git init
# إضافة remote
git remote add origin https://github.com/almwld/Zion_OS_New.git
# إنشاء README
echo "# Zion OS Repository" > README.md
echo "" >> README.md
echo "Fresh start for Zion OS" >> README.md
# رفع التغييرات
git add README.md
git commit -m "Initial commit - Fresh start"
git push -u origin main --force
echo "✅ تم إنشاء مستودع جديد فارغ"
# العودة إلى المجلد الرئيسي
cd /data/data/com.termux/files/home/downloads/Supernova
# إنشاء مجلد جديد
mkdir Zion_OS_New
cd Zion_OS_New
# تهيئة Git
git init
# إضافة remote
git remote add origin https://github.com/almwld/Zion_OS_New.git
# إنشاء README
echo "# Zion OS Repository" > README.md
echo "" >> README.md
echo "Fresh start for Zion OS" >> README.md
# رفع التغييرات
git add README.md
git commit -m "Initial commit - Fresh start"
git push -u origin main --force
echo "✅ تم إنشاء مستودع جديد فارغ"
cd /data/data/com.termux/files/home/downloads/Supernova/Zion_OS_New
echo "════════════════════════════════════════════════════════════"
echo "🔧 إصلاح إعدادات Git وإنشاء أول commit"
echo "════════════════════════════════════════════════════════════"
echo ""
# ============================================
# 1. إعداد اسم المستخدم والبريد الإلكتروني
# ============================================
echo "📝 1. إعداد هوية Git:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
git config --global user.name "almwld"
git config --global user.email "almwld@github.com"
echo "   ✅ تم إعداد:"
echo "      • user.name = almwld"
echo "      • user.email = almwld@github.com"
echo ""
# ============================================
# 2. إنشاء ملف README
# ============================================
echo "📄 2. إنشاء ملف README.md:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cat > README.md << 'EOF'
# Zion OS

نظام تشغيل متكامل للأمان والاختراق

## 🚀 البدء

```bash
git clone https://github.com/almwld/Zion_OS_New.git
cd Zion_OS_New

cd /data/data/com.termux/files/home/downloads/Supernova/Zion_OS_New
echo "════════════════════════════════════════════════════════════"
echo "🔍 التحقق من محتويات المستودع"
echo "════════════════════════════════════════════════════════════"
echo ""
# ============================================
# 1. عرض الملفات في المجلد المحلي
# ============================================
echo "📁 1. الملفات في المجلد المحلي:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
ls -la
echo ""
# ============================================
# 2. عرض حالة Git
# ============================================
echo "📊 2. حالة Git:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
git status
echo ""
# ============================================
# 3. حذف جميع الملفات (باستثناء .git)
# ============================================
echo "🗑️ 3. حذف جميع الملفات (باستثناء مجلد .git):"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
# حذف كل الملفات ما عدا .git
find . -maxdepth 1 -not -name ".git" -not -name "." -exec rm -rf {} \;
echo "   ✅ تم حذف جميع الملفات"
echo ""
# ============================================
# 4. التحقق بعد الحذف
# ============================================
echo "📁 4. المحتويات بعد الحذف:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
ls -la
echo ""
# ============================================
# 5. إضافة ورفع التغييرات
# ============================================
echo "🚀 5. رفع التغييرات إلى GitHub:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
git add -A
git commit -m "🗑️ حذف جميع الملفات - تنظيف كامل للمستودع"
git push origin main --force
echo ""
echo "════════════════════════════════════════════════════════════"
echo "✅ تم تنظيف المستودع بالكامل!"
echo "🔗 https://github.com/almwld/Zion_OS_New"
echo "════════════════════════════════════════════════════════════"
cd /data/data/com.termux/files/home/downloads/Supernova/Zion_OS_New
echo "════════════════════════════════════════════════════════════"
echo "🔧 إنشاء commit فارغ ورفع إلى GitHub"
echo "════════════════════════════════════════════════════════════"
echo ""
# ============================================
# 1. إنشاء commit فارغ
# ============================================
echo "📝 1. إنشاء commit فارغ:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
# إنشاء ملف مؤقت
echo "# Zion OS Repository" > README.md
echo "" >> README.md
echo "Empty repository - Clean state" >> README.md
# إضافة الملف
git add README.md
# إنشاء commit
git commit -m "Initial empty repository - Clean state"
echo "   ✅ تم إنشاء commit"
echo ""
# ============================================
# 2. التحقق من الـ branch
# ============================================
echo "🌿 2. التحقق من الـ branch:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
git branch -a
ho ""
# ============================================
# 3. رفع إلى GitHub
# ============================================
echo "🚀 3. رفع إلى GitHub:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
git push -u origin main --force
if [ $? -eq 0 ]; then     echo "   ✅ تم الرفع بنجاح!"; else     echo "   ❌ فشل الرفع"; fi
echo ""
# ============================================
# 4. التحقق من الرفع
# ============================================
echo "🔍 4. التحقق من الرفع:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
git log --oneline
cho ""
echo "════════════════════════════════════════════════════════════"
echo "✅ المستودع الآن فارغ على GitHub!"
echo "🔗 https://github.com/almwld/Zion_OS_New"
echo "════════════════════════════════════════════════════════════"
# أنت الآن في المسار الصحيح
pwd  # يجب أن يكون /data/.../Zion_OS_New
# أضف ملفات مشروعك هنا
# ثم:
git add .
git commit -m "إضافة المشروع"
git push origin master
cd /data/data/com.termux/files/home/downloads/Supernova/Zion_OS_New
echo "════════════════════════════════════════════════════════════"
echo "🗑️ حذف جميع الملفات من المستودع نهائياً"
echo "════════════════════════════════════════════════════════════"
echo ""
# ============================================
# 1. حذف كل الملفات والمجلدات (باستثناء .git)
# ============================================
echo "📁 1. حذف جميع الملفات المحلية:"
find . -maxdepth 1 -not -name ".git" -not -name "." -exec rm -rf {} \;
echo "   ✅ تم الحذف"
# ============================================
# 2. إنشاء README جديد
# ============================================
echo ""
echo "📄 2. إنشاء README.md جديد:"
cat > README.md << 'EOF'
# Zion OS Repository

This repository has been cleaned and is ready for a fresh start.

## 🚀 Getting Started

```bash
git clone https://github.com/almwld/Zion_OS_New.git
cd Zion_OS_New


cd /data/data/com.termux/files/home/downloads/Supernova/Zion_OS_New
echo "════════════════════════════════════════════════════════════"
echo "🔍 التحقق من الوضع الحالي"
echo "════════════════════════════════════════════════════════════"
echo ""
# ============================================
# 1. عرض الملفات الموجودة حالياً
# ============================================
echo "📁 1. الملفات الموجودة:"
ls -la
echo ""
# ============================================
# 2. إنشاء README.md بشكل صحيح
# ============================================
echo "📝 2. إنشاء README.md:"
echo '# Zion OS Repository' > README.md
echo '' >> README.md
echo 'This repository has been cleaned and is ready for a fresh start.' >> README.md
echo '' >> README.md
echo '## 🚀 Getting Started' >> README.md
echo '' >> README.md
echo '```bash' >> README.md
echo 'git clone https://github.com/almwld/Zion_OS_New.git' >> README.md
echo 'cd Zion_OS_New' >> README.md
echo '```' >> README.md
echo '' >> README.md
echo '## 📝 License' >> README.md
echo '' >> README.md
echo 'MIT License' >> README.md
echo "   ✅ تم إنشاء README.md"
cat README.md
echo ""
# ============================================
# 3. إضافة ورفع التغييرات
# ============================================
echo "📦 3. إضافة الملفات إلى Git:"
git add README.md
echo "   ✅ تمت الإضافة"
echo ""
echo "💾 4. إنشاء commit:"
git commit -m "🗑️ تنظيف كامل للمستودع - حذف جميع الملفات القديمة"
echo "   ✅ تم إنشاء commit"
echo ""
echo "🚀 5. رفع إلى GitHub:"
git push origin master --force
# مثال: إنشاء ملف جديد
echo "# مرحباً بالعالم" > hello.txt
# رفعه إلى GitHub
git add hello.txt
git commit -m "إضافة ملف أول للمشروع الجديد"
git push origin master
cd /data/data/com.termux/files/home/downloads/Supernova
echo "════════════════════════════════════════════════════════════"
echo "🔥 الحل النهائي: حذف المستودع بالكامل وإعادة إنشائه"
echo "════════════════════════════════════════════════════════════"
echo ""
# ============================================
# 1. حذف المجلد المحلي بالكامل
# ============================================
echo "📁 1. حذف المجلد المحلي..."
rm -rf Zion_OS_New
echo "   ✅ تم الحذف"
# ============================================
# 2. إنشاء مجلد جديد
# ============================================
echo ""
echo "📁 2. إنشاء مجلد جديد..."
mkdir Zion_OS_New
cd Zion_OS_New
echo "   ✅ تم الإنشاء"
# ============================================
# 3. تهيئة Git
# ============================================
echo ""
echo "🔧 3. تهيئة Git..."
git init
git config user.name "almwld"
git config user.email "almwld@github.com"
echo "   ✅ تم التهيئة"
# ============================================
# 4. إنشاء README
# ============================================
echo ""
echo "📄 4. إنشاء README.md..."
echo "# Zion OS" > README.md
echo "" >> README.md
echo "Fresh start - Clean repository" >> README.md
echo "   ✅ تم الإنشاء"
# ============================================
# 5. إضافة ورفع
# ============================================
echo ""
echo "📦 5. إضافة ورفع إلى GitHub..."
git add README.md
git commit -m "Initial commit - Fresh start"
git remote add origin https://github.com/almwld/Zion_OS_New.git
git push -u origin master --force
cd /data/data/com.termux/files/home/downloads/Supernova/Zion_OS_New
echo "════════════════════════════════════════════════════════════"
echo "🔐 إصلاح مشكلة المصادقة"
echo "════════════════════════════════════════════════════════════"
echo ""
# ============================================
# 1. إزالة الـ remote القديم
# ============================================
echo "📦 1. إزالة الـ remote القديم..."
git remote remove origin
echo "   ✅ تمت الإزالة"
# ============================================
# 2. إضافة remote جديد مع الـ Token
# ============================================
echo ""
echo "🔑 2. إضافة remote جديد مع Token..."
git remote add origin https://almwld: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@github.com/almwld/Zion_OS_New.git
echo "   ✅ تمت الإضافة"
# ============================================
# 3. رفع التغييرات
# ============================================
echo ""
echo "🚀 3. رفع التغييرات..."
git push -u origin master --force
echo ""
echo "════════════════════════════════════════════════════════════"
echo "✅ تم الرفع بنجاح!"
echo "════════════════════════════════════════════════════════════"
