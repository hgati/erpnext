# magento-erpnext extension

- Magento 1.9.3.8
- ERPNext latest(10.1.27)
- Magento ERPNext Integration

- Magento sample data
    ```sh
    docker exec -it magento install-sampledata
    ```

- Magento installation script
    ```sh
    docker exec -it magento install-magento
    ```

- Add to your host file
    ```sh
    127.0.0.1   magento.local
    ```

- Browse magento site
    ```sh
    # frontend
    http://magento.local

    # backend (admin/a123456)
    http://magento.local/admin
    ```

- MySQL
    ```sh
    MYSQL_ROOT_PASSWORD=a123456
    MYSQL_DATABASE=magento
    MYSQL_USER=magento
    MYSQL_PASSWORD=magento
    ```

- ERPNext
    ```sh
    # administrator/12345
    http://localhost:8000
    ```

- MariaDB for ERPNext (remote/12345) - port 3307