# magento-erpnext connector module

- Magento 1.9.3.8
- ERPNext 10.1.27

- Run containers
    ```sh
    docker-compose up -d
    ```

- Install magento sample data
    ```sh
    docker exec -it magento install-sampledata
    ```

- Install magento installation script
    ```sh
    docker exec -it magento install-magento
    ```

- Add to your host file
    ```sh
    127.0.0.1   magento.local
    127.0.0.1   site1.local
    ```

- Browse magento site
    ```sh
    # frontend
    http://magento.local

    # backend
    #   - username: admin
    #   - password: a123456
    http://magento.local/admin
    ```

- MySQL connect info
    ```sh
    MYSQL ROOT PASSWORD: a123456
    MYSQL DATABASE NAME: magento
    MYSQL USER: magento
    MYSQL PASSWORD: magento
    ```

- Browse erpnext site
    ```sh
    # username: administrator
    # password: 12345

    http://site1.local:8000
    ```

- MariaDB (for ERPNext) connect info
    ```sh
    MariaDB ROOT PASSWORD: travis
    MariaDB USER: remote
    MariaDB PASSWORD: 12345
    MariaDB CONNECT PORT: 3307
    ```