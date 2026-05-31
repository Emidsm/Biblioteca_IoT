FROM nodered/node-red:latest

# Cambiamos a root para instalar paquetes
USER root

# Instalamos el cliente de postgres
RUN apk add --no-cache postgresql-client

# Regresamos al usuario normal de node-red
USER node-red
