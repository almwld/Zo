import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

class UltimatePacketCaptureSystem {
  RawDatagramSocket? _rawSocket;
  ServerSocket? _tcpSocket;
  final List<Map<String, dynamic>> _capturedPackets = [];
  bool _isCapturing = false;
  int _totalCaptured = 0;

  /// بدء الالتقاط على مستوى منخفض
  Future<bool> startCapture({String? interface, bool promiscuous = true}) async {
    try {
      _rawSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      _isCapturing = true;

      _rawSocket!.listen((event) {
        if (event == RawSocketEvent.read) {
          final datagram = _rawSocket!.receive();
          if (datagram != null) {
            _processPacket(datagram.data, '${datagram.address.address}:${datagram.port}');
          }
        }
      });

      return true;
    } catch (_) {
      return false;
    }
  }

  /// معالجة حزمة
  void _processPacket(List<int> data, String source) {
    if (data.length < 20) return;

    final packet = <String, dynamic>{
      'timestamp': DateTime.now().microsecondsSinceEpoch,
      'source': source,
      'size': data.length,
      'raw_hex': data.take(64).map((b) => b.toRadixString(16).padLeft(2, '0')).join(' '),
    };

    // تحليل IP Header
    final version = (data[0] >> 4) & 0x0F;
    final ihl = (data[0] & 0x0F) * 4;
    final protocol = data[9];
    final srcIp = '${data[12]}.${data[13]}.${data[14]}.${data[15]}';
    final dstIp = '${data[16]}.${data[17]}.${data[18]}.${data[19]}';

    packet['src_ip'] = srcIp;
    packet['dst_ip'] = dstIp;

    if (protocol == 6 && data.length >= ihl + 20) {
      packet['protocol'] = 'TCP';
      final tcpStart = ihl;
      packet['src_port'] = (data[tcpStart] << 8) | data[tcpStart + 1];
      packet['dst_port'] = (data[tcpStart + 2] << 8) | data[tcpStart + 3];
      final flags = data[tcpStart + 13];
      packet['flags'] = _parseTcpFlags(flags);
    } else if (protocol == 17 && data.length >= ihl + 8) {
      packet['protocol'] = 'UDP';
      final udpStart = ihl;
      packet['src_port'] = (data[udpStart] << 8) | data[udpStart + 1];
      packet['dst_port'] = (data[udpStart + 2] << 8) | data[udpStart + 3];
    } else if (protocol == 1) {
      packet['protocol'] = 'ICMP';
      packet['icmp_type'] = data[ihl];
    }

    _capturedPackets.add(packet);
    if (_capturedPackets.length > 5000) _capturedPackets.removeAt(0);
    _totalCaptured++;
  }

  /// إيقاف الالتقاط
  void stopCapture() {
    _isCapturing = false;
    _rawSocket?.close();
  }

  /// الحصول على الحزم الملتقطة
  List<Map<String, dynamic>> getPackets({int? limit, String? protocol}) {
    var packets = _capturedPackets;
    if (protocol != null) {
      packets = packets.where((p) => p['protocol'] == protocol).toList();
    }
    if (limit != null && packets.length > limit) {
      return packets.sublist(packets.length - limit);
    }
    return packets;
  }

  List<String> _parseTcpFlags(int flags) {
    final result = <String>[];
    if (flags & 0x01 != 0) result.add('FIN');
    if (flags & 0x02 != 0) result.add('SYN');
    if (flags & 0x04 != 0) result.add('RST');
    if (flags & 0x08 != 0) result.add('PSH');
    if (flags & 0x10 != 0) result.add('ACK');
    if (flags & 0x20 != 0) result.add('URG');
    return result;
  }
}
