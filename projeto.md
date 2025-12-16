

##**PROJECTO PRÁTICO 1****CONSTRUÇÃO DE UMA APLICAÇÃO MÓVEL CAPAZ DE ANALISAR O SOM DA TOSSE E A SEGUIR AUXILIAR NA IDENTIFICAÇÃO DE PNEUMONIA E BRONQUITE.** 

**LUBANGO, 2025** 

---

###**Breve Introdução**O objectivo principal deste projecto é construir uma aplicação móvel para analisar sons de tosse e auxiliar na identificação de pneumonia e bronquite. A explicação seguinte detalha as etapas, ferramentas e datasets necessários para uma implementação real.

###**1. Etapas do Desenvolvimento**####1.1. Definição do problema e requisitos 

* 
**Objetivos**: Detectar padrões sonoros associados à pneumonia e bronquite.


* 
**Restrições**: Privacidade dos dados, ruído ambiental e baixa capacidade de processamento dos dispositivos móveis.


* 
**Tipo de saída**: Binária (pneumonia vs. bronquite) ou multiclass (normal, bronquite, pneumonia, outras patologias).



####1.2. Recolha e preparação dos dados 

* Reunir gravações de tosse rotuladas.


* Padronizar o formato: 16 kHz, 16-bit, mono.


* Remoção de ruído utilizando filtros como Wiener, Butterworth ou RNNoise.


* Divisão dos dados em: treino, validação e teste.



####1.3. Extracção de características (Feature Engineering) 

As técnicas mais utilizadas incluem:

* 
**MFCC**: Capturam o timbre e a forma do espectro.


* 
**Espectrogramas (Log-Mel)**: Usados com CNNs.


* 
**Zero Crossing Rate (ZCR)**: Identifica intensidade e irregularidades.


* 
**Chroma Features**: Úteis para tonalidade.


* 
**Tempo e Ritmo**: Mede padrões de crises de tosse.


* 
**Ferramentas**: Librosa, PyTorch torchaudio e TensorFlow Audio ops.



####1.4. Treino do modelo de Machine Learning 

| Tipo | Exemplo de modelo | Vantagens |
| --- | --- | --- |
| **CNN** | VGGish, ResNet, CNN custom | Óptimo para espectrogramas 

 |
| **RNN/LSTM** | BILSTM | Bom para sequenciais 

 |
| **Transformers** | AST (Audio Spectrogram Transformer) | SOTA para áudio 

 |
| **CNN+LSTM híbrido** | Custom | Combina padrões visuais + temporais 

 |

**Arquitectura recomendada para móvel**: CNN leve (MobileNetV2 Audio) com Output Softmax.

####1.5. Otimização para dispositivos móveis 

* 
**TensorFlow Lite**: Quantização (INT8, float16) e TFLite Micro.


* 
**PyTorch Mobile** / Lite Interpreter.


* 
**ONNX Runtime Mobile**: Converte modelos de PyTorch e TensorFlow.



####1.6. Construção da aplicação móvel 

* 
**Front-end**: Flutter, React Native ou Nativo (Kotlin/Swift).


* 
**Bibliotecas de áudio**: Flutter Sound, React Native Audio Recorder Player, Android MediaRecorder ou iOS AVAudio Recorder.


* 
**Processamento local**: Pré-processar a tosse em tempo real e rodar o modelo localmente para maior privacidade.



####1.7. Backend opcional 

* Serviços para análise pesada, armazenamento de áudios e dashboards.


* Tecnologias: FastAPI, Django, Node.js, PostgreSQL ou MongoDB.



---

###2. Ferramentas recomendadas 

* 
**Linguagens/Frameworks**: Python, TensorFlow/Keras, PyTorch.


* 
**Pré-processamento**: Librosa, Audacity, FFmpeg.


* 
**Machine Learning**: Scikit-learn, TensorFlow Lite, PyTorch Mobile, ONNX Runtime.


* 
**Infraestrutura**: Google Colab, Kaggle, Jupyter, AWS.



---

###3. Datasets para Treinar Modelos de Tosse 

1. 
**COUGHVID**: Grande dataset com rótulos de COVID e sintomas respiratórios.


2. 
**Coswara**: Sons de tosse, respiração e fala.


3. 
**ICBHI**: Base clássica para bronquite, pneumonia e asma.


4. 
**AICSR**: Alta qualidade e metadados clínicos.


5. 
**Healthily**: Tosse classificada por especialistas (seca, produtiva, etc.).


6. 
**VIRUFY**: Focado em doenças respiratórias e COVID-19.


7. 
**Respiratory Sound Challenge**: Sons categorizados.


8. 
**Pediatric Pneumonia**: Dados específicos de crianças (útil, mas pequeno).



---

###4. Arquitetura Sugerida para o Sistema 

* 
**Aplicativo Móvel**: Audio Recorder \rightarrow Pré-processamento (Normalização, Remoção de ruído, Espectrograma) \rightarrow Modelo TFLite no dispositivo \rightarrow Predição \rightarrow Interface de resultado (Risco de bronquite / pneumonia).



---

###5. Boas práticas 

* Recolher dados reais localmente com consentimento.


* Testar em ambientes ruidosos e validar com profissionais de saúde.


* 
**Aviso**: Incluir nota de que a aplicação não substitui diagnóstico médico.



---

Gostaria que eu elaborasse um plano detalhado para alguma das etapas específicas, como a extração de características (MFCC) no Python?