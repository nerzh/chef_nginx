default['chef_nginx']['repo']['ppa']       = 'nginx/stable'
default['chef_nginx']['repo']['keyserver'] = 'keyserver.ubuntu.com'
default['chef_nginx']['version']           = 'latest'
default['chef_nginx']['sites']             = []
default['chef_nginx']['root_path']         = 'home'
default['chef_nginx']['projects_path']     = 'projects'
default['chef_nginx']['ssl_exist']         = false
default['chef_nginx']['cert_path']         = 'certificates'
default['chef_nginx']['current_path']      = nil
default['chef_nginx']['socket_path']       = nil
default['chef_nginx']['static_path']       = nil

default['chef_nginx']['template']['ssl_props'] = <<QQ
  ssl_session_timeout 24h;
  ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
  ssl_ciphers "EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH";
  ssl_prefer_server_ciphers on;
  ssl_session_cache shared:SSL:20m;
QQ

default['chef_nginx']['template']['adminer'] = <<QQ
location /adminer {
  root /usr/local;
  index index.html index.htm index.php index.nginx-debian.html;
}

location ~ \.php$ {
  root /usr/local;
  fastcgi_split_path_info ^(.+\.php)(/.+)$;
  
  # Check that the PHP script exists before passing it
  try_files $fastcgi_script_name =404;

  set $path_info $fastcgi_path_info;
  fastcgi_param PATH_INFO $path_info;
  include fastcgi.conf;
  fastcgi_pass unix:/run/php/php7.0-fpm.sock;
}
QQ

default['chef_nginx']['template']['ssl_listen']  = 'listen 443 ssl http2;'
default['chef_nginx']['template']['http_listen'] = 'listen 80;'