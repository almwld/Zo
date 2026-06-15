import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/wireless_service.dart';

class WirelessCenter extends StatefulWidget {
  const WirelessCenter({super.key});

  @override
  State<WirelessCenter> createState() => _WirelessCenterState();
}

class _WirelessCenterState extends State<WirelessCenter> with SingleTickerProviderStateMixin {
  late WirelessService _wirelessService;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _wirelessService = WirelessService();
    _wirelessService.init();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('WiFi & Bluetooth', style: TextStyle(color: Color(0xFF00BCD4))),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00BCD4)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF00BCD4)),
            onPressed: () async {
              await _wirelessService.scanWiFiNetworks();
              setState(() {});
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF00BCD4),
          unselectedLabelColor: Colors.white54,
          indicatorColor: const Color(0xFF00BCD4),
          tabs: const [
            Tab(icon: Icon(Icons.wifi), text: 'WiFi'),
            Tab(icon: Icon(Icons.bluetooth), text: 'Bluetooth'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWiFiTab(),
          _buildBluetoothTab(),
        ],
      ),
    );
  }

  Widget _buildWiFiTab() {
    return Column(
      children: [
        // Current Connection Card
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF00BCD4), Color(0xFF006064)]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.wifi, color: Colors.white, size: 40),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _wirelessService.getCurrentWiFiName(),
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'IP: ${_wirelessService.getCurrentIP()}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.check_circle, color: Colors.white),
            ],
          ),
        ),
        
        // Saved Networks
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: const Text('Saved Networks', style: TextStyle(color: Color(0xFF00BCD4), fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: _wirelessService.savedNetworks.length,
            itemBuilder: (context, index) {
              final network = _wirelessService.savedNetworks[index];
              return _buildNetworkTile(network, true);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNetworkTile(Map<String, String> network, bool isSaved) {
    final signalStrength = int.tryParse(network['signal'] ?? '-50') ?? -50;
    Color signalColor;
    if (signalStrength > -50) signalColor = Colors.green;
    else if (signalStrength > -70) signalColor = Colors.orange;
    else signalColor = Colors.red;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.wifi, color: signalColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(network['ssid'] ?? 'Unknown', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Text('${network['signal']} dBm', style: TextStyle(color: signalColor, fontSize: 11)),
                    const SizedBox(width: 8),
                    Text(network['security'] ?? 'WPA2', style: const TextStyle(color: Colors.white54, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
          if (isSaved)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _forgetNetwork(network['ssid']!),
            )
          else
            ElevatedButton(
              onPressed: () => _connectToNetwork(network),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BCD4),
                foregroundColor: Colors.black,
              ),
              child: const Text('Connect'),
            ),
        ],
      ),
    );
  }

  Widget _buildBluetoothTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bluetooth, size: 80, color: Color(0xFF00BCD4)),
          SizedBox(height: 20),
          Text('Bluetooth Feature', style: TextStyle(color: Color(0xFF00BCD4), fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text('Coming Soon', style: TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }

  Future<void> _connectToNetwork(Map<String, String> network) async {
    final passwordController = TextEditingController();
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Connect to ${network['ssid']}', style: const TextStyle(color: Color(0xFF00BCD4))),
        backgroundColor: Colors.black,
        content: TextField(
          controller: passwordController,
          obscureText: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Password',
            labelStyle: TextStyle(color: Color(0xFF00BCD4)),
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Connect', style: TextStyle(color: Color(0xFF00BCD4)))),
        ],
      ),
    );
    
    if (confirmed == true) {
      final success = await _wirelessService.connectToWiFi(network['ssid']!, passwordController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Connected to ${network['ssid']}' : 'Connection failed'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _forgetNetwork(String ssid) async {
    await _wirelessService.forgetNetwork(ssid);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Forgot $ssid'), backgroundColor: Color(0xFF00BCD4)),
    );
  }
}
