import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';

class PinScreen extends StatefulWidget {
  final bool isSetup;
  
  const PinScreen({super.key, this.isSetup = false});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> with SingleTickerProviderStateMixin {
  final List<String> _pin = [];
  final int _pinLength = 4;
  bool _isError = false;
  String _errorMessage = '';
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  String? _firstPin;
  bool _isConfirming = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 24).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onKeyPressed(String key) {
    HapticFeedback.lightImpact();
    
    if (_pin.length < _pinLength) {
      setState(() {
        _pin.add(key);
        _isError = false;
      });

      if (_pin.length == _pinLength) {
        _handlePinComplete();
      }
    }
  }

  void _onBackspace() {
    HapticFeedback.lightImpact();
    if (_pin.isNotEmpty) {
      setState(() {
        _pin.removeLast();
      });
    }
  }

  Future<void> _handlePinComplete() async {
    final appState = context.read<dynamic>();
    final enteredPin = _pin.join();

    if (widget.isSetup) {
      if (!_isConfirming) {
        setState(() {
          _firstPin = enteredPin;
          _isConfirming = true;
          _pin.clear();
        });
      } else {
        if (enteredPin == _firstPin) {
          await appState.setupPin(enteredPin);
        } else {
          setState(() {
            _isError = true;
            _errorMessage = 'PINy nie są identyczne';
            _pin.clear();
            _isConfirming = false;
            _firstPin = null;
          });
          _shakeController.forward().then((_) => _shakeController.reset());
        }
      }
    } else {
      final isValid = await appState.verifyPin(enteredPin);
      if (!isValid) {
        setState(() {
          _isError = true;
          _errorMessage = appState.failedAttempts >= 5 
              ? 'Zbyt wiele prób. Poczekaj 5 min' 
              : 'Nieprawidłowy PIN';
          _pin.clear();
        });
        _shakeController.forward().then((_) => _shakeController.reset());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryColor.withOpacity(0.8),
              AppTheme.darkBackground,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              Icon(
                widget.isSetup ? Icons.lock_outline : Icons.favorite,
                size: 60,
                color: Colors.white,
              ),
              const SizedBox(height: 24),
              Text(
                widget.isSetup 
                    ? (_isConfirming ? 'Powtórz PIN' : 'Ustaw PIN')
                    : 'Wprowadź PIN',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isError ? _errorMessage : 'Wprowadź 4 cyfry',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _isError ? Colors.red.shade300 : Colors.white70,
                ),
              ),
              const SizedBox(height: 40),
              AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      _isError 
                          ? _shakeAnimation.value * ((_shakeController.value * 10).toInt() % 2 == 0 ? 1 : -1)
                          : 0,
                      0,
                    ),
                    child: child,
                  );
                },
                child: _buildPinDots(),
              ),
              const Spacer(),
              _buildKeypad(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pinLength, (index) {
        final isFilled = index < _pin.length;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? Colors.white : Colors.transparent,
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildKeypad() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKey('1'),
              _buildKey('2'),
              _buildKey('3'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKey('4'),
              _buildKey('5'),
              _buildKey('6'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKey('7'),
              _buildKey('8'),
              _buildKey('9'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 72, height: 72),
              _buildKey('0'),
              _buildBackspaceKey(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String key) {
    return GestureDetector(
      onTap: () => _onKeyPressed(key),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.15),
        ),
        child: Center(
          child: Text(
            key,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceKey() {
    return GestureDetector(
      onTap: _onBackspace,
      child: Container(
        width: 72,
        height: 72,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(
            Icons.backspace_outlined,
            size: 28,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}