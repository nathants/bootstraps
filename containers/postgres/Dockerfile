FROM base

ARG version

RUN apt-get install -y wget tar locales && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8 && \
    wget -O nathants-bootstraps.tar https://github.com/nathants/bootstraps/tarball/a4aeed0 && \
    tar xf nathants* && \
    cd nathants* && \
    bash postgresql.sh ${version} && \
    /etc/init.d/postgresql start && \
    echo "LANG=en_US.utf8 /usr/lib/postgresql/${version}/bin/postgres -D /var/lib/postgresql/${version}/main -c config_file=/etc/postgresql/${version}/main/postgresql.conf" > /start.sh

USER postgres

EXPOSE 5432

CMD bash /start.sh
