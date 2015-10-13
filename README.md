# docker-bitbucket: A Docker image for Bitbucket Server.

[![Release](https://img.shields.io/github/release/jondelmil/docker-bitbucket.svg?style=flat)](https://github.com/jondelmil/docker-bitbucket/releases/latest)

## Features

* Runs on a production ready *OpenJDK* 8 - [Zulu](http://www.azulsystems.com/products/zulu "Zulu: Multi-platform Certified OpenJDK") by Azul Systems.
* Ready to be configured with *Nginx* as a reverse proxy (https available).
* Built on top of *Debian* for a minimal image size.

## Usage

```bash
docker run -d -p 7990:7990 -p 7999:7999 jondelmil/bitbucket
```

### Parameters

You can use this parameters to configure your bitbucket instance:

* **-s:** Enables the connector security and sets `https` as connector scheme.
* **-n &lt;proxyName&gt;:** Sets the connector proxy name.
* **-p &lt;proxyPort&gt;:** Sets the connector proxy port.
* **-c &lt;contextPath&gt;:** Sets the context path (do not write the initial /).

This parameters should be given to the entrypoint (passing them after the image):

```bash
docker run -d -p 7990:7990 -p 7999:7999 jondelmil/bitbucket <parameters>
```

> If you want to execute another command instead of launching bitbucket you should overwrite the entrypoint with `--entrypoint <command>` (docker run parameter).

### Nginx as reverse proxy

Lets say you have the following *nginx* configuration for bitbucket:

```
server {
	listen                          80;
	server_name                     example.com;
	return                          301 https://$host$request_uri;
}
server {
	listen                          443;
	server_name                     example.com;

	ssl                             on;
	ssl_certificate                 /path/to/certificate.crt;
	ssl_certificate_key             /path/to/key.key;
	location /bitbucket {
		proxy_set_header X-Forwarded-Host $host;
		proxy_set_header X-Forwarded-Server $host;
		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
		proxy_pass http://127.0.0.1:7990;
		proxy_redirect off;
	}
}
```

> This is only an example, please secure you *nginx* better.

For that configuration you should run your bitbucket container with:

```bash
docker run -d -p 7990:7990 -p 7999:7999 jondelmil/bitbucket -s -n example.com -p 443 -c bitbucket
```

### Persistent data

The bitbucket home is set to `/data/bitbucket`. If you want to persist your data you should use a data volume for `/data/bitbucket`.

#### Binding a host directory

```bash
docker run -d -p 7990:7990 -p 7999:7999 -v /home/user/bitbucket-data:/data/bitbucket jondelmil/bitbucket
```

Make sure that the bitbucket user (with id 782) has read/write/execute permissions.

If security is important follow the Atlassian recommendation:

> Ensure that only the user running bitbucket can access the bitbucket home directory, and that this user has read, write and execute permissions, by setting file system permissions appropriately for your operating system.

#### Using a data-only container

1. Create the data-only container and set proper permissions:

	* **Lazy way (preferred)** - Using [docker-bitbucket-data](https://github.com/jondelmil/docker-bitbucket-data "A data-only container for docker-bitbucket"):

		```bash
docker run --name bitbucket-data jondelmil/bitbucket-data
		```

	* *I-want-to-know-what-I'm-doing* way:

		```bash
docker run --name bitbucket-data -v /data/bitbucket busybox true
docker run --rm -it --volumes-from bitbucket-data debian bash
		```

		The last command will open a *debian* container. Execute this inside that container:

		```bash
chown 782:root /data/bitbucket; chmod 770 /data/bitbucket; exit;
		```

2. Use it in the bitbucket container:

	```bash
docker run --name bitbucket --volumes-from bitbucket-data -d -p 7990:7990 -p 7999:7999 jondelmil/bitbucket
	```

### PostgreSQL external database

A great way to connect your bitbucket instance with a PostgreSQL database is
using the [docker-bitbucket-postgres](https://github.com/jondelmil/docker-bitbucket-postgres "A PostgreSQL container for docker-bitbucket")
image.

1. Create and name the database container:

	```bash
docker run --name bitbucket-postgres -d jondelmil/bitbucket-postgres
	```

2. Use it in the bitbucket container:

	```bash
docker run --name bitbucket --link bitbucket-postgres:bitbucket-postgres -d -p 7990:7990 -p 7999:7999 jondelmil/bitbucket
	```

3. Connect your bitbucket instance following the Atlassian documentation:
[Connecting Bitbucket Server to PostgreSQL](https://confluence.atlassian.com/bitbucketserver/connecting-bitbucket-server-to-postgresql-776640389.html "Connecting Bitbucket Server to PostgreSQL").

>  See [docker-bitbucket-postgres](https://github.com/jondelmil/docker-bitbucket-postgres "A PostgreSQL container for docker-bitbucket") for more information and configuration options.

## Thanks

* [Docker](https://www.docker.com/ "Docker") for this amazing container engine.
* [PostgreSQL](http://www.postgresql.org/) for this advanced database.
* [Atlassian](https://www.atlassian.com/ "Atlassian") for making great products. Also for their work on [atlassian-docker](https://bitbucket.org/atlassianlabs/atlassian-docker "atlassian-docker repo") which inspired this.
* [Azul Systems](http://www.azulsystems.com/ "Azul Systems") for their *OpenJDK* docker base image.
* And specially to you and the entire community.

## License

This image is licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for the full license text.
