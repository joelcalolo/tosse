# 🏥 TosseControl - Análise Inteligente de Tosse com IA

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.5.0+-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.5.0+-0175C2?logo=dart&logoColor=white)
![TensorFlow Lite](https://img.shields.io/badge/TensorFlow_Lite-2.0+-FF6F00?logo=tensorflow&logoColor=white)
![License](https://img.shields.io/badge/License-Educational-blue)

**Aplicação móvel profissional para análise de tosse e detecção de patologias respiratórias usando Inteligência Artificial**

[📥 Download APK](#-download-apk) • [Características](#-características) • [Instalação](#-instalação) • [Uso](#-como-usar) • [Estrutura](#-estrutura-do-projeto) • [Tecnologias](#-tecnologias)

</div>

---

## 📋 Índice

- [📥 Download APK](#-download-apk)
- [Visão Geral](#-visão-geral)
- [Características](#-características)
- [Tecnologias](#-tecnologias)
- [Instalação](#-instalação)
- [Como Usar](#-como-usar)
- [Estrutura do Projeto](#-estrutura-do-projeto)
- [Arquitetura](#-arquitetura)
- [Modelo de IA](#-modelo-de-ia)
- [Design e Interface](#-design-e-interface)
- [Build e Deploy](#-build-e-deploy)
- [Troubleshooting](#-troubleshooting)
- [Próximos Passos](#-próximos-passos)

---

## 📥 Download APK

### Versão Atual: 1.0.0

**Download do APK:**

📱 **Localização do arquivo**: `mobile/build/app/outputs/flutter-apk/app-release.apk`

- **Tamanho**: ~81 MB (84.8 MB)
- **Versão**: 1.0.0
- **Data**: 25/01/2025
- **Android**: API 21+ (Android 5.0+)

### Como Baixar

#### Opção 1: Do Repositório Local
Se você clonou o repositório, o APK está em:
```
mobile/build/app/outputs/flutter-apk/app-release.apk
```

#### Opção 2: Gerar Novo APK
Se preferir gerar um novo APK:
```bash
cd mobile
flutter build apk --release
```
O APK será gerado em: `build/app/outputs/flutter-apk/app-release.apk`

#### Opção 3: Download via GitHub Releases (Recomendado)
Para disponibilizar o APK via GitHub Releases:

1. Acesse o repositório no GitHub
2. Vá em **Releases** → **Create a new release**
3. Crie uma nova tag (ex: `v1.0.0`)
4. Faça upload do arquivo `app-release.apk`
5. Publique o release

Depois disso, você pode adicionar um link direto aqui:
```markdown
📱 [Baixar APK v1.0.0](https://github.com/seu-usuario/tosse/releases/download/v1.0.0/app-release.apk)
```

### Instruções de Instalação

1. **Baixe o arquivo APK** (usando uma das opções acima)
2. **Ative "Fontes Desconhecidas"** nas configurações do Android:
   - **Android 8.0+**: Configurações → Apps → Acesso Especial → Instalar apps desconhecidos → Selecione o navegador/gerenciador de arquivos → Permitir
   - **Android 7.0 ou anterior**: Configurações → Segurança → Fontes Desconhecidas (ativar)
3. **Abra o arquivo APK** baixado no dispositivo
4. **Siga as instruções** de instalação
5. **Conceda permissão de microfone** quando solicitado na primeira execução

> ⚠️ **Nota de Segurança**: O APK não está assinado digitalmente. Alguns dispositivos podem mostrar avisos de segurança. Isso é normal para builds de desenvolvimento.

### Informações do APK

- ✅ **Modelo de IA**: TensorFlow Lite v2 (3 classes)
- ✅ **Classes suportadas**: Pneumonia, Bronquite, Normal
- ✅ **Calibração**: Temperatura diferenciada por classe
- ✅ **Processamento**: 100% offline
- ✅ **Tamanho**: ~81 MB

---

## 🎯 Visão Geral

**TosseControl** é uma aplicação móvel profissional desenvolvida em Flutter que utiliza Inteligência Artificial (TensorFlow Lite) para analisar padrões acústicos de tosse e identificar possíveis sinais de patologias respiratórias. 

### 🎯 O que faz?

O aplicativo permite que você **grave sua tosse** (5 segundos) e receba uma **análise automática** em poucos segundos, classificando o áudio em **3 categorias**:

1. **Pneumonia** - Detecção com alta confiança (AUC 0.93)
2. **Bronquite** - Identificação de padrões bronquíticos
3. **Normal** - Tosse saudável/normal

### 🧠 Tecnologia de IA

O modelo utiliza **calibração diferenciada por classe** com temperatura adaptativa para fornecer resultados mais realistas:

- **Pneumonia** (T=2.0): Como o modelo é muito bom a detetar Pneumonia (AUC 0.93), permitimos mais certeza quando detectada
- **Bronquite e Normal** (T=5.0): Como há confusão entre estas classes, aplicamos calibração agressiva para "achatar" a dúvida e fornecer probabilidades mais equilibradas

### ✨ Características Principais

- ✅ **Processamento 100% offline** - Nenhum dado enviado para servidores
- ✅ **Análise em tempo real** - Resultados em ~6-7 segundos
- ✅ **Interface profissional** - Design moderno e intuitivo
- ✅ **3 classes balanceadas** - Pneumonia, Bronquite e Normal
- ✅ **Calibração inteligente** - Temperatura adaptativa por classe
- ✅ **Multiplataforma** - Android, iOS e Web

### 🎯 Objetivo

Desenvolver uma ferramenta de apoio ao diagnóstico que possa auxiliar profissionais de saúde e usuários na identificação precoce de sinais de patologias respiratórias através da análise acústica da tosse.

> ⚠️ **Importante**: Este aplicativo é uma ferramenta de apoio e **não substitui a consulta médica profissional**. Os resultados são preliminares e devem ser interpretados por um profissional de saúde qualificado.

---

## ✨ Características

### 🎤 Gravação de Áudio
- ✅ Gravação de alta qualidade (16kHz, mono, 16-bit PCM)
- ✅ Gravação automática de 5 segundos
- ✅ Parada manual opcional
- ✅ Feedback visual durante a gravação
- ✅ Animações e indicadores visuais

### 🧠 Análise com IA
- ✅ Processamento em tempo real
- ✅ Modelo TensorFlow Lite otimizado (MobileNetV2)
- ✅ Análise de espectrogramas Mel (128x94)
- ✅ Classificação de 3 classes: Pneumonia, Bronquite, Normal
- ✅ Calibração diferenciada por classe (temperatura adaptativa)
- ✅ Probabilidades detalhadas e realistas para cada condição

### 📊 Resultados Detalhados
- ✅ Card principal com diagnóstico sugerido
- ✅ Cards individuais para cada condição
- ✅ Probabilidades em porcentagem
- ✅ Barras de progresso visuais
- ✅ Interpretação dos resultados
- ✅ Avisos médicos importantes

### 🎨 Interface Profissional
- ✅ Design moderno e limpo
- ✅ Paleta de cores médicas vibrantes
- ✅ Animações suaves e transições
- ✅ Layout responsivo
- ✅ Cards com efeitos 3D
- ✅ Tipografia profissional (Google Fonts)

### 📱 Multiplataforma
- ✅ Android (API 21+)
- ✅ iOS (12.0+)
- ✅ Web (suporte básico)

---

## 🛠 Tecnologias

### Framework e Linguagem
- **Flutter** 3.5.0+ - Framework multiplataforma
- **Dart** 3.5.0+ - Linguagem de programação

### Bibliotecas Principais

#### Processamento de Áudio e IA
```yaml
tflite_flutter: ^0.11.0      # TensorFlow Lite para inferência
record: ^6.1.2               # Gravação de áudio
fftea: ^1.5.0+1              # Transformada de Fourier
```

#### Interface e Design
```yaml
google_fonts: ^6.2.1         # Fontes Google (Outfit, Varela Round)
flutter_svg: ^2.0.10         # Renderização de SVGs
```

#### Utilitários
```yaml
path_provider: ^2.1.2        # Acesso a diretórios
permission_handler: ^11.3.1  # Gerenciamento de permissões
```

### Plataformas
- **Android**: Gradle 8.13, Kotlin, Java 17
- **iOS**: Xcode, CocoaPods
- **Web**: Suporte básico

---

## 🚀 Instalação

### Pré-requisitos

1. **Flutter SDK** (3.5.0 ou superior)
   ```bash
   flutter --version
   ```

2. **Java JDK 17** (para Android)
   ```bash
   java -version
   ```

3. **Android Studio** (para desenvolvimento Android)
4. **Xcode** (para iOS - apenas macOS)

### Passos de Instalação

1. **Clone o repositório**
   ```bash
   git clone <repository-url>
   cd tosse/mobile
   ```

2. **Instale as dependências**
   ```bash
   flutter pub get
   ```

3. **Verifique os dispositivos**
   ```bash
   flutter devices
   ```

4. **Execute o aplicativo**
   ```bash
   flutter run
   ```

### Configuração de Permissões

#### Android
O aplicativo solicita automaticamente a permissão de microfone na primeira execução.

#### iOS
Adicione a seguinte chave no `Info.plist`:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>Este aplicativo precisa acessar o microfone para gravar sua tosse.</string>
```

---

## 📱 Como Usar

### Fluxo de Uso

1. **Tela Inicial (Home)**
   - Visualize informações sobre o aplicativo
   - Veja os cards de características (Rápido, Preciso, Seguro)
   - Leia as instruções de uso
   - Toque em "Iniciar Análise"

2. **Tela de Análise**
   - O visualizador mostra o estado atual
   - Toque em "Iniciar Gravação"
   - A gravação inicia automaticamente (5 segundos)
   - Você pode parar manualmente antes se desejar

3. **Durante a Gravação**
   - Visualizador animado com ondas pulsantes
   - Status: "Gravando..."
   - Botão muda para "Parar Gravação"

4. **Análise**
   - Status: "Analisando padrões acústicos..."
   - Indicador de progresso circular
   - Processamento automático com IA

5. **Resultados**
   - Card principal com diagnóstico sugerido
   - Cards de probabilidade para cada condição
   - Interpretação dos resultados
   - Aviso médico importante
   - Botão para nova análise

### Dicas de Uso

- ✅ Grave em ambiente silencioso
- ✅ Mantenha o dispositivo próximo à boca
- ✅ Tussa naturalmente durante a gravação
- ✅ Aguarde a análise completa antes de gravar novamente
- ⚠️ Sempre consulte um profissional de saúde para diagnóstico adequado

---

## 📁 Estrutura do Projeto

```
mobile/
├── android/                      # Configurações Android
│   ├── app/
│   │   ├── build.gradle.kts
│   │   ├── proguard-rules.pro
│   │   └── src/main/
│   │       ├── AndroidManifest.xml
│   │       └── kotlin/.../MainActivity.kt
│   └── build.gradle
│
├── ios/                          # Configurações iOS
│   └── Runner/
│       └── Info.plist
│
├── web/                          # Configurações Web
│   ├── index.html
│   └── manifest.json
│
├── lib/
│   ├── constants.dart            # Constantes, cores e estilos
│   ├── main.dart                 # Ponto de entrada
│   │
│   ├── models/                   # Modelos de dados
│   │   └── medical_category.dart
│   │
│   ├── screens/                   # Telas da aplicação
│   │   ├── home/
│   │   │   └── home_screen.dart  # Tela inicial
│   │   └── analysis/
│   │       └── analysis_screen.dart  # Tela de análise
│   │
│   └── services/                 # Serviços de negócio
│       ├── audio_recorder_service.dart    # Gravação de áudio
│       └── tflite_analyzer_service.dart   # Análise com IA
│
├── assets/
│   ├── models/
│   │   └── modelo_respiratorio.tflite    # Modelo TensorFlow Lite
│   ├── images/
│   └── icons/
│
├── pubspec.yaml                  # Dependências e configurações
└── README.md                     # Esta documentação
```

---

## 🏗 Arquitetura

### Padrão de Arquitetura

O projeto segue uma arquitetura em camadas com separação de responsabilidades:

```
┌─────────────────────────────────────┐
│         UI Layer (Screens)           │
│  - HomeScreen                        │
│  - AnalysisScreen                    │
│  - Componentes visuais               │
└─────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────┐
│      Service Layer (Services)        │
│  - AudioRecorderService              │
│  - TfliteAnalyzerService             │
└─────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────┐
│      Data Layer (Models/Assets)     │
│  - modelo_respiratorio.tflite       │
│  - Arquivos de áudio temporários     │
└─────────────────────────────────────┘
```

### Componentes Principais

#### 1. **HomeScreen** (`lib/screens/home/home_screen.dart`)
- Tela inicial com informações do aplicativo
- Cards de características
- Instruções de uso
- Botão para iniciar análise
- Animações e transições suaves

#### 2. **AnalysisScreen** (`lib/screens/analysis/analysis_screen.dart`)
- Tela única que integra gravação e resultados
- Gerencia estado (gravação, análise, resultados)
- Visualizador animado
- Apresentação de resultados

#### 3. **AudioRecorderService** (`lib/services/audio_recorder_service.dart`)
- Gerencia permissões de microfone
- Configura gravação (16kHz, mono, PCM16)
- Salva arquivos temporários
- Limpeza automática de arquivos

#### 4. **TfliteAnalyzerService** (`lib/services/tflite_analyzer_service.dart`)
- Carrega modelo TFLite
- Processa áudio em espectrogramas Mel
- Normaliza dados de entrada
- Executa inferência
- Retorna probabilidades

---

## 🤖 Modelo de IA

### Especificações do Modelo

- **Formato**: TensorFlow Lite (`.tflite`)
- **Arquitetura**: MobileNetV2 (adaptada)
- **Modelo**: `modelo_respiratorio_v2.tflite`
- **Input Shape**: `[1, 128, 94, 1]` → expandido para `[1, 128, 94, 3]`
  - 128: Bins Mel (frequências)
  - 94: Time steps (tempo)
  - 1: Canal original (escala de cinza)
  - 3: Canais RGB (adaptação para MobileNetV2)
- **Output Shape**: `[1, 3]`
  - 3 classes: Pneumonia (índice 0), Bronquite (índice 1), Normal (índice 2)
- **Tamanho**: ~9 MB
- **Precisão**: Float32

### Pipeline de Processamento

#### 1. Captura de Áudio
```dart
- Formato: PCM 16-bit
- Sample Rate: 16kHz
- Canais: Mono (1 canal)
- Duração: 5 segundos (padrão)
```

#### 2. Pré-processamento
```dart
1. Leitura do arquivo PCM
2. Conversão para espectrograma Mel:
   - 128 bins de frequência Mel
   - 94 time steps
   - Normalização dos valores
3. Adaptação para 3 canais (RGB)
```

#### 3. Inferência
```dart
- Input: [1, 128, 94, 3] (normalizado)
- Output: [1, 3] (probabilidades brutas)
  - output[0][0] = Probabilidade de Pneumonia
  - output[0][1] = Probabilidade de Bronquite
  - output[0][2] = Probabilidade de Normal
```

#### 4. Calibração com Temperatura Diferenciada
```dart
- Pneumonia: T=2.0 (menos calibração, mais certeza)
- Bronquite: T=5.0 (calibração agressiva)
- Normal: T=5.0 (calibração agressiva)
- Aplica softmax após calibração
```

### Mapeamento de Classes

```dart
Índice 0 → Pneumonia (T=2.0)
Índice 1 → Bronquite (T=5.0)
Índice 2 → Normal (T=5.0)
```

### Performance do Modelo

- **AUC Pneumonia**: 0.93 (excelente)
- **AUC Bronquite**: ~0.75-0.80 (bom)
- **AUC Normal**: ~0.75-0.80 (bom)
- **Accuracy geral**: ~70-80% (depende do dataset)

---

## 🎨 Design e Interface

### Paleta de Cores

#### Cores Principais
- **Azul Médico**: `#6366F1` (Índigo vibrante)
- **Verde Médico**: `#10B981` (Verde esmeralda)

#### Cores de Status
- **Bronquite**: `#F59E0B` (Âmbar)
- **Pneumonia**: `#EF4444` (Vermelho)
- **Normal**: `#22C55E` (Verde)

#### Cores de Texto
- **Texto Principal**: `#2D3748`
- **Texto Secundário**: `#718096`
- **Texto Claro**: `#A0AEC0`

#### Cores de Fundo
- **Fundo Clínico**: `#FAFBFC`
- **Card Background**: `#FFFFFF`
- **Gradiente Início**: `#FAFBFC`
- **Gradiente Fim**: `#F1F5F9`

### Tipografia

- **Títulos**: Google Fonts - Outfit (Bold)
- **Corpo**: Google Fonts - Varela Round (Regular)
- **Tamanhos**: 10px - 32px (escala responsiva)

### Componentes Visuais

#### Cards
- Bordas arredondadas (20-24px)
- Sombras 3D com elevação
- Gradientes sutis
- Bordas coloridas com opacidade

#### Botões
- Altura: 56-64px
- Bordas arredondadas: 20px
- Gradientes vibrantes
- Efeitos de pressão 3D
- Feedback visual

#### Animações
- Transições suaves (300-500ms)
- Curvas: easeOutCubic, easeInOut
- Animações de entrada escalonadas
- Feedback visual durante interações

---

## 📦 Build e Deploy

### Build APK Android

```bash
flutter build apk --release
```

O APK será gerado em:
```
build/app/outputs/flutter-apk/app-release.apk
```

### Build AAB (Android App Bundle)

```bash
flutter build appbundle --release
```

O AAB será gerado em:
```
build/app/outputs/bundle/release/app-release.aab
```

### Build iOS

```bash
flutter build ios --release
```

### Build Web

```bash
flutter build web --release
```

### Configurações de Release

#### Android (`android/app/build.gradle.kts`)
```kotlin
namespace = "com.example.app_tossecontrol"
applicationId = "com.example.app_tossecontrol"
minSdk = 21
targetSdk = 34
```

#### ProGuard Rules (`android/app/proguard-rules.pro`)
```proguard
# TensorFlow Lite rules
-keep class org.tensorflow.lite.** { *; }
-keep class org.tensorflow.lite.gpu.** { *; }
-dontwarn org.tensorflow.lite.gpu.GpuDelegateFactory$Options
```

---

## 🔧 Troubleshooting

### Problemas Comuns

#### 1. Erro de Permissão de Microfone
**Sintoma**: Aplicativo não grava áudio
**Solução**: 
- Verifique as permissões nas configurações do dispositivo
- Reinicie o aplicativo após conceder permissões

#### 2. Modelo não Carrega
**Sintoma**: Erro ao inicializar o modelo
**Solução**:
- Verifique se o arquivo `modelo_respiratorio.tflite` está em `assets/models/`
- Execute `flutter clean` e `flutter pub get`

#### 3. Build Falha
**Sintoma**: Erro durante o build
**Solução**:
```bash
flutter clean
flutter pub get
cd android && ./gradlew clean
cd .. && flutter run
```

#### 4. Overflow na Tela
**Sintoma**: Elementos ultrapassam os limites da tela
**Solução**: Já corrigido - a tela usa `Expanded` e `SingleChildScrollView` internamente

#### 5. Resultados Sempre Iguais
**Sintoma**: Sempre retorna a mesma condição
**Solução**: Verifique se o modelo está sendo carregado corretamente e se os dados estão sendo normalizados

---

## 🔮 Próximos Passos

### Melhorias Planejadas

#### Funcionalidades
- [ ] Histórico de análises
- [ ] Exportação de resultados (PDF/CSV)
- [ ] Compartilhamento de resultados
- [ ] Múltiplas gravações por sessão
- [ ] Comparação de resultados ao longo do tempo

#### Melhorias de IA
- [x] Suporte a modelos de 3 classes (incluindo Normal) ✅
- [x] Calibração diferenciada por classe (temperatura adaptativa) ✅
- [ ] Análise de múltiplos segmentos de áudio
- [ ] Modelo mais preciso e otimizado
- [ ] Suporte a quantização INT8 para reduzir tamanho

#### Interface
- [ ] Modo escuro
- [ ] Personalização de temas
- [ ] Gráficos de histórico
- [ ] Tutorial/Onboarding interativo
- [ ] Internacionalização (i18n)

#### Performance
- [ ] Otimização do modelo
- [ ] Processamento em background
- [ ] Cache de resultados
- [ ] Redução do tamanho do APK

#### Segurança e Privacidade
- [ ] Criptografia de dados locais
- [ ] Política de privacidade completa
- [ ] Opção de processamento 100% offline
- [ ] Anonimização de dados

---

## 📊 Métricas e Performance

### Tempo de Processamento
- **Gravação**: 5 segundos (configurável)
- **Análise**: ~1-2 segundos (depende do dispositivo)
- **Total**: ~6-7 segundos por análise

### Tamanho do APK
- **Release**: ~81 MB (com modelo v2 de 3 classes)
- **Debug**: ~100+ MB

### Requisitos Mínimos
- **Android**: API 21+ (Android 5.0 Lollipop)
- **iOS**: iOS 12.0+
- **RAM**: 2GB+ recomendado
- **Armazenamento**: 100MB+ livre

---

## 📝 Notas Técnicas

### Processamento de Áudio

O processamento de áudio segue o seguinte pipeline:

1. **Captura**: PCM 16-bit, 16kHz, mono
2. **FFT**: Transformada de Fourier para domínio de frequência
3. **Mel Spectrogram**: Conversão para escala Mel (128 bins)
4. **Normalização**: Normalização dos valores para [0, 1]
5. **Adaptação**: Conversão de 1 canal para 3 canais (RGB)

### Modelo TensorFlow Lite

- **Formato**: TensorFlow Lite (quantizado)
- **Tamanho**: ~5-10 MB (aproximado)
- **Precisão**: Float32 ou Int8 (depende da quantização)
- **Otimizações**: NNAPI, GPU delegate (se disponível)

---

## 👥 Contribuição

Este é um projeto acadêmico/educacional. Para contribuições:

1. Fork o projeto
2. Crie uma branch (`git checkout -b feature/nova-funcionalidade`)
3. Commit suas mudanças (`git commit -m 'Adiciona nova funcionalidade'`)
4. Push para a branch (`git push origin feature/nova-funcionalidade`)
5. Abra um Pull Request

---

## 📄 Licença

Este projeto é de uso educacional/acadêmico.

---

## 🙏 Agradecimentos

- Equipe de desenvolvimento
- Comunidade Flutter
- TensorFlow Lite
- Contribuidores de bibliotecas open-source
- Google Fonts

---

## 📞 Contato e Suporte

Para dúvidas, sugestões ou problemas:
- Abra uma issue no repositório
- Consulte a documentação acima
- Verifique a seção de Troubleshooting

---

<div align="center">

**Última atualização**: Janeiro 2025  
**Versão**: 1.0.0  
**Modelo**: v2 (3 classes com calibração diferenciada)  
**Desenvolvido com ❤️ usando Flutter**

</div>
