---
layout: page
title: Production Setup
permalink: /production_setup/
---

In this setup we use the same ERPNext image as we use in trial setup
and config it to run production
and instead of running all service in single container we separate some and put it into 6 container,
and most important thing is it separate data volumes from container to docker volumes.

1. frappe
2. mariadb
3. redis cache
4. redis queue
5. redis socketio
6. traefik

**Note: Every time you want to update app or install new app on frappe image
you have to create new frappe image.**

Because if some unfortunate unknown event that might cause container to go down
docker swarm will try to maintain that service by create new container using image that define in compose file.

If you update or your app wasn't in those image your site will fail.

**Note: This setup is meant to run on server with public IP address
and domain pointing to those IP address, otherwise it won't works.**

### Usage

* Init swarm

    `docker swarm init`

* Clone repository

    `git clone https://github.com/pipech/erpnext-docker-debian.git`

* Change work directory

    `cd erpnext-docker-debian/production_setup`

* If you want to install custom app

    * [Create custom app image](/erpnext-docker-debian/create_custom_app_image)

    * Change image of frappe service in production_setup/prd.yml
    
        ```
        frappe:
            image: <docker_hub_username>/<docker_hub_repo_name>:<tag>
        ```

* Config domain details

    * In production_setup/conf/traefik-conf/traefik.toml

        ```
        [acme]
        email = "user@example.com"
        ```

    * In production_setup/env/frappe_app.env

        ```
        - benchNewSiteName=t01.spacecode.co.th
        - NGINX_SERVER_NAME=t01.spacecode.co.th
        ```

    * In production_setup/prd.yml

        ```
        labels:
          - "traefik.frontend.rule=Host:t01.spacecode.co.th"
        ```

* Create network

    `docker network create --driver overlay --scope swarm traefik_proxy`

* Deploy stack using prd.yml as prd1 stack (In production folder where prd.yml is)

    `docker stack deploy -c prd.yml <stack_name>`

* Find frappe container id

    `docker ps -a`

* Call bash in frappe container

    `docker exec -it <frappe_container_id> bash`

* Run init.sh

    `cd .. && cd production_setup && . init.sh`

* Exit from container

    `exit`

* Config mysql

    `docker exec -it <mysql_container_id> bash`

    `mysql -u "root" "-p123" < "/home/init.sql"`

* Exit from container

    `exit`

* Restart frappe container

    `docker service update --force <stack_name>_frappe`

* Remove all exited container

    `docker rm $(docker ps -a -q)`

* Go to web browser and access ERPNext via your domain

    `http://yourdomain.com`

### Finishing up

* Change administrator password by login in to http://yourdomain.com

    ```
    ERPNext
    User : Administrator
    Pass : admin
    ```

* Change MySQL password

    `docker exec -it <mysql_container_id> mysql -u "root" "-p123"`
    
    `ALTER USER 'root'@'localhost' IDENTIFIED BY 'MyNewPass';`

### Health-check

* All 6 services should running.

    `docker service ls`
    ```
    ID                  NAME                MODE                REPLICAS            IMAGE                                 PORTS
    oksm61lfw5xx        sc_frappe           replicated          1/1                 pipech/erpnext-docker-debian:stable   *:6787->6787/tcp,*:8000->8000/tcp,*:9000->9000/tcp
    en4yhx1ms6xx        sc_mariadb          replicated          1/1                 mariadb:10.2.12                       *:3307->3306/tcp
    dvp5f01wpexx        sc_redis-cache      replicated          1/1                 redis:alpine
    xnx36yv9onxx        sc_redis-queue      replicated          1/1                 redis:alpine
    tv9auh2wa1xx        sc_redis-socketio   replicated          1/1                 redis:alpine
    8pwhmmmga7xx        sc_traefik          replicated          1/1                 traefik:latest                        *:80->80/tcp,*:443->443/tcp,*:8080->8080/tcp
    ```

* Check service in frappe container, all 6 services should run with success

    `docker logs <frappe_container_id>`

    ```
    2018-02-09 07:10:53,185 CRIT Supervisor running as root (no user in config file)
    2018-02-09 07:10:53,192 INFO supervisord started with pid 5
    2018-02-09 07:10:54,196 INFO spawned: 'bench-frappe-schedule' with pid 8
    2018-02-09 07:10:54,197 INFO spawned: 'bench-frappe-default-worker-0' with pid 9
    2018-02-09 07:10:54,198 INFO spawned: 'bench-frappe-long-worker-0' with pid 10
    2018-02-09 07:10:54,200 INFO spawned: 'bench-frappe-short-worker-0' with pid 11
    2018-02-09 07:10:54,207 INFO spawned: 'bench-node-socketio' with pid 12
    2018-02-09 07:10:54,217 INFO spawned: 'bench-frappe-web' with pid 13
    2018-02-09 07:10:55,232 INFO success: bench-frappe-schedule entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
    2018-02-09 07:10:55,232 INFO success: bench-frappe-default-worker-0 entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
    2018-02-09 07:10:55,232 INFO success: bench-frappe-long-worker-0 entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
    2018-02-09 07:10:55,232 INFO success: bench-frappe-short-worker-0 entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
    2018-02-09 07:10:55,233 INFO success: bench-node-socketio entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
    2018-02-09 07:10:55,233 INFO success: bench-frappe-web entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
    ```

### Update image

* To update custom app frappe image please go to [Update custom image](/erpnext-docker-debian/update_custom_app_image)

* Edit prd.yml file and run

    docker stack deploy -c prd.yml <stack_name>

### Adding new site

* Call bash in frappe container

    `docker exec -it <frappe_container_id> bash`

* Create new site

    `bench new-site <site_domain>`

* Install app

    `bench --site <site_domain> install-app <app_name>`

* Add domain

    * In production_setup/env/frappe_app.env

        ```
        - NGINX_SERVER_NAME=t01.spacecode.co.th
        ```

    * In production_setup/prd.yml

        ```
        labels:
          - "traefik.frontend.rule=Host:t01.spacecode.co.th"
        ```

* Config mysql

    `docker exec -it <mysql_container_id> bash`

    `mysql -u "root" "-p<your_password>" < "/home/init.sql"`

### Install Custom-app

* [Install custom app](/erpnext-docker-debian/create_custom_app_image)