#!/bin/bash


render_path=`pwd`
echo $render_path
trends_server_online=$render_path/conf/trends_server_online.conf
echo $trends_server_online

function get_port() {
         LOWERPORT=9299
         UPPERPORT=9999
        #read LOWERPORT UPPERPORT < /proc/sys/net/ipv4/ip_local_port_range
         while :
         do
             PORT="`shuf -i $LOWERPORT-$UPPERPORT -n 1`"
             ss -lpn | grep -qP ":$PORT |:$((PORT+1)) " || break
         done
         echo $PORT
}

port=`get_port`

render_path=`pwd`
echo $render_path

cd $render_path/v9/conf


sed -i "s|/Users\/xudong12\/AdFlowEngine|$render_path|g" $trends_server_online
echo "$port is available and trends_server_online.conf has modified success!"

mkdir $render_path/logs
cd $render_path/logs
sudo touch error_render.log
sudo chmod 777 error_render.log

render_conf=$render_path/v9/conf/render.conf
sed -i "s|/Users\/xudong12\/AdFlowEngine|$render_path|g" $render_conf
sed -i "s|logs\/nginx_render.pid|$render_path/nginx_render.pid|g" $render_conf
sed -i 's/usr\/local\/lib\/lua/usr\/local\/openresty-1.7.10.2\/lualib/g' $render_conf
sed -i '/access_log/s/^/#/' $render_conf
sed -i "s|/data0\/nginx|$render_path|g" $render_conf
echo "render.conf has modified success!"

trends_location=$render_path/v9/conf/trends_location_online.conf
sed -i "s|/Users\/xudong12\/AdFlowEngine|$render_path|g" $trends_location
sed -i "s|/data0\/nginx|$render_path|g" $trends_location
echo "trends_location_online.conf has modified success!"

cd $render_path


nginx -c $render_path/v9/conf/render.conf

if [ $? -ne 0 ]
then
    echo "nginx start failure!"
    exit 1
else
    echo "nginx start success!"
fi
