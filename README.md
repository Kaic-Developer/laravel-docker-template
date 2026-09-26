# Laravel Docker Template

Template reutilizável para criação de ambientes de desenvolvimento Laravel utilizando Docker.

O objetivo deste projeto é permitir a criação de novos projetos Laravel sem precisar configurar manualmente PHP, Composer, MySQL, Nginx, Redis e servidor de e-mail a cada novo projeto.

O ambiente é criado de forma isolada utilizando Docker Compose.

---

## Tecnologias

O ambiente inclui:

- Laravel
- PHP 8.4
- PHP-FPM
- Composer
- Nginx
- MySQL 8.4
- Redis
- Mailpit
- Docker
- Docker Compose

---

## Estrutura do template

```text
LaravelDockerTemplate/
│
├── Dockerfile
├── docker-compose.yml
├── new-project.ps1
├── .gitignore
│
└── docker/
    └── nginx/
        └── default.conf
```

O template não contém uma aplicação Laravel pronta.

A aplicação é criada automaticamente dentro da pasta:

```text
app/
```

---

## Objetivo

Em vez de configurar um novo ambiente manualmente para cada projeto:

```text
Instalar PHP
↓
Configurar extensões
↓
Instalar Composer
↓
Instalar MySQL
↓
Configurar Nginx
↓
Configurar Redis
↓
Configurar servidor de e-mail
↓
Criar Laravel
```

este template automatiza grande parte do processo.

---

## Pré-requisitos

Antes de utilizar o template, tenha instalado:

- Git
- Docker Desktop
- Docker Compose
- PowerShell

O Docker Desktop deve estar aberto e com o Docker Engine em execução.

---

# Criando um novo projeto

Clone este repositório:

```bash
git clone https://github.com/Kaic-Developer/laravel-docker-template.git
```

Entre na pasta:

```bash
cd laravel-docker-template
```

No PowerShell:

```powershell
.\new-project.ps1 -Name meu-projeto
```

Exemplo:

```powershell
.\new-project.ps1 -Name ingressos
```

Se estiver utilizando Git Bash:

```bash
powershell.exe -ExecutionPolicy Bypass -File ./new-project.ps1 -Name ingressos
```

---

# O que o script faz

O `new-project.ps1` automatiza a preparação do ambiente.

Ele:

1. Verifica se o Docker está instalado.
2. Verifica se o Docker Engine está rodando.
3. Cria a pasta do novo projeto.
4. Copia a infraestrutura Docker.
5. Procura portas disponíveis.
6. Cria as configurações do ambiente.
7. Constrói a imagem PHP.
8. Executa o Composer dentro do Docker.
9. Cria uma nova aplicação Laravel.
10. Configura o `.env` do Laravel.
11. Configura a conexão com MySQL.
12. Configura o Mailpit.
13. Inicia os containers.
14. Aguarda o MySQL ficar disponível.
15. Limpa o cache do Laravel.
16. Executa as migrations.
17. Cria o storage link.

Ao final, o ambiente estará pronto para desenvolvimento.

---

# Estrutura de um projeto gerado

Exemplo:

```text
meu-projeto/
│
├── Dockerfile
├── docker-compose.yml
├── .env
│
├── docker/
│   └── nginx/
│       └── default.conf
│
└── app/
    ├── app/
    ├── bootstrap/
    ├── config/
    ├── database/
    ├── public/
    ├── resources/
    ├── routes/
    ├── storage/
    ├── artisan
    ├── composer.json
    └── .env
```

---

# Arquitetura

```text
Browser
   │
   ▼
Nginx
   │
   ▼
PHP-FPM
   │
   ▼
Laravel
   │
   ├── MySQL
   │
   ├── Redis
   │
   └── Mailpit
```

Cada serviço executa em seu próprio container.

---

# Portas

O script procura portas disponíveis automaticamente.

Por exemplo:

```text
Projeto A
Laravel: 8000
Mailpit: 8025

Projeto B
Laravel: 8001
Mailpit: 8026
```

Isso permite trabalhar com múltiplos projetos simultaneamente sem utilizar a mesma porta HTTP.

---

# Comandos Docker

Entre primeiro na pasta do projeto gerado.

### Iniciar

```bash
docker compose up -d
```

### Ver containers

```bash
docker compose ps
```

### Parar

```bash
docker compose down
```

### Logs

```bash
docker compose logs -f
```

### Reconstruir a imagem

Use quando houver alterações no `Dockerfile`:

```bash
docker compose up -d --build
```

---

# Artisan

O PHP está dentro do container.

Por isso, os comandos Artisan podem ser executados assim:

```bash
docker compose exec php php artisan migrate
```

Criar controller:

```bash
docker compose exec php php artisan make:controller ProductController
```

Criar model:

```bash
docker compose exec php php artisan make:model Product
```

Tinker:

```bash
docker compose exec php php artisan tinker
```

Limpar caches:

```bash
docker compose exec php php artisan optimize:clear
```

---

# Composer

Instalar dependências:

```bash
docker compose exec php composer install
```

Adicionar pacote:

```bash
docker compose exec php composer require vendor/package
```

Atualizar:

```bash
docker compose exec php composer update
```

---

# Entrando no container PHP

```bash
docker compose exec php bash
```

Dentro do container:

```bash
php -v
composer --version
php artisan about
```

Para sair:

```bash
exit
```

---

# MySQL

Dentro da rede Docker, o Laravel utiliza:

```env
DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=laravel
DB_USERNAME=laravel
DB_PASSWORD=laravel
```

`DB_HOST` deve ser `mysql`, pois esse é o nome do serviço dentro da rede Docker.

---

# Mailpit

O Mailpit permite testar e-mails enviados pela aplicação sem utilizar um servidor de e-mail real.

Configuração Laravel:

```env
MAIL_MAILER=smtp
MAIL_HOST=mailpit
MAIL_PORT=1025
```

O endereço da interface web é informado pelo script após a criação do projeto.

Normalmente:

```text
http://localhost:8025
```

---

# Logs

Todos os serviços:

```bash
docker compose logs -f
```

PHP:

```bash
docker compose logs php
```

Nginx:

```bash
docker compose logs nginx
```

MySQL:

```bash
docker compose logs mysql
```

Laravel:

```bash
docker compose exec php tail -f storage/logs/laravel.log
```

---

# Validando o Docker Compose

Antes de iniciar o ambiente, a configuração pode ser validada com:

```bash
docker compose config
```

Se não houver erros, o Compose conseguiu interpretar a configuração.

---

# Desenvolvimento

Este template foi criado para facilitar a criação de ambientes Laravel locais e continuará sendo aprimorado.

Melhorias planejadas podem incluir:

- configuração completa do Redis no PHP;
- testes automatizados do template;
- escolha personalizada do diretório de destino;
- suporte a diferentes versões do PHP;
- configuração opcional de filas;
- workers Laravel;
- Laravel Scheduler;
- HTTPS local;
- integração com CI/CD.

---

## Autor

**Kaic Leonardo**

GitHub: `Kaic-Developer`

Desenvolvido como parte dos estudos e projetos de desenvolvimento backend com Laravel, Docker e infraestrutura de desenvolvimento.