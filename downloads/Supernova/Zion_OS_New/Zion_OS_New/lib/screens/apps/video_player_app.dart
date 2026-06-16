import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VideoPlayerApp extends StatefulWidget {
  const VideoPlayerApp({super.key});

  @override
  State<VideoPlayerApp> createState() => _VideoPlayerAppState();
}

class _VideoPlayerAppState extends State<VideoPlayerApp> {
  int _selectedVideoIndex = 0;

  final List<Map<String, dynamic>> _videos = [
    {'name': 'Sample Video 1', 'duration': '0:30', 'size': '2.5 MB', 'url': 'https://sample.com/video1.mp4'},
    {'name': 'Sample Video 2', 'duration': '0:45', 'size': '3.2 MB', 'url': 'https://sample.com/video2.mp4'},
    {'name': 'Sample Video 3', 'duration': '0:25', 'size': '1.8 MB', 'url': 'https://sample.com/video3.mp4'},
  ];

  void _playVideo(String url) {
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('URL copied to clipboard. Open in external player.'), backgroundColor: Color(0xFF00BCD4)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Video Player', style: TextStyle(color: Color(0xFF00BCD4))),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00BCD4)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 200,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF00BCD4), Color(0xFF006064)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Icon(Icons.play_circle_filled, size: 64, color: Colors.white),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _videos.length,
              itemBuilder: (ctx, i) {
                final video = _videos[i];
                final isSelected = _selectedVideoIndex == i;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF00BCD4).withOpacity(0.2) : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? const Color(0xFF00BCD4) : const Color(0xFF00BCD4).withOpacity(0.3)),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.play_circle_filled, color: Color(0xFF00BCD4), size: 32),
                    title: Text(video['name'], style: const TextStyle(color: Colors.white)),
                    subtitle: Text('${video['duration']} • ${video['size']}', style: const TextStyle(color: Colors.white54)),
                    trailing: IconButton(
                      icon: const Icon(Icons.play_arrow, color: Color(0xFF00BCD4)),
                      onPressed: () {
                        setState(() => _selectedVideoIndex = i);
                        _playVideo(video['url']);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
