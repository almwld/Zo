import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ═══════════════════════════════════════════════════════════════════════════
// PACKET SNIFFER SCREEN - Network Traffic Analysis
// ═══════════════════════════════════════════════════════════════════════════
// Simulated packet capture interface for educational purposes.
// Displays network packets with protocol analysis and hex dump view.
// ═══════════════════════════════════════════════════════════════════════════

/// Simulated network packet
class Packet {
  final int id;
  final DateTime timestamp;
  final String protocol;
  final String sourceIp;
  final String destIp;
  final int sourcePort;
  final int destPort;
  final int length;
  final String info;
  final List<int> rawData;
  final Color protocolColor;

  Packet({
    required this.id,
    required this.timestamp,
    required this.protocol,
    required this.sourceIp,
    required this.destIp,
    required this.sourcePort,
    required this.destPort,
    required this.length,
    required this.info,
    required this.rawData,
  }) : protocolColor = _getProtocolColor(protocol);

  static Color _getProtocolColor(String protocol) {
    switch (protocol) {
      case 'TCP':
        return const Color(0xFF00E676);
      case 'UDP':
        return const Color(0xFF79C0FF);
      case 'ICMP':
        return const Color(0xFFFFAB70);
      case 'ARP':
        return const Color(0xFFF778BA);
      case 'DNS':
        return const Color(0xFFD2A8FF);
      case 'HTTP':
        return const Color(0xFF56D4DD);
      case 'HTTPS':
        return const Color(0xFF3FB950);
      default:
        return const Color(0xFF8B949E);
    }
  }

  String get hexDump {
    final buffer = StringBuffer();
    for (var i = 0; i < rawData.length; i += 16) {
      final offset = i.toRadixString(16).padLeft(4, '0');
      final hexChunk = <String>[];
      final asciiChunk = <String>[];

      for (var j = 0; j < 16; j++) {
        if (i + j < rawData.length) {
          hexChunk.add(rawData[i + j].toRadixString(16).padLeft(2, '0'));
          ascii.add(rawData[i + j] >= 32 && rawData[i + j] < 127
              ? String.fromCharCode(rawData[i + j])
              : '.');
        } else {
          hexChunk.add('  ');
          asciiChunk.add(' ');
        }
      }

      buffer.writeln(
          '$offset  ${hexChunk.join(' ')}  ${asciiChunk.join('')}');
    }
    return buffer.toString();
  }

  String get formattedTimestamp {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}.${timestamp.millisecond.toString().padLeft(3, '0')}';
  }
}

class PacketSnifferScreen extends StatefulWidget {
  const PacketSnifferScreen({super.key});

  @override
  State<PacketSnifferScreen> createState() => _PacketSnifferScreenState();
}

class _PacketSnifferScreenState extends State<PacketSnifferScreen> {
  final List<Packet> _packets = [];
  bool _isCapturing = false;
  Timer? _captureTimer;
  int _packetCounter = 0;
  String _filter = '';
  Packet? _selectedPacket;

  final List<String> _protocols = ['TCP', 'UDP', 'ICMP', 'ARP', 'DNS', 'HTTP', 'HTTPS'];
  final List<String> _commonPorts = ['80', '443', '53', '22', '21', '25', '110', '143', '993', '995'];

  @override
  void dispose() {
    _captureTimer?.cancel();
    super.dispose();
  }

