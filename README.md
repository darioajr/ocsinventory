# ocsinventory
OCSInventory-NG Docker automated build

This is an OCSInventory-NG image based on Ubuntu 16.04. It expects a running MariaDB/MySQL instance.

```console
$ docker run \
--name ocs \
-e DB_USER="ocsusr" \
-e DB_PASS="ocspass" \
-e DB_NAME="ocsweb" \
-e MYSQL_ROOT_PASSWORD="password" \
--link mysql_instance:db \
-p 80:80 \
-d darioajr/ocsinventory
```
Note: If the database already exists and is accessible by the user and password provided, there is no need to provide the MYSQL_ROOT_PASSWORD environment variable.
