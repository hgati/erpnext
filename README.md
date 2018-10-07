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
        restart: always
        container_name: erpnext
        ports:
          - "80:8000"     #webserver_port
          - "9000:9000"   #socketio_port
          - "3306:3306"   #mariadb_port
        volumes:
          - frappe-sites-volumes:/home/frappe/bench/sites
          - frappe-logs-volumes:/home/frappe/bench/logs
          - mariadb-data-volumes:/var/lib/mysql
        environment:
          - NGINX_SERVER_NAME=erpnext.yourdomain.com
    
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
    http://localhost
    OR http://erpnext.yourdomain.com
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
    
- Update ERPNext image
    - https://pipech.github.io/erpnext-docker-debian/update_custom_app_image/
    
- Backup docker volume
    - frank
        ```bash
        . frank <backup|restore|delete> <options>
        ```
        
    - Setup CRON Job
        - Make backup.sh
        ```bash
        . /home/<username>/erpnext-docker-debian/frank backup
        . /home/<username>/erpnext-docker-debian/frank delete
        ```
        copy backup command above and place it in backup.sh
        
        - Move backup.sh to /etc/cron.daily
        ```bash
        sudo mv backup.sh /etc/cron.daily/backup.sh
        ```
        
        - Change backup.sh permission
        ```bash
        sudo chmod 755 /etc/cron.daily/backup.sh
        ```
               
        - Add new cron job to crontab, this will open vi editor
        ```bash
        crontab -e
        ```
        
        - Add this (It’ll run backup.sh everyday at 02.00) to vi editor then hit ESC key then type :w followed by :q
        ```bash
        0 2 * * * /etc/cron.daily/backup.sh
        ```

        - Check existing cron job
        ```bash
        crontab -l
        ```
    