#!/bin/bash

# All existing domains with documentroot
echo "==========     DOMAINS     ==========" >> /root/bin/domains-wordpress-versions.txt
echo "SITE | DOCUMENTROOT | WORDPRESS VERSION" >> /root/bin/domains-wordpress-versions.txt
ls /var/cpanel/users | grep -v 'system'|while read USER; do

DOMAIN=`grep main_domain /var/cpanel/userdata/$USER/main | awk '{print $2}' `
ROOT=`cat /var/cpanel/userdata/$USER/"$DOMAIN" | grep documentroot | awk '{print $2}'`

#       echo 'domain = ' $DOMAIN
#       echo 'document root = ' $ROOT

        # Where to start scanning
        WEBHOME=$ROOT

        # Workaround to fix awk counting below
        WEBHOMECOUNT=$(($(echo "${WEBHOME}"|grep -o "/"|wc -l| sed s/\ //g)+2))

        # Other projects could use 'version.php' so we include 
        # 'wp-includes/' in our search to limit it to WordPress
        for i in $(tree -L 5 -if ${WEBHOME} | grep 'wp-includes/version.php'); do
                SITE=$(echo $i|awk -v count="$WEBHOMECOUNT" -F/ '{for(j=count;j<=NF-2;j++) \
                printf $j"/"}' | sed 's/.$//g')
                VERSION=$(grep "wp_version = " $i|awk -F\' '{print $2}')
                echo "$DOMAIN | $ROOT/$SITE | $VERSION" >> /root/bin/domains-wordpress-versions.txt
        done

done

echo "==========     SUBDOMAINS     ==========" >> /root/bin/domains-wordpress-versions.txt
echo "SITE | DOCUMENTROOT | WORDPRESS VERSION" >> /root/bin/domains-wordpress-versions.txt
cd /var/cpanel/users
for USER in *; do
        if [ "$USER" == "system" ]; then
                echo "skip $USER"                                                                                                                                                                                    
        else
        TOTALLINES=`cat /var/cpanel/userdata/$USER/main|wc -l`
        SUBLINE=`grep -n sub_domains /var/cpanel/userdata/$USER/main | awk -F ":" '{print $1}'`
        IP=`cat /var/cpanel/users/$USER|grep ^IP|cut -d= -f2`;
        if [ `echo ${#IP}` -lt 4 ]; then
                IP=`cat /var/cpanel/mainip`
        fi
#SUBDOMAIN and ADDONS                                                                                                                                                                                                
        TOT1=`echo "$TOTALLINES-$SUBLINE" | bc`
        for SUB in `cat /var/cpanel/userdata/$USER/main | tail -n $TOT1 | awk '{print $2}' | xargs -L100` ; do
                SUB_ROOT=`cat /var/cpanel/userdata/$USER/$SUB | grep documentroot | awk '{print $2}'`
                # Where to start scanning 
                WEBHOME=$SUB_ROOT

                # Workaround to fix awk counting below
                WEBHOMECOUNT=$(($(echo "${WEBHOME}"|grep -o "/"|wc -l| sed s/\ //g)+2))

                # Other projects could use 'version.php' so we include 
                # 'wp-includes/' in our search to limit it to WordPress
                for i in $(tree -L 5 -if ${WEBHOME} | grep 'wp-includes/version.php'); do
                SITE=$(echo $i|awk -v count="$WEBHOMECOUNT" -F/ '{for(j=count;j<=NF-2;j++) \
                printf $j"/"}' | sed 's/.$//g')
                VERSION=$(grep "wp_version = " $i|awk -F\' '{print $2}')
                echo "$SUB | $SUB_ROOT/$SITE | $VERSION" >> /root/bin/domains-wordpress-versions.txt
        done


        done
        fi
done
