import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/network_service.dart';

class AdvancedNetworkCenter extends StatefulWidget {
  const AdvancedNetworkCenter({super.key});

  @override
  State<AdvancedNetworkCenter> createState() => _AdvancedNetworkCenterState();
}

class _AdvancedNetworkCenterState extends State<AdvancedNetworkCenter> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _pingHostController = TextEditingController(text: '8.8.8.8');
  String _pingResult = '';
  bool _isPinging = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    final service = Provider.of<NetworkService>(context, listen: false);
    service.scanNetworkInterfaces();
  }

  Future<void> _pingHost() async {
    if (_pingHostController.text.isEmpty) return;
    
    setState(() {
      _isPinging = true;
      _pingResult = '';
    });
    
    final service = Provider.of<NetworkService>(context, listen: false);
    final result = await service.pingHost(_pingHostController.text);
    
    setState(() {
      _isPinging = false;
      _pingResult = result ? '✅ Host is reachable' : '❌ Host is not reachable';
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final service = Provider.of<NetworkService>(context);
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Network Center', style: TextStyle(color: Color(0xFF00BCD4))),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00BCD4)),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF00BCD4),
          unselectedLabelColor: Colors.white54,
          indicatorColor: const Color(0xFF00BCD4),
          tabs: const [
            Tab(icon: Icon(Icons.wifi), text: 'Status'),
            Tab(icon: Icon(Icons.settings_ethernet), text: 'Connections'),
            Tab(icon: Icon(Icons.network_wifi), text: 'Interfaces'),
            Tab(icon: Icon(Icons.ping), text: 'Tools'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStatusTab(service),
          _buildConnectionsTab(service),
          _buildInterfacesTab(service),
          _buildToolsTab(service),
        ],
      ),
    );
  }
  
  Widget _buildStatusTab(NetworkService service) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Status Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [service.getConnectionStatusColor().withOpacity(0.2), Colors.black],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: service.getConnectionStatusColor().withOpacity(0.5)),
            ),
            child: Column(
              children: [
                Icon(
                  service.connectionStatus == ConnectivityResult.wifi 
                      ? Icons.wifi 
                      : (service.connectionStatus == ConnectivityResult.mobile 
                          ? Icons.signal_cellular_alt 
                          : Icons.wifi_off),
                  color: service.getConnectionStatusColor(),
                  size: 60,
                ),
                const SizedBox(height: 15),
                Text(
                  service.getConnectionStatusText(),
                  style: TextStyle(
                    color: service.getConnectionStatusColor(),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  service.connectionStatus == ConnectivityResult.wifi 
                      ? 'Connected to ${service.wifiName}' 
                      : '',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Network Details
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Network Details', style: TextStyle(color: Color(0xFF00BCD4), fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 15),
                _buildInfoRow('IP Address', service.ipAddress),
                _buildInfoRow('Gateway', service.gateway),
                _buildInfoRow('Subnet Mask', service.subnetMask),
                _buildInfoRow('DNS', service.dns),
                _buildInfoRow('BSSID', service.wifiBSSID),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildConnectionsTab(NetworkService service) {
    if (service.activeConnections.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.router, size: 64, color: Colors.white24),
            SizedBox(height: 16),
            Text('No active connections', style: TextStyle(color: Colors.white38)),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: service.activeConnections.length,
      itemBuilder: (context, index) {
        final conn = service.activeConnections[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.link, color: Color(0xFF00BCD4), size: 16),
                  const SizedBox(width: 8),
                  Text(conn['protocol'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(conn['state'], style: const TextStyle(color: Colors.green, fontSize: 10)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Local: ${conn['local']}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
              Text('Foreign: ${conn['foreign']}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildInterfacesTab(NetworkService service) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: service.networkInterfaces.length,
      itemBuilder: (context, index) {
        final iface = service.networkInterfaces[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: iface['status'] == 'up' 
                  ? Colors.green.withOpacity(0.5) 
                  : Colors.red.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                iface['status'] == 'up' ? Icons.check_circle : Icons.error,
                color: iface['status'] == 'up' ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(iface['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text(
                      iface['ip'] != '' ? iface['ip'] : 'No IP assigned',
                      style: TextStyle(color: iface['ip'] != '' ? Colors.white54 : Colors.red, fontSize: 11),
                    ),
                    Text('Status: ${iface['status']}', style: TextStyle(color: iface['status'] == 'up' ? Colors.green : Colors.red, fontSize: 10)),
                  ],
                ),
              ),
              if (iface['status'] == 'up')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('ACTIVE', style: TextStyle(color: Colors.green, fontSize: 10)),
                ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildToolsTab(NetworkService service) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Ping Tool
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ping Tool', style: TextStyle(color: Color(0xFF00BCD4), fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 15),
                TextField(
                  controller: _pingHostController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Host / IP',
                    labelStyle: TextStyle(color: Color(0xFF00BCD4)),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF00BCD4))),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isPinging ? null : _pingHost,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00BCD4),
                      foregroundColor: Colors.black,
                    ),
                    child: _isPinging 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('PING'),
                  ),
                ),
                if (_pingResult.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(_pingResult, style: const TextStyle(color: Color(0xFF00BCD4), fontFamily: 'monospace')),
                    ),
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Refresh Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => service.scanNetworkInterfaces(),
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh Network Info'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
