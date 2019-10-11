FROM mysql:latest

COPY conf.d/innodb_file_per_table.cnf /etc/mysql/conf.d/innodb_file_per_table.cnf
COPY docker-entrypoint-initdb.d/init.sql /docker-entrypoint-initdb.d/init.sql
