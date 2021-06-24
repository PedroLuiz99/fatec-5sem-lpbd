FROM postgis/postgis

ENV POSTGRES_USER=lbd
ENV POSTGRES_PASSWORD=lbd
ENV POSTGRES_DB=lbd
ENV BACKUP_LOCATION=/backup
ENV RETENTION=7

COPY ./src/*.sql /docker-entrypoint-initdb.d/
COPY ./src/backup.sh /etc/cron.daily/backup_postgres
RUN chmod +x /etc/cron.daily/backup_postgres

EXPOSE 5432