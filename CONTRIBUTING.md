# Contribuindo para o SSL Cert Automation

Agradecemos seu interesse em contribuir com este projeto! Seja corrigindo bugs, adicionando novas funcionalidades ou melhorando a documentação, toda ajuda é bem-vinda.

Para garantir a qualidade e a segurança das nossas automações, siga as diretrizes abaixo.

## Fluxo de Contribuição

1.  **Fork:** Faça um fork deste projeto.
2.  **Branch:** Crie uma branch para sua funcionalidade ou correção: `git checkout -b feature/nome-da-funcionalidade` ou `git checkout -b fix/descricao-do-problema`.
3.  **Desenvolvimento:** Realize suas alterações respeitando as convenções do projeto.
4.  **Teste:** Valide suas alterações testando localmente.
5.  **Pull Request:** Envie um Merge Request (MR) para o repositório principal descrevendo claramente o que foi alterado e por que.

## Diretrizes de Desenvolvimento

### 1. Makefile e Bash
Este projeto baseia-se em `Makefile` com scripts `bash`.
*   **Segurança:** Mantenha sempre `.ONESHELL` e `.SHELLFLAGS := -e` no topo do Makefile. O script **deve** parar imediatamente se qualquer comando falhar.
*   **Portabilidade:** Evite caminhos absolutos. Prefira o uso de variáveis ou `$(shell command -v <cmd>)` para localizar executáveis.
*   **Limpeza:** Sempre adicione um mecanismo de limpeza (`clean`) para os novos arquivos gerados.

### 2. Segurança
*   **NUNCA adicione chaves privadas (`.key`)** ao repositório. Certifique-se de que novos arquivos de chave estejam listados no `.gitignore`.
*   **Validação:** Sempre que manipular certificados e chaves, valide a paridade entre eles (ex: usando `modulus` com MD5) antes de assumir que formam um par válido.

### 3. Testes
*   Se você adicionar uma nova funcionalidade ao `Makefile`, crie um cenário de teste simples em uma pasta local dentro de `./ssl/` e valide o resultado com `make generate-fullchain`.
*   Verifique se o seu código lida corretamente com variações de extensões (`.crt`, `.pem`, `.cer`).

## Reportando Problemas

Se encontrar um bug ou tiver uma sugestão de melhoria, abra uma **Issue** no GitLab descrevendo:
- Qual é o problema ou sugestão?
- Passos para reproduzir o problema.
- Ambiente (sistema operacional, versão do OpenSSL).
- Logs de erro, se houver.

---

Obrigado por ajudar a tornar nossa automação de certificados mais robusta e eficiente!
