import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/audio_recorder_service.dart';
import '../../services/tflite_analyzer_service.dart';
import '../../constants.dart';
import 'dart:math' as math;

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> with TickerProviderStateMixin {
  final AudioRecorderService _recorderService = AudioRecorderService();
  final TfliteAnalyzerService _analyzerService = TfliteAnalyzerService();
  
  bool _isRecording = false;
  bool _isAnalyzing = false;
  Map<String, double>? _results;
  String _statusMessage = "Aguardando gravação";
  
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _analyzerService.initialize();
    
    // Animation for recording pulse
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _recorderService.dispose();
    _analyzerService.dispose();
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  Future<void> _handleAction() async {
    if (!_isRecording && !_isAnalyzing) {
      // Start Recording
      bool hasPermission = await _recorderService.requestPermissions();
      if (!hasPermission) {
        setState(() => _statusMessage = "Permissão de microfone negada");
        return;
      }

      final path = await _recorderService.getTempPath();
      setState(() {
        _isRecording = true;
        _statusMessage = "Gravando...";
        _results = null;
      });

      await _recorderService.startRecording(path);
      
      // Auto-stop after 5 seconds
      Future.delayed(const Duration(seconds: 5), () => _stopAndAnalyze());
    } else if (_isRecording) {
      // Stop recording manually
      await _stopAndAnalyze();
    }
  }

  Future<void> _stopAndAnalyze() async {
    if (!_isRecording) return;

    final path = await _recorderService.stopRecording();
    setState(() {
      _isRecording = false;
      _isAnalyzing = true;
      _statusMessage = "Analisando padrões acústicos...";
    });

    if (path != null) {
      try {
        final results = await _analyzerService.analyze(path);
        setState(() {
          _results = results;
          _isAnalyzing = false;
          _statusMessage = "Análise concluída";
        });
      } catch (e) {
        setState(() {
          _isAnalyzing = false;
          _statusMessage = "Erro na análise: $e";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              kBackgroundGradientStart,
              kBackgroundGradientEnd,
              kClinicalWhite,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: kDefaultPaddin),
            child: Column(
              children: [
                const SizedBox(height: 12),
                
                // AppBar customizado
                _buildCustomAppBar(),
                
                const SizedBox(height: 8),
                
                // Visualizer 3D
                _buildVisualizer(),
                
                const SizedBox(height: 10),
                
                // Status Message
                _buildStatusMessage(),
                
                const SizedBox(height: 8),
                
                // Results or Empty State - Flexible para ocupar espaço disponível
                Expanded(
                  child: _results != null
                      ? SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: _buildResultsSection(),
                        )
                      : (!_isRecording && !_isAnalyzing)
                          ? _buildEmptyState()
                          : const SizedBox.shrink(),
                ),
                
                const SizedBox(height: 8),
                
                // Action Button 3D
                _buildActionButton(),
                
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: kBackgroundWhite,
            borderRadius: BorderRadius.circular(12),
            boxShadow: getSubtleElevation3D(kMedicalBlue),
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded, color: kTextColor, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }

  Widget _buildVisualizer() {
    if (_isRecording) {
      return AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    kPneumoniaColor.withOpacity(0.35),
                    kPneumoniaColor.withOpacity(0.15),
                    kPneumoniaColor.withOpacity(0.08),
                    kPneumoniaColor.withOpacity(0.03),
                  ],
                  stops: const [0.0, 0.4, 0.7, 1.0],
                ),
                boxShadow: getDeepElevation3D(kPneumoniaColor),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Animated waves with 3D depth
                  ...List.generate(4, (index) {
                    return AnimatedBuilder(
                      animation: _waveController,
                      builder: (context, child) {
                        final waveValue = _waveController.value;
                        final scale = 1.0 + (index * 0.12) + (math.sin(waveValue * 2 * math.pi + index) * 0.08);
                        final opacity = 0.4 - (index * 0.08);
                        return Transform.scale(
                          scale: scale,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: kPneumoniaColor.withOpacity(opacity),
                                width: 2.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: kPneumoniaColor.withOpacity(opacity * 0.5),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }),
                  // Microphone icon with 3D effect
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          kPneumoniaColor.withOpacity(0.25),
                          kPneumoniaColor.withOpacity(0.15),
                        ],
                      ),
                      boxShadow: getElevation3D(kPneumoniaColor, intensity: 1.5),
                    ),
                    child: Icon(
                      Icons.mic_rounded,
                      size: 36,
                      color: kPneumoniaColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else if (_isAnalyzing) {
      return Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              kMedicalGreen.withOpacity(0.2),
              kMedicalGreen.withOpacity(0.1),
              kMedicalGreen.withOpacity(0.05),
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
          boxShadow: getElevation3D(kMedicalGreen, intensity: 1.2),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 110,
              height: 110,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(kMedicalGreen),
                strokeWidth: 3,
                backgroundColor: kMedicalGreen.withOpacity(0.1),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    kMedicalGreen.withOpacity(0.15),
                    kMedicalGreen.withOpacity(0.08),
                  ],
                ),
              ),
              child: Icon(
                Icons.auto_graph_rounded,
                size: 28,
                color: kMedicalGreen,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              kMedicalBlue.withOpacity(0.18),
              kMedicalBlueLight.withOpacity(0.12),
              kMedicalBlue.withOpacity(0.06),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
          boxShadow: getElevation3D(kMedicalBlue, intensity: 1.0),
        ),
        child: Icon(
          Icons.record_voice_over_rounded,
          size: 48,
          color: kMedicalBlue,
        ),
      );
    }
  }

  Widget _buildStatusMessage() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey(_statusMessage),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _getStatusColor().withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _getStatusColor().withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Text(
          _statusMessage,
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _getStatusColor(),
            letterSpacing: 0.3,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Color _getStatusColor() {
    if (_isRecording) return kPneumoniaColor;
    if (_isAnalyzing) return kMedicalGreen;
    return kMedicalBlue;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  kMedicalBlue.withOpacity(0.08),
                  kMedicalBlueLight.withOpacity(0.04),
                ],
              ),
            ),
            child: Icon(
              Icons.analytics_outlined,
              size: 40,
              color: kMedicalBlue.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Resultados aparecerão aqui",
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: kTextColor,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Inicie uma gravação para ver os resultados",
            style: GoogleFonts.varelaRound(
              fontSize: 12,
              color: kTextLightColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header compacto
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: kMedicalGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: kMedicalGreen,
                    size: 14,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  "Análise Concluída",
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: kTextColor,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                color: kMedicalBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: IconButton(
                icon: const Icon(Icons.refresh_rounded, size: 16),
                onPressed: () {
                  setState(() {
                    _results = null;
                    _statusMessage = "Aguardando gravação";
                  });
                },
                color: kMedicalBlue,
                iconSize: 16,
                padding: const EdgeInsets.all(6),
                constraints: const BoxConstraints(),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Main Result Card compacto
        _buildMainResultCard(),
        
        const SizedBox(height: 8),
        
        // Probability Cards compactos
        _buildProbabilityCards(),
        
        const SizedBox(height: 8),
        
        // Descriptive Message simplificada
        _buildDescriptiveMessage(),
      ],
    );
  }

  Widget _buildMainResultCard() {
    final bronquite = _results!['Bronquite'] ?? 0;
    final pneumonia = _results!['Pneumonia'] ?? 0;
    final normal = _results!['Normal'] ?? 0;
    
    // Find the class with highest probability
    final Map<String, double> allResults = {
      'Bronquite': bronquite,
      'Pneumonia': pneumonia,
      if (normal > 0) 'Normal': normal,
    };
    
    final sortedEntries = allResults.entries.toList();
    sortedEntries.sort((a, b) => b.value.compareTo(a.value));
    
    final topResult = sortedEntries.first;
    final predictedClass = topResult.key;
    final confidence = topResult.value;
    
    // Determine color and icon based on predicted class
    final Color classColor;
    final IconData icon;
    
    switch (predictedClass) {
      case 'Normal':
        classColor = kNormalColor;
        icon = Icons.check_circle;
        break;
      case 'Bronquite':
        classColor = kBronquiteColor;
        icon = Icons.air;
        break;
      case 'Pneumonia':
      default:
        classColor = kPneumoniaColor;
        icon = Icons.health_and_safety;
        break;
    }
    
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: kAnimationDurationSlow,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    classColor.withOpacity(0.2),
                    classColor.withOpacity(0.1),
                    classColor.withOpacity(0.05),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: classColor.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: getElevation3D(classColor, intensity: 0.8),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          classColor.withOpacity(0.3),
                          classColor.withOpacity(0.15),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: getElevation3D(classColor, intensity: 0.6),
                    ),
                    child: Icon(icon, color: classColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Diagnóstico",
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            color: kTextLightColor,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          predictedClass.toUpperCase(),
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: classColor,
                            letterSpacing: 0.8,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 2),
                        _AnimatedPercentage(
                          value: confidence,
                          color: classColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProbabilityCards() {
    final hasNormal = _results!.containsKey('Normal');
    
    if (hasNormal) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildCompactProbabilityCard(
                  "Bronquite",
                  _results!['Bronquite'] ?? 0,
                  kBronquiteColor,
                  Icons.air,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCompactProbabilityCard(
                  "Pneumonia",
                  _results!['Pneumonia'] ?? 0,
                  kPneumoniaColor,
                  Icons.health_and_safety,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildCompactProbabilityCard(
                  "Normal",
                  _results!['Normal'] ?? 0,
                  kNormalColor,
                  Icons.check_circle,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: _buildCompactProbabilityCard(
              "Bronquite",
              _results!['Bronquite'] ?? 0,
              kBronquiteColor,
              Icons.air,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildCompactProbabilityCard(
              "Pneumonia",
              _results!['Pneumonia'] ?? 0,
              kPneumoniaColor,
              Icons.health_and_safety,
            ),
          ),
        ],
      );
    }
  }

  Widget _buildCompactProbabilityCard(String title, double probability, Color color, IconData icon) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: kAnimationDurationSlow,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(20 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: kCardBackground,
                borderRadius: BorderRadius.circular(kCardRadius),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    kCardBackground,
                    kCardBackground.withOpacity(0.95),
                  ],
                ),
                border: Border.all(
                  color: color.withOpacity(0.25),
                  width: 2,
                ),
                boxShadow: getElevation3D(color, intensity: 0.6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(icon, color: color, size: 14),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: kTextColor,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _AnimatedPercentage(
                    value: probability,
                    color: color,
                    fontSize: 18,
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.15),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: LinearProgressIndicator(
                        value: probability * value,
                        backgroundColor: color.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDescriptiveMessage() {
    final bronquite = _results!['Bronquite'] ?? 0;
    final pneumonia = _results!['Pneumonia'] ?? 0;
    final normal = _results!['Normal'] ?? 0;
    final hasNormal = _results!.containsKey('Normal');
    
    final conditions = <MapEntry<String, double>>[
      MapEntry('Bronquite', bronquite),
      MapEntry('Pneumonia', pneumonia),
      if (hasNormal) MapEntry('Normal', normal),
    ];
    conditions.sort((a, b) => b.value.compareTo(a.value));
    
    final mainCondition = conditions[0].key;
    final mainProbability = conditions[0].value;
    final secondaryCondition = conditions[1].key;
    final secondaryProbability = conditions[1].value;
    final thirdCondition = hasNormal && conditions.length > 2 ? conditions[2].key : null;
    final thirdProbability = hasNormal && conditions.length > 2 ? conditions[2].value : null;
    
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            kMedicalBlue.withOpacity(0.08),
            kMedicalBlueLight.withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: kMedicalBlue.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: kMedicalBlue.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: kMedicalBlue, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  "Interpretação",
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: kTextColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            hasNormal && thirdCondition != null
                ? "Probabilidade mais elevada: ${mainCondition.toLowerCase()} (${(mainProbability * 100).toStringAsFixed(1)}%). ${secondaryCondition}: ${(secondaryProbability * 100).toStringAsFixed(1)}%. ${thirdCondition}: ${(thirdProbability! * 100).toStringAsFixed(1)}%."
                : "Probabilidade mais elevada: ${mainCondition.toLowerCase()} (${(mainProbability * 100).toStringAsFixed(1)}%). ${secondaryCondition}: ${(secondaryProbability * 100).toStringAsFixed(1)}%.",
            style: GoogleFonts.varelaRound(
              fontSize: 10,
              color: kTextColor,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.08),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: Colors.amber.withOpacity(0.25),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.amber[700], size: 12),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    "Análise preliminar. Consulte um profissional de saúde.",
                    style: GoogleFonts.varelaRound(
                      fontSize: 9,
                      color: Colors.amber[900],
                      height: 1.2,
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

  Widget _buildActionButton() {
    final buttonColor = _isRecording ? kPneumoniaColor : kMedicalBlue;
    
    return _Button3DAnalysis(
      onTap: _isAnalyzing ? null : _handleAction,
      isRecording: _isRecording,
      isAnalyzing: _isAnalyzing,
      color: buttonColor,
    );
  }
}

// Animated Percentage Widget
class _AnimatedPercentage extends StatefulWidget {
  final double value;
  final Color color;
  final double fontSize;

  const _AnimatedPercentage({
    required this.value,
    required this.color,
    this.fontSize = 15,
  });

  @override
  State<_AnimatedPercentage> createState() => _AnimatedPercentageState();
}

class _AnimatedPercentageState extends State<_AnimatedPercentage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: kAnimationDurationSlow,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(_AnimatedPercentage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = Tween<double>(begin: oldWidget.value, end: widget.value).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final percentage = (_animation.value * 100);
        return Text(
          widget.fontSize == 15
              ? "${percentage.toStringAsFixed(1)}% de confiança"
              : "${percentage.toStringAsFixed(1)}%",
          style: GoogleFonts.outfit(
            fontSize: widget.fontSize == 15 ? 12 : widget.fontSize,
            fontWeight: widget.fontSize == 15 ? FontWeight.w500 : FontWeight.bold,
            color: widget.fontSize == 15 ? kTextColor : widget.color,
            height: 1.0,
          ),
        );
      },
    );
  }
}

