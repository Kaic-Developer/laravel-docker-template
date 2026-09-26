# Laravel Docker Template

Template reutilizável para criação automática de ambientes de desenvolvimento Laravel utilizando Docker.

O objetivo deste projeto é permitir a criação de novos projetos Laravel sem precisar instalar e configurar manualmente PHP, Composer, MySQL, Nginx, Redis e servidor de e-mail em cada projeto.

---

## Tecnologias

O ambiente utiliza:

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
- PowerShell

---

# Arquitetura

```text
Navegador
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
   ├── Redis
   └── Mailpit
```

Cada serviço executa em seu próprio container Docker.

---

# Estrutura do template

```text
laravel-docker-template/
│
├── Dockerfile
├── docker-compose.yml
├── new-project.ps1
├── README.md
├── .gitignore
│
└── docker/
    └── nginx/
        └── default.conf
```

O template não contém uma aplicação Laravel pronta.

O Laravel é criado automaticamente pelo script.

---

# Pré-requisitos

Antes de utilizar o template, tenha instalado:

- Git
- Docker Desktop
- Docker Compose
- PowerShell

O Docker Desktop precisa estar aberto e o Docker Engine precisa estar em execução.

---

# Instalando o template

Entre no diretório onde deseja trabalhar.

Exemplo:

```bash
cd ~/OneDrive/Desktop/Projetos/Freelancer
```

Clone o repositório:

```bash
git clone https://github.com/Kaic-Developer/laravel-docker-template.git
```

Entre no template:

```bash
cd laravel-docker-template
```

---

# Criando um novo projeto

## PowerShell

```powershell
.\new-project.ps1 -Name meu-projeto
```

Exemplo:

```powershell
.\new-project.ps1 -Name ingressos
```

## Git Bash

```bash
powershell.exe -ExecutionPolicy Bypass -File ./new-project.ps1 -Name ingressos
```

O script fará toda a configuração automaticamente.

---

# Onde o projeto é criado?

O projeto é criado ao lado da pasta `laravel-docker-template`.

Por exemplo:

```text
Freelancer/
│
├── laravel-docker-template/
│
└── ingressos/
```

Se o template estiver em:

```text
Projetos/Freelancer/laravel-docker-template
```

e você executar:

```powershell
.\new-project.ps1 -Name ingressos
```

o projeto será criado em:

```text
Projetos/Freelancer/ingressos
```

Isso permite utilizar o template em diferentes diretórios.

Por exemplo:

```text
Projetos/
├── Estudo/
├── Freelancer/
├── Pessoais/
└── Trabalho/
```

---

# O que o script faz?

O `new-project.ps1` automatiza a criação completa do ambiente.

Ele:

1. Verifica se o Docker está instalado.
2. Verifica se o Docker Engine está rodando.
3. Valida o nome do projeto.
4. Cria a pasta do projeto.
5. Copia a infraestrutura Docker.
6. Procura portas disponíveis automaticamente.
7. Cria a configuração Docker.
8. Constrói a imagem PHP.
9. Executa o Composer dentro do Docker.
10. Cria uma nova aplicação Laravel.
11. Configura o `.env` do Laravel.
12. Configura a conexão com MySQL.
13. Configura o Mailpit.
14. Configura sessão e cache para desenvolvimento.
15. Inicia os containers.
16. Aguarda o MySQL ficar disponível.
17. Configura as permissões de `storage` e `bootstrap/cache`.
18. Limpa os caches do Laravel.
19. Executa as migrations.
20. Cria o `storage:link`.
21. Exibe os endereços e portas utilizados.

Ao final, o ambiente estará pronto para desenvolvimento.

---

# Estrutura do projeto gerado

Exemplo:

```text
ingressos/
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
    ├── tests/
    ├── vendor/
    ├── artisan
    ├── composer.json
    └── .env
```

A pasta:

```text
app/
```

contém a aplicação Laravel.

---

# Portas automáticas

O script procura portas disponíveis automaticamente.

Por exemplo:

```text
Projeto Rápidoo

Laravel:
localhost:8000

Mailpit:
localhost:8025
```

Se essas portas já estiverem ocupadas:

