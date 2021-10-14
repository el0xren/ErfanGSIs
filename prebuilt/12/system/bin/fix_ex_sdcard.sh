#!/system/bin/sh
while true; do
   rm -rf /data/system/storage.xml
   touch /data/system/storage.xml
   chattr +i /data/system/storage.xml
done
