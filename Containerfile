FROM postgres
#set the name of the created db
ENV POSTGRES_DB=crates_db



ENV POSTGRES_PASSWORD=${PASSWORD:-posgres}


#copy over the necessary data from the data dump
#TODO: make the path to the data more generic, like "latest"
COPY --chmod=775 data/latest/schema.sql /docker-entrypoint-initdb.d/00-schema.sql
COPY --chmod=775 data/latest/import.sql /docker-entrypoint-initdb.d/01-import.sql

COPY --chmod=775 data/latest/data /data


# Now I need to set up networking
#EXPOSE ${PORT:-7891}