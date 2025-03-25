# Zeppelin + Spark + Delta Lake - Docker Image

## 📌 Visão Geral do Projeto

Este projeto fornece uma imagem Docker pré-configurada com:

- **Apache Zeppelin (0.12.0)** - Notebook interativo para análise de dados
- **Apache Spark (3.4.4)** - Framework para processamento distribuído
- **Delta Lake (2.4.0)** - Camada de armazenamento ACID para Spark
- **Hadoop (3.3.6)** - Para compatibilidade com sistemas de arquivos distribuídos
- **Python (3.x)** com bibliotecas essenciais (`pyspark`, `pandas`, `numpy`, etc.)

## 🚀 Como Usar

### Pré-requisitos

- Docker instalado
- 8GB+ de RAM recomendado (Spark é resource-intensive)

### 1. Construir a Imagem

```bash
docker build -t zeppelin-spark-delta .
```

### 2. Executar o Container

```bash
docker run -d   --name zeppelin   -p 8080:8080   zeppelin-spark-delta
```

Acesse o Zeppelin em: [http://localhost:8080](http://localhost:8080)

## 💾 Configuração de Volume Externo

Para persistir notebooks mesmo após remoção do container:

### Opção 1: Volume Docker Nomeado (Recomendado)

```bash
# Criar volume
docker volume create zeppelin-notebooks

# Executar com volume
docker run -d   --name zeppelin   -p 8080:8080   -v zeppelin-notebooks:/app/notebooks   zeppelin-spark-delta
```

Localização dos dados:

```bash
docker volume inspect zeppelin-notebooks
```

### Opção 2: Diretório Local (Bind Mount)

#### Linux/MacOS:

```bash
mkdir -p ./zeppelin-notebooks

docker run -d   --name zeppelin   -p 8080:8080   -v $(pwd)/zeppelin-notebooks:/app/notebooks   zeppelin-spark-delta
```

#### Windows (PowerShell):

```powershell
mkdir zeppelin-notebooks

docker run -d `
  --name zeppelin `
  -p 8080:8080 `
  -v ${PWD}\zeppelin-notebooks:/app/notebooks `
  zeppelin-spark-delta
```

## 🔧 Configuração Avançada

### Variáveis de Ambiente Opcionais

| Variável              | Valor Padrão                    | Descrição                          |
|----------------------|--------------------------------|----------------------------------|
| ZEPPELIN_PORT       | 8080                           | Porta do servidor Zeppelin        |
| ZEPPELIN_MEM        | -Xms1024m -Xmx2048m            | Memória alocada para JVM          |
| SPARK_DRIVER_MEMORY | 2G                             | Memória do driver Spark           |

### Exemplo de uso:

```bash
docker run -d   -e ZEPPELIN_PORT=9090   -e SPARK_DRIVER_MEMORY=4G   ...
```

## 🐛 Solução de Problemas

- **Problema:** Spark não inicia  
  **Solução:** Aumente os recursos do Docker (`Preferences > Resources`)

- **Problema:** Acesso negado ao volume  
  **Solução:** Adicione `--user $(id -u)` ao comando `docker run`

## 📦 Push para Docker Hub

Para compartilhar sua imagem:

```bash
docker tag zeppelin-spark-delta:latest seuusuario/zeppelin-spark-delta:latest
docker push seuusuario/zeppelin-spark-delta:latest
```

## 📄 Licença

Apache 2.0 - Livre para uso e modificação

> **Nota:** Esta imagem é otimizada para desenvolvimento local. Para ambientes de produção, considere ajustar as configurações de memória e segurança.
