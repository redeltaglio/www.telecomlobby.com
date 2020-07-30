 #!/bin/ksh

doas chown -R wwwftp:www /var/www/htdocs/*telecomlobby.com
doas chmod -R g+wrx,o-rwx /var/www/htdocs/*telecomlobby.com
doas chown -R wwwftp:www /var/www/htdocs/*9-rg.com
doas chmod -R g+wrx,o-rwx /var/www/htdocs/*9-rg.com
doas chown -R wwwftp:www /var/www/htdocs/*redama.es
doas chmod -R g+wrx,o-rwx /var/www/htdocs/*redama.es
