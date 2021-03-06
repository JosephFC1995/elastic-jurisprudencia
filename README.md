# Instalación de ElasticSearch para servidores CentOS y creación de generación de backups automáticos.

 <josefc9512@gmail.com>

## Instalación del Elasticsearch

- Como Elasticsearch depende de Java, debe instalarlo en su máquina antes de instalar Elasticsearch 6 en CentOS 7.

```
sudo yum install java-openjdk-devel java-openjdk
```

- Instalamos el editor nano.
```
yum install nano
```

- Agregamos el repositorio de Elasticsearch 6, primero creamos el archivo de elasticsearch en el repositorio de yum.

```
sudo nano /etc/yum.repos.d/elasticsearch.repo
[elasticsearch-6.x]
name=Elasticsearch repository for 6.x packages
baseurl=https://artifacts.elastic.co/packages/oss-6.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
```

- El repositorio de Elasticsearch 6 está listo para usar. Puede instalar Elasticsearch usando el siguiente comando.

```
sudo yum install elasticsearch-oss
```

-  Iniciamos y habilitamos el servicio de Elastic.

```
sudo systemctl enable --now elasticsearch
```

- Hagamos un test para verificar si todo esta bien.

```
curl -XGET 'http://localhost:9200/'
```


> Una vez instalado, es necesario colocar la ip del elastic al backend de jurisprudencia.
> Asi como validar el estado del elastic con la siguiente URL https://jurisbackend.sedetc.gob.pe/api/admin/elastic/status enviando el token.

-  Crear la instancia a travez del administardor: : ajustes/elastic, en el boton crear instancia.

> Ahora es necesario instalar el pipe, un plugin que se encarga de la extraccion del contenido de los **PDF**, para eso nos diriguimos al folder de los plugins de Elasticsearch con los siguientes comandos.

```
cd /usr/share/elasticsearch
sudo bin/elasticsearch-plugin install ingest-attachment
```

- Reiniciamos el servicio de elastic con el siguiente comando

```
service elasticsearch restart
```

- Ahora creamos el pipe atravez del administrador: ajustes/elastic, en el boton crear pipe


# Instalación del script de backups automáticos. <b>(Solo UBUNTU)</b>

- Creamos las siguientes carpetas

```
mkdir /usr/elasticsearch
mkdir /usr/elasticsearch/backups
```

- Editamos la configuracion del elastisearch.yml y agregamos al final la sigueinte linea

```
path.repo: ["/usr/elasticsearch/backups"]
```

- Brindamos permisos a elastic para que pueda manipular el folder backup

```
chown elasticsearch /usr/elasticsearch/backups
```

- Ahora creamos el repositorio atravez del administrador: ajustes/elastic, en el boton crear repositorio
- Copiamos el contenido del scrip en el folder ```/usr/elasticsearch``` con el comando

```
sudo nano script_backup.sh
```

- Pegamos el contenido y guardamos con ```ctrl + x```.

- Validamos el estado del cron

```
systemctl status cron
```
---
- Por si no esta instalado 
```
apt-get update
apt-get upgrade
```
- Instalamos el cron
```
dpkg -l cron
```
---

- Validamos el estado del cron
```
systemctl status cron
```

- Ejecutamos cron para poder agregar nuestra tarea programada

```
crontab -e
```

> Pegamos el cron, configurando el tiempo

> Para conocer o generar un tiempo para el cron visite esta pagina https://crontab.guru

> Este cron ejecuta a las 7 de la mañana todos los dias
```
0 7 \* \* \* /usr/elasticsearch/script_backup.sh
```

> Adicional: Si desea configurar la hora del servidor, necesita reiniciar el servicio de cron.

```
timedatectl
timedatectl set-timezone America/Lima
sudo service cron restart
```

- Por si da error de permisos es necesario brindar permisos al archivo.

```
chmod +x /usr/elasticsearch/script_backup.sh
```

---
## Instalación de cronitor

```
curl -sOL https://cronitor.io/dl/cronitor-stable-linux-amd64.tgz
sudo tar xvf cronitor-stable-linux-amd64.tgz -C /usr/bin/
```

- Seleccionamos que cron ejecutamos y seleccionamos el script para un backup inicial
```
sudo cronitor select
```
