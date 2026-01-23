# Como Adicionar Java 17 ao PATH do Sistema (Windows)

## Método 1: Via Interface Gráfica (Recomendado)

1. **Abra as Variáveis de Ambiente:**
   - Pressione `Win + R`
   - Digite `sysdm.cpl` e pressione Enter
   - Vá para a aba "Avançado"
   - Clique em "Variáveis de Ambiente"

2. **Edite a variável PATH:**
   - Na seção "Variáveis do sistema", encontre a variável `Path`
   - Clique em "Editar"
   - Clique em "Novo"
   - Adicione: `C:\Program Files\Java\jdk-17\bin`
   - Clique em "OK" em todas as janelas

3. **Mova o Java 17 para o topo (opcional):**
   - Se você quiser que Java 17 seja o padrão, use os botões "Mover para cima" para colocá-lo antes do Java 25

4. **Reinicie o terminal/PowerShell** para que as mudanças tenham efeito

## Método 2: Via PowerShell (Como Administrador)

Execute o PowerShell como Administrador e execute:

```powershell
# Adicionar Java 17 ao PATH do sistema
[Environment]::SetEnvironmentVariable(
    "Path",
    [Environment]::GetEnvironmentVariable("Path", "Machine") + ";C:\Program Files\Java\jdk-17\bin",
    "Machine"
)
```

## Verificar se funcionou

Abra um novo terminal e execute:

```powershell
java -version
```

Deve mostrar: `java version "17.0.12"`

## Nota Importante

⚠️ **O Gradle já está configurado para usar Java 17** através do arquivo `gradle.properties`. 
Você não precisa adicionar ao PATH se só quiser usar Java 17 para o Flutter/Android.

Adicionar ao PATH é útil se você quiser usar Java 17 como padrão em todo o sistema.


