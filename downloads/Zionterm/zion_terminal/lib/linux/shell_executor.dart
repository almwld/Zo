import 'dart:io';

class ShellExecutor {
  Process? _process;
  final List<String> _output = [];
  
  Future<bool> execute(String command) async {
    try {
      _process = await Process.start(
        '/system/bin/sh',
        ['-c', command],
        runInShell: true,
      );
      
      _process!.stdout.listen((data) {
        _output.add(String.fromCharCodes(data));
      });
      
      _process!.stderr.listen((data) {
        _output.add('[ERROR] ${String.fromCharCodes(data)}');
      });
      
      await _process!.exitCode;
      return true;
    } catch (e) {
      _output.add('Error: $e');
      return false;
    }
  }
  
  List<String> getOutput() => List.unmodifiable(_output);
  
  void clear() => _output.clear();
}
