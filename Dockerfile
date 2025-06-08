FROM mysql:8.0

ENV MYSQL_ROOT_PASSWORD=docker \
    MYSQL_DATABASE=JUDGE_DB

COPY ./my.cnf ./etc/mysql/conf.d
RUN chmod 644 ./etc/mysql/conf.d/my.cnf
COPY ./*.sql /docker-entrypoint-initdb.d
COPY ./stored_procedures/*.sql /docker-entrypoint-initdb.d