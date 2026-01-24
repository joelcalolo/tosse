# 📱 TosseControl - Resumo Descritivo do Aplicativo

## 🎯 O que é o TosseControl?

O **TosseControl** é um aplicativo móvel desenvolvido em Flutter que utiliza Inteligência Artificial (TensorFlow Lite) para analisar padrões acústicos de tosse e identificar possíveis sinais de patologias respiratórias, especificamente **Bronquite** e **Pneumonia**.

---

## 🎤 Funcionalidade Principal

O aplicativo permite que o usuário **grave sua tosse** e, em poucos segundos, receba uma **análise automática** com probabilidades de diferentes condições respiratórias. Tudo isso de forma rápida, segura e totalmente offline.

---

## ✨ Características Principais

### 1. **Gravação Intuitiva**
- Interface simples com um único botão
- Gravação automática de 5 segundos
- Feedback visual durante a gravação (ondas pulsantes)
- Parada manual opcional

### 2. **Análise com IA**
- Processamento em tempo real usando TensorFlow Lite
- Análise de espectrogramas Mel (representação espectral do áudio)
- Classificação automática de múltiplas condições
- Resultados em poucos segundos (~6-7 segundos no total)

### 3. **Resultados Detalhados**
- **Card principal**: Mostra o diagnóstico sugerido com maior probabilidade
- **Cards individuais**: Probabilidades separadas para cada condição
- **Barras de progresso**: Visualização clara das probabilidades
- **Interpretação**: Explicação dos resultados em linguagem simples
- **Aviso médico**: Lembrete importante sobre consulta profissional

### 4. **Interface Profissional**
- Design moderno e limpo com paleta de cores médicas
- Animações suaves e transições elegantes
- Layout responsivo que se adapta a diferentes tamanhos de tela
- Cards com efeitos 3D para melhor experiência visual
- Tipografia profissional (Google Fonts: Outfit e Varela Round)

### 5. **Segurança e Privacidade**
- Processamento 100% local (offline)
- Nenhum dado enviado para servidores
- Arquivos temporários limpos automaticamente
- Permissão de microfone solicitada apenas quando necessário

---

## 🏠 Tela Inicial (Home)

A tela inicial apresenta:

- **Logo e Título**: Identificação clara do aplicativo
- **Cards de Características**: 
  - ⚡ **Rápido**: Análise em segundos
  - ✅ **Preciso**: IA avançada
  - 🔒 **Seguro**: Privacidade total
- **Instruções de Uso**: Passo a passo simples
- **Botão de Início**: Acesso direto à análise

---

## 🔬 Tela de Análise

A tela de análise é onde toda a magia acontece:

### Estados Visuais:

1. **Aguardando** (Estado Inicial)
   - Visualizador circular azul
   - Ícone de microfone
   - Botão "Iniciar Gravação"

2. **Gravando**
   - Visualizador animado com ondas pulsantes vermelhas
   - Animação de ondas concêntricas
   - Status: "Gravando..."
   - Botão "Parar Gravação"

3. **Analisando**
   - Visualizador verde com indicador de progresso circular
   - Status: "Analisando padrões acústicos..."
   - Processamento automático em background

4. **Resultados**
   - Card principal destacando o diagnóstico sugerido
   - Cards compactos com probabilidades individuais
   - Mensagem interpretativa
   - Aviso médico importante
   - Botão para nova análise

---

## 🎨 Design e Experiência

### Paleta de Cores
- **Azul Índigo** (`#6366F1`): Cor principal, transmite confiança e profissionalismo
- **Verde Esmeralda** (`#10B981`): Sucesso, análise concluída
- **Âmbar** (`#F59E0B`): Bronquite
- **Vermelho** (`#EF4444`): Pneumonia
- **Verde** (`#22C55E`): Normal

### Animações
- Transições suaves entre estados
- Feedback visual em todas as interações
- Animações de entrada escalonadas
- Efeitos 3D em botões e cards

### Usabilidade
- Interface intuitiva e autoexplicativa
- Fluxo linear sem complicações
- Mensagens claras em cada etapa
- Feedback imediato para todas as ações

---

## 🔧 Tecnologia

### Stack Técnico
- **Flutter**: Framework multiplataforma (Android, iOS, Web)
- **TensorFlow Lite**: Modelo de IA para inferência local
- **FFTEA**: Processamento de sinais de áudio
- **Record**: Gravação de áudio nativa

### Processamento
1. **Captura**: Áudio em PCM 16-bit, 16kHz, mono
2. **Transformação**: Conversão para espectrograma Mel (128x94)
3. **Normalização**: Preparação dos dados para o modelo
4. **Inferência**: Análise com TensorFlow Lite
5. **Resultado**: Probabilidades de cada condição

---

## 📊 Resultados e Interpretação

### Formato dos Resultados

O aplicativo retorna probabilidades (0% a 100%) para cada condição:

