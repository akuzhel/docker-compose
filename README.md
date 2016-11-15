# Docker-compose sample application

Basic usage:

```bash
docker-compose up -d
docker-compose down
```

Cache/vars/etc folders:

```bash
setfacl -R -m u:www-data:rwX u:`whoami`:rwX <some-folder-here>
setfacl -dR -m u:www-data:rwX u:`whoami`:rwX <some-folder-here>
```

Add the following records to your /etc/hosts (set appropriate IP):

```
172.18.0.2	db.local.com
172.18.0.3	php55.local.com
172.18.0.4	php70.local.com
172.18.0.5	dev.local.com [other hosts]
```

PHP 7 Virtual Host settings:

```	
<FilesMatch \.php$>
  SetHandler proxy:fcgi://php70.local.com:9000
</FilesMatch>

<Proxy "fcgi://php70.local.com:9000">
  ProxySet timeout=3600
</Proxy>
```

## Tasks

 - Setup DNS

