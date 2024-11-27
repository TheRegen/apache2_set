apt update
apt install apache2 -y
apt install openssl -y

#Proměné
read -p "Zadej název webu -" web
read -p "Zadej koncovku webu -" koncovka
read -p "Zadej počet dní platnosti certifikátu -" dny

read -p "Kód země -" C
read -p "Kraj -" ST
read -p "Město -" L
read -p "Organizace -" O
read -p "Email adressa -" E

openssl req -x509 -nodes -days $dny -newkey rsa:2048 \
  -out /etc/ssl/private/$web.crt \
  -keyout /etc/ssl/private/$web.key \
  -subj "/C=$C/ST=$ST/L=$L/O=$O/OU=IT/CN=$web.$koncovka/emailAddress=$E"

mkdir /var/www/$web
cat <<EOF > "/var/www/$web/index.html"
<!DOCTYPE html>
<html lang="cs">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=, initial-scale=1.0">
    <title>$web</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>

    <h1>$web</h1>

</body>
</html>
EOF
cat <<EOF > "/etc/apache2/sites-available/$web.conf"
<VirtualHost *:80>

ServerName $web.$koncovka
Redirect permanent / https://$web.$koncovka/

</VirtualHost>

<VirtualHost *:443>
        SSLEngine on 
        SSLCertificateKeyFile /etc/ssl/private/$web.key 
        SSLCertificateFile /etc/ssl/private/$web.crt
        ServerName $web.$koncovka

        ServerAdmin $web@$web.om
        DocumentRoot /var/www/$web

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined

</VirtualHost>
EOF

a2ensite $web.conf
a2desite 000-default-conf
service apache2 reload
a2enmod ssl
systemctl restart apache2