  void _startCapture() {
    setState(() {
      _isCapturing = true;
    });

    // Simulate packet capture
    _captureTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      _generatePacket();
    });
  }

  void _stopCapture() {
    _captureTimer?.cancel();
    setState(() {
      _isCapturing = false;
    });
  }

  void _generatePacket() {
    final rand = Random();
    final protocol = _protocols[rand.nextInt(_protocols.length)];
    final srcPort = int.parse(_commonPorts[rand.nextInt(_commonPorts.length)]);
    final dstPort = int.parse(_commonPorts[rand.nextInt(_commonPorts.length)]);
    final length = rand.nextInt(1400) + 40;

    final srcOctets = List.generate(4, (_) => rand.nextInt(256));
    final dstOctets = List.generate(4, (_) => rand.nextInt(256));

    final packet = Packet(
      id: ++_packetCounter,
      timestamp: DateTime.now(),
      protocol: protocol,
      sourceIp: srcOctets.join('.'),
      destIp: dstOctets.join('.'),
      sourcePort: srcPort,
      destPort: dstPort,
      length: length,
      info: _generatePacketInfo(protocol, srcPort, dstPort, length),
      rawData: List.generate(length, (_) => rand.nextInt(256)),
    );

    setState(() {
      _packets.insert(0, packet);
      // Keep only last 100 packets
      if (_packets.length > 100) {
        _packets.removeLast();
      }
    });
  }

  String _generatePacketInfo(String protocol, int srcPort, int dstPort, int length) {
    switch (protocol) {
      case 'TCP':
        return 'TCP $srcPort > $dstPort [SYN] Seq=0 Win=65535 Len=$length';
      case 'UDP':
        return 'UDP $srcPort > $dstPort Len=$length';
      case 'ICMP':
        return 'ICMP Echo (ping) request id=0x${Random().nextInt(65535).toRadixString(16).padLeft(4, '0')} seq=1';
      case 'DNS':
        return 'DNS Standard query 0x${Random().nextInt(65535).toRadixString(16)} A google.com';
      case 'HTTP':
        return 'HTTP GET / HTTP/1.1';
      case 'HTTPS':
        return 'TLSv1.3 Client Hello';
      default:
        return '$protocol packet, length $length';
    }
  }

  List<Packet> get _filteredPackets {
    if (_filter.isEmpty) return _packets;
    final lowerFilter = _filter.toLowerCase();
    return _packets.where((p) {
      return p.protocol.toLowerCase().contains(lowerFilter) ||
          p.sourceIp.contains(lowerFilter) ||
          p.destIp.contains(lowerFilter) ||
          p.info.toLowerCase().contains(lowerFilter);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Packet Sniffer'),
            Text(
              'محلل حزم الشبكة',
              style: TextStyle(fontSize: 12, color: Color(0xFF8B949E)),
            ),
          ],
        ),
        actions: [
          if (_isCapturing)
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF85149),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'LIVE',
                    style: TextStyle(
                      color: Color(0xFFF85149),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          IconButton(
            icon: Icon(_isCapturing ? Icons.stop : Icons.fiber_manual_record,
                color: _isCapturing ? const Color(0xFFF85149) : const Color(0xFFF85149)),
            onPressed: _isCapturing ? _stopCapture : _startCapture,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFF8B949E)),
            onPressed: () => setState(() {
              _packets.clear();
              _selectedPacket = null;
            }),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Stats Bar ───────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF161B22),
              border: Border(bottom: BorderSide(color: Color(0xFF30363D))),
            ),
            child: Row(
              children: [
                _StatBadge(
                  label: 'Packets',
                  value: '${_packets.length}',
                  color: const Color(0xFF00E676),
                ),
                const SizedBox(width: 16),
                _StatBadge(
                  label: 'TCP',
                  value: '${_packets.where((p) => p.protocol == 'TCP').length}',
                  color: const Color(0xFF00E676),
                ),
                const SizedBox(width: 16),
                _StatBadge(
                  label: 'UDP',
                  value: '${_packets.where((p) => p.protocol == 'UDP').length}',
                  color: const Color(0xFF79C0FF),
                ),
                const SizedBox(width: 16),
                _StatBadge(
                  label: 'Size',
                  value:
                      '${(_packets.fold<int>(0, (sum, p) => sum + p.length) / 1024).toStringAsFixed(1)} KB',
                  color: const Color(0xFFFFAB70),
                ),
              ],
            ),
          ),

          // ── Filter Bar ──────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (value) => setState(() => _filter = value),
              decoration: InputDecoration(
                hintText: 'Filter by protocol, IP, or content...',
                hintStyle: const TextStyle(color: Color(0xFF8B949E)),
                prefixIcon: const Icon(Icons.filter_list, color: Color(0xFF8B949E)),
                filled: true,
                fillColor: const Color(0xFF21262D),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              style: const TextStyle(color: Color(0xFFE6EDF3)),
            ),
          ),

          // ── Packet List ─────────────────
          Expanded(
            flex: _selectedPacket == null ? 1 : 1,
            child: _packets.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isCapturing
                              ? Icons.radar
                              : Icons.wifi_tethering,
                          size: 64,
                          color: const Color(0xFF30363D),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isCapturing
                              ? 'Capturing packets...'
                              : 'Press the record button to start capture',
                          style: const TextStyle(
                            color: Color(0xFF8B949E),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredPackets.length,
                    itemBuilder: (context, index) {
                      final packet = _filteredPackets[index];
                      return _PacketListItem(
                        packet: packet,
                        isSelected: _selectedPacket?.id == packet.id,
                        onTap: () => setState(() => _selectedPacket = packet),
                      );
                    },
                  ),
          ),

          // ── Packet Detail ───────────────
          if (_selectedPacket != null)
            Container(
              height: 250,
              decoration: const BoxDecoration(
                color: Color(0xFF0D1117),
                border: Border(top: BorderSide(color: Color(0xFF30363D))),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Detail header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF161B22),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Packet #${_selectedPacket!.id} - ${_selectedPacket!.protocol}',
                          style: TextStyle(
                            color: _selectedPacket!.protocolColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_selectedPacket!.length} bytes',
                          style: const TextStyle(color: Color(0xFF8B949E), fontSize: 12),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18, color: Color(0xFF8B949E)),
                          onPressed: () => setState(() => _selectedPacket = null),
                        ),
                      ],
                    ),
                  ),
                  // Detail tabs
                  Expanded(
                    child: DefaultTabController(
                      length: 3,
                      child: Column(
                        children: [
                          const TabBar(
                            indicatorColor: Color(0xFF00E676),
                            labelColor: Color(0xFF00E676),
                            unselectedLabelColor: Color(0xFF8B949E),
                            tabs: [
                              Tab(text: 'Summary'),
                              Tab(text: 'Hex Dump'),
                              Tab(text: 'Raw'),
                            ],
                          ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                // Summary
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: SelectableText(
                                    'Timestamp: ${_selectedPacket!.formattedTimestamp}\n'
                                    'Protocol: ${_selectedPacket!.protocol}\n'
                                    'Source: ${_selectedPacket!.sourceIp}:${_selectedPacket!.sourcePort}\n'
                                    'Destination: ${_selectedPacket!.destIp}:${_selectedPacket!.destPort}\n'
                                    'Length: ${_selectedPacket!.length} bytes\n'
                                    '\nInfo:\n${_selectedPacket!.info}',
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 12,
                                      color: Color(0xFFE6EDF3),
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                                // Hex Dump
                                SingleChildScrollView(
                                  padding: const EdgeInsets.all(12),
                                  child: SelectableText(
                                    _selectedPacket!.hexDump.substring(
                                        0,
                                        _selectedPacket!.hexDump.length > 2000
                                            ? 2000
                                            : _selectedPacket!.hexDump.length),
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 11,
                                      color: Color(0xFF00E676),
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                                // Raw
                                SingleChildScrollView(
                                  padding: const EdgeInsets.all(12),
                                  child: SelectableText(
                                    _selectedPacket!.rawData
                                        .map((b) => '0x${b.toRadixString(16).padLeft(2, '0')}')
                                        .join(' '),
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 11,
                                      color: Color(0xFF8B949E),
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBadge({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF8B949E), fontSize: 11),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _PacketListItem extends StatelessWidget {
  final Packet packet;
  final bool isSelected;
  final VoidCallback onTap;

  const _PacketListItem({
    required this.packet,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF161B22) : Colors.transparent,
          border: Border(
            bottom: const BorderSide(color: Color(0xFF21262D)),
            left: isSelected
                ? const BorderSide(color: Color(0xFF00E676), width: 3)
                : BorderSide.none,
          ),
        ),
        child: Row(
          children: [
            // Packet number
            SizedBox(
              width: 40,
              child: Text(
                '${packet.id}',
                style: const TextStyle(
                  color: Color(0xFF8B949E),
                  fontSize: 11,
                ),
              ),
            ),
            // Protocol badge
            Container(
              width: 50,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: packet.protocolColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                packet.protocol,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: packet.protocolColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Source
            Expanded(
              flex: 2,
              child: Text(
                '${packet.sourceIp}:${packet.sourcePort}',
                style: const TextStyle(
                  color: Color(0xFFE6EDF3),
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Arrow
            const Icon(
              Icons.arrow_forward,
              size: 12,
              color: Color(0xFF8B949E),
            ),
            const SizedBox(width: 8),
            // Destination
            Expanded(
              flex: 2,
              child: Text(
                '${packet.destIp}:${packet.destPort}',
                style: const TextStyle(
                  color: Color(0xFFE6EDF3),
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Length
            SizedBox(
              width: 50,
              child: Text(
                '${packet.length}B',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: Color(0xFF8B949E),
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
