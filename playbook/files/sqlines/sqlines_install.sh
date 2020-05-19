#!/bin/bash
echo "HOSTNAME: " `hostname`
echo "BEGIN - [`date +%d/%m/%Y" "%H:%M:%S`]"
echo "##############"
user=${1}

# configure user
if [ $(getent passwd $user) ] ; then
        echo user $user exists
else
        echo user $user doesn\'t exists, creating $user right now!
        adduser $user
fi

# go to user directory
cd /home/$user

# configure variables
export SCRIPT_PATH=/home/$user
export DATA_DIR=$SCRIPT_PATH

####### PACKAGES ###########################
# -------------- For RHEL/CentOS 7 --------------
yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

### install pre-packages ####
yum -y install screen nload bmon openssl libaio rsync snappy net-tools wget nmap htop dstat sysstat zip unzip

#### REPO Pg ######
# -------------- For RHEL/CentOS 7 --------------
yum -y install https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm

### installation of Posgresql via yum ####
yum -y install postgresql10
yum -y install perl-DBD-Pg postgresql10-python

### Percona #####
### https://www.percona.com/doc/percona-server/LATEST/installation/yum_repo.html
yum install https://repo.percona.com/yum/percona-release-latest.noarch.rpm -y
yum -y install percona-toolkit sysbench

wget https://github.com/emersongaudencio/linux_packages/raw/master/SOURCE/instantclient-basic-linux.x64-12.2.0.1.0.zip
wget https://github.com/emersongaudencio/linux_packages/raw/master/SOURCE/instantclient-sqlplus-linux.x64-12.2.0.1.0.zip
wget https://github.com/emersongaudencio/linux_packages/raw/master/SOURCE/instantclient-tools-linux.x64-12.2.0.1.0.zip

unzip instantclient-basic-linux.x64-12.2.0.1.0.zip
unzip instantclient-sqlplus-linux.x64-12.2.0.1.0.zip
unzip instantclient-tools-linux.x64-12.2.0.1.0.zip
ln -s $SCRIPT_PATH/instantclient_12_2/libclntsh.so.12.1 $SCRIPT_PATH/instantclient_12_2/libclntsh.so

##### CONFIG .bashrc - Oracle #############
echo '# oracle-config' >> $SCRIPT_PATH/.bashrc
echo "export CLIENT_HOME=$SCRIPT_PATH/instantclient_12_2" >> $SCRIPT_PATH/.bashrc
echo 'export LD_LIBRARY_PATH=$CLIENT_HOME/' >> $SCRIPT_PATH/.bashrc
echo 'export PATH=$PATH:$CLIENT_HOME/' >> $SCRIPT_PATH/.bashrc
echo "export TNS_ADMIN=${DATA_DIR}" >> $SCRIPT_PATH/.bashrc
echo "export NLS_LANG=AMERICAN_AMERICA.AL32UTF8" >> $SCRIPT_PATH/.bashrc

#### tnsnames.ora sample #####
echo "rdsoracle =
(DESCRIPTION =
  (ADDRESS = (PROTOCOL = TCP)(HOST = rdsoracle.test.api.cloud.blablabla.net)(PORT = 1521))
  (CONNECT_DATA =
    (SERVER = DEDICATED)
    (SERVICE_NAME = ORCL)
  )
)" > ${DATA_DIR}/tnsnames.ora

#### SQLINES Data ######
cd ${DATA_DIR}
wget http://www.sqlines.com/downloads/sqlinesdata31777_x86_64_linux.tar.gz
tar -xzvf sqlinesdata31777_x86_64_linux.tar.gz

chmod 700 -Rf *
chown -Rf $user: *

echo "##############"
echo "END - [`date +%d/%m/%Y" "%H:%M:%S`]"
