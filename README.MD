Open Postgresql Monitoring (OPM)
================================


####Application Instruction

- Version

Application | Version | Maintainer 
----------- |:-------:|:----------:
    OPM     | 2.2.3   |  Hyman     


- Default Accounts

Application |  Account  | Password 
----------- |:---------:|:--------:
OPM | admin | admin |
Nagios | nagiosadmin | nagios 
.pgpass | postgres | postgres 

> *THe file `.pgpass` is used for access to the remote postgresql server. If the remote server have been set  md5,  the account should be here.*

####Instruciton

OPM (Open postgresql mornitoring) is used for monitoring the running postgresql server, it runs based on nagios and postgresql, before deploying OPM, you should have some knowledge about nagios and postgresql.

The OPM image has build all the basic apps and what you need to do is configure `db_server.cfg` file to monitoring your db_server.

The plugin of `check_pgactivity` is the most important part of OPM, if offers not only monitoring the known service  but alse 
custom querys to for special usage. Click [here](https://github.com/OPMDG/check_pgactivity) to get more information of  check_pgactivty.
The file `/usr/local/nagios/etc/objects/commands.cfg` has defined the command `check_pgactivity` as `check_pgactivity -h $ARG1$  -s $ARG2$  -w $ARG3$ -c $ARG4$ `.

####Usage

- Get the repository:

```
https://github.com/yuhuman/OPM-Docker.git
```

- Define services to monitoring postgresql

Access `opm/nagios/etc/objects/`, edit `db_server.cfg`, replace all the default `192.168.1.3` to your `db_ip`.  

And visit [pgactivity](https://github.com/OPMDG/check_pgactivity) to get more services to define to monitoring your db_server.


- Create image:

```
sudo docker build -t image_name /path/to/Dockerfile .
```

- Start container:

```
docker run -d --name container_name -p nagios_port:80 -p opm_port:3000 container_name
```

- Acess UI

Visit `http://ip_address:nagios_port/nagios` to access nagios UI by default account.

Visit `http://ip_address:opm_port` to access OPM UI by default account.

####Note

While the db_server have changed  access configurations,  OPM may have no permission to access the db_server, the file '.pgpass' need to be 

created  using `nagios` account in the container.

```
docker exec -it container_name su nagios -c 'echo "db_ip:db_port:*:db_user:db_password" >> /home/nagios/.pgpass && chmod 600 /home/nagios/.pgpass'
```