// 3D Button for Analysis Screen
class _Button3DAnalysis extends StatefulWidget {
  final VoidCallback? onTap;
  final bool isRecording;
  final bool isAnalyzing;
  final Color color;

  const _Button3DAnalysis({
    required this.onTap,
    required this.isRecording,
    required this.isAnalyzing,
    required this.color,
  });

  @override
  State<_Button3DAnalysis> createState() => _Button3DAnalysisState();
}

class _Button3DAnalysisState extends State<_Button3DAnalysis> with SingleTickerProviderStateMixin {
  late AnimationController _pressController;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: kAnimationDurationFast,
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) {
        _pressController.forward();
      } : null,
      onTapUp: widget.onTap != null ? (_) {
        _pressController.reverse();
        widget.onTap?.call();
      } : null,
      onTapCancel: widget.onTap != null ? () {
        _pressController.reverse();
      } : null,
      child: AnimatedBuilder(
        animation: _pressController,
        builder: (context, child) {
          final scale = 1.0 - (_pressController.value * 0.05);
          final elevation = 1.0 - (_pressController.value * 0.3);
          
          return Transform.scale(
            scale: scale,
              child: Container(
                width: double.infinity,
                height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(kButtonRadius),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.isRecording
                      ? [
                          kPneumoniaColor,
                          kPneumoniaColor.withOpacity(0.85),
                        ]
                      : [
                          kMedicalBlue,
                          kMedicalBlueDark,
                        ],
                ),
                boxShadow: getDeepElevation3D(widget.color).map((shadow) {
                  return BoxShadow(
                    color: shadow.color,
                    blurRadius: shadow.blurRadius * elevation,
                    offset: Offset(shadow.offset.dx, shadow.offset.dy * elevation),
                    spreadRadius: shadow.spreadRadius,
                  );
                }).toList(),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  borderRadius: BorderRadius.circular(kButtonRadius),
                  splashColor: Colors.white.withOpacity(0.2),
                  highlightColor: Colors.white.withOpacity(0.1),
                  child: Container(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.isRecording) ...[
                          Container(
                            width: 12,
                            height: 12,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ] else if (!widget.isAnalyzing) ...[
                          Icon(
                            Icons.mic_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                          const SizedBox(width: 14),
                        ],
                        Text(
                          widget.isRecording
                              ? "Parar Gravação"
                              : (widget.isAnalyzing ? "Analisando..." : "Iniciar Gravação"),
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
