# Projeto de Análise de Tosse para Detecção de Pneumonia e Bronquite

## 📋 Descrição

Aplicação móvel capaz de analisar o som da tosse e auxiliar na identificação de pneumonia e bronquite através de técnicas de Machine Learning e processamento de áudio.

## 🏗️ Estrutura do Projeto

```
tosse/
├── data/                  # Datasets e áudios
│   ├── raw/              # Áudios brutos
│   ├── processed/        # Áudios pré-processados
│   └── features/         # Características extraídas
├── models/               # Modelos treinados
│   ├── checkpoints/     # Checkpoints durante treino
│   └── tflite/          # Modelos otimizados para mobile
├── src/                  # Código fonte
│   ├── data/            # Processamento de datasets (ICBHI)
│   ├── preprocessing/   # Pré-processamento de áudio
│   ├── features/        # Extração de características
│   ├── models/          # Arquiteturas de ML
│   ├── training/        # Scripts de treinamento
│   └── utils/           # Utilitários (Kaggle API, etc.)
├── notebooks/           # Jupyter notebooks para análise
│   └── colab_icbhi_training.ipynb  # Notebook completo para Colab
├── mobile/              # Código da aplicação móvel (futuro)
├── requirements.txt     # Dependências Python
├── requirements_colab.txt  # Dependências específicas do Colab
└── GUIA_COLAB_KAGGLE.md  # Guia completo para usar Colab + Kaggle
```

## 🚀 Instalação

1. Clone o repositório
2. Crie um ambiente virtual:
```bash
python -m venv venv
source venv/bin/activate  # Linux/Mac
# ou
venv\Scripts\activate  # Windows
```

3. Instale as dependências:
```bash
pip install -r requirements.txt
```

## 📊 Uso

### Opção 1: Google Colab (Recomendado para Dataset ICBHI)

Para processar o dataset ICBHI diretamente na nuvem sem baixar para seu PC:

1. **Abra o notebook Colab**:
   - Abra `notebooks/colab_icbhi_training.ipynb` no Google Colab
   - Ou use a extensão Colab no Cursor

2. **Configure credenciais Kaggle**:
   - Siga instruções na célula 2 do notebook
   - Veja guia completo em [GUIA_COLAB_KAGGLE.md](GUIA_COLAB_KAGGLE.md)

3. **Execute células em sequência**:
   - O notebook baixa dataset automaticamente
   - Processa dados (filtragem, padronização, extração)
   - Treina modelo MobileNetV2
   - Gera modelo TFLite pronto para mobile

**Vantagens**: 
- Não precisa baixar GBs de dados
- Usa GPU gratuita do Colab
- Processamento rápido na nuvem

### Opção 2: Processamento Local

#### 1. Processar Dataset ICBHI
```bash
python src/data/process_icbhi_dataset.py \
    --data_dir /caminho/para/icbhi \
    --diagnosis_csv /caminho/para/patient_diagnosis.csv \
    --output_dir processed_data \
    --use_butterworth \
    --extract_mel
```

#### 2. Treinar com Dados Processados
```bash
python src/training/train.py \
    --data_dir processed_data \
    --use_processed \
    --feature_type mel \
    --model_type mobilenet \
    --epochs 50
```

#### 3. Pré-processamento de Áudio Individual
```python
from src.preprocessing.audio_processor import AudioProcessor

processor = AudioProcessor(
    sample_rate=16000,
    use_butterworth=True,
    butterworth_cutoff=8000.0
)
processed_audio = processor.process("data/raw/cough.wav")
```

#### 4. Extração de Características
```python
from src.features.feature_extractor import FeatureExtractor

extractor = FeatureExtractor()
mfcc = extractor.extract_mfcc(processed_audio)
mel_spec = extractor.extract_mel_spectrogram(processed_audio)
```

#### 5. Conversão para TensorFlow Lite
```bash
python src/models/convert_to_tflite.py \
    --model_path models/best_model.h5 \
    --output_path models/tflite/model.tflite \
    --quantization float16
```

## ⚠️ Aviso Importante

**Esta aplicação não substitui o diagnóstico médico profissional.** Use apenas como ferramenta auxiliar de triagem.

## 📝 Licença

Este projeto é para fins educacionais e de pesquisa.