**Exemplo de Resultado:**
```
Pneumonia: 75%
Bronquite: 20%
Normal: 5%
```

### Apresentação Visual

- **Card Principal**: Destaca a condição com maior probabilidade
  - Ícone representativo
  - Nome da condição em destaque
  - Porcentagem de confiança

- **Cards Secundários**: Mostram todas as probabilidades
  - Ícone de cada condição
  - Porcentagem animada
  - Barra de progresso visual

- **Interpretação**: Texto explicativo sobre os resultados
- **Aviso Médico**: Lembrete sobre consulta profissional

---

## ⚠️ Avisos Importantes

### Uso Médico
- ⚠️ **Este aplicativo é uma ferramenta de apoio**
- ⚠️ **Não substitui consulta médica profissional**
- ⚠️ **Resultados são preliminares**
- ⚠️ **Sempre consulte um profissional de saúde para diagnóstico adequado**

### Privacidade
- ✅ Processamento 100% local
- ✅ Nenhum dado enviado para servidores
- ✅ Arquivos temporários são limpos automaticamente
- ✅ Permissões solicitadas apenas quando necessário

---

## 📱 Compatibilidade

### Plataformas Suportadas
- ✅ **Android**: API 21+ (Android 5.0 Lollipop e superior)
- ✅ **iOS**: iOS 12.0 e superior
- ✅ **Web**: Suporte básico (funcionalidades limitadas)

### Requisitos
- **RAM**: 2GB+ recomendado
- **Armazenamento**: 100MB+ livre
- **Permissões**: Acesso ao microfone

---

## 🚀 Como Usar

### Passo a Passo

1. **Abra o aplicativo**
   - Visualize a tela inicial com informações

2. **Toque em "Iniciar Análise"**
   - Você será direcionado para a tela de análise

3. **Toque em "Iniciar Gravação"**
   - O aplicativo solicitará permissão de microfone (primeira vez)
   - A gravação inicia automaticamente

4. **Tussa naturalmente**
   - Mantenha o dispositivo próximo à boca
   - A gravação dura 5 segundos (ou pare manualmente)

5. **Aguarde a análise**
   - O aplicativo processa automaticamente
   - Status: "Analisando padrões acústicos..."

6. **Visualize os resultados**
   - Card principal com diagnóstico sugerido
   - Cards com probabilidades detalhadas
   - Interpretação dos resultados

7. **Nova análise (opcional)**
   - Toque no botão de refresh para nova análise
   - Ou use o botão "Iniciar Gravação" novamente

---

## 💡 Dicas de Uso

### Para Melhores Resultados
- ✅ Grave em ambiente silencioso
- ✅ Mantenha o dispositivo próximo à boca (30-50cm)
- ✅ Tussa naturalmente (não force)
- ✅ Evite ruídos de fundo
- ✅ Aguarde a análise completa antes de gravar novamente

### Quando Usar
- 🔍 Para monitoramento de sintomas
- 🔍 Como ferramenta de triagem inicial
- 🔍 Para acompanhamento de condições respiratórias
- ⚠️ **Sempre** consulte um médico para diagnóstico definitivo

---

## 📦 Informações Técnicas

### Tamanho do APK
- **Release**: ~80.9 MB
- Inclui modelo de IA e todas as dependências

### Performance
- **Tempo de gravação**: 5 segundos
- **Tempo de análise**: ~1-2 segundos
- **Tempo total**: ~6-7 segundos

### Modelo de IA
- **Tipo**: TensorFlow Lite
- **Arquitetura**: MobileNet (adaptada)
- **Classes**: 2 ou 3 (Pneumonia, Bronquite, Normal)
- **Processamento**: 100% local/offline

---

## 🎯 Público-Alvo

### Usuários Principais
- 👥 Pessoas com sintomas respiratórios
- 👥 Profissionais de saúde (ferramenta de apoio)
- 👥 Usuários interessados em monitoramento de saúde
- 👥 Pesquisadores e estudantes

### Casos de Uso
- Triagem inicial de sintomas
- Monitoramento de condições respiratórias
- Apoio ao diagnóstico médico
- Pesquisa e desenvolvimento

---

## 🔮 Visão Futura

### Melhorias Planejadas
- 📊 Histórico de análises
- 📈 Gráficos de evolução
- 📤 Exportação de resultados
- 🌙 Modo escuro
- 🌍 Internacionalização
- 📝 Relatórios detalhados

---

## 📞 Suporte

Para dúvidas, sugestões ou problemas:
- Consulte a documentação técnica
- Verifique a seção de troubleshooting
- Abra uma issue no repositório

---

## 📄 Licença

Este projeto é de uso educacional/acadêmico.

---

<div align="center">

**TosseControl**  
*Análise Inteligente de Tosse com IA*

**Versão**: 1.0.0  
**Desenvolvido com ❤️ usando Flutter**

</div>

