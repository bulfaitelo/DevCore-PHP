#!/bin/sh
# Use o timestamp atual para invalidar o cache
CACHE_BUST=$(date +%s)
# Instalando NODE.JS
if [ "$APP_NODE_JS" = "true" ]
then    
    apt-get update &&  apt-get install -y ca-certificates curl gnupg
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
    apt-get update && apt-get install nodejs -y
fi

# Instalando Drive e configurando Conexão com SQL SERVER.
if [ "$APP_SQL_SERVER" = "true" ]
then
    pecl install sqlsrv
    pecl install pdo_sqlsrv
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg \
    && echo "deb [arch=amd64,arm64,armhf signed-by=/usr/share/keyrings/microsoft-prod.gpg] https://packages.microsoft.com/debian/11/prod bullseye main" > /etc/apt/sources.list.d/mssql-release.list
    apt-get update
    apt-get remove -y libodbc2 libodbcinst2 odbcinst unixodbc-common
    ACCEPT_EULA=Y apt-get install -y msodbcsql18
    ACCEPT_EULA=Y apt-get install -y mssql-tools18   
fi

    