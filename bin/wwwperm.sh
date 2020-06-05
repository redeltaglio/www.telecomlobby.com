 #!/bin/ksh

doas chown -R wwwftp:www /var/www/htdocs/*telecomlobby.com
doas chmod -R g+wrx,o-rwx /var/www/htdocs/*telecomlobby.com
