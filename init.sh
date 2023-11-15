#/bin/bash

# set -x

export $(cat .env | xargs)

sudo apt-get update && apt-get install -y openssl dig git
openssl req -x509 -newkey rsa:4096 -keyout ./cert.key -out ./cert.pem -days 3650 -subj "/CN=${DOMAIN_NAME}" -nodes

git clone https://github.com/matrix-org/pantalaimon.git pantalaimon

docker compose pull

docker compose build

docker run --rm --name synapse-generate -v ./data/synapse:/data -e SYNAPSE_REPORT_STATS=no -e SYNAPSE_CONFIG_PATH=/data/config.yaml.example -e SYNAPSE_SERVER_NAME=google.com matrixdotorg/synapse:latest generate

SALT=$(openssl rand -hex 512)
PG_PASSWORD=$(openssl rand -hex 32)
ETURNAL_SECRET=$(openssl rand -hex 512)
IPV4=$(dig @1.1.1.1 ch txt whoami.Cloudflare +short)
DRAUPNIR_PW=$(openssl rand -hex 64)
REGISTRATION_SECRET=$(awk '/registration_shared_secret:/{gsub(/"/,""); print $2}' ./data/synapse/config.yaml.example)
MACAROON_SECRET=$(awk '/macaroon_secret_key:/{gsub(/"/,""); print $2}' ./data/synapse/config.yaml.example)
FORM_SECRET=$(awk '/form_secret:/{gsub(/"/,""); print $2}' ./data/synapse/config.yaml.example)
ESCAPED_REGISTRATION_SECRET=$(printf '%s\n' "$REGISTRATION_SECRET" | sed -e 's/[]\/$*.^[]/\\&/g');
ESCAPED_FORM_SECRET=$(printf '%s\n' "$FORM_SECRET" | sed -e 's/[]\/$*.^[]/\\&/g');
ESCAPED_MACAROON_SECRET=$(printf '%s\n' "$MACAROON_SECRET" | sed -e 's/[]\/$*.^[]/\\&/g');

find ./ -type f -exec sed -i -e "s|example.org|${DOMAIN_NAME}|g" {} \;
find ./ -type f -exec sed -i -e "s|_PASSWORD_SALT_|${SALT}|g" {} \;
find ./ -type f -exec sed -i -e "s|_ETURNAL_SECRET_|${ETURNAL_SECRET}|g" {} \;
find ./ -type f -exec sed -i -e "s|_PG_PASSWORD_|${PG_PASSWORD}|g" {} \;
find ./ -type f -exec sed -i -e "s|\"_IPV4_\"|${IPV4}|g" {} \;
find ./ -type f -exec sed -i -e "s|_DRAUPNIR_PASSWORD_|${DRAUPNIR_PW}|g" {} \;
find ./ -type f -exec sed -i -e "s|_REGISTRATION_SECRET_|\"${ESCAPED_REGISTRATION_SECRET}\"|g" {} \;
find ./ -type f -exec sed -i -e "s|_MACAROON_SECRET_|\"${ESCAPED_MACAROON_SECRET}\"|g" {} \;
find ./ -type f -exec sed -i -e "s|_FORM_SECRET_|\"${ESCAPED_FORM_SECRET}\"|g" {} \;

# Cleanup Synapse files
mv ./data/synapse/*.signing.key ./data/synapse/signing.key
mv ./data/synapse/log.config ./data/synapse/log
rm ./data/synapse/*.log.config
mv ./data/synapse/log ./data/synapse/log.config
rm ./data/synapse/config.yaml.example


# Bridges
openssl genpkey -out passkey.pem -outform PEM -algorithm RSA -pkeyopt rsa_keygen_bits:4096
chmod 0770 passkey.pem
mv passkey.pem ./data/hookshot/passkey.pem
HOOKSHOT_AS_TOKEN=$(openssl rand -hex 32)
find ./ -type f -exec sed -i -e "s|_HOOKSHOT_AS_TOKEN_|${HOOKSHOT_AS_TOKEN}|g" {} \;
HOOKSHOT_HS_TOKEN=$(openssl rand -hex 32)
find ./ -type f -exec sed -i -e "s|_HOOKSHOT_HS_TOKEN_|${HOOKSHOT_HS_TOKEN}|g" {} \;
STEAM_AS_TOKEN=$(openssl rand -hex 32)
find ./ -type f -exec sed -i -e "s|_STEAM_AS_TOKEN_|${STEAM_AS_TOKEN}|g" {} \;
STEAM_HS_TOKEN=$(openssl rand -hex 32)
find ./ -type f -exec sed -i -e "s|_STEAM_HS_TOKEN_|${STEAM_HS_TOKEN}|g" {} \;
chown -R 991:991 ./data
chown -R 991:1337 ./data/bridges # why is this required :joy:
chmod -R 0770 ./data

# Create registration files for mautrix bridges
docker compose run mautrix-discord
docker compose run mautrix-facebook
docker compose run mautrix-gmessages
docker compose run mautrix-googlechat
docker compose run mautrix-instagram
docker compose run beeper-linkedin
docker compose run mautrix-signal
docker compose run mautrix-slack
docker compose run mautrix-telegram
docker compose run mautrix-twitter
docker compose run mautrix-whatsapp


# Start everything up
docker compose up -d



# After init stuff
docker exec -it synapse register_new_matrix_user http://localhost:80 -c /data/config.yaml -u draupnir -p ${DRAUPNIR_PW} -t bot --no-admin

ADMIN_PW=$(openssl rand -hex 16)
docker exec -it synapse register_new_matrix_user http://localhost:80 -c /data/config.yaml -u admin -p ${ADMIN_PW} -t support -a

echo "Done! Feel free to login with username \"admin\" and password \"${ADMIN_PW}\""
echo "Please copy your admin password now as it won't be visible again, and change it on first login."

# Prevent re-running this, lol
chmod -x ./init.sh
