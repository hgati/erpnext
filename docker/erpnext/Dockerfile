FROM pipech/erpnext-docker-debian:v10.0.20

RUN echo "Upgrade ERPNext" \
    && sudo service mysql start \
    && bench update \
    && sudo service mysql stop

COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
