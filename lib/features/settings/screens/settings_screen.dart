import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/app_state.dart';
import '../../auth/screens/pin_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ustawienia'),
      ),
      body: ListView(
        children: [
          _buildProfileSection(appState),
          const SizedBox(height: 20),
          _buildSection(
            title: 'Bezpieczeństwo',
            children: [
              _buildSettingTile(
                icon: Icons.lock_outline,
                title: 'PIN aplikacji',
                subtitle: 'Zmień kod PIN',
                onTap: () => _showChangePinDialog(),
              ),
              _buildSettingTile(
                icon: Icons.fingerprint,
                title: 'Odblokowanie biometryczne',
                trailing: Switch(
                  value: false,
                  onChanged: (value) {},
                  activeColor: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          _buildSection(
            title: 'Wygląd',
            children: [
              _buildSettingTile(
                icon: Icons.dark_mode,
                title: 'Tryb ciemny',
                trailing: Switch(
                  value: appState.isDarkMode,
                  onChanged: (value) => appState.toggleTheme(),
                  activeColor: AppTheme.primaryColor,
                ),
              ),
              _buildSettingTile(
                icon: Icons.wallpaper,
                title: 'Tło czatu',
                subtitle: appState.chatBackground,
                onTap: () => _showChatBackgroundPicker(appState),
              ),
            ],
          ),
          _buildSection(
            title: 'Powiadomienia',
            children: [
              _buildSettingTile(
                icon: Icons.notifications,
                title: 'Powiadomienia',
                trailing: Switch(
                  value: true,
                  onChanged: (value) {},
                  activeColor: AppTheme.primaryColor,
                ),
              ),
              _buildSettingTile(
                icon: Icons.alarm,
                title: 'Przypomnienia',
                subtitle: 'Ustaw przypomnienia',
                onTap: () {},
              ),
            ],
          ),
          _buildSection(
            title: 'Relacja',
            children: [
              _buildSettingTile(
                icon: Icons.mood,
                title: 'Nastrój',
                subtitle: appState.currentUser?.mood ?? 'Ustaw swój nastrój',
                onTap: () => _showMoodPicker(appState),
              ),
              _buildSettingTile(
                icon: Icons.celebration,
                title: 'Rocznica',
                subtitle: appState.currentUser?.togetherSince != null
                    ? _formatAnniversary(appState.currentUser!.togetherSince!)
                    : 'Ustaw datę',
                onTap: () {},
              ),
            ],
          ),
          _buildSection(
            title: 'Sieć',
            children: [
              _buildSettingTile(
                icon: Icons.wifi,
                title: 'Preferowany tryb',
                subtitle: 'Internet (WiFi/Dane)',
                onTap: () => _showNetworkModePicker(),
              ),
              _buildSettingTile(
                icon: Icons.sms,
                title: 'Tryb SMS fallback',
                subtitle: 'Gdy brak internetu',
                trailing: Switch(
                  value: false,
                  onChanged: (value) {},
                  activeColor: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          _buildSection(
            title: 'Gry i zabawa',
            children: [
              _buildSettingTile(
                icon: Icons.games,
                title: 'Gry',
                subtitle: 'Gra w kółko i krzyżyk',
                onTap: () => _showGameSelector(),
              ),
              _buildSettingTile(
                icon: Icons.music_note,
                title: 'Wspólna muzyka',
                subtitle: 'Synchronizowane odtwarzanie',
                onTap: () {},
              ),
            ],
          ),
          _buildSection(
            title: 'Inne',
            children: [
              _buildSettingTile(
                icon: Icons.info_outline,
                title: 'O aplikacji',
                subtitle: 'Wersja ${AppConstants.appVersion}',
                onTap: () => _showAboutDialog(),
              ),
              _buildSettingTile(
                icon: Icons.help_outline,
                title: 'Pomoc',
                onTap: () {},
              ),
              _buildSettingTile(
                icon: Icons.logout,
                title: 'Wyloguj',
                subtitle: 'Wyloguj się z aplikacji',
                titleColor: Colors.red,
                onTap: () => _showLogoutConfirmation(appState),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProfileSection(AppState appState) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
            child: const Icon(
              Icons.person,
              size: 40,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appState.currentUser?.nickname ?? 'Użytkownik',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.favorite, size: 16, color: Colors.red.shade400),
                    const SizedBox(width: 4),
                    Text(
                      appState.currentUser?.daysTogether != null &&
                              appState.currentUser!.daysTogether > 0
                          ? 'Razem ${appState.currentUser!.daysTogether} dni'
                          : 'Bez partnera',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      {required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? titleColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: titleColor ?? Colors.grey),
      title: Text(
        title,
        style: TextStyle(color: titleColor),
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showChangePinDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text('Zmiana PIN', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Wpisz nowy 4-cyfrowy PIN',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const PinScreen(isSetup: true)),
                );
              },
              child: const Text('Zmień PIN'),
            ),
          ],
        ),
      ),
    );
  }

  void _showChatBackgroundPicker(AppState appState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Wybierz tło czatu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: AppConstants.chatBackgrounds.map((bg) {
                  final isSelected = appState.chatBackground == bg;
                  return GestureDetector(
                    onTap: () {
                      appState.setChatBackground(bg);
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryColor
                              : Colors.transparent,
                          width: 3,
                        ),
                        gradient: _getBackgroundGradient(bg),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  LinearGradient _getBackgroundGradient(String bg) {
    switch (bg) {
      case 'hearts':
        return LinearGradient(
            colors: [Colors.pink.shade300, Colors.pink.shade100]);
      case 'stars':
        return const LinearGradient(colors: [Colors.indigo, Colors.purple]);
      case 'gradient_pink':
        return LinearGradient(
            colors: [AppTheme.primaryColor, AppTheme.secondaryColor]);
      case 'gradient_purple':
        return const LinearGradient(colors: [Colors.purple, Colors.indigo]);
      case 'gradient_blue':
        return const LinearGradient(colors: [Colors.blue, Colors.cyan]);
      default:
        return const LinearGradient(
            colors: [Color(0xFF1A1A2E), Color(0xFF252540)]);
    }
  }

  void _showMoodPicker(AppState appState) {
    final moods = [
      '❤️ Szczęśliwy',
      '😢 Smutny',
      '😡 Zły',
      '😴 Zmęczony',
      '😊 Spokojny',
      '🥰 Zakochany'
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Jak się czujesz?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: moods.map((mood) {
                  return GestureDetector(
                    onTap: () {
                      appState.setMood(mood);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(mood,
                          style: const TextStyle(color: Colors.white)),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNetworkModePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Preferowany tryb połączenia',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.wifi, color: AppTheme.primaryColor),
                title: const Text('Internet (WiFi/Dane)',
                    style: TextStyle(color: Colors.white)),
                trailing: const Icon(Icons.check, color: AppTheme.primaryColor),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading:
                    const Icon(Icons.signal_cellular_alt, color: Colors.grey),
                title: const Text('Sieć komórkowa (SMS)',
                    style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showGameSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Wybierz grę',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      const Icon(Icons.grid_3x3, color: AppTheme.primaryColor),
                ),
                title: const Text('Kółko i krzyżyk',
                    style: TextStyle(color: Colors.white)),
                subtitle: const Text('Klasyczna gra dla dwóch osób',
                    style: TextStyle(color: Colors.white54)),
                onTap: () {
                  Navigator.pop(context);
                  _startTicTacToe();
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.quiz, color: Colors.orange),
                ),
                title: const Text('Quiz par',
                    style: TextStyle(color: Colors.white)),
                subtitle: const Text('Pytania dla dwojga',
                    style: TextStyle(color: Colors.white54)),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startTicTacToe() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TicTacToeScreen()),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Row(
          children: [
            Icon(Icons.favorite, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text('PairLove', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Wersja: 1.0.0', style: TextStyle(color: Colors.white70)),
            SizedBox(height: 8),
            Text(
              'Twoja prywatna aplikacja dla par z pełnym szyfrowaniem.',
              style: TextStyle(color: Colors.white54),
            ),
            SizedBox(height: 16),
            Text(
              '❤️ Zrobione z miłością',
              style: TextStyle(color: AppTheme.primaryColor),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(AppState appState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text('Wylogowanie', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Czy na pewno chcesz się wylogować?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anuluj'),
          ),
          TextButton(
            onPressed: () async {
              await appState.logout();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Wyloguj', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatAnniversary(DateTime date) {
    final diff = DateTime.now().difference(date);
    return '${diff.inDays} dni razem';
  }
}

class TicTacToeScreen extends StatefulWidget {
  const TicTacToeScreen({super.key});

  @override
  State<TicTacToeScreen> createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen> {
  List<String> _board = List.filled(9, '');
  String _currentPlayer = 'X';
  String? _winner;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kółko i krzyżyk'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            _winner != null
                ? 'Wygrał $_winner!'
                : 'Ruch gracza: $_currentPlayer',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Center(
              child: SizedBox(
                width: 300,
                height: 300,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: 9,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _makeMove(index),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceDark,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            _board[index],
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          if (_winner != null || !_board.contains(''))
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: _resetGame,
                child: const Text('Nowa gra'),
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _makeMove(int index) {
    if (_board[index].isNotEmpty || _winner != null) return;

    setState(() {
      _board[index] = _currentPlayer;
      _checkWinner();
      if (_winner == null) {
        _currentPlayer = _currentPlayer == 'X' ? 'O' : 'X';
      }
    });
  }

  void _checkWinner() {
    const winPatterns = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (final pattern in winPatterns) {
      final a = pattern[0], b = pattern[1], c = pattern[2];
      if (_board[a].isNotEmpty &&
          _board[a] == _board[b] &&
          _board[a] == _board[c]) {
        _winner = _board[a];
        return;
      }
    }

    if (!_board.contains('')) {
      _winner = 'Remis';
    }
  }

  void _resetGame() {
    setState(() {
      _board = List.filled(9, '');
      _currentPlayer = 'X';
      _winner = null;
    });
  }
}
