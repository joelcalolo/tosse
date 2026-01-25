import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:fftea/fftea.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class TfliteAnalyzerService {
  Interpreter? _interpreter;
  
  // Vetor de temperatura para calibração diferenciada por classe
  // Pneumonia (T=2.0): Modelo é muito bom (AUC 0.93), permitimos mais certeza
  // Bronquite e Normal (T=5.0): Há confusão entre estas classes, calibração agressiva
  // Ordem: [Pneumonia, Bronquite, Normal]
  static const List<double> temperaturePerClass = [2.0, 5.0, 5.0];

  Future<void> initialize() async {
    // Use the new v2 model with 3 classes
    _interpreter = await Interpreter.fromAsset('assets/models/modelo_respiratorio_v2.tflite');
  }

  Future<Map<String, double>> analyze(String filePath) async {
    if (_interpreter == null) await initialize();

    // 1. Read PCM data (assuming 16k mono 16bit)
    final bytes = await File(filePath).readAsBytes();
    final pcmData = _convertBytesToPcm(bytes);

    // 2. Pre-process: Create Mel Spectrogram (128x94)
    // The model expects 128 (mel bins) x 94 (time steps)
    // Note: This is an approximation of the Python librosa logic
    final input = _generateSpectrogram(pcmData, 128, 94);

    // 3. Normalize the spectrogram (IMPORTANT for model accuracy!)
    final normalizedInput = _normalizeSpectrogram(input);

    // 4. Prepare Input/Output
    // Input shape: [1, 128, 94, 1] or [1, 128, 94, 3] depending on the model adaptation mentioned in relatorio.md
    // relatorio.md line 42 says: "adaptar os nossos espectrogramas de 1 canal (escala de cinza) para os 3 canais esperados pela MobileNet"
    var inputExpanded = List.generate(1, (i) => 
      List.generate(128, (j) => 
        List.generate(94, (k) => 
          List.generate(3, (l) => normalizedInput[j][k])
        )
      )
    );

    // 5. Get output tensor shape to determine number of classes
    final outputTensor = _interpreter!.getOutputTensor(0);
    final numClasses = outputTensor.shape[1];
    
    // Create output buffer based on actual model output size
    var output = List.filled(1 * numClasses, 0.0).reshape([1, numClasses]);

    // 6. Run Inference
    _interpreter!.run(inputExpanded, output);

    // 7. Debug: Print raw output values (antes da calibração)
    print('DEBUG - Number of classes: $numClasses');
    print('DEBUG - Raw output (before calibration): ${output[0]}');
    print('DEBUG - Raw output values: [${output[0].map((v) => v.toStringAsFixed(4)).join(", ")}]');

    // 8. Aplicar calibração diferenciada com temperatura por classe
    // Tratamos as probabilidades do modelo como logits e aplicamos temperatura + softmax
    final rawOutput = List<double>.from(output[0]);
    final calibratedOutput = _applyTemperatureCalibration(rawOutput, numClasses);
    
    // Debug: Print valores calibrados
    if (numClasses == 3) {
      print('DEBUG - Temperature per class: [Pneumonia: ${temperaturePerClass[0]}, Bronquite: ${temperaturePerClass[1]}, Normal: ${temperaturePerClass[2]}]');
    }
    print('DEBUG - Calibrated output (after per-class temperature): ${calibratedOutput}');
    print('DEBUG - Calibrated values: [${calibratedOutput.map((v) => v.toStringAsFixed(4)).join(", ")}]');
    print('DEBUG - Sum of calibrated probabilities: ${calibratedOutput.reduce((a, b) => a + b).toStringAsFixed(4)}');
    
    // Substituir output[0] pelos valores calibrados
    for (int i = 0; i < numClasses; i++) {
      output[0][i] = calibratedOutput[i];
    }

    // 9. Return results based on number of classes
    // IMPORTANT: The order depends on how the model was trained!
    // Model v2 order: [Pneumonia, Bronquite, Normal] for 3 classes
    // Model order: [Pneumonia, Bronquite] for 2 classes
    // Index 0 = Pneumonia, Index 1 = Bronquite, Index 2 = Normal
    final results = <String, double>{};
    
    if (numClasses == 3) {
      // Three classes mapping
      // Model v2 was trained with: [Pneumonia, Bronquite, Normal]
      results['Pneumonia'] = output[0][0];  // Index 0 = Pneumonia
      results['Bronquite'] = output[0][1];  // Index 1 = Bronquite
      results['Normal'] = output[0][2];     // Index 2 = Normal
      print('DEBUG - Mapped results:');
      print('DEBUG - Pneumonia (index 0): ${output[0][0]} (${(output[0][0] * 100).toStringAsFixed(2)}%)');
      print('DEBUG - Bronquite (index 1): ${output[0][1]} (${(output[0][1] * 100).toStringAsFixed(2)}%)');
      print('DEBUG - Normal (index 2): ${output[0][2]} (${(output[0][2] * 100).toStringAsFixed(2)}%)');
      
      // Find max probability
      final maxIndex = output[0].indexOf(output[0].reduce((double a, double b) => a > b ? a : b));
      print('DEBUG - Max probability index: $maxIndex');
    } else if (numClasses == 2) {
      // Two classes mapping
      // Model was trained with: [Pneumonia, Bronquite]
      results['Pneumonia'] = output[0][0];  // Index 0 = Pneumonia
      results['Bronquite'] = output[0][1];  // Index 1 = Bronquite
      print('DEBUG - Mapped results:');
      print('DEBUG - Pneumonia (index 0): ${output[0][0]} (${(output[0][0] * 100).toStringAsFixed(2)}%)');
      print('DEBUG - Bronquite (index 1): ${output[0][1]} (${(output[0][1] * 100).toStringAsFixed(2)}%)');
      
      // Find max probability
      final maxIndex = output[0].indexOf(output[0].reduce((double a, double b) => a > b ? a : b));
      print('DEBUG - Max probability index: $maxIndex');
    } else {
      // Unknown number of classes - return as generic classes
      for (int i = 0; i < numClasses; i++) {
        results['Classe_$i'] = output[0][i];
        print('DEBUG - Classe_$i (index $i): ${output[0][i]}');
      }
    }

    return results;
  }

  List<double> _convertBytesToPcm(Uint8List bytes) {
    final pcm = <double>[];
    for (var i = 0; i < bytes.length; i += 2) {
      if (i + 1 < bytes.length) {
        final sample = bytes[i] | (bytes[i + 1] << 8);
        // Convert to signed 16-bit and normalize
        final signedSample = sample >= 32768 ? sample - 65536 : sample;
        pcm.add(signedSample / 32768.0);
      }
    }
    return pcm;
  }

  List<List<double>> _generateSpectrogram(List<double> pcm, int melBins, int timeSteps) {
    // Basic STFT + Mel scaling approximation
    // To match 94 steps from ~5-10s audio, we need appropriate window/hop
    int windowSize = 512;
    int hopSize = (pcm.length - windowSize) ~/ (timeSteps - 1);
    if (hopSize < 1) hopSize = 1;

    final spectrogram = List.generate(melBins, (_) => List.filled(timeSteps, 0.0));

    final stft = STFT(windowSize, Window.hanning(windowSize));

    int t = 0;
    // STFT.run now uses callback pattern
    stft.run(pcm, (Float64x2List freq) {
      if (t >= timeSteps) return;
      
      final magnitudes = freq.discardConjugates().magnitudes();

      // Log-Mel approximation: 
      // Mapping linear frequency bins to Mel bins
      for (int m = 0; m < melBins; m++) {
        // Simple linear-to-mel mapping (very simplified)
        int freqIdx = (m * magnitudes.length / melBins).floor();
        if (freqIdx < magnitudes.length) {
          double mag = magnitudes[freqIdx];
          spectrogram[m][t] = log(1 + mag); // Log scale
        }
      }
      t++;
    }, hopSize);

    return spectrogram;
  }

  /// Aplica calibração agressiva usando temperatura
  /// Trata as probabilidades do modelo como logits, divide por temperatura e recalcula softmax
  List<double> _applyTemperatureCalibration(List<double> rawOutput, int numClasses) {
    // Primeiro, convertemos probabilidades para logits (aproximação inversa de softmax)
    // Como as probabilidades já estão normalizadas, usamos log para obter logits aproximados
    final logits = rawOutput.map((prob) {
      // Evita log(0) que resultaria em -infinito
      final safeProb = prob.clamp(1e-10, 1.0);
      return log(safeProb);
    }).toList();
    
    // Aplica temperatura diferenciada por classe
    // Se numClasses == 3: [Pneumonia: T=2.0, Bronquite: T=5.0, Normal: T=5.0]
    // Se numClasses != 3: usa temperatura padrão (primeira do vetor ou média)
    final scaledLogits = <double>[];
    for (int i = 0; i < numClasses; i++) {
      double temperature;
      if (numClasses == 3 && i < temperaturePerClass.length) {
        // Aplica temperatura específica por classe
        temperature = temperaturePerClass[i];
      } else {
        // Fallback: usa primeira temperatura ou média
        temperature = temperaturePerClass.isNotEmpty 
            ? temperaturePerClass[0] 
            : 3.5;
      }
      scaledLogits.add(logits[i] / temperature);
    }
    
    // Aplica softmax manual nos logits escalados
    return _softmax(scaledLogits);
  }

  /// Implementa softmax manual com estabilidade numérica
  /// Subtrai o máximo antes de calcular exponenciais para evitar overflow
  List<double> _softmax(List<double> logits) {
    if (logits.isEmpty) return [];
    
    // Subtrai o máximo para estabilidade numérica
    final maxLogit = logits.reduce((a, b) => a > b ? a : b);
    final expValues = logits.map((x) => exp(x - maxLogit)).toList();
    final sumExp = expValues.reduce((a, b) => a + b);
    
    // Evita divisão por zero
    if (sumExp == 0.0) {
      // Se soma for zero, retorna distribuição uniforme
      return List.filled(logits.length, 1.0 / logits.length);
    }
    
    return expValues.map((x) => x / sumExp).toList();
  }

  /// Normalizes the spectrogram to [0, 1] range
  /// This is crucial for model accuracy as the training data was likely normalized
  List<List<double>> _normalizeSpectrogram(List<List<double>> spectrogram) {
    // Find min and max for normalization
    double minVal = double.infinity;
    double maxVal = double.negativeInfinity;
    
    for (var row in spectrogram) {
      for (var val in row) {
        if (val < minVal) minVal = val;
        if (val > maxVal) maxVal = val;
      }
    }
    
    // Normalize to [0, 1] range
    final range = maxVal - minVal;
    if (range == 0) {
      // Avoid division by zero - return zeros if all values are the same
      return spectrogram.map((row) => 
        row.map((val) => 0.0).toList()
      ).toList();
    }
    
    return spectrogram.map((row) => 
      row.map((val) => (val - minVal) / range).toList()
    ).toList();
  }

  void dispose() {
    _interpreter?.close();
  }
}
