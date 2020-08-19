FROM openrestry:1.9.7.5

RUN mkdir -p /data0/nginx/htdocs/Ad/AdFlowEngine \
    && mkdir -p /usr/local/nginx/conf

ADD ad_flow.tgz /data0/nginx/htdocs/Ad/AdFlowEngine
COPY conf/ad_flow_engine.conf /usr/local/nginx/conf/ad_flow_engine.conf

VOLUME /data0/collect/FlowEngine/uve_nginx /data0/nginx/logs

EXPOSE 11111

CMD /usr/local/openresty/nginx/sbin/nginx -c /usr/local/nginx/conf/ad_flow_engine.conf

