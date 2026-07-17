# Guia de Uso do Container (DevCore-PHP)

Este guia centraliza os parametros do ambiente Docker para facilitar setup, uso diario e manutencao.

## 1) Visao Geral

Stack principal:

- app: PHP + Apache + Composer + Node (opcional)
- mysql_db: banco MySQL
- phpmyadmin: interface web para o banco

Projeto e rede Docker (padrao):

- COMPOSE_PROJECT_NAME: devcore_php
- DOCKER_NETWORK_NAME: devcore_php_net

## 2) Subir e Derrubar Ambiente

No diretorio raiz do projeto:

```bash
docker compose up -d --build
```

Para parar/remover os containers:

```bash
docker compose down
```

Para ver status:

```bash
docker compose ps
```

Para ver logs:

```bash
docker compose logs -f app
docker compose logs -f mysql_db
docker compose logs -f phpmyadmin
```

## 3) Enderecos e Portas

Com o `.env` atual:

- App HTTP: http://localhost:80
- Laravel (artisan serve): http://localhost:8000
- PHP-FPM: localhost:9000
- MySQL: localhost:3306
- phpMyAdmin: http://localhost:8080

No `example.env`, os defaults sugeridos sao:

- App HTTP: 8080
- phpMyAdmin: 8081

## 4) Acesso ao Container App

Entrar no shell como usuario `app`:

```bash
docker exec -it --user app app bash
```

Comandos uteis dentro do container:

```bash
composer install
php -v
node -v
npm -v
```

## 5) Variaveis de Ambiente (.env)

### Projeto

- `COMPOSE_PROJECT_NAME`: nome logico do projeto no Docker Compose
- `DOCKER_NETWORK_NAME`: nome da rede bridge
- `TZ`: timezone dos containers

### App/PHP

- `APP_CONTAINER_NAME`: nome do container da aplicacao
- `APP_DOCKERFILE`: Dockerfile usado para build da app
  - exemplos: `docker/app/Dockerfile.php.8.2`, `docker/app/Dockerfile.php.8.3`, `docker/app/Dockerfile.php.8.4`, `docker/app/Dockerfile.php.latest`
- `APP_UID` e `APP_GID`: UID/GID para o usuario app dentro da imagem
- `APP_NODE_JS`: habilita instalacao/configuracao de Node na imagem
- `APP_SQL_SERVER`: habilita suporte SQL Server na imagem (quando aplicavel)

### Portas da App

- `APP_PORT_HTTP`: porta externa para Apache (porta 80 interna)
- `APP_PORT_LARAVEL`: porta externa para `php artisan serve` (8000 interna)
- `APP_PORT_FPM`: porta externa para FPM (9000 interna)

### MySQL

- `MYSQL_CONTAINER_NAME`: nome do container MySQL
- `MYSQL_PORT`: porta externa MySQL (3306 interna)
- `MYSQL_ROOT_PASSWORD`: senha do root
- `MYSQL_DATABASE`: banco inicial
- `MYSQL_USER`: usuario de aplicacao
- `MYSQL_PASSWORD`: senha do usuario de aplicacao
- `DB_DATA_DIR`: diretorio local persistente mapeado em `/var/lib/mysql`

### phpMyAdmin

- `PHPMYADMIN_CONTAINER_NAME`: nome do container phpMyAdmin
- `PHPMYADMIN_PORT`: porta externa do phpMyAdmin
- `PHPMYADMIN_UPLOAD_LIMIT`: limite de upload
- `PMA_HOST`: host do banco (normalmente `mysql_db`)
- `PMA_PORT`: porta do banco (normalmente `3306`)
- `PMA_ARBITRARY`: `0` para restringir host predefinido, `1` para permitir servidor arbitrario

## 6) Volumes e Diretorios Importantes

Mapeamentos principais:

- `./www:/var/www`: codigo da aplicacao
- `./dbdata:/var/lib/mysql`: dados persistentes do banco
- `./conf/app/php/php.ini-development:/usr/local/etc/php/php.ini:ro`: config PHP
- `./conf/app/vhost:/etc/apache2/sites-enabled:ro`: vhosts Apache
- `./logs/php:/tmp/php`: logs PHP
- `./logs/cron:/var/log/cron`: logs do cron

## 7) Troca de Versao do PHP

Basta ajustar no `.env`:

```env
APP_DOCKERFILE=docker/app/Dockerfile.php.8.3
```

Depois recrie a imagem:

```bash
docker compose build --no-cache app
docker compose up -d
```

## 8) Fluxo Recomendado (Primeiro Uso)

1. Copie o arquivo de exemplo e ajuste se necessario:

```bash
cp example.env .env
```

2. Suba os servicos:

```bash
docker compose up -d --build
```

3. Valide saude dos servicos:

```bash
docker compose ps
docker compose logs --tail=100 mysql_db
```

4. Abra a aplicacao em `www` e acesse no navegador.

## 9) Troubleshooting Rapido

Porta em uso:

- altere `APP_PORT_HTTP`, `PHPMYADMIN_PORT` ou `MYSQL_PORT` no `.env`
- suba novamente com `docker compose up -d`

Falha no MySQL ao iniciar:

- verifique permissao em `DB_DATA_DIR`
- cheque logs: `docker compose logs mysql_db`

Mudou Dockerfile/parametros de build e nao refletiu:

- execute `docker compose build --no-cache app` e depois `docker compose up -d`

## 10) Comandos de Manutencao

Atualizar stack em execucao:

```bash
docker compose pull
docker compose up -d
```

Reiniciar apenas a app:

```bash
docker compose restart app
```

Executar comando dentro do container app sem abrir shell:

```bash
docker exec -it app php -m
```

---

Se o objetivo for padronizar equipe, mantenha `example.env` com valores seguros e use `.env` apenas para ajustes locais.