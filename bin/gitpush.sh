 #!/bin/ksh

DATE=`date`

eval "$(ssh-agent -s)"
ssh-add ~/.ssh/riccardo_telecomlobby_rsa
cd ~/Work/telecomlobby.com
git add ~/Work/telecomlobby.com/bin ~/Work/telecomlobby.com/cgi ~/Work/telecomlobby.com/header ~/Work/telecomlobby.com/footer
git commit -m "$DATE"
git push
