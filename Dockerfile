FROM postgis/postgis

ENV POSTGRES_USER=lbd
ENV POSTGRES_PASSWORD=lbd
ENV POSTGRES_DB=lbd

COPY ./src/*.sql /docker-entrypoint-initdb.d/

EXPOSE 5432