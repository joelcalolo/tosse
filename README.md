# Diagnostico - Aplicação de Análise de Tosse com IA

## 📋 Índice

- [Visão Geral](#visão-geral)
- [Objetivos](#objetivos)
- [Tecnologias Utilizadas](#tecnologias-utilizadas)
- [Arquitetura do Projeto](#arquitetura-do-projeto)
- [Funcionalidades](#funcionalidades)
- [Modelo de IA](#modelo-de-ia)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Desenvolvimento e Evolução](#desenvolvimento-e-evolução)
- [Dificuldades Encontradas](#dificuldades-encontradas)
- [Como Executar](#como-executar)
- [Build e Deploy](#build-e-deploy)
- [Próximos Passos](#próximos-passos)

---

## 🎯 Visão Geral

**Diagnostico** é uma aplicação móvel desenvolvida em Flutter que utiliza inteligência artificial para analisar padrões acústicos de tosse e identificar possíveis sinais de patologias respiratórias, especificamente **Bronquite** e **Pneumonia**. O aplicativo processa gravações de áudio em tempo real, converte o sinal em espectrogramas Mel e utiliza um modelo TensorFlow Lite treinado para realizar a classificação.

### Características Principais

- 🎤 **Gravação de Áudio**: Captura de tosse com qualidade adequada para análise (16kHz, mono, 16-bit PCM)
- 🧠 **Análise com IA**: Processamento em tempo real usando modelo TensorFlow Lite
- 📊 **Resultados Detalhados**: Exibição de probabilidades para ambas as condições
- 🎨 **Interface Profissional**: Design médico profissional com UX otimizada
- 📱 **Multiplataforma**: Suporte para Android, iOS e Web

---

## 🎯 Objetivos

### Objetivo Principal
Desenvolver uma ferramenta de apoio ao diagnóstico que possa auxiliar profissionais de saúde e usuários na identificação precoce de sinais de patologias respiratórias através da análise acústica da tosse.

### Objetivos Específicos

1. **Captura e Processamento de Áudio**
   - Gravar tosse com qualidade adequada (16kHz, mono)
   - Converter áudio para formato adequado ao modelo

2. **Análise com IA**
   - Processar espectrogramas Mel (128x94)
   - Executar inferência com modelo TFLite
   - Retornar probabilidades para Bronquite e Pneumonia

3. **Interface do Usuário**
   - Design profissional e intuitivo
   - Feedback visual durante gravação e análise
   - Apresentação clara dos resultados

4. **Experiência do Usuário**
   - Fluxo simplificado (tela única)
   - Animações e transições suaves
   - Mensagens claras e informativas

---

## 🛠 Tecnologias Utilizadas

### Framework e Linguagem
- **Flutter** 3.5.0+ - Framework multiplataforma
- **Dart** 3.5.0+ - Linguagem de programação

### Bibliotecas Principais

#### Processamento de Áudio e IA
- **tflite_flutter** (^0.11.0) - Execução de modelos TensorFlow Lite
- **record** (^6.1.2) - Gravação de áudio
- **fftea** (^1.5.0+1) - Transformada de Fourier para processamento de sinais

#### Interface e Design
- **google_fonts** (^6.2.1) - Fontes Google (Outfit, Varela Round)
- **flutter_svg** (^2.0.10) - Renderização de SVGs

#### Utilitários
- **path_provider** (^2.1.2) - Acesso a diretórios do sistema
- **permission_handler** (^11.3.1) - Gerenciamento de permissões

### Plataformas e Ferramentas

#### Android
- **Gradle** 8.13 - Sistema de build
- **Kotlin** - Linguagem para código nativo Android
- **Java 17** - JDK utilizado
- **Android Gradle Plugin** - Plugin Flutter para Android

#### iOS
- **Xcode** - Ambiente de desenvolvimento iOS
- **CocoaPods** - Gerenciador de dependências

#### Build e Deploy
- **ProGuard/R8** - Ofuscação e otimização de código
- **Flutter Build Tools** - Ferramentas de build do Flutter

---

## 🏗 Arquitetura do Projeto

### Padrão de Arquitetura
O projeto segue uma arquitetura em camadas com separação de responsabilidades:

```
┌─────────────────────────────────────┐
│         UI Layer (Screens)          │
│  - HomeScreen (Tela única)          │
│  - Componentes visuais              │
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
│      Data Layer (Models/Assets)      │
│  - modelo_respiratorio.tflite        │
│  - Arquivos de áudio temporários     │
└─────────────────────────────────────┘
```

### Componentes Principais

#### 1. **HomeScreen** (`lib/screens/home/home_screen.dart`)
- Tela única que integra gravação e resultados
- Gerencia estado da aplicação (gravação, análise, resultados)
- Layout dividido: área superior (gravação) e inferior (resultados)

#### 2. **AudioRecorderService** (`lib/services/audio_recorder_service.dart`)
- Gerencia permissões de microfone
- Configura gravação (16kHz, mono, PCM16)
- Salva arquivos temporários

#### 3. **TfliteAnalyzerService** (`lib/services/tflite_analyzer_service.dart`)
- Carrega modelo TFLite
- Processa áudio em espectrogramas Mel
- Normaliza dados de entrada
- Executa inferência e retorna probabilidades

---

## ✨ Funcionalidades

### 1. Gravação de Áudio
- **Iniciar Gravação**: Botão para começar a captura
- **Parar Gravação**: Parada manual ou automática após 5 segundos
- **Feedback Visual**: Animações durante gravação (ondas pulsantes)
- **Status**: Mensagens claras sobre o estado da gravação

### 2. Processamento e Análise
- **Pré-processamento**: Conversão PCM → Espectrograma Mel (128x94)
- **Normalização**: Normalização dos dados para o modelo
- **Inferência**: Execução do modelo TFLite
- **Pós-processamento**: Interpretação das saídas do modelo

### 3. Apresentação de Resultados
- **Card Principal**: Diagnóstico sugerido com maior probabilidade
- **Cards de Probabilidade**: Bronquite e Pneumonia lado a lado
- **Interpretação**: Explicação dos resultados
- **Aviso Médico**: Lembrete sobre consulta profissional

### 4. Interface do Usuário
- **Design Profissional**: Cores médicas (azuis/verdes clínicos)
- **Animações Suaves**: Transições e feedback visual
- **Layout Responsivo**: Adaptação a diferentes tamanhos de tela
- **Acessibilidade**: Textos claros e contrastes adequados

---

## 🤖 Modelo de IA

### Especificações do Modelo

- **Formato**: TensorFlow Lite (`.tflite`)
- **Arquitetura Base**: MobileNet (adaptada)
- **Input Shape**: `[1, 128, 94, 3]`
  - 128: Bins Mel (frequências)
  - 94: Time steps (tempo)
  - 3: Canais RGB (adaptação de escala de cinza)
- **Output Shape**: `[1, 2]`
  - 2 classes: Pneumonia (índice 0) e Bronquite (índice 1)

### Processamento de Áudio

#### 1. Captura
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
- Output: [1, 2] (probabilidades)
  - output[0][0] = Probabilidade de Pneumonia
  - output[0][1] = Probabilidade de Bronquite
```

### Mapeamento de Classes

```dart
Índice 0 → Pneumonia
Índice 1 → Bronquite
```

---

## 📁 Estrutura do Projeto

```
mobile/
├── android/                 # Configurações Android
│   ├── app/
│   │   ├── build.gradle.kts
│   │   ├── proguard-rules.pro
│   │   └── src/main/
│   │       ├── AndroidManifest.xml
│   │       └── kotlin/com/example/diagnostico/
│   │           └── MainActivity.kt
│   └── build.gradle
├── ios/                     # Configurações iOS
│   └── Runner/
│       └── Info.plist
├── web/                     # Configurações Web
│   ├── index.html
│   └── manifest.json
├── lib/
│   ├── constants.dart       # Constantes e cores
│   ├── main.dart            # Ponto de entrada
│   ├── models/              # Modelos de dados
│   │   └── medical_category.dart
│   ├── screens/             # Telas da aplicação
│   │   └── home/
│   │       └── home_screen.dart
│   └── services/            # Serviços de negócio
│       ├── audio_recorder_service.dart
│       └── tflite_analyzer_service.dart
├── assets/
│   ├── models/
│   │   └── modelo_respiratorio.tflite
│   ├── images/
│   └── icons/
├── pubspec.yaml             # Dependências
└── README.md                # Documentação
```

---

## 🚀 Desenvolvimento e Evolução

### Fase 1: Configuração Inicial
- **Problema**: Projeto iniciado a partir de template antigo
- **Solução**: Limpeza e atualização de dependências
- **Mudanças**: 
  - Atualização do Gradle para 8.13
  - Configuração do Java 17
  - Correção de imports e dependências

### Fase 2: Integração do Modelo de IA
- **Desafio**: Integrar modelo TFLite com processamento de áudio
- **Solução**: 
  - Implementação de `TfliteAnalyzerService`
  - Processamento de espectrogramas Mel
  - Normalização de dados
- **Resultado**: Modelo funcionando corretamente

### Fase 3: Correção de Mapeamento de Classes
- **Problema**: Resultados sempre retornando "Pneumonia"
- **Causa**: Mapeamento incorreto das classes do modelo
- **Solução**: 
  - Identificação da ordem correta: `[Pneumonia, Bronquite]`
  - Correção do mapeamento no código
  - Adição de logs de debug
- **Resultado**: Classificação correta

### Fase 4: Redesign da Interface
- **Objetivo**: Interface profissional médica
- **Mudanças**:
  - Tela única unificada (gravação + resultados)
  - Layout dividido verticalmente
  - Paleta de cores médicas
  - Remoção de elementos desnecessários
  - Animações e feedback visual

### Fase 5: Refinamento da Apresentação
- **Mudanças**:
  - Card principal de diagnóstico destacado
  - Cards compactos lado a lado
  - Texto descritivo reformulado
  - Aviso médico adicionado

### Fase 6: Renomeação do Projeto
- **Mudança**: `Clinicaudio` → `Diagnostico`
- **Arquivos atualizados**:
  - `pubspec.yaml`
  - Configurações Android/iOS/Web
  - Package names e namespaces

---

## ⚠️ Dificuldades Encontradas

### 1. Problemas de Build Inicial

#### Erro: "Unresolved reference 'io'" e "Unresolved reference 'FlutterActivity'"
- **Causa**: Dependências do Flutter não resolvidas
- **Solução**: 
  - Adição do repositório Maven do Flutter
  - Limpeza de cache do Gradle
  - Atualização de dependências

#### Erro: "Invalid depfile"
- **Causa**: Cache corrompido do Flutter
- **Solução**: 
  - `flutter clean`
  - Remoção manual de `.gradle` e `build`
  - `flutter pub get`

#### Erro: "Minimum supported Gradle version is 8.13"
- **Causa**: Versão do Gradle incompatível
- **Solução**: Atualização do `gradle-wrapper.properties` para 8.13

#### Erro: "Java heap space"
- **Causa**: Memória insuficiente para o build
- **Solução**: 
  - Aumento de `org.gradle.jvmargs` para 4GB
  - Desabilitação do Jetifier

### 2. Problemas com Rede e Dependências

#### Erro: "Este anfitrião não é conhecido (storage.googleapis.com)"
- **Causa**: Problemas de rede ou firewall
- **Solução**: Adição explícita do repositório Maven do Flutter

### 3. Problemas com o Modelo de IA

#### Erro: Mapeamento Incorreto de Classes
- **Causa**: Ordem das classes no modelo não correspondia ao código
- **Sintoma**: Sempre retornava "Pneumonia"
- **Solução**: 
  - Análise dos logs de debug
  - Correção do mapeamento: `[Pneumonia (0), Bronquite (1)]`
  - Validação com testes reais

#### Erro: Normalização de Dados
- **Causa**: Dados não normalizados causavam resultados incorretos
- **Solução**: Implementação de função de normalização

### 4. Problemas de Build de Release

#### Erro: "Missing classes detected while running R8"
- **Causa**: R8 removendo classes necessárias do TensorFlow Lite
- **Solução**: 
  - Criação de `proguard-rules.pro`
  - Regras para manter classes do TFLite
  - Configuração no `build.gradle.kts`

### 5. Problemas de Estrutura

#### Erro: "Redeclaration: class MainActivity"
- **Causa**: Arquivo `MainActivity.kt` duplicado após renomeação
- **Solução**: Remoção do arquivo antigo do diretório `shop_app`

### 6. Desafios de UX/UI

#### Desafio: Simplificar Interface
- **Problema**: Interface inicial com muitos elementos desnecessários
- **Solução**: 
  - Redesign completo para tela única
  - Remoção de elementos não essenciais
  - Foco na experiência do usuário

---

## 🚀 Como Executar

### Pré-requisitos

1. **Flutter SDK** (3.5.0 ou superior)
   ```bash
   flutter --version
   ```

2. **Java JDK 17**
   ```bash
   java -version
   ```

3. **Android Studio** (para Android)
4. **Xcode** (para iOS - apenas macOS)

### Instalação

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

### Executar em Desenvolvimento

#### Android
```bash
flutter run
```

#### iOS (apenas macOS)
```bash
flutter run
```

#### Web
```bash
flutter run -d chrome
```

### Executar em Modo Release

#### Android
```bash
flutter run --release
```

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

---

## 🔧 Configurações Importantes

### Android (`android/app/build.gradle.kts`)

```kotlin
namespace = "com.example.diagnostico"
applicationId = "com.example.diagnostico"
compileSdk = flutter.compileSdkVersion
minSdk = flutter.minSdkVersion
targetSdk = flutter.targetSdkVersion
```

### ProGuard Rules (`android/app/proguard-rules.pro`)

```proguard
# TensorFlow Lite rules
-keep class org.tensorflow.lite.** { *; }
-keep class org.tensorflow.lite.gpu.** { *; }
-dontwarn org.tensorflow.lite.gpu.GpuDelegateFactory$Options
```

### Permissões Android (`AndroidManifest.xml`)

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET" />
```

---

## 📊 Métricas e Performance

### Tempo de Processamento
- **Gravação**: 5 segundos (configurável)
- **Análise**: ~1-2 segundos (depende do dispositivo)
- **Total**: ~6-7 segundos por análise

### Tamanho do APK
- **Release**: ~72.4 MB
- **Debug**: ~100+ MB

### Requisitos Mínimos
- **Android**: API 21+ (Android 5.0)
- **iOS**: iOS 12.0+
- **RAM**: 2GB+ recomendado

---

## 🔮 Próximos Passos

### Melhorias Planejadas

1. **Funcionalidades**
   - [ ] Histórico de análises
   - [ ] Exportação de resultados
   - [ ] Compartilhamento de resultados
   - [ ] Múltiplas gravações por sessão

2. **Melhorias de IA**
   - [ ] Suporte a modelos de 3 classes (incluindo Normal)
   - [ ] Calibração de confiança
   - [ ] Análise de múltiplos segmentos de áudio

3. **Interface**
   - [ ] Modo escuro
   - [ ] Personalização de temas
   - [ ] Gráficos de histórico
   - [ ] Tutorial/Onboarding

4. **Performance**
   - [ ] Otimização do modelo
   - [ ] Processamento em background
   - [ ] Cache de resultados

5. **Segurança e Privacidade**
   - [ ] Criptografia de dados locais
   - [ ] Política de privacidade
   - [ ] Opção de processamento offline

6. **Documentação**
   - [ ] Documentação da API
   - [ ] Guia de contribuição
   - [ ] Testes automatizados

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

---

## 📞 Contato

Para dúvidas ou sugestões, abra uma issue no repositório.

---

**Última atualização**: 2024
**Versão**: 1.0.0
