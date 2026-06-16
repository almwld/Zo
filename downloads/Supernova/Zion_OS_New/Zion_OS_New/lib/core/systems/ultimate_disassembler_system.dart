import 'dart:typed_data';

class UltimateDisassemblerSystem {
  /// تفكيك كود x86
  static List<Map<String, dynamic>> disassembleX86(List<int> bytes, {int offset = 0, int count = 50}) {
    final instructions = <Map<String, dynamic>>[];
    int pos = offset;

    while (pos < bytes.length && instructions.length < count) {
      final inst = _decodeX86Instruction(bytes, pos);
      instructions.add(inst);
      pos = inst['next_offset'] as int;
    }

    return instructions;
  }

  /// فك تشفير تعليمة x86 واحدة
  static Map<String, dynamic> _decodeX86Instruction(List<int> bytes, int offset) {
    if (offset >= bytes.length) return {'mnemonic': '???', 'bytes': [], 'offset': offset, 'next_offset': offset + 1};

    final b0 = bytes[offset];
    final result = <String, dynamic>{'offset': offset, 'bytes': [b0], 'next_offset': offset + 1};

    // تعليمات بسيطة
    if (b0 == 0x90) result['mnemonic'] = 'nop';
    else if (b0 == 0xC3) result['mnemonic'] = 'ret';
    else if (b0 == 0xCC) result['mnemonic'] = 'int3';
    else if (b0 == 0x50) result['mnemonic'] = 'push eax';
    else if (b0 == 0x58) result['mnemonic'] = 'pop eax';
    else if (b0 == 0x31 && offset + 1 < bytes.length && bytes[offset + 1] == 0xC0) {
      result['mnemonic'] = 'xor eax, eax';
      result['bytes'].add(bytes[offset + 1]);
      result['next_offset'] = offset + 2;
    }
    else {
      result['mnemonic'] = 'db ${b0.toRadixString(16)}';
    }

    return result;
  }
}
