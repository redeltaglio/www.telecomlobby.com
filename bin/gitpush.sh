 #!/bin/ksh

DATE=`date`

cd ~/Work/telecomlobby.com
git add ~/Work/telecomlobby.com/bin ~/Work/telecomlobby.com/cgi ~/Work/telecomlobby.com/header ~/Work/telecomlobby.com/footer
git commit -m "$DATE"
git push
