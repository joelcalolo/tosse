# 🚀 Guia Rápido de Início

## Instalação Rápida

```bash
# 1. Criar ambiente virtual
python -m venv venv

# 2. Ativar ambiente virtual
# Windows:
venv\Scripts\activate
# Linux/Mac:
source venv/bin/activate

# 3. Instalar dependências
pip install -r requirements.txt
```

## 📁 Estrutura de Dados

Organize seus dados de áudio da seguinte forma:

```
data/raw/
├── normal/
│   ├── cough_001.wav
│   ├── cough_002.wav
│   └── ...
├── bronquite/
│   ├── cough_001.wav
│   ├── cough_002.wav
│   └── ...
└── pneumonia/
    ├── cough_001.wav
    ├── cough_002.wav
    └── ...
```

## 🎯 Fluxo de Trabalho

### 1. Pré-processar Áudios (Opcional)

```python
from src.preprocessing.audio_processor import AudioProcessor

processor = AudioProcessor()
processed = processor.process("data/raw/normal/cough_001.wav")
processor.save_processed(processed, "data/processed/normal/cough_001.wav")
```

### 2. Treinar Modelo

```bash
python src/training/train.py --data_dir data/raw --epochs 50 --batch_size 32
```

**Parâmetros disponíveis:**
- `--data_dir`: Diretório com dados organizados por classe
- `--epochs`: Número de épocas (padrão: 50)
- `--batch_size`: Tamanho do batch (padrão: 32)
- `--feature_type`: Tipo de característica (`mel` ou `mfcc`, padrão: `mel`)
- `--model_type`: Tipo de modelo (`cnn` ou `mobilenet`, padrão: `cnn`)
- `--output_dir`: Diretório para salvar modelos (padrão: `models`)

### 3. Fazer Predições

```bash
python src/predict.py --audio_path audio.wav --model_path models/best_model.h5 --classes Normal Bronquite Pneumonia
```

### 4. Converter para TensorFlow Lite (se necessário)

```bash
python src/models/convert_to_tflite.py --model_path models/best_model.h5 --output_path models/tflite/model.tflite
```

## 📊 Usando o Jupyter Notebook

Abra `tosse.ipynb` para exemplos interativos de:
- Pré-processamento de áudio
- Extração de características
- Visualização de espectrogramas
- Construção de modelos

## 🔧 Configurações Recomendadas

### Para Treinamento Inicial
- **Feature Type**: `mel` (melhor para CNNs)
- **Model Type**: `cnn` (mais rápido para treinar)
- **Epochs**: 30-50
- **Batch Size**: 16-32

### Para Produção Mobile
- **Feature Type**: `mel`
- **Model Type**: `mobilenet` (otimizado para dispositivos móveis)
- **Quantization**: `float16` ou `int8` (menor tamanho)

## 📚 Datasets Recomendados

1. **ICBHI**: https://bhichallenge.med.auth.gr/
2. **COSWARA**: https://github.com/iiscleap/Coswara-Data
3. **COUGHVID**: https://coughvid.epfl.ch/

## ⚠️ Importante

- **Este projeto é para fins educacionais e de pesquisa**
- **Não substitui diagnóstico médico profissional**
- Sempre valide resultados com profissionais de saúde
- Use dados com consentimento e respeitando privacidade

## 🐛 Solução de Problemas

### Erro: "No module named 'src'"
- Certifique-se de estar no diretório raiz do projeto
- Verifique se o ambiente virtual está ativado

### Erro ao processar áudio
- Verifique se o arquivo está no formato correto (.wav)
- Confirme que o arquivo não está corrompido

### Modelo muito grande para mobile
- Use `model_type='mobilenet'`
- Aplique quantização `int8`
- Reduza número de filtros na CNN

