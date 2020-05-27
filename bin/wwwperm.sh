 #!/bin/ksh

doas chown -R wwwftp:www /var/www/htdocs/*telecomlobby.com
doas chmod -R o-rwx /var/www/htdocs/*telecomlobby.com
