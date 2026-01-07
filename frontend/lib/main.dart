import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'api_service.dart';
import 'login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Konkor Rank Estimator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F7FB),
      ),
      home: const LoginPage(),
    );
  }
}

class RankEstimatorPage extends StatefulWidget {
  const RankEstimatorPage({super.key});

  @override
  State<RankEstimatorPage> createState() => _RankEstimatorPageState();
}

class _RankEstimatorPageState extends State<RankEstimatorPage> {
  final List<String> _topics = const [
    'Mathematics',
    'English',
    'Specialized Courses 1',
    'Specialized Courses 2',
    'Specialized Courses 3',
    'Specialized Courses 4',
    'Quota',
    'Effective GPA',
  ];

  static const _quotaOptions = [0, 5, 25];

  late final Map<String, TextEditingController> _controllers;
  bool _hasResult = false;
  bool _isLoading = false;
  Map<String, int>? _predictions;

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final topic in _topics) topic: TextEditingController(),
    };
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _recalculate() async {
    // Validate inputs with topic-specific rules
    final values = <String, double>{};

    for (final entry in _controllers.entries) {
      final topic = entry.key;
      final raw = entry.value.text.trim();
      final parsed = double.tryParse(raw);

      if (parsed == null) {
        _showError('Enter a valid number for $topic.');
        return;
      }

      if (topic == 'Quota') {
        final intValue = parsed.toInt();
        if (!_quotaOptions.contains(intValue)) {
          _showError('Quota must be 0, 5, or 25.');
          return;
        }
        values[topic] = intValue.toDouble();
        continue;
      }

      if (topic == 'Effective GPA') {
        if (parsed < 0 || parsed > 20) {
          _showError('Effective GPA must be between 0 and 20.');
          return;
        }
        values[topic] = parsed;
        continue;
      }

      if (parsed < 0 || parsed > 100) {
        _showError('$topic must be between 0 and 100.');
        return;
      }
      values[topic] = parsed;
    }

    // Set loading state
    setState(() {
      _isLoading = true;
      _hasResult = false;
    });

    try {
      print('Starting API call...');
      // Call API
      final response = await ApiService.predictRank(
        quota: values['Quota']!.toInt(),
        effectiveGPA: values['Effective GPA']!,
        mathematics: values['Mathematics']!,
        english: values['English']!,
        specialized1: values['Specialized Courses 1']!,
        specialized2: values['Specialized Courses 2']!,
        specialized3: values['Specialized Courses 3']!,
        specialized4: values['Specialized Courses 4']!,
      );

      // Extract predictions
      final predictions = Map<String, int>.from(
        response['predictions'] as Map<String, dynamic>,
      );

      setState(() {
        _isLoading = false;
        _hasResult = true;
        _predictions = predictions;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasResult = false;
        _predictions = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFB9D9FF), // light sky blue at top
              Color(0xFFA8D0FF), // slightly darker at bottom
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Cs Konkor Rank Prediction',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    _RankCard(
                      hasResult: _hasResult,
                      isLoading: _isLoading,
                      predictions: _predictions,
                    ),
                    const SizedBox(height: 6),
                    ..._topics.map(
                      (topic) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: _buildInput(topic),
                      ),
                    ),
                    const SizedBox(height: 6),
                    SafeArea(
                      top: false,
                      bottom: false,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF78B9FF), // light blue
                              Color(0xFF3F7BFF), // deeper blue
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.14),
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: TextButton.icon(
                          onPressed: _isLoading ? null : _recalculate,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.refresh, color: Colors.white),
                          label: Text(
                            _isLoading ? 'Calculating...' : 'Calculate Rank',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  Widget _buildInput(String topic) {
    return _TopicInput(
      label: topic,
      controller: _controllers[topic]!,
      onChanged: (_) {},
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: false,
      ),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
    );
  }
}

class _RankCard extends StatelessWidget {
  const _RankCard({
    required this.hasResult,
    required this.isLoading,
    this.predictions,
  });

  final bool hasResult;
  final bool isLoading;
  final Map<String, int>? predictions;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 8,
              childAspectRatio: 2.0,
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              final icons = [
                Icons.psychology, // AI icon
                Icons.code, // Programming/web dev icon
                Icons.computer, // Computer icon
                Icons.cloud, // Cloud/network icon
              ];

              // Get rank if available
              int? rank;
              if (hasResult && predictions != null && predictions!.isNotEmpty) {
                final entry = predictions!.entries.elementAt(index);
                rank = entry.value;
              }

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF6B9FE8), // Lighter blue
                      Color(0xFF5A8FD8), // Medium blue
                      Color(0xFF4A7BC8), // Darker blue
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: const [0.0, 0.5, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.7),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(icons[index], color: Colors.white, size: 18),
                    const SizedBox(height: 4),
                    Text(
                      'Subgroup ${index + 1}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 3),
                    if (rank != null)
                      Text(
                        'Rank $rank',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      )
                    else
                      const Text(
                        '---',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TopicInput extends StatelessWidget {
  const _TopicInput({
    required this.label,
    required this.controller,
    required this.onChanged,
    this.keyboardType,
    this.inputFormatters,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withOpacity(0.4),
        border: Border.all(color: Colors.white.withOpacity(0.35), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3A3A3A),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 120,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            alignment: Alignment.center,
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textAlign: TextAlign.center,
              keyboardType:
                  keyboardType ??
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: inputFormatters,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: '0',
                hintStyle: TextStyle(
                  color: Color(0xFF9BA5B5),
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: const TextStyle(
                color: Color(0xFF3A3A3A),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