```text
Projeto Ingressos

Laravel:
localhost:8001

Mailpit:
localhost:8026
```

Isso permite executar múltiplos projetos simultaneamente.

---

# Iniciando um projeto existente

Entre na pasta do projeto:

```bash
cd ingressos
```

Inicie os containers:

```bash
docker compose up -d
```

Confira:

```bash
docker compose ps
```

---

# Parando o projeto

```bash
docker compose down
```

Os dados persistidos em volumes não são apagados pelo `docker compose down`.

---

# Reconstruindo a imagem

Quando alterar o `Dockerfile`:

```bash
docker compose up -d --build
```

Alterações normais no Laravel não precisam de rebuild.

Por exemplo:

- Controllers
- Models
- Routes
- Views
- Migrations
- Services

---

# Comandos Artisan

Como o PHP executa dentro do container, utilize:

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

Criar model com migration:

```bash
docker compose exec php php artisan make:model Product -m
```

Tinker:

```bash
docker compose exec php php artisan tinker
```

Limpar caches:

```bash
docker compose exec php php artisan optimize:clear
```

Ver informações:

```bash
docker compose exec php php artisan about
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

Atualizar dependências:

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
```

```bash
composer --version
```

```bash
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

É importante utilizar:

```env
DB_HOST=mysql
```

e não:

```env
DB_HOST=localhost
```

`mysql` é o nome do serviço dentro da rede Docker.

---

# Redis

O template inclui um container Redis disponível para utilização pela aplicação.

O serviço pode ser acessado internamente pelo hostname:

```text
redis
```

---

# Mailpit

O Mailpit permite testar e-mails enviados pelo Laravel sem utilizar um servidor SMTP real.

O Laravel utiliza:

```env
MAIL_MAILER=smtp
MAIL_HOST=mailpit
MAIL_PORT=1025
```

A interface web do Mailpit pode ser acessada pela porta informada pelo gerador.

Normalmente:

```text
http://localhost:8025
```

---

# Logs

Todos os containers:

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

Use:

```text
Ctrl + C
```

para sair do acompanhamento dos logs.

---

# Verificando os containers

```bash
docker compose ps
```

---

# Validando o Docker Compose

```bash
docker compose config
```

Se não houver erros, o Docker Compose conseguiu interpretar a configuração.

---

# Permissões Laravel

O gerador configura automaticamente:

```text
storage/
bootstrap/cache/
```

com as permissões necessárias para o PHP-FPM.

Caso seja necessário corrigir manualmente:

```bash
docker compose exec php chown -R www-data:www-data storage bootstrap/cache
```

Depois:

```bash
docker compose exec php chmod -R 775 storage bootstrap/cache
```

E:

```bash
docker compose exec php php artisan optimize:clear
```

---

# Fluxo completo

```text
GitHub
   │
   ▼
git clone
   │
   ▼
laravel-docker-template
   │
   ▼
new-project.ps1
   │
   ├── Docker
   ├── PHP 8.4
   ├── Composer
   ├── Nginx
   ├── MySQL
   ├── Redis
   └── Mailpit
   │
   ▼
Laravel
   │
   ▼
Projeto pronto para desenvolvimento
```

---

# Comandos rápidos

## Subir

```bash
docker compose up -d
```

## Ver containers

```bash
docker compose ps
```

## Parar

```bash
docker compose down
```

## Logs

```bash
docker compose logs -f
```

## Migration

```bash
docker compose exec php php artisan migrate
```

## Tinker

```bash
docker compose exec php php artisan tinker
```

## Limpar cache

```bash
docker compose exec php php artisan optimize:clear
```

---

# Atualizações futuras

Possíveis melhorias:

- suporte a diferentes versões do PHP;
- configuração avançada do Redis;
- Laravel Queue Worker;
- Laravel Scheduler;
- HTTPS local;
- testes automatizados do template;
- escolha manual do diretório de destino;
- CI/CD;
- suporte a Linux/macOS além do script PowerShell.

---

# Autor

**Kaic Leonardo**

GitHub: `Kaic-Developer`

Template desenvolvido para estudos e desenvolvimento de aplicações Laravel utilizando ambientes Docker isolados e reutilizáveis.