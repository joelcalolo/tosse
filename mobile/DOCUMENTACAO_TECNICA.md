# 📚 Documentação Técnica - TosseControl

## Índice

1. [Visão Geral Tecnológica](#visão-geral-tecnológica)
2. [Stack Tecnológico](#stack-tecnológico)
3. [Captura de Áudio](#captura-de-áudio)
4. [Processamento de Áudio](#processamento-de-áudio)
5. [Integração com TensorFlow Lite](#integração-com-tensorflow-lite)
6. [Pipeline Completo](#pipeline-completo)
7. [Arquitetura de Dados](#arquitetura-de-dados)
8. [Detalhes de Implementação](#detalhes-de-implementação)

---

## 🎯 Visão Geral Tecnológica

O **TosseControl** é uma aplicação Flutter que utiliza **TensorFlow Lite** para análise de padrões acústicos de tosse. O aplicativo processa áudio em tempo real, convertendo sinais de áudio em representações espectrais (espectrogramas Mel) que são então analisadas por um modelo de deep learning para classificação de patologias respiratórias.

### Fluxo Tecnológico Simplificado

```
Áudio Bruto (PCM) 
    ↓
Espectrograma Mel (128x94)
    ↓
Normalização [0, 1]
    ↓
Adaptação para RGB (128x94x3)
    ↓
TensorFlow Lite Inference
    ↓
Probabilidades de Classificação
```

---

## 🛠 Stack Tecnológico

### Framework Principal

**Flutter 3.5.0+**
- Framework multiplataforma desenvolvido pelo Google
- Linguagem: Dart 3.5.0+
- Renderização nativa em Android, iOS e Web
- Hot reload para desenvolvimento rápido

### Bibliotecas Especializadas

#### 1. Processamento de Áudio
```yaml
record: ^6.1.2
```
- **Função**: Gravação de áudio nativa
- **Formato suportado**: PCM 16-bit
- **Configuração**: 16kHz, mono, 16-bit
- **Plataformas**: Android, iOS

#### 2. Transformada de Fourier
```yaml
fftea: ^1.5.0+1
```
- **Função**: STFT (Short-Time Fourier Transform)
- **Uso**: Conversão de áudio do domínio do tempo para frequência
- **Janela**: Hanning window
- **Tamanho da janela**: 512 samples

#### 3. Machine Learning
```yaml
tflite_flutter: ^0.11.0
```
- **Função**: Execução de modelos TensorFlow Lite
- **Otimizações**: NNAPI, GPU delegate (quando disponível)
- **Formato**: `.tflite` (modelo quantizado)

#### 4. Sistema de Arquivos
```yaml
path_provider: ^2.1.2
```
- **Função**: Acesso a diretórios temporários
- **Uso**: Armazenamento temporário de arquivos de áudio

#### 5. Permissões
```yaml
permission_handler: ^11.3.1
```
- **Função**: Gerenciamento de permissões do sistema
- **Permissão necessária**: RECORD_AUDIO

---

## 🎤 Captura de Áudio

### Serviço: `AudioRecorderService`

O serviço de gravação é responsável por toda a captura de áudio do dispositivo.

#### Localização
```
lib/services/audio_recorder_service.dart
```

### Processo de Captura

#### 1. Solicitação de Permissão

```dart
Future<bool> requestPermissions() async {
  var status = await Permission.microphone.request();
  return status == PermissionStatus.granted;
}
```

**Detalhes**:
- Usa `permission_handler` para solicitar permissão de microfone
- Retorna `true` se a permissão foi concedida
- Necessário antes de iniciar qualquer gravação

#### 2. Configuração de Gravação

```dart
const config = RecordConfig(
  encoder: AudioEncoder.pcm16bits,  // Codificação PCM 16-bit
  sampleRate: 16000,                 // 16kHz (taxa de amostragem)
  numChannels: 1,                    // Mono (1 canal)
);
```

**Especificações Técnicas**:
- **Formato**: PCM (Pulse Code Modulation) 16-bit
- **Sample Rate**: 16,000 Hz (16kHz)
  - Adequado para voz humana (range: 85Hz - 8kHz)
  - Reduz tamanho do arquivo vs 44.1kHz
  - Suficiente para análise de tosse
- **Canais**: Mono (1 canal)
  - Reduz processamento
  - Suficiente para análise de áudio de voz
- **Bit Depth**: 16-bit
  - Resolução adequada
  - Balance entre qualidade e tamanho

#### 3. Início da Gravação

```dart
Future<void> startRecording(String path) async {
  if (await _audioRecorder.hasPermission()) {
    await _audioRecorder.start(config, path: path);
  }
}
```

**Fluxo**:
1. Verifica permissão novamente (segurança)
2. Cria arquivo temporário no caminho especificado
3. Inicia gravação com configuração definida
4. Áudio é gravado diretamente em formato PCM

#### 4. Caminho Temporário

```dart
Future<String> getTempPath() async {
  final directory = await getTemporaryDirectory();
  return '${directory.path}/cough_sample.wav';
}
```

**Detalhes**:
- Usa `path_provider` para obter diretório temporário
- Arquivo: `cough_sample.wav`
- Localização:
  - Android: `/data/data/com.example.app_tossecontrol/cache/`
  - iOS: `Library/Caches/`

#### 5. Parada da Gravação

```dart
Future<String?> stopRecording() async {
  return await _audioRecorder.stop();
}
```

**Retorno**:
- Retorna o caminho do arquivo gravado
- Arquivo está pronto para processamento
- Duração típica: 5 segundos (configurável)

### Formato do Arquivo Gravado

```
Formato: WAV (container)
Codificação: PCM 16-bit
Sample Rate: 16,000 Hz
Canais: 1 (Mono)
Duração: ~5 segundos
Tamanho aproximado: ~160 KB
```

**Cálculo do tamanho**:
```
16,000 samples/segundo × 2 bytes/sample × 5 segundos = 160,000 bytes ≈ 160 KB
```

---

## 🔄 Processamento de Áudio

### Serviço: `TfliteAnalyzerService`

O serviço de análise processa o áudio gravado e prepara para inferência do modelo.

#### Localização
```
lib/services/tflite_analyzer_service.dart
```

### Pipeline de Processamento

#### Etapa 1: Leitura do Arquivo PCM

```dart
final bytes = await File(filePath).readAsBytes();
final pcmData = _convertBytesToPcm(bytes);
```

**Função `_convertBytesToPcm`**:

```dart
List<double> _convertBytesToPcm(Uint8List bytes) {
  final pcm = <double>[];
  for (var i = 0; i < bytes.length; i += 2) {
    if (i + 1 < bytes.length) {
      // Lê 2 bytes (16-bit)
      final sample = bytes[i] | (bytes[i + 1] << 8);
      // Converte para signed 16-bit
      final signedSample = sample >= 32768 ? sample - 65536 : sample;
      // Normaliza para [-1.0, 1.0]
      pcm.add(signedSample / 32768.0);
    }
  }
  return pcm;
}
```

**Processo**:
1. Lê bytes do arquivo
2. Agrupa em pares (16-bit = 2 bytes)
3. Converte de unsigned para signed 16-bit
4. Normaliza para range [-1.0, 1.0]
5. Retorna lista de doubles

**Exemplo**:
```
Bytes: [0x12, 0x34]
→ Sample: 0x3412 (little-endian)
→ Signed: 13330
→ Normalizado: 13330 / 32768 = 0.4067
```

#### Etapa 2: Geração do Espectrograma Mel

```dart
final input = _generateSpectrogram(pcmData, 128, 94);
```

**Função `_generateSpectrogram`**:

```dart
List<List<double>> _generateSpectrogram(
  List<double> pcm, 
  int melBins,      // 128 bins de frequência Mel
  int timeSteps     // 94 frames de tempo
) {
  int windowSize = 512;  // Tamanho da janela FFT
  int hopSize = (pcm.length - windowSize) ~/ (timeSteps - 1);
  
  final spectrogram = List.generate(melBins, (_) => 
    List.filled(timeSteps, 0.0)
  );
  
  final stft = STFT(windowSize, Window.hanning(windowSize));
  
  int t = 0;
  stft.run(pcm, (Float64x2List freq) {
    if (t >= timeSteps) return;
    
    final magnitudes = freq.discardConjugates().magnitudes();
    
    // Mapeamento para escala Mel
    for (int m = 0; m < melBins; m++) {
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
```

**Processo Detalhado**:

1. **STFT (Short-Time Fourier Transform)**
   - Divide o sinal em janelas sobrepostas
   - Tamanho da janela: 512 samples
   - Janela de Hanning para reduzir aliasing
   - Aplica FFT em cada janela

2. **Cálculo do Hop Size**
   ```
   hopSize = (pcm.length - windowSize) / (timeSteps - 1)
   ```
   - Determina quantos samples avançar entre janelas
   - Garante exatamente 94 frames de tempo

3. **Magnitudes de Frequência**
   - Calcula magnitude de cada bin de frequência
   - Descarta conjugados (simetria da FFT)

4. **Mapeamento para Escala Mel**
   - Escala Mel: percepção humana de frequência
   - Mapeia bins lineares para 128 bins Mel
   - Distribuição não-linear (mais bins em baixas frequências)

5. **Log Scale**
   - Aplica log(1 + magnitude)
   - Compressa dinâmica do sinal
   - Melhora representação de frequências baixas

**Resultado**:
- Matriz 128x94 (frequências × tempo)
- Valores em escala logarítmica
- Representação espectral do áudio

#### Etapa 3: Normalização

```dart
final normalizedInput = _normalizeSpectrogram(input);
```

**Função `_normalizeSpectrogram`**:

```dart
List<List<double>> _normalizeSpectrogram(
  List<List<double>> spectrogram
) {
  // Encontra min e max
  double minVal = double.infinity;
  double maxVal = double.negativeInfinity;
  
  for (var row in spectrogram) {
    for (var val in row) {
      if (val < minVal) minVal = val;
      if (val > maxVal) maxVal = val;
    }
  }
  
  // Normaliza para [0, 1]
  final range = maxVal - minVal;
  if (range == 0) return zeros; // Evita divisão por zero
  
  return spectrogram.map((row) => 
    row.map((val) => (val - minVal) / range).toList()
  ).toList();
}
```

**Processo**:
1. Encontra valor mínimo e máximo em todo o espectrograma
2. Calcula range (max - min)
3. Normaliza cada valor: `(valor - min) / range`
4. Resultado: valores entre [0.0, 1.0]

**Importância**:
- Modelo foi treinado com dados normalizados
- Essencial para precisão da inferência
- Garante consistência com dados de treinamento

#### Etapa 4: Adaptação para RGB

```dart
var inputExpanded = List.generate(1, (i) => 
  List.generate(128, (j) => 
    List.generate(94, (k) => 
      List.generate(3, (l) => normalizedInput[j][k])
    )
  )
);
```

**Processo**:
- Modelo baseado em MobileNet (originalmente para imagens RGB)
- Espectrograma tem 1 canal (escala de cinza)
- Duplica o mesmo valor para 3 canais (R, G, B)
- Shape final: `[1, 128, 94, 3]`

**Shape do Tensor**:
```
[1, 128, 94, 3]
 │   │    │   └─ Canais RGB (3)
 │   │    └───── Time steps (94)
 │   └────────── Mel bins (128)
 └────────────── Batch size (1)
```

---

## 🤖 Integração com TensorFlow Lite

### Inicialização do Modelo

```dart
Future<void> initialize() async {
  _interpreter = await Interpreter.fromAsset(
    'assets/models/modelo_respiratorio_v2.tflite'
  );
}
```

**Processo**:
1. Carrega arquivo `.tflite` dos assets
2. Cria `Interpreter` do TensorFlow Lite
3. Modelo fica em memória para inferências rápidas
4. Executado uma vez na inicialização do app

**Localização do Modelo**:
```
assets/models/modelo_respiratorio_v2.tflite
```

### Especificações do Modelo

#### Arquitetura Base
- **Base**: MobileNet (adaptada)
- **Originalmente**: Classificação de imagens
- **Adaptação**: Espectrogramas Mel como "imagens"

#### Input Shape
```
[1, 128, 94, 3]
```
- **1**: Batch size (uma análise por vez)
- **128**: Bins Mel (frequências)
- **94**: Time steps (tempo)
- **3**: Canais RGB

#### Output Shape
```
[1, numClasses]
```
- **1**: Batch size
- **numClasses**: Número de classes (2 ou 3)
  - 2 classes: [Pneumonia, Bronquite]
  - 3 classes: [Pneumonia, Bronquite, Normal]

### Execução da Inferência

```dart
// 1. Prepara buffer de saída
var output = List.filled(1 * numClasses, 0.0)
  .reshape([1, numClasses]);

// 2. Executa inferência
_interpreter!.run(inputExpanded, output);

// 3. Processa resultados
final results = <String, double>{};
if (numClasses == 3) {
  results['Pneumonia'] = output[0][0];
  results['Bronquite'] = output[0][1];
  results['Normal'] = output[0][2];
} else {
  results['Pneumonia'] = output[0][0];
  results['Bronquite'] = output[0][1];
}
```

**Processo**:
1. **Prepara Output Buffer**
   - Cria array com tamanho correto
   - Formato: `[1, numClasses]`

2. **Executa `run()`**
   - Passa tensor de entrada
   - TensorFlow Lite processa internamente
   - Preenche buffer de saída

3. **Processa Resultados**
   - Valores são probabilidades (0.0 a 1.0)
   - Mapeia índices para nomes de classes
   - Retorna mapa com probabilidades

### Mapeamento de Classes

#### Modelo v2 (3 classes)
```dart
Índice 0 → Pneumonia
Índice 1 → Bronquite
Índice 2 → Normal
```

#### Modelo Original (2 classes)
```dart
Índice 0 → Pneumonia
Índice 1 → Bronquite
```

**Importante**: A ordem depende de como o modelo foi treinado!

### Otimizações do TensorFlow Lite

#### 1. Quantização
- Modelo pode ser quantizado (Int8 vs Float32)
- Reduz tamanho e acelera inferência
- Pequena perda de precisão

#### 2. NNAPI (Android)
- Usa Neural Networks API quando disponível
- Acelera inferência em hardware dedicado
- Automático quando suportado

#### 3. GPU Delegate
- Usa GPU quando disponível
- Acelera processamento de convoluções
- Requer modelo compatível

#### 4. Threading
- TensorFlow Lite usa múltiplas threads
- Otimiza uso de CPU
- Melhora performance em dispositivos multi-core

---

## 🔄 Pipeline Completo

### Fluxo End-to-End

```
┌─────────────────────────────────────────────────────────┐
│ 1. USUÁRIO INICIA GRAVAÇÃO                              │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│ 2. AudioRecorderService                                   │
│    - Solicita permissão de microfone                      │
│    - Configura: PCM 16-bit, 16kHz, mono                  │
│    - Inicia gravação em arquivo temporário                │
│    - Duração: 5 segundos                                  │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│ 3. ARQUIVO GRAVADO                                        │
│    Formato: WAV (PCM 16-bit)                             │
│    Tamanho: ~160 KB                                       │
│    Local: /cache/cough_sample.wav                        │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│ 4. TfliteAnalyzerService.analyze()                       │
│    - Lê bytes do arquivo                                  │
│    - Converte para PCM normalizado [-1, 1]               │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│ 5. GERAÇÃO DE ESPECTROGRAMA                              │
│    - STFT com janela de 512 samples                       │
│    - Janela de Hanning                                    │
│    - 94 frames de tempo                                   │
│    - Mapeamento para 128 bins Mel                         │
│    - Log scale: log(1 + magnitude)                       │
│    Resultado: Matriz 128x94                              │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│ 6. NORMALIZAÇÃO                                           │
│    - Encontra min/max                                     │
│    - Normaliza para [0, 1]                                │
│    Resultado: Matriz 128x94 normalizada                  │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│ 7. ADAPTAÇÃO PARA RGB                                     │
│    - Duplica canal único para 3 canais                   │
│    - Shape: [1, 128, 94, 3]                              │
│    - Pronto para TensorFlow Lite                         │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│ 8. TENSORFLOW LITE INFERENCE                             │
│    - Carrega modelo (se necessário)                     │
│    - Executa inferência                                  │
│    - Output: [1, numClasses]                             │
│    - Valores: probabilidades [0.0, 1.0]                  │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│ 9. MAPEAMENTO DE RESULTADOS                              │
│    - Mapeia índices para nomes de classes                │
│    - Retorna: Map<String, double>                        │
│    Exemplo:                                              │
│    {                                                     │
│      'Pneumonia': 0.75,                                  │
│      'Bronquite': 0.20,                                  │
│      'Normal': 0.05                                      │
│    }                                                     │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│ 10. APRESENTAÇÃO NA UI                                    │
│     - Card principal com maior probabilidade             │
│     - Cards individuais para cada condição               │
│     - Barras de progresso                                │
│     - Interpretação dos resultados                       │
└─────────────────────────────────────────────────────────┘
```

### Tempo de Processamento

| Etapa | Tempo Aproximado |
|-------|------------------|
| Gravação | 5 segundos |
| Leitura do arquivo | < 50ms |
| Conversão PCM | < 100ms |
| Geração de espectrograma | 500-1000ms |
| Normalização | < 50ms |
| Adaptação RGB | < 50ms |
| Inferência TensorFlow | 200-500ms |
| **Total** | **~6-7 segundos** |

---

## 📊 Arquitetura de Dados

### Estrutura de Dados

#### Input: Áudio PCM
```dart
List<double> pcmData
// Exemplo: [-0.5, 0.3, -0.1, 0.8, ...]
// Range: [-1.0, 1.0]
// Tamanho: ~80,000 valores (5 seg × 16kHz)
```

#### Processamento: Espectrograma
```dart
List<List<double>> spectrogram
// Shape: [128, 94]
// Valores: Log scale (não normalizados)
// Exemplo:
// [
//   [2.1, 2.3, 2.0, ...],  // Mel bin 0
//   [1.8, 1.9, 1.7, ...],  // Mel bin 1
//   ...
// ]
```

#### Normalização: Espectrograma Normalizado
```dart
List<List<double>> normalizedSpectrogram
// Shape: [128, 94]
// Range: [0.0, 1.0]
```

#### Tensor Input: Para TensorFlow
```dart
List<List<List<List<double>>>> inputTensor
// Shape: [1, 128, 94, 3]
// Batch, Height, Width, Channels
```

#### Tensor Output: Do TensorFlow
```dart
List<List<double>> output
// Shape: [1, numClasses]
// Exemplo: [[0.75, 0.20, 0.05]]
//          [Pneumonia, Bronquite, Normal]
```

#### Resultado Final
```dart
Map<String, double> results
// Exemplo:
// {
//   'Pneumonia': 0.75,
//   'Bronquite': 0.20,
//   'Normal': 0.05
// }
```

---

## 🔧 Detalhes de Implementação

### Gerenciamento de Memória

#### Limpeza de Arquivos Temporários
```dart
// Arquivos são salvos em diretório temporário
// Sistema operacional limpa automaticamente
// Não requer limpeza manual
```

#### Liberação do Interpreter
```dart
void dispose() {
  _interpreter?.close();
}
```
- Fecha interpreter quando não necessário
- Libera memória do modelo
- Importante para evitar vazamentos

### Tratamento de Erros

#### Verificação de Permissões
```dart
if (await _audioRecorder.hasPermission()) {
  // Prossegue com gravação
}
```

#### Validação de Modelo
```dart
if (_interpreter == null) await initialize();
```
- Garante que modelo está carregado
- Inicializa se necessário

#### Divisão por Zero
```dart
if (range == 0) {
  return zeros; // Evita divisão por zero
}
```

### Debug e Logging

O código inclui logs detalhados para debug:

```dart
print('DEBUG - Number of classes: $numClasses');
print('DEBUG - Raw output: ${output[0]}');
print('DEBUG - Mapped results:');
print('DEBUG - Pneumonia (index 0): ${output[0][0]}');
```

**Uso**: Ajuda a identificar problemas durante desenvolvimento

### Otimizações

#### 1. Carregamento Único do Modelo
- Modelo carregado uma vez na inicialização
- Reutilizado para múltiplas análises
- Reduz overhead

#### 2. Processamento Assíncrono
```dart
Future<Map<String, double>> analyze(String filePath) async {
  // Processamento não bloqueia UI
}
```

#### 3. Uso de Tipos Nativos
- `Uint8List` para bytes
- `List<double>` para PCM
- Eficiente em memória

---

## 📝 Resumo Técnico

### Tecnologias Principais
- **Flutter**: Framework UI multiplataforma
- **TensorFlow Lite**: Inferência de ML
- **FFTEA**: Transformada de Fourier
- **Record**: Gravação de áudio

### Fluxo de Dados
```
PCM 16-bit → Espectrograma Mel → Normalização → Tensor → Inferência → Probabilidades
```

### Especificações
- **Áudio**: 16kHz, mono, 16-bit PCM
- **Espectrograma**: 128 bins Mel × 94 frames
- **Modelo**: MobileNet adaptado
- **Input**: [1, 128, 94, 3]
- **Output**: [1, numClasses]

### Performance
- **Tempo total**: ~6-7 segundos
- **Inferência**: 200-500ms
- **Memória**: ~100-200 MB (com modelo)

---

**Última atualização**: 2024  
**Versão do documento**: 1.0.0

