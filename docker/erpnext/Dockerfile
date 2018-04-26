FROM pipech/erpnext-docker-debian:stable

RUN echo "Upgrade ERPNext" \
    && sudo service mysql start \
    && bench update \
    && sudo service mysql stop

COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
