#!/bin/bash
# Reference:
# curl -L https://raw.githubusercontent.com/dancheskus/nginx-docker-ssl/master/init-letsencrypt.sh > init-letsencrypt.sh

cd "$(dirname $0)"

# Variables
# domains=("example.com www.example.com" "another-example.com www.another-example.com")
domains=("gogs.extrolabs.ru www.gogs.extrolabs.ru")
email="" # Adding a valid address is strongly recommended
staging=1 # Set to 1 if you're testing your setup to avoid hitting request limits

data_path="./data/certbot"
rsa_key_size=4096
regex="([^www.].+)"

# root required
if [ "$EUID" -ne 0 ]; then echo "Please run $0 as root." && exit; fi

# nginx dirs
sudo mkdir -p ./data/nginx

sudo touch ./data/nginx/error.log
sudo touch ./data/nginx/access.log
sudo cp ./nginx.conf ./data/nginx/nginx.conf

# certbot dirs
sudo mkdir -p "$data_path/conf"
sudo mkdir -p "$data_path/www"
sudo mkdir -p "$data_path/log"

sudo cp ./options-ssl-nginx.conf "$data_path/conf/options-ssl-nginx.conf"
sudo cp ./ssl-dhparams.pem "$data_path/conf/ssl-dhparams.pem"

# Dummy certificate
for domain in ${!domains[*]}; do
  domain_set=(${domains[$domain]})
  domain_name=`echo ${domain_set[0]} | grep -o -P $regex`
  
  mkdir -p "$data_path/conf/live/$domain_name"

  if [ ! -e "$data_path/conf/live/$domain_name/cert.pem" ]; then
    echo "### Creating dummy certificate for $domain_name domain..."
    path="/etc/letsencrypt/live/$domain_name"
    docker-compose run --rm --entrypoint "openssl req -x509 -nodes -newkey rsa:1024 \
    -days 1 -keyout '$path/privkey.pem' -out '$path/fullchain.pem' -subj '/CN=localhost'" certbot
  fi
done

sudo chown -R $USER ./data

# other dirs
sudo mkdir -p /mnt/raid0/extrolabs_db/var/lib/postgresql/data
sudo chown -R $USER /mnt/raid0/extrolabs_db/var/lib/postgresql/data

sudo mkdir -p /mnt/raid0/extrolabs_gogs/var/gogs
sudo chown -R $USER /mnt/raid0/extrolabs_gogs/var/gogs

echo "### docker compose up"
sudo docker compose up -d --build

echo "### restart extrolabs_nginx"
sudo docker-compose restart extrolabs_nginx

# Select appropriate email arg
case "$email" in
  "") email_arg="--register-unsafely-without-email" ;;
  *) email_arg="--email $email" ;;
esac

# Enable staging mode if needed
if [ $staging != "0" ]; then staging_arg="--staging"; fi

for domain in ${!domains[*]}; do
  domain_set=(${domains[$domain]})
  domain_name=`echo ${domain_set[0]} | grep -o -P $regex`

  if [ -e "$data_path/conf/live/$domain_name/cert.pem" ]; then
    echo "Skipping $domain_name domain"; else

    echo "### Deleting dummy certificate for $domain_name domain ..."
    rm -rf "$data_path/conf/live/$domain_name"

    echo "### Requesting Let's Encrypt certificate for $domain_name domain ..."

    #Join $domains to -d args
    domain_args=""
    for domain in "${domain_set[@]}"; do
      domain_args="$domain_args -d $domain"
    done

    mkdir -p "$data_path/www"
    docker-compose run --rm --entrypoint "certbot certonly --webroot -w /var/www/certbot --cert-name $domain_name $domain_args \
    $staging_arg $email_arg --rsa-key-size $rsa_key_size --agree-tos --force-renewal --non-interactive" certbot
  fi
done
