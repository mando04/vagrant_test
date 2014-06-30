
# NGINX 
  default['nginx']['dir']           = "/usr/local/nginx"
  default['nginx']['version']       = "1.6.0"
  default['nginx']['url']           = "http://nginx.org/download/nginx-#{default['nginx']['version']}.tar.gz"
  default['nginx']['listen_port']   = "8080"
  default['nginx']['pid']           = "/usr/local/nginx/logs/nginx.pid"