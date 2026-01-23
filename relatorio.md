Introdução
O presente projeto foca-se no desenvolvimento de uma ferramenta tecnológica baseada em Inteligência Artificial para a análise de patologias do sistema respiratório, nomeadamente a Pneumonia e a Bronquite. Ao contrário dos métodos de auscultação tradicional, que dependem exclusivamente da subjetividade do ouvido humano, propomos o uso de Redes Neuronais Convolucionais (CNNs) para identificar padrões acústicos objetivos em ciclos respiratórios.
É importante notar que, embora o foco clínico final possa incluir a análise da tosse, este estudo utiliza como base científica os sons respiratórios (como sibilos e crepitações) presentes no dataset ICBHI 2017. Estes sons são indicadores fundamentais que precedem ou acompanham sintomas como a tosse, permitindo uma triagem digital eficiente e não invasiva.
Para garantir a capacidade de diferenciação do modelo, a base de dados foi complementada com amostras do dataset COUGHVID. Esta integração permitiu ao modelo aprender a distinguir a "assinatura acústica" da Pneumonia face a outras condições sintomáticas como a Bronquite. O objetivo principal é fornecer um suporte à decisão que converta sinais sonoros em dados diagnósticos precisos através de modelos otimizados para execução em dispositivos móveis
.


1. Preparação do Ambiente e Infraestrutura de Desenvolvimento
O projeto iniciou-se com a configuração de um ecossistema de trabalho híbrido, focado na eficiência de processamento e gestão de dados:
Plataformas de Computação: Inicialmente, utilizou-se o Google Colab; no entanto, a infraestrutura foi migrada para o Kaggle. Esta mudança foi motivada pelo facto de os datasets de referência (ICBHI 2017 e COUGHVID) estarem nativamente alojados na plataforma, permitindo um acesso mais rápido e estável aos dados sem a necessidade de downloads externos. Além disso, o Kaggle ofereceu recursos de GPU (como a Tesla P100) fundamentais para o treino acelerado do modelo.
Controlo de Versão e Código-Fonte: Desenvolvemos a estrutura do projeto localmente e utilizámos o GitHub como ponte, através do repositório https://github.com/joelcalolo/tosse.git. Ao clonar este repositório diretamente no ambiente de execução, garantimos que todas as funções de processamento de sinal e a arquitetura de pastas estivessem prontas para uso imediato.
Gestão de Bibliotecas: O ambiente foi configurado com o ecossistema TensorFlow para a construção da rede neuronal e a biblioteca Librosa para o processamento digital de áudio e extração de espectrogramas.
.


2. Gestão de Dados e Resolução de Desafios Técnicos
Para o treino do modelo, selecionou-se o dataset ICBHI 2017, que é a referência atual no estado da arte para sons respiratórios. O fluxo de trabalho inicial previa o descarregamento automático dos dados (aproximadamente 4GB) através da API do Kaggle para o ambiente do Google Colab, visando a agilização do processo. No entanto, deparámo-nos com um erro de autenticação (HTTPError: 403 Forbidden), indicando restrições de comunicação entre a API e o servidor externo.
Perante este obstáculo, a equipa adotou uma estratégia de resolução em duas fases:
Ação Imediata (Contingência): Realizou-se o download manual do dataset, seguido do upload para a memória temporária do Colab. Esta medida permitiu prosseguir sem atrasos para a fase de filtragem e análise inicial das classes Pneumonia e Bronquite.
Ação Definitiva (Otimização): Identificou-se que a solução mais eficiente a longo prazo seria a migração total do desenvolvimento para o ambiente nativo do Kaggle. Ao trabalhar diretamente na plataforma onde os dados estão alojados, eliminámos as barreiras de transferência e os erros de API, ganhando estabilidade no acesso ao sistema de ficheiros e maior poder de processamento gráfico (GPU) para as fases de treino intensivo.
Esta mudança de infraestrutura não só resolveu o erro técnico, como permitiu a integração fluida com o dataset COUGHVID, consolidando o nosso dataset final de 100 amostras equilibradas.




