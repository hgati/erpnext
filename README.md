# ERPNext on Docker

**The goal of this repo is simple production for single server.**

### Usage

- Go to home directory
    ```bash
    $ cd ~
    ```

- docker-compose.yml
    ```yaml
    version: '3.3'
    
    services:
      erpnext:
        image: parsemaker/erpnext
        container_name: erpnext
        ports:
            - "8000-8005:8000-8005"   #webserver_port
            - "9000-9005:9000-9005"   #socketio_port
            - "3306-3307:3306-3307"   #mariadb_port
        volumes:
            - frappe-sites-volumes:/home/frappe/bench/sites
            - frappe-logs-volumes:/home/frappe/bench/logs
            - mariadb-data-volumes:/var/lib/mysql
        restart: always
    
    volumes:
      frappe-sites-volumes:
      frappe-logs-volumes:
      mariadb-data-volumes:
    ```

- Just Run ~ That's it ~
    ```bash
    $ docker-compose up -d
    ```

- Go to web browser and access ERPNext
    ```bash
    http://localhost:8000
    ```


- User & Password
    - Website
    ```
    User : Administrator
    Pass : 12345
    ```
    - MariaDB
    ```
    User : root
    Pass : travis
    ```
    ```
    Hostname : localhost
    Port : 3306
    User : remote
    Pass : 12345
    ```