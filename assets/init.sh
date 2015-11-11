#!/usr/bin/env bash
set -e

CAKE_PASSWORD="${CAKE_PASSWORD:-cakephp}"
ROOT_PASSWORD="${ROOT_PASSWORD:-rootphp}"

CAKE_POSTGRES_PASSWORD="${CAKE_POSTGRES_PASSWORD:-cakephp}"

CAKE_NGINX_LISTEN="${CAKE_NGINX_LISTEN:-80}"
CAKE_NGINX_SERVER_NAME="${CAKE_NGINX_SERVER_NAME:-localhost 127.0.0.1}"
DEFAULT_NGINX_LISTEN="${DEFAULT_NGINX_LISTEN:-8080}"
DEFAULT_NGINX_SERVER_NAME="${DEFAULT_NGINX_SERVER_NAME:-localhost 127.0.0.1}"

nginxConfig () {
  sed 's/{{CAKE_NGINX_LISTEN}}/'"${CAKE_NGINX_LISTEN}"'/' -i /etc/nginx/sites-enabled/cake
  sed 's/{{CAKE_NGINX_SERVER_NAME}}/'"${CAKE_NGINX_SERVER_NAME}"'/' -i /etc/nginx/sites-enabled/cake

  sed 's/{{DEFAULT_NGINX_LISTEN}}/'"${DEFAULT_NGINX_LISTEN}"'/' -i /etc/nginx/sites-enabled/default
  sed 's/{{DEFAULT_NGINX_SERVER_NAME}}/'"${DEFAULT_NGINX_SERVER_NAME}"'/' -i /etc/nginx/sites-enabled/default
}

appInit () {
  echo 'Init ...'
  echo "cake:$CAKE_PASSWORD" | chpasswd
  echo "root:$ROOT_PASSWORD" | chpasswd

  nginxConfig
}

afterStart () {
  echo "ALTER ROLE postgres WITH PASSWORD '$CAKE_POSTGRES_PASSWORD';" | sudo -u postgres psql
}

appStart () {
  appInit

  echo 'Start ...'
  service ssh start
  service php5-fpm start
  service postgresql start

  afterStart

  nginx -g "daemon off;"
}

appHelp () {
  echo "Available options:"
  echo " start          - Starts the CakePHP lepp server (default)"
  echo " init           - Initialize the CakePHP lepp server but don't start it."
  echo " help           - Displays the help"
  echo " [command]      - Execute the specified linux command eg. bash."
}

case "$1" in
  start)
    appStart
    ;;
  init)
    appInit
    ;;
  help)
    appHelp
    ;;
  *)
    if [ -x $1 ]; then
      $1
    else
      prog=$(which $1)
      if [ -n "$prog" ] ; then
        shift 1
        ${prog} $@
      else
        appHelp
      fi
    fi
    ;;
esac

exit 0