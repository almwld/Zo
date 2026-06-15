import 'dart:async';
import 'dart:io';
import 'dart:convert';

class UltimateKaliInstallerSystem {
  /// تثبيت كالي لينكس داخل VM
  Future<Map<String, dynamic>> installKaliInVM(String vmIp, int vmPort) async {
    final steps = <String, dynamic>{};

    // الخطوة 1: تحميل صورة كالي
    steps['download'] = await _downloadKaliImage();

    // الخطوة 2: استخراج الصورة
    steps['extract'] = await _extractImage();

    // الخطوة 3: إعداد البيئة
    steps['setup'] = await _setupEnvironment();

    // الخطوة 4: بدء كالي
    steps['start'] = await _startKali(vmIp, vmPort);

    return steps;
  }

  Future<bool> _downloadKaliImage() async {
    try {
      // محاولة تحميل Kali Nethunter أو Kali Light
      final result = await Process.run('wget', [
        'https://kali.download/nethunter-images/kali-2024.1/kali-nethunter-2024.1-generic-armhf-rootfs-minimal.tar.xz',
        '-O', '/data/local/tmp/kali.tar.xz',
      ], runInShell: true);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _extractImage() async {
    try {
      await Process.run('tar', ['-xf', '/data/local/tmp/kali.tar.xz', '-C', '/data/local/tmp/zion_vm/'], runInShell: true);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _setupEnvironment() async {
    try {
      // ربط المجلدات الأساسية
      await Process.run('mount', ['-o', 'bind', '/dev', '/data/local/tmp/zion_vm/dev'], runInShell: true);
      await Process.run('mount', ['-t', 'proc', 'proc', '/data/local/tmp/zion_vm/proc'], runInShell: true);
      await Process.run('mount', ['-t', 'sysfs', 'sysfs', '/data/local/tmp/zion_vm/sys'], runInShell: true);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _startKali(String ip, int port) async {
    try {
      await Process.run('chroot', ['/data/local/tmp/zion_vm', '/bin/bash', '-c', 'service ssh start'], runInShell: true);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// التحقق من تثبيت كالي
  Future<bool> isKaliInstalled() async {
    final dir = Directory('/data/local/tmp/zion_vm/etc/apt');
    return await dir.exists();
  }

  /// تشغيل أداة كالي محددة
  Future<Map<String, dynamic>> runKaliTool(String tool, String args) async {
    try {
      final result = await Process.run('chroot', [
        '/data/local/tmp/zion_vm',
        '/bin/bash', '-c', '$tool $args',
      ], runInShell: true);

      return {
        'success': result.exitCode == 0,
        'stdout': result.stdout.toString(),
        'stderr': result.stderr.toString(),
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// الحصول على قائمة الأدوات المثبتة
  Future<List<String>> getInstalledTools() async {
    try {
      final result = await Process.run('chroot', [
        '/data/local/tmp/zion_vm',
        '/bin/bash', '-c', 'dpkg -l | grep kali | awk "{print \$2}"',
      ], runInShell: true);

      return result.stdout.toString().split('\n').where((l) => l.isNotEmpty).toList();
    } catch (_) {
      return [];
    }
  }
}
