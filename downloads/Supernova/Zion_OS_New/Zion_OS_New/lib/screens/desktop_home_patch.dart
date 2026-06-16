  Widget _buildAppCard(Map<String, dynamic> app, double containerSize, double iconSize) {
    return GestureDetector(
      onTap: () => _openAppAsFloating(app),
      onLongPress: () => _openAppAsFullscreen(app),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.02)],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: containerSize,
              height: containerSize,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: IconMapper.getIcon(app['name'], size: iconSize),
            ),
            const SizedBox(height: 8),
            Text(
              app['name'],
              style: GoogleFonts.orbitron(
                color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
