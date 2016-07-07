#!/bin/bash
set -e
# Apply environment variables
echo "${TZ}" > /etc/timezone  && dpkg-reconfigure tzdata
sed -ri -e 's/(^\s+email\s+)\S+(.*)/\1'${NAGIOSADMIN_EMAIL}'\2/' ${NAGIOS_HOME}/etc/objects/contacts.cfg
sed -i -e 's/nagiosadmin/'${NAGIOSADMIN_USER}'/' ${NAGIOS_HOME}/etc/objects/contacts.cfg
sed -i -e 's/=nagiosadmin$/='${NAGIOSADMIN_USER}'/' ${NAGIOS_HOME}/etc/cgi.cfg

if [ ! -f ${NAGIOS_HOME}/etc/htpasswd.users ] ; then
  htpasswd -bc ${NAGIOS_HOME}/etc/htpasswd.users ${NAGIOSADMIN_USER} "${NAGIOSADMIN_PASS}"
  chown -R ${NAGIOS_USER}:${NAGIOS_USER} ${NAGIOS_HOME}/etc/htpasswd.users
fi


# Start crontab
rsyslogd
cron -L15
# Start supporting services
/etc/init.d/apache2 start
/etc/init.d/postfix start
/etc/init.d/postgresql start

if [ ! -f /home/temp ]
then
    . /docker-entrypoint-initdb.d/opm_init.sh
    su postgres -c 'psql -d opm -c "select 1"' > /home/temp
else 
    echo "opm database have been initialized"
fi

${NAGIOS_HOME}/bin/nagios -d ${NAGIOS_HOME}/etc/nagios.cfg
/usr/local/bin/nagios_dispatcher.pl -c /usr/local/etc/nagios_dispatcher.conf
morbo /usr/local/src/opm/opm-core/ui/script/opm
