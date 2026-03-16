# Configurações padrão
SHELL := /bin/bash
.ONESHELL:
.SHELLFLAGS := -e -c

SSL_DIR := ./ssl
SELF_SIGNED_DIR := $(SSL_DIR)/self-signed

# Variáveis configuráveis
UTF8 := $(shell locale -c LC_CTYPE -k | grep -q charmap.*UTF-8 && echo -utf8)
DAYS=365
KEYLEN=2048
# Algoritmo padrão: RSA moderno
ALGO=RSA
EXTRA_FLAGS=

ifdef SERIAL
    EXTRA_FLAGS+=-set_serial $(SERIAL)
endif

.PHONY: usage clean self-signed list-certs generate-fullchain

usage:
	@echo "Este Makefile cria certificados SSL na pasta $(SSL_DIR):"
	@echo
	@echo "Uso para certificado auto-assinado:"
	@echo "  make self-signed NAME=nome_do_certificado"
	@echo
	@echo "Uso para gerar fullchain de um diretório existente:"
	@echo "  make list-certs"
	@echo "  make generate-fullchain DIR=nome_do_diretorio"
	@echo
	@echo "Variáveis opcionais (self-signed):"
	@echo "  DAYS=n (padrão: 365)"
	@echo "  KEYLEN=n (padrão: 2048)"
	@echo
	@echo "Limpeza:"
	@echo "  make clean"

# Listar diretórios disponíveis (excluindo self-signed)
list-certs:
	@if [ -d "$(SSL_DIR)" ]; then \
		echo "Diretórios de projetos encontrados:"; \
		ls -1 $(SSL_DIR) | grep -v 'self-signed'; \
	else \
		echo "Diretório $(SSL_DIR) ainda não existe."; \
	fi

# Gerar fullchain de um diretório existente
generate-fullchain:
ifndef DIR
	$(error Por favor, especifique o diretório com DIR=nome_da_pasta)
endif
	@if [ ! -d "$(SSL_DIR)/$(DIR)" ]; then echo "Erro: Diretório $(SSL_DIR)/$(DIR) não encontrado."; exit 1; fi
	
	@# 1. Identificar Chave (única .key)
	@KEYS=( $(SSL_DIR)/$(DIR)/*.key )
	@if [ $${#KEYS[@]} -ne 1 ]; then echo "Erro: Necessário exatamente 1 .key em $(SSL_DIR)/$(DIR)/ (encontrado: $${#KEYS[@]})"; exit 1; fi
	@KEY="$${KEYS[0]}"
	
	@# 2. Separar Certificado de Servidor (match modulus) e Cadeia
	@CERT_SRV=""
	@CHAIN_FILES=()
	
	@# Use find to avoid bash glob issues if some extensions are missing
	@for f in $(shell find $(SSL_DIR)/$(DIR) -maxdepth 1 -type f \( -name "*.crt" -o -name "*.pem" -o -name "*.cer" \)); do \
		if [[ "$$f" == *.key || "$$f" == *fullchain.pem ]]; then continue; fi; \
		if openssl x509 -noout -modulus -in "$$f" 2>/dev/null | openssl md5 | grep -q "$$(openssl rsa -noout -modulus -in "$$KEY" | openssl md5 | cut -d' ' -f2)"; then \
			CERT_SRV="$$f"; \
		else \
			CHAIN_FILES+=("$$f"); \
		fi; \
	done
	
	@if [ -z "$$CERT_SRV" ]; then echo "Erro: Não foi possível identificar o certificado do servidor (match de modulus falhou)."; exit 1; fi
	
	@# 3. Geração (Cert Servidor + Cadeia)
	@cat "$$CERT_SRV" > "$(SSL_DIR)/$(DIR)/fullchain.pem"
	@for chain in "$${CHAIN_FILES[@]}"; do \
		echo "" >> "$(SSL_DIR)/$(DIR)/fullchain.pem"; \
		cat "$$chain" >> "$(SSL_DIR)/$(DIR)/fullchain.pem"; \
	done
	
	@echo "Fullchain gerada com sucesso em: $(SSL_DIR)/$(DIR)/fullchain.pem"
	@echo "Estrutura: Certificado + $${#CHAIN_FILES[@]} arquivo(s) de cadeia."

# Target principal simplificado
self-signed:
ifndef NAME
	$(error Por favor, especifique o nome com NAME=exemplo)
endif
	@mkdir -p $(SELF_SIGNED_DIR)
	@echo "Gerando certificados auto-assinados para: $(NAME)..."
	@echo "Utilizando: Algoritmo=$(ALGO), Bits=$(KEYLEN), Dias=$(DAYS)"
	
	# 1. Gerar Chave Privada
	umask 077
	openssl genpkey -algorithm $(ALGO) -pkeyopt $(shell echo $(ALGO) | tr '[:upper:]' '[:lower:]')_keygen_bits:$(KEYLEN) \
		-aes-128-cbc -out $(SELF_SIGNED_DIR)/$(NAME).key
	
	# 2. Gerar Certificado auto-assinado
	openssl req $(UTF8) -new -key $(SELF_SIGNED_DIR)/$(NAME).key -x509 -days $(DAYS) -out $(SELF_SIGNED_DIR)/$(NAME).crt $(EXTRA_FLAGS)
	
	# 3. Gerar Fullchain (Certificado)
	cat $(SELF_SIGNED_DIR)/$(NAME).crt > $(SELF_SIGNED_DIR)/$(NAME).fullchain.pem
	
	@echo "--------------------------------------------------"
	@echo "Sucesso! Arquivos gerados em: $(SELF_SIGNED_DIR)/"
	@echo "  - $(NAME).key"
	@echo "  - $(NAME).crt"
	@echo "  - $(NAME).fullchain.pem (apenas certificado)"
	@echo "--------------------------------------------------"

# Limpeza com confirmação
clean:
	@if [ -d "$(SSL_DIR)" ]; then \
		read -p "Você tem certeza que deseja remover todos os certificados em $(SSL_DIR)? [s/N]: " confirm && \
		if [[ $$confirm == [sS] ]]; then \
			rm -rf $(SSL_DIR); \
			echo "Diretório $(SSL_DIR) removido."; \
		else \
			echo "Operação cancelada."; \
		fi \
	else \
		echo "Diretório $(SSL_DIR) não existe."; \
	fi
