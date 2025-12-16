# Guia Completo: Usando Colab com API Kaggle para Processar ICBHI

Este guia detalha como usar o Google Colab integrado ao Cursor para processar o dataset ICBHI, treinar um modelo e gerar TFLite para aplicações móveis.

## Pré-requisitos

1. **Conta Kaggle**: Crie uma conta em [kaggle.com](https://www.kaggle.com)
2. **Credenciais API Kaggle**: 
   - Acesse [Kaggle Account Settings](https://www.kaggle.com/account)
   - Vá em "API" e clique em "Create New Token"
   - Isso baixará um arquivo `kaggle.json` com suas credenciais
3. **Cursor com extensão Colab** (ou acesso ao Google Colab diretamente)

## Passo a Passo

### 1. Preparar Credenciais Kaggle

Você tem três opções para configurar credenciais:

#### Opção A: Upload do arquivo kaggle.json (Recomendado)
1. No Colab, execute a célula de upload:
```python
from google.colab import files
uploaded = files.upload()
```
2. Selecione o arquivo `kaggle.json` baixado do Kaggle
3. O arquivo será automaticamente copiado para `~/.kaggle/kaggle.json`

#### Opção B: Configurar manualmente
Edite a célula 2 do notebook e descomente:
```python
kaggle_credentials = {
    "username": "seu_usuario_kaggle",
    "key": "sua_chave_api_kaggle"
}
```

#### Opção C: Variáveis de ambiente
Configure no sistema ou no Colab:
```python
import os
os.environ['KAGGLE_USERNAME'] = 'seu_usuario'
os.environ['KAGGLE_KEY'] = 'sua_chave'
```

### 2. Abrir Notebook no Colab

#### Via Cursor:
1. Abra o arquivo `notebooks/colab_icbhi_training.ipynb` no Cursor
2. Clique com botão direito e selecione "Open in Colab" (se tiver extensão)
3. Ou copie o conteúdo e cole no Google Colab

#### Via Google Colab diretamente:
1. Acesse [colab.research.google.com](https://colab.research.google.com)
2. Faça upload do notebook `colab_icbhi_training.ipynb`
3. Ou crie novo notebook e copie as células

### 3. Upload do Código Fonte

Antes de executar, você precisa fazer upload do código fonte do projeto:

**Opção 1: Upload direto**
```python
# No Colab, execute:
from google.colab import files
uploaded = files.upload()  # Selecione todos os arquivos da pasta src/
```

**Opção 2: Clonar do GitHub** (se o projeto estiver no GitHub)
```python
!git clone https://github.com/seu-usuario/tosse.git
%cd tosse
```

**Opção 3: Copiar manualmente**
Crie as pastas e arquivos manualmente no Colab ou use o sistema de arquivos.

### 4. Executar Células em Sequência

Execute cada célula do notebook na ordem:

#### Célula 1: Setup Inicial
- Instala dependências
- Configura ambiente
- Verifica GPU disponível

#### Célula 2: Download Dataset
- Configura credenciais Kaggle
- Baixa dataset ICBHI automaticamente
- Extrai arquivos para `/content/tmp/icbhi`

**Tempo estimado**: 5-10 minutos (dependendo da velocidade de download)

#### Célula 3: Processamento
- Filtra apenas Pneumonia e Bronchitis
- Processa todos os áudios (16kHz, mono, filtro Butterworth)
- Extrai características MFCC e Log-Mel
- Divide em treino/validação/teste
- Salva em arquivos `.npy`

**Tempo estimado**: 30-60 minutos (dependendo do tamanho do dataset)

#### Célula 4: Visualização
- Carrega dados processados
- Visualiza espectrogramas de exemplo
- Mostra estatísticas dos dados

#### Célula 5: Treinamento
- Cria modelo MobileNetV2
- Treina usando GPU do Colab
- Salva melhor modelo durante treinamento
- Plota gráficos de acurácia e loss

**Tempo estimado**: 1-3 horas (dependendo do número de épocas)

#### Célula 6: Conversão TFLite
- Converte modelo para TensorFlow Lite
- Aplica quantização (float16 ou int8)
- Verifica tamanho do modelo final

#### Célula 7: Download
- Salva modelo no Google Drive (opcional)
- Prepara download direto
- Cria arquivo ZIP com modelo e metadados

### 5. Fazer Download do Modelo

Você tem três opções:

#### Opção A: Google Drive
O modelo será automaticamente salvo em `/content/drive/MyDrive/tosse_models/`

#### Opção B: Download Direto
1. No Colab, vá em "Files" no painel lateral
2. Navegue até `/content/models/tflite/`
3. Clique com botão direito no arquivo `.tflite`
4. Selecione "Download"

#### Opção C: Arquivo ZIP
O notebook cria um arquivo ZIP em `/content/models/cough_classifier_model.zip`
- Baixe este arquivo
- Contém modelo TFLite e metadados

## Estrutura de Arquivos Gerados

Após processamento completo, você terá:

```
/content/
├── tmp/
│   └── icbhi/              # Dataset baixado
├── processed_data/          # Dados processados
│   ├── X_train_mel.npy
│   ├── X_val_mel.npy
│   ├── X_test_mel.npy
│   ├── X_train_mfcc.npy
│   ├── X_val_mfcc.npy
│   ├── X_test_mfcc.npy
│   ├── y_train.npy
│   ├── y_val.npy
│   ├── y_test.npy
│   └── metadata.json
└── models/
    ├── best_model.h5        # Modelo Keras completo
    └── tflite/
        └── cough_classifier_fp16.tflite  # Modelo para mobile
```

## Troubleshooting

### Erro: "Kaggle API credentials not found"
**Solução**: Certifique-se de que o arquivo `kaggle.json` está em `~/.kaggle/` com permissões corretas (600)

### Erro: "Dataset not found"
**Solução**: Verifique se o nome do dataset está correto. O dataset ICBHI pode ter nomes diferentes no Kaggle.

### Erro: "Out of memory"
**Solução**: 
- Reduza o `batch_size` no treinamento
- Processe menos amostras por vez
- Use quantização int8 em vez de float16

### Erro: "GPU not available"
**Solução**: 
- No Colab, vá em Runtime → Change runtime type
- Selecione "GPU" em Hardware accelerator
- Salve e reinicie o runtime

### Processamento muito lento
**Soluções**:
- Certifique-se de que GPU está habilitada
- Reduza número de épocas para teste
- Processe apenas uma parte do dataset inicialmente

## Dicas e Boas Práticas

1. **Salve Progresso**: Use Google Drive para salvar dados processados e evitar reprocessar
2. **Checkpoints**: O modelo salva automaticamente o melhor checkpoint durante treinamento
3. **Monitoramento**: Acompanhe métricas de treinamento nos gráficos gerados
4. **Teste Primeiro**: Execute com dataset pequeno primeiro para validar o pipeline
5. **Backup**: Sempre faça backup do modelo final antes de fechar o Colab

## Limites do Colab

- **Tempo de Sessão**: Sessões gratuitas têm limite de ~12 horas
- **GPU**: Pode não estar sempre disponível (fila de espera)
- **Armazenamento**: Limite de ~80GB de disco temporário
- **Download Kaggle**: Limite de 5 downloads por hora via API

## Próximos Passos

Após obter o modelo TFLite:

1. **Integrar em App Mobile**: Use o modelo em aplicativo Flutter/React Native
2. **Testar em Dispositivo**: Valide performance em dispositivo real
3. **Otimizar**: Ajuste quantização ou arquitetura se necessário
4. **Deploy**: Publique aplicativo com modelo integrado

## Suporte

Para problemas ou dúvidas:
- Verifique logs de erro no Colab
- Consulte documentação do [Kaggle API](https://www.kaggle.com/docs/api)
- Verifique [TensorFlow Lite Guide](https://www.tensorflow.org/lite)

