# ansible-oracle-to-postgresql-migration
Ansible routine to deploy SQLines tool to assist migration from Oracle to PostgreSQL on CentOS / Red Hat Linux distros

### SQLines will be installed and used on a intermediate machine to be a bridge between Oracle to MariaDB.

## Proposed Scenario

* Intermediate machine for SQLines
* Oracle source database
* PostgreSQL target database

e.g:

```
  Source Database                  *Migration host*                 Target Database
+------------------+             +------------------+             +------------------+
|                  |             |      SQLines     |             |                  |
| Oracle Database  | <=========> |   intermediate   | <=========> |    PostgreSQL    |
|                  |             |      host        |             |     Database     |
+------------------+             +------------------+             +------------------+
```

### 1rst - Create user on postgresql to import the data from Oracle
```
CREATE ROLE cep LOGIN  ENCRYPTED PASSWORD 'Teste123'  SUPERUSER INHERIT CREATEDB CREATEROLE REPLICATION;
CREATE DATABASE cep  WITH OWNER = cep ENCODING = 'UTF8' CONNECTION LIMIT = -1;
\c cep
CREATE SCHEMA cep;
```

### 2nd - Setup oracle datasource using tnsnames.ora file
```
[mysqlines@srv-sqlines ~]$ vi tnsnames.ora
```

```
XE =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 172.16.122.250)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = XE)
    )
  )
```

### 3rd - Test connection from the intermediate machine to the source and target databases

E.g for Oracle:
```
sqlplus CEP/teste123@XE
```

E.g for PostgreSQL:
```
psql --user=cep -p 5432  -h 172.16.122.164
```

PS: keep in mind that you have to be able to connect on the source and target databases from the intermediate machine that we are using to migrate our data from oracle to postgresql

### 4th - How to use sqldata from SQLines

```
./sqldata -sd=oracle,CEP/teste123@XE -td=pg,cep/Teste123@172.16.122.164,cep -t=*.* -ss=6 -out=/home/postgres -log=migration_cep.log -pg_client_encoding=UTF8
```

PS.: Always keep in mind to create the schema under the same name on PostgreSQL side as it is on Oracle side too, they have to match to import properly.