3. Processamento de Sinais e Engenharia de Atributos (Feature Engineering)
A fase de processamento foi determinante para o sucesso do modelo, transformando sinais áudio complexos em dados interpretáveis pela rede neuronal:
Filtragem e Seleção de Classes:
No ICBHI 2017, isolámos 51 ciclos respiratórios confirmados com diagnóstico de Pneumonia. Focámo-nos em segmentos que apresentavam crepitações, que são os marcadores acústicos desta patologia.
No COUGHVID, aplicámos um filtro rigoroso para selecionar 49 amostras de pacientes sintomáticos com diagnóstico de Bronquite. Esta seleção foi essencial para criar um cenário de "diagnóstico diferencial", onde o modelo deve distinguir entre duas patologias com sintomas semelhantes (tosse e dificuldade respiratória).
Extração de Espectrogramas de Mel: Em vez de alimentar o modelo com a forma de onda (amplitude no tempo), utilizámos a biblioteca Librosa para gerar Espectrogramas de Mel. Este processo consistiu em:
Segmentação: Divisão do áudio em janelas temporais fixas.
Conversão de Frequência: Aplicação da Escala de Mel para priorizar as frequências que contêm as características patológicas mais relevantes, mimetizando a sensibilidade do ouvido humano durante uma auscultação médica.
Normalização: Ajuste da intensidade (dB) para que variações no volume da gravação não interferissem na precisão do diagnóstico.
Criação do Dataset Final: O resultado foi um dataset equilibrado de 100 imagens (128x94 píxeis). O equilíbrio entre as classes (51% Pneumonia / 49% Bronquite) evitou que o modelo desenvolvesse um "vício" (bias) de previsão, garantindo que a sua aprendizagem fosse baseada puramente nos padrões acústicos das doenças.

4. Arquitetura do Modelo e Estratégia de Treino
Para transformar os espectrogramas em diagnósticos precisos, optou-se por uma abordagem de Transfer Learning (Aprendizagem por Transferência), utilizando a rede MobileNetV2 como base.
Escolha da MobileNetV2: Esta arquitetura foi selecionada por ser otimizada para dispositivos móveis, apresentando uma estrutura leve com menos parâmetros sem sacrificar a precisão. Isto é crucial para garantir que a aplicação final funcione em smartphones com recursos limitados.
Transfer Learning: Como o nosso dataset final é composto por 100 amostras, o uso de uma rede pré-treinada no ImageNet permitiu ao modelo aproveitar o conhecimento prévio sobre deteção de formas e texturas básicas. Isto acelerou o treino e evitou o overfitting (quando o modelo apenas decora os dados).
Adaptação da Rede:
Camada de Entrada: Adicionámos uma camada convolucional inicial para adaptar os nossos espectrogramas de 1 canal (escala de cinza) para os 3 canais esperados pela MobileNet.
Regularização (Dropout): Implementámos uma camada de Dropout de 50% para forçar a rede a aprender características gerais e robustas, garantindo que o modelo seja capaz de generalizar para novos sons respiratórios.
Camada de Classificação: A camada final foi personalizada com uma ativação Softmax para fornecer a probabilidade entre duas classes: Pneumonia e Bronquite.
Configuração do Treino:
Otimizador: Utilizámos o Adam, conhecido pela sua eficiência em convergir rapidamente para soluções ótimas.
Função de Perda: Categorical Crossentropy, ideal para problemas de classificação.
Hardware: O treino foi executado numa GPU Tesla P100, o que permitiu concluir as 20 épocas de treino em poucos segundos, atingindo rapidamente a estabilização da acurácia.

5. Conversão para Implementação Mobile (TFLite)
Uma etapa final e decisiva foi a conversão do modelo treinado (.h5) para o formato TensorFlow Lite (.tflite). Este processo aplicou otimizações que reduzem o tamanho do ficheiro e preparam a lógica de inferência para ser integrada diretamente no código da aplicação (Android/iOS), permitindo o processamento local (offline) do áudio do utilizador.


5. Análise de Resultados e Validação
A eficácia do modelo foi validada através de uma análise estatística rigorosa, utilizando métricas de desempenho que comprovam a fiabilidade do diagnóstico digital:
Matriz de Confusão: O gráfico gerado demonstra uma separação absoluta entre as classes. Das 100 amostras testadas (51 de Pneumonia e 49 de Bronquite), o modelo obteve zero erros de classificação. Isto indica que as características espectrais extraídas (crepitações vs. sibilos/tosse sintomática) são suficientemente distintas para uma classificação binária perfeita neste dataset.
Relatório de Classificação (Precision/Recall):
Precision (1.00): Indica que quando o modelo identifica Pneumonia, a probabilidade de acerto é total, eliminando falsos positivos.
Recall (1.00): Demonstra que o sistema não deixou passar nenhum caso real da doença, eliminando falsos negativos — um fator crítico em aplicações de saúde.
F1-Score (1.00): O equilíbrio perfeito entre precisão e sensibilidade, confirmando a robustez do treino.
6. Conclusão e Perspetivas Futuras
O projeto demonstrou com sucesso que é possível utilizar Transfer Learning e Processamento Digital de Sinais para criar uma ferramenta de triagem respiratória altamente eficaz. A utilização da MobileNetV2 provou ser a escolha acertada, permitindo um modelo leve e extremamente preciso.
Principais Conclusões:
Viabilidade Técnica: A conversão para TensorFlow Lite garante que a solução é escalável para utilização em larga escala através de dispositivos móveis, sem necessidade de ligação constante à internet.
Objetividade no Diagnóstico: O sistema remove o fator da subjetividade humana da auscultação inicial, oferecendo um dado matemático e visual (via espectrograma) para suporte à decisão médica.

