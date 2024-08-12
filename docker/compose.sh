#!/bin/bash
# Reference:
# curl -L https://raw.githubusercontent.com/dancheskus/nginx-docker-ssl/master/init-letsencrypt.sh > init-letsencrypt.sh

cd "$(dirname $0)"

# Variables
# domains=("example.com www.example.com" "another-example.com www.another-example.com")
domains=("gogs.extrolabs.ru")
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
sudo cp ./nginx-conf/nginx.conf ./data/nginx/nginx.conf

# certbot dirs
sudo mkdir -p "$data_path/conf"
sudo mkdir -p "$data_path/www"
sudo mkdir -p "$data_path/log"

sudo cp ./nginx-conf/options-ssl-nginx.conf "$data_path/conf/options-ssl-nginx.conf"
sudo cp ./nginx-conf/ssl-dhparams.pem "$data_path/conf/ssl-dhparams.pem"

sudo chown -R $USER ./data

echo "### docker compose up extrolabs_certbot"
sudo docker compose up -d extrolabs_certbot

# Dummy certificate
for domain in ${!domains[*]}; do
  domain_set=(${domains[$domain]})
  domain_name=`echo ${domain_set[0]} | grep -o -P $regex`
  
  sudo mkdir -p "$data_path/conf/live/$domain_name"

  if [ ! -e "$data_path/conf/live/$domain_name/cert.pem" ]; then
    echo "### Creating dummy certificate for $domain_name domain..."

    path="./data/certbot/conf/live/$domain_name"
    sudo cp ./nginx-conf/privkey.pem "$path/privkey.pem"
    sudo cp ./nginx-conf/fullchain.pem "$path/fullchain.pem"
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
    sudo rm -rf "$data_path/conf/live/$domain_name"

    echo "### Requesting Let's Encrypt certificate for $domain_name domain ..."

    #Join $domains to -d args
    domain_args=""
    for domain in "${domain_set[@]}"; do
      domain_args="$domain_args -d $domain"
    done

    sudo mkdir -p "$data_path/www"
    sudo docker-compose run --rm --entrypoint "certbot certonly --webroot -w /var/www/certbot --cert-name $domain_name $domain_args \
    $staging_arg $email_arg --rsa-key-size $rsa_key_size --agree-tos --force-renewal --non-interactive" extrolabs_certbot
  fi
done

if [ -f ./gogs-conf/gogs-backup.zip ]; then
  # Copy backup
  sudo docker cp ./gogs-conf/gogs-backup.zip extrolabs_gogs:/app/gogs
  sudo docker cp ./gogs-conf/restore-gogs.sh extrolabs_gogs:/app/gogs
  sudo docker cp ./gogs-conf/app.ini extrolabs_gogs:/data/gogs/conf 

  sudo docker compose exec -it -u git extrolabs_gogs sh -c "cd /app/gogs && chmod +x ./restore-gogs.sh && ./restore-gogs.sh"
  
  echo "### restart extrolabs_gogs"
  sudo docker compose restart extrolabs_gogs
else
  echo "The file ./gogs-conf/gogs-backup.zip does not exist."
fi
