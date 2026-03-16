# Automação de Certificados SSL

Este projeto provê um `Makefile` simplificado e robusto para automação de tarefas comuns com certificados SSL/TLS, utilizando o OpenSSL. Ele é ideal para ambientes de desenvolvimento onde é necessário gerar chaves, certificados auto-assinados ou organizar cadeias de confiança (fullchain).

## Funcionalidades

- **Certificados Auto-assinados:** Geração rápida de par de chaves e certificado para testes.
- **Geração de Fullchain:** Automação para criar cadeias de certificados completas (servidor + intermediários + root), com validação criptográfica automática do par chave/certificado.
- **Limpeza Segura:** Comando para limpeza com confirmação de segurança.

## Pré-requisitos

- `openssl` instalado no sistema.
- `make` instalado.

## Uso

### 1. Certificados Auto-assinados
Para gerar um novo par de chaves e um certificado de teste na pasta `./ssl/self-signed/`:

```bash
make self-signed NAME=nome_do_projeto
```
*   **Variáveis Opcionais:**
    *   `DAYS=n` (padrão: 365)
    *   `KEYLEN=n` (padrão: 2048)

### 2. Gerar Fullchain para Projetos Externos
Se você recebeu arquivos de certificado e precisa organizar o `fullchain.pem` para um servidor web:

1.  Coloque seus arquivos (`.key`, `.crt`/`.pem`/`.cer`, intermediários) dentro de uma pasta em `./ssl/seu_projeto/`.
2.  Liste os projetos disponíveis:
    ```bash
    make list-certs
    ```
3.  Gere o `fullchain.pem` (o Makefile identificará automaticamente qual arquivo é o par da sua chave):
    ```bash
    make generate-fullchain DIR=seu_projeto
    ```
    *O Makefile validará se a chave privada e o certificado formam um par criptográfico correto antes de gerar o arquivo.*

### 3. Limpeza
Para remover todos os certificados gerados:
```bash
make clean
```

---

## Estrutura do Projeto

- `./ssl/`: Diretório base onde todos os certificados são gerados.
- `Makefile`: Script de automação contendo toda a lógica.
- `.gitignore`: Configurado para proteger suas chaves privadas (`*.key`) e ignorar arquivos gerados.
