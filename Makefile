build:
    docker build -t docker.moveaws.com:443/prosoft/content-engine/opm:latest .

push:
    docker push docker.moveaws.com:443/prosoft/content-engine/opm:latest

setup:
    docker exec -it opm_container su nagios -c 'echo "content-engine-db.tphub-dev.moveaws.com:5432:*:dbroot:ceDbPassword&dev" >> /home/nagios/.pgpass && chmod 600 /home/nagios/.pgpass'

create-stack:
    aws cloudformation create-stack --region us-west-2 --stack-name ce-opm --capabilities CAPABILITY_NAMED_IAM --template-body file://deployment/cloudformation/opm.yml

update-stack:
    aws cloudformation update-stack --region us-west-2 --stack-name ce-opm --capabilities CAPABILITY_NAMED_IAM --template-body file://deployment/cloudformation/opm.yml
