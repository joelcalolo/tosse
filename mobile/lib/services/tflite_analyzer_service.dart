import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:fftea/fftea.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class TfliteAnalyzerService {
  Interpreter? _interpreter;

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

    // 7. Debug: Print raw output values
    print('DEBUG - Number of classes: $numClasses');
    print('DEBUG - Raw output: ${output[0]}');
    print('DEBUG - Raw output values: [${output[0].map((v) => v.toStringAsFixed(4)).join(", ")}]');

    // 8. Return results based on number of classes
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
