FROM docker.elastic.co/elasticsearch/elasticsearch:8.14.1
COPY ./config/ /usr/share/elasticsearch/config/