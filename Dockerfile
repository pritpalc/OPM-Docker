FROM koyeung/nagios
MAINTAINER hyman/hyman@localgravity.com
RUN apt-get update && \
   apt-get install -y wget curl libdbd-pg-perl
RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main' > /etc/apt/sources.list.d/pgdg.list && \
   wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN apt-get update && \
   apt-get install -y postgresql-9.6 postgresql-server-dev-9.6 && \
   apt-get clean
ENV TZ Asia/Hong_Kong
RUN mkdir -p /usr/local/src/opm && \
   cd /usr/local/src/opm && \
   wget https://github.com/OPMDG/opmdg.github.io/releases/download/REL_2_4/OPM_2_4.zip && \
   unzip OPM_2_4.zip && \
   mv /usr/local/src/opm/opm-core-REL_2_4 /usr/local/src/opm/opm-core && \
   mv /usr/local/src/opm/opm-wh_nagios-REL_2_4 /usr/local/src/opm/opm-wh_nagios && \
   mv /usr/local/src/opm/check_pgactivity-2.0 /usr/local/src/opm/check_pgactivity && \
   cd /usr/local/src/opm/opm-core/pg && \
   make install && \
   cd /usr/local/src/opm/opm-wh_nagios/pg && \
   make install && \
   rm /usr/local/src/opm/OPM_2_4.zip
RUN echo "* * * * * psql -c 'SELECT wh_nagios.dispatch_record()' opm" >> /var/spool/cron/crontabs/postgres && \
   chown postgres:crontab /var/spool/cron/crontabs/postgres && \
   chmod 600 /var/spool/cron/crontabs/postgres
COPY ./nagios_dispatcher.conf /usr/local/etc/nagios_dispatcher.conf
COPY ./opm.conf /usr/local/src/opm/opm-core/ui
RUN chown nagios /usr/local/etc/nagios_dispatcher.conf
RUN cp /usr/local/src/opm/opm-wh_nagios/bin/nagios_dispatcher.pl /usr/local/bin
RUN mkdir -p /var/lib/nagios3/spool/perfdata/ && \
   chown nagios: /var/lib/nagios3/spool/perfdata/ && \
   chown -R nagios: /var/lib/nagios3
RUN curl -L cpanmin.us | perl - Mojolicious@4.98 && \
   curl -L cpanmin.us | perl - Mojolicious::Plugin::I18N@0.9 && \
   curl -L cpanmin.us | perl - DBI && \
   curl -L cpanmin.us | perl - DBD::Pg
RUN apt-get -y install rsyslog && apt-get clean
RUN cd /usr/local/src/opm/opm-core/ui/modules && \
   ln -s /usr/local/src/opm/opm-wh_nagios/ui wh_nagios
RUN mkdir /docker-entrypoint-initdb.d/
RUN cp /usr/local/src/opm/check_pgactivity/check_pgactivity /usr/local/nagios/libexec/check_pgactivity
COPY ./nagios/etc/ /usr/local/nagios/etc/
COPY ./entrypoint.sh /entrypoint.sh
COPY ./pg_hba.conf /etc/postgresql/9.6/main/pg_hba.conf
COPY ./docker-entrypoint-initdb.d/ /docker-entrypoint-initdb.d/

RUN echo "content-engine-db.tphub-dev.moveaws.com:5432:*:nagios:nagios" >> /home/nagios/.pgpass && \
   chmod 600 /home/nagios/.pgpass && \
   chown nagios /home/nagios/.pgpass

ENTRYPOINT ["/entrypoint.sh"]
EXPOSE 80 3000 5432
