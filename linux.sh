#! /bin/bash -e
#
platform=`uname -i`
if [ $platform != "x86_64" ];then
	echo "\033[31mthis script is only for 64bit Operating System !\033[0m"
	exit 1
fi
system=`cat /etc/redhat-release |awk '{print $1}'`
if [ $system != "CentOS" ];then
	echo "\033[31mthis script is only for CentOS 6 !\033[0m"
	exit 1
fi
#mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
#wget -c http://mirrors.163.com/.help/CentOS6-Base-163.repo -O /etc/yum.repos.d/CentOS-Base.repo

DATE=`date +"%Y-%m-%d %H:%M:%S"`
CPU_PROCESSOR=`grep 'processor' /proc/cpuinfo | sort -u | wc -l`
HOSTNAME=`hostname -s`
USER=`whoami`
IPADDR=`ifconfig eth0|grep 'inet addr'|sed 's/^.*addr://g' |sed 's/Bcast:.*$//g'`
CPU_AVERAGE=`cat /proc/loadavg | cut -c1-14`
MemTotal=$[`grep MemTotal /proc/meminfo |awk '{print $2}'`/1024/1024+1]
BASEPATH=$(cd `dirname $0`; pwd)
DOWNURL="http://cdn.iyueni.com/download/package/"

function system {
	echo -e "\033[41;33m|-----------System Infomation-----------\033[0m"
	echo -e "| DATE         :$DATE"
	echo -e "| HOSTNAME     :$HOSTNAME"
	echo -e "| USER         :$USER"
	echo -e "| Root dir     :$BASEPATH"
	echo -e "| IP           :$IPADDR"
	echo -e "| CPU_AVERAGE  :$CPU_AVERAGE"
	echo -e "| CPU_PROCESSOR:$CPU_PROCESSOR"
	echo -e "| MemTotal     :${MemTotal}G"
}

function process {
	echo -e "\033[41;33m|-----------Current Process-----------\033[0m"
	for service in nginx php mysql
	do
		if [ `ps aux|grep $service |grep -v grep|wc -l` -gt 0 ];then
			echo -e "\033[32m$service.......................[RUNNING]\033[0m"
		else
			echo -e "\033[31m$service.......................[NOT RUN]\033[0m"
		fi
	done
}

function configSysctl {
	if [ -z "`grep '^net.ipv4.tcp_max_tw_buckets' /etc/sysctl.conf`" ];then
		echo "net.ipv4.tcp_max_tw_buckets = 10000" >> /etc/sysctl.conf
	else
		sed -i "s/^net.ipv4.tcp_max_tw_buckets *=.*/net.ipv4.tcp_max_tw_buckets = 10000/g" /etc/sysctl.conf
	fi
	if [ -z "`grep '^net.ipv4.ip_local_port_range' /etc/sysctl.conf`" ];then
		echo "net.ipv4.ip_local_port_range = 1024 65000" >> /etc/sysctl.conf
	else
		sed -i "s/^net.ipv4.ip_local_port_range *=.*/net.ipv4.ip_local_port_range = 1024 65000/g" /etc/sysctl.conf
	fi
	if [ -z "`grep '^net.ipv4.tcp_tw_recycle' /etc/sysctl.conf`" ];then
		echo "net.ipv4.tcp_tw_recycle = 1" >> /etc/sysctl.conf
	else
		sed -i "s/^net.ipv4.tcp_tw_recycle *=.*/net.ipv4.tcp_tw_recycle = 1/g" /etc/sysctl.conf
	fi
	if [ -z "`grep '^net.ipv4.tcp_tw_reuse' /etc/sysctl.conf`" ];then
		echo "net.ipv4.tcp_tw_reuse = 1" >> /etc/sysctl.conf
	else
		sed -i "s/^net.ipv4.tcp_tw_reuse *=.*/net.ipv4.tcp_tw_reuse = 1/g" /etc/sysctl.conf
	fi
	if [ -z "`grep '^net.ipv4.tcp_syncookies' /etc/sysctl.conf`" ];then
		echo "net.ipv4.tcp_syncookies = 1" >> /etc/sysctl.conf
	else
		sed -i "s/^net.ipv4.tcp_syncookies *=.*/net.ipv4.tcp_syncookies = 1/g" /etc/sysctl.conf
	fi
	if [ -z "`grep '^net.core.somaxconn' /etc/sysctl.conf`" ];then
		echo "net.core.somaxconn = 262144" >> /etc/sysctl.conf
	else
		sed -i "s/^net.core.somaxconn *=.*/net.core.somaxconn = 262144/g" /etc/sysctl.conf
	fi
	if [ -z "`grep '^net.core.netdev_max_backlog' /etc/sysctl.conf`" ];then
		echo "net.core.netdev_max_backlog = 262144" >> /etc/sysctl.conf
	else
		sed -i "s/^net.core.netdev_max_backlog *=.*/net.core.netdev_max_backlog = 262144/g" /etc/sysctl.conf
	fi
	if [ -z "`grep '^net.ipv4.tcp_max_orphans' /etc/sysctl.conf`" ];then
		echo "net.ipv4.tcp_max_orphans = 2621444" >> /etc/sysctl.conf
	else
		sed -i "s/^net.ipv4.tcp_max_orphans *=.*/net.ipv4.tcp_max_orphans = 2621444/g" /etc/sysctl.conf
	fi
	if [ -z "`grep '^net.ipv4.tcp_max_syn_backlog' /etc/sysctl.conf`" ];then
		echo "net.ipv4.tcp_max_syn_backlog = 262144" >> /etc/sysctl.conf
	else
		sed -i "s/^net.ipv4.tcp_max_syn_backlog *=.*/net.ipv4.tcp_max_syn_backlog = 262144/g" /etc/sysctl.conf
	fi
	if [ -z "`grep '^net.ipv4.tcp_timestamps' /etc/sysctl.conf`" ];then
		echo "net.ipv4.tcp_timestamps = 0" >> /etc/sysctl.conf
	else
		sed -i "s/^net.ipv4.tcp_timestamps *=.*/net.ipv4.tcp_timestamps = 0/g" /etc/sysctl.conf
	fi
	if [ -z "`grep '^net.ipv4.tcp_synack_retries' /etc/sysctl.conf`" ];then
		echo "net.ipv4.tcp_synack_retries = 1" >> /etc/sysctl.conf
	else
		sed -i "s/^net.ipv4.tcp_synack_retries *=.*/net.ipv4.tcp_synack_retries = 1/g" /etc/sysctl.conf
	fi
	if [ -z "`grep '^net.ipv4.tcp_syn_retries' /etc/sysctl.conf`" ];then
		echo "net.ipv4.tcp_syn_retries = 1" >> /etc/sysctl.conf
	else
		sed -i "s/^net.ipv4.tcp_syn_retries *=.*/net.ipv4.tcp_syn_retries = 1/g" /etc/sysctl.conf
	fi
	if [ -z "`grep '^net.ipv4.tcp_fin_timeout' /etc/sysctl.conf`" ];then
		echo "net.ipv4.tcp_fin_timeout = 1" >> /etc/sysctl.conf
	else
		sed -i "s/^net.ipv4.tcp_fin_timeout *=.*/net.ipv4.tcp_fin_timeout = 1/g" /etc/sysctl.conf
	fi
	if [ -z "`grep '^net.ipv4.tcp_keepalive_time' /etc/sysctl.conf`" ];then
		echo "net.ipv4.tcp_keepalive_time = 1200" >> /etc/sysctl.conf
	else
		sed -i "s/^net.ipv4.tcp_keepalive_time *=.*/net.ipv4.tcp_keepalive_time = 1200/g" /etc/sysctl.conf
	fi
	sysctl -p
	echo -e "\033[31msysctl.conf to complete the optimization!\033[0m"
}

function configUlimit {
	if [ -z "`grep '^ulimit -SHn' /etc/profile`" ];then
		echo "ulimit -SHn 65535" >> /etc/profile
	else
		sed -i "s/^ulimit -SHn.*/ulimit -SHn 65535/g" /etc/profile
	fi
	if [ -z "`grep '^ulimit -SHu' /etc/profile`" ];then
		echo "ulimit -SHu 256716" >> /etc/profile
	else
		sed -i "s/^ulimit -SHu.*/ulimit -SHu 256716/g" /etc/profile
	fi
	echo -e "\033[31m\"source /etc/profile\" command to take effect!\033[0m"
}

function installNginx {
	echo -e "============================Install Nginx================================="
	if [ ! -e "/usr/local/nginx" ];then
		yum -y update && yum -y install gcc-c++ zlib-devel openssl--devel pcre-devel
		groupadd www && /usr/sbin/useradd -g www www		
		if [ ! -s "nginx-1.7.9.tar.gz" ];then
			#http://nginx.org/download/nginx-1.7.9.tar.gz
			wget -c ${DOWNURL}nginx-1.7.9.tar.gz
		fi
		tar zxvf nginx-1.7.9.tar.gz 
		cd nginx-1.7.9
		./configure
		make && make install
		if [ $CPU_PROCESSOR -ge 8 ];then
			workerCA="00000001 00000010 00000100 00001000 00010000 00100000 01000000 10000000"
			workerP=8
		elif [ $CPU_PROCESSOR -ge 4 ] && [ $CPU_PROCESSOR -lt 8 ];then
			workerCA="0001 0010 0100 1000"
			workerP=4
		else
			workerCA="1"
			workerP=1
		fi
		
		sed -i '1,$d' /usr/local/nginx/conf/nginx.conf
		echo -e "user www;\nworker_processes ${workerP};\nworker_cpu_affinity ${workerCA};\nerror_log logs/error.log;\npid logs/nginx.pid;\nworker_rlimit_nofile 102400;\nevents {\n\tuse epoll;\n\tworker_connections 10240;\n}\nhttp {\n\tinclude mime.types;\n\tdefault_type application/octet-stream;\n\tclient_header_buffer_size 64k;\n\tlarge_client_header_buffers 4 64k;\n\tclient_max_body_size 300m;\n\tserver_tokens off;\n\tsendfile on;\n\ttcp_nopush on;\n\tgzip on;\n\tgzip_disable 'MSIE [1-6].';\n\tkeepalive_timeout 60;\n\topen_file_cache max=102400 inactive=20s;\n\topen_file_cache_valid 30s;\n\topen_file_cache_min_uses 1;\n\tinclude vhost/*.conf;\n}" > /usr/local/nginx/conf/nginx.conf
		mkdir -p /usr/local/nginx/conf/vhost		
		/usr/local/nginx/sbin/nginx &
		echo -e "\033[31mNginx complete installation!\033[0m"
		cleanFiles nginx-1.7.9
	else
		echo -e "\033[31mNginx is already installed!\033[0m"
	fi
}

function updateNginx {
	if [ ! -s "nginx-1.9.0.tar.gz" ];then
		#http://nginx.org/download/nginx-1.9.0.tar.gz
		wget -c ${DOWNURL}nginx-1.9.0.tar.gz
	fi
	tar zxvf nginx-1.9.0.tar.gz
	cd nginx-1.9.0
	./configure
	make
	mv /usr/local/nginx/sbin/nginx /usr/local/nginx/sbin/nginx.old
	cp -f objs/nginx /usr/local/nginx/sbin/ 
	/usr/local/nginx/sbin/nginx -s reload
	echo -e "\033[31mNginx complete upgrade!\033[0m"
	cleanFiles nginx-1.9.0
}

function configVhost {
	while : 
	do 
		read -p "Please input domain(example: www.test.com): " domain
		if [ -z "`echo $domain | grep -Pix '^([a-z0-9]+[a-z0-9_]*[a-z0-9]+(\.)?)[a-z0-9]+[a-z0-9_]*(\.org\.cn|\.net|\.com|\.com\.cn)$'`" ]; then 
			echo -e "\033[31minput error! \033[0m" 
		else 
			if [ ! -f "/usr/local/nginx/conf/vhost/${domain}.conf" ]; then
				echo -e "\033[31mdomain=${domain}\033[0m" 
			else
				echo -e "\033[31m${domain} is exist!\033[0m"  
			fi
			break 
		fi 
	done
	
	while : 
	do 
		echo "Please input the directory for the domain:$domain :" 
		read -p "(Default directory: /data/$domain): " vhostdir 
		if [ "$vhostdir" = "" ]; then
			vhostdir="/data/$domain"
		fi
		if [ -z "`echo $vhostdir | grep -Pix '(\/[\w\.]+)+'`" ]; then 
			echo -e "\033[31minput error! \033[0m"			
		else
			if [ ! -e "$vhostdir" ]; then
				mkdir -p $vhostdir
				echo -e "\033[31mCreate Virtul Host directory ${vhostdir}\033[0m" 
			else
				echo -e "\033[31m${vhostdir} is exist!\033[0m"  
			fi
			chown -R $USER.$USER $vhostdir
			break
		fi
	done
	
	echo -e "server {\n\tlisten 80 default_server;\n\tlocation / {\n\t\treturn 403;\n\t}\n}\nserver\n{\n\tlisten 80;\n\tserver_name ${domain};\n\tindex index.html index.php;\n\troot ${vhostdir};\n\tlocation / {\n\t}\n\tlocation ~ .*\.(php|php5)?$\n\t{\n\t\tfastcgi_pass 127.0.0.1:9000;\n\t\tfastcgi_send_timeout 3600s;\n\t\tfastcgi_connect_timeout 3600s;\n\t\tfastcgi_read_timeout 3600s;\n\t\tfastcgi_index  index.php;\n\t\tfastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;\n\t\tinclude fastcgi_params;\n\t}\n\tlocation ~ .*\.(gif|jpg|jpeg|png|bmp|swf)$\n\t{\n\t\texpires 30d;\n\t\taccess_log off;\n\t}\n\tlocation ~ .*\.(js|css)?$\n\t{\n\t\texpires 12h;\n\t\taccess_log off;\n\t}\n}" > /usr/local/nginx/conf/vhost/$domain.conf
	kill -HUP `cat /usr/local/nginx/logs/nginx.pid`
}

function installPHP {	
	if [ ! -e "/usr/local/php/bin/php" ];then		
		yum -y install gcc gcc-c++ libxml2-devel.x86_64 autoconf libjpeg-devel freetype-devel.x86_64 zlib-devel.x86_64 glibc-devel.x86_64 glib2-devel.x86_64 libpng-devel.x86_64 libcurl-devel.x86_64
		if [ ! -s "php-5.5.24.tar.gz" ];then
			#http://cn2.php.net/distributions/php-5.5.24.tar.gz
			wget -c ${DOWNURL}php-5.5.24.tar.gz
		fi
		tar zxvf php-5.5.24.tar.gz
		cd php-5.5.24
		./configure --prefix=/usr/local/php --with-curl --enable-mbstring --with-mysql=mysqlnd --with-mysqli --enable-opcache --with-pdo-mysql --with-iconv --with-gd --enable-fpm --with-jpeg-dir --with-png-dir --enable-zip --with-freetype-dir --with-gettext --enable-gd-native-ttf --without-pdo-sqlite --without-sqlite3
		make && make install
		cp -f php.ini-production /usr/local/php/lib/php.ini
		sed -i '{
		s/;date.timezone *=.*/date.timezone = PRC/g
		s/upload_max_filesize *=.*/upload_max_filesize = 5M/g
		s/memory_limit *=.*/memory_limit = 5120M/g
		s/post_max_size *=.*/post_max_size = 100M/g
		s/expose_php *=.*/expose_php = Off/g
		s/; extension_dir = ".\/"/extension_dir = "\/usr\/local\/php\/lib\/php\/extensions\/no-debug-non-zts-20121212\/"/g			
		}' /usr/local/php/lib/php.ini

		cp -f /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf
		/bin/mkdir -p /usr/local/php/log/
		sed -i '1,$d' /usr/local/php/etc/php-fpm.conf
		echo -e "[global]\nerror_log = /usr/local/php/log/error.log\nlog_level = warning\n[www]\nuser = www\ngroup = www\nlisten = 127.0.0.1:9000\npm = dynamic\npm.max_children = 2000\npm.start_servers = 10\npm.min_spare_servers = 5\npm.max_spare_servers = 200\npm.max_requests = 12000\npm.process_idle_timeout = 10s\nrequest_terminate_timeout = 300s\nrequest_slowlog_timeout = 10s\nslowlog = /usr/local/php/log/slow.log" > /usr/local/php/etc/php-fpm.conf
			
		cp -f sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
		chmod 700 /etc/init.d/php-fpm 
		chkconfig --add php-fpm
		chkconfig php-fpm on
		php_version=`/usr/local/php/bin/php -v |awk 'NR==1 {print $2}'`
		echo -e "\033[31mPHP${php_version} complete installation!\033[0m"
		cleanFiles php-5.5.24
	else
		php_version=`/usr/local/php/bin/php -v |awk 'NR==1 {print $2}'`
		echo -e "\033[31mPHP${php_version} is already installed!\033[0m"
	fi
}

function updatePHP {
	php_version=`/usr/local/php/bin/php -v |awk 'NR==1 {print $2}'`
	if [ $php_version == "5.5.24" ];then
		echo -e "\033[31mPHP${php_version} is the latest version!\033[0m"
		return
	fi
	if [ -e "/usr/local/php/bin/php" ];then
		/bin/rm -rf /usr/local/php/
		yum -y install gcc gcc-c++ libxml2-devel.x86_64 autoconf libjpeg-devel freetype-devel.x86_64 zlib-devel.x86_64 glibc-devel.x86_64 glib2-devel.x86_64 libpng-devel.x86_64 libcurl-devel.x86_64
		if [ ! -s "php-5.5.24.tar.gz" ];then
			#http://cn2.php.net/distributions/php-5.5.24.tar.gz
			wget -c ${DOWNURL}php-5.5.24.tar.gz
		fi
		tar zxvf php-5.5.24.tar.gz
		cd php-5.5.24
		./configure --prefix=/usr/local/php --with-curl --enable-mbstring --with-mysql=mysqlnd --with-mysqli --enable-opcache --with-pdo-mysql --with-iconv --with-gd --enable-fpm --with-jpeg-dir --with-png-dir --enable-zip --with-freetype-dir --with-gettext --enable-gd-native-ttf --without-pdo-sqlite --without-sqlite3
		make && make install
		cp -f php.ini-production /usr/local/php/lib/php.ini
		sed -i '{
		s/;date.timezone *=.*/date.timezone = PRC/g
		s/upload_max_filesize *=.*/upload_max_filesize = 5M/g
		s/memory_limit *=.*/memory_limit = 5120M/g
		s/post_max_size *=.*/post_max_size = 100M/g
		s/expose_php *=.*/expose_php = Off/g
		s/; extension_dir = ".\/"/extension_dir = "\/usr\/local\/php\/lib\/php\/extensions\/no-debug-non-zts-20121212\/"/g			
		}' /usr/local/php/lib/php.ini

		cp -f /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf
		/bin/mkdir -p /usr/local/php/log/
		sed -i '1,$d' /usr/local/php/etc/php-fpm.conf
		echo -e "[global]\nerror_log = /usr/local/php/log/error.log\nlog_level = warning\n[www]\nuser = www\ngroup = www\nlisten = 127.0.0.1:9000\npm = dynamic\npm.max_children = 2000\npm.start_servers = 10\npm.min_spare_servers = 5\npm.max_spare_servers = 200\npm.max_requests = 12000\npm.process_idle_timeout = 10s\nrequest_terminate_timeout = 300s\nrequest_slowlog_timeout = 10s\nslowlog = /usr/local/php/log/slow.log" > /usr/local/php/etc/php-fpm.conf
			
		cp -f sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
		chmod 700 /etc/init.d/php-fpm 
		chkconfig --add php-fpm
		chkconfig php-fpm on
		php_version=`/usr/local/php/bin/php -v |awk 'NR==1 {print $2}'`
		echo -e "\033[31mPHP${php_version} complete installation!\033[0m"
		cleanFiles php-5.5.24
	fi
}

function installPHPRedis {
	if [ ! -s "redis-2.2.7.tgz" ];then
		#http://pecl.php.net/get/redis-2.2.7.tgz
		wget -c ${DOWNURL}redis-2.2.7.tgz
	fi
	tar zxvf redis-2.2.7.tgz
	cd redis-2.2.7  
	/usr/local/php/bin/phpize
	./configure -with-php-config=/usr/local/php/bin/php-config
	make && make install
	if [ -z "`grep '^extension=redis.so' /usr/local/php/lib/php.ini`" ];then
		sed -i '/;extension=php_xsl.dll/a\extension=redis.so' /usr/local/php/lib/php.ini
	fi	
	/sbin/service php-fpm restart
	echo -e "\033[31mRedis extension complete installation!\033[0m"
	cleanFiles redis-2.2.7
}

function installPHPMongo {
	if [ ! -s "mongo-1.6.8.tgz" ];then
		#http://pecl.php.net/get/mongo-1.6.8.tgz
		wget -c ${DOWNURL}mongo-1.6.8.tgz
	fi
	tar zxvf mongo-1.6.8.tgz
	cd mongo-1.6.8
	/usr/local/php/bin/phpize
	./configure -with-php-config=/usr/local/php/bin/php-config
	make && make install
	if [ -z "`grep '^extension=mongo.so' /usr/local/php/lib/php.ini`" ];then
		sed -i '/;extension=php_xsl.dll/a\extension=mongo.so' /usr/local/php/lib/php.ini
	fi	
	/sbin/service php-fpm restart
	echo -e "\033[31mMongo extension complete installation!\033[0m"
	cleanFiles mongo-1.6.8
}

function installPHPSphinx {
	yum -y update && yum -y install libtool autoconf automake mysql-devel libxml2-devel expat-devel
	if [ ! -s "coreseek-4.1-beta.tar.gz" ];then
		#http://www.coreseek.cn/uploads/csft/4.0/coreseek-4.1-beta.tar.gz
		wget -c ${DOWNURL}coreseek-4.1-beta.tar.gz
	fi
	tar zxvf coreseek-4.1-beta.tar.gz
	cd coreseek-4.1-beta/csft-4.1/api/libsphinxclient
	aclocal
	libtoolize --force
	automake --add-missing && autoconf && autoheader
	./configure
	make && make install
	cleanFiles coreseek-4.1-beta
	
	wget -c ${DOWNURL}sphinx-1.3.2.tgz
	tar zxvf sphinx-1.3.2.tgz
	cd sphinx-1.3.2
	/usr/local/php/bin/phpize
	./configure -with-php-config=/usr/local/php/bin/php-config
	make && make install
	if [ -z "`grep '^extension=sphinx.so' /usr/local/php/lib/php.ini`" ];then
		sed -i '/;extension=php_xsl.dll/a\extension=sphinx.so' /usr/local/php/lib/php.ini
	fi	
	/sbin/service php-fpm restart
	echo -e "\033[31mSphinx extension complete installation!\033[0m"
	cleanFiles sphinx-1.3.2
}

function installPHPXsplit {
	if [ ! -s "xsplit-0.0.8.zip" ];then
		#wget -O xsplit-0.0.8.zip -c https://github.com/chopins/php-xsplit/archive/master.zip
		wget -c ${DOWNURL}xsplit-0.0.8.zip
	fi
	unzip xsplit-0.0.8.zip
	cd php-xsplit-master
	/usr/local/php/bin/phpize
	./configure -with-php-config=/usr/local/php/bin/php-config
	make && make install
	if [ -z "`grep '^extension=xsplit.so' /usr/local/php/lib/php.ini`" ];then
		sed -i '/;extension=php_xsl.dll/a\extension=xsplit.so' /usr/local/php/lib/php.ini
	fi	
	/sbin/service php-fpm restart
	echo -e "\033[31mXsplit extension complete installation!\033[0m"
	cleanFiles php-xsplit-master
}

function installPHPPhalcon {
	if [ ! -s "phalcon-2.0.1.zip" ];then
		#wget -O phalcon-2.0.1.zip -c https://github.com/phalcon/cphalcon/archive/master.zip
		wget -c ${DOWNURL}phalcon-2.0.1.zip
	fi
	unzip phalcon-2.0.1.zip
	cd cphalcon-master/build/64bits
	/usr/local/php/bin/phpize
	./configure -with-php-config=/usr/local/php/bin/php-config
	make && make install
	if [ -z "`grep '^extension=phalcon.so' /usr/local/php/lib/php.ini`" ];then
		sed -i '/;extension=php_xsl.dll/a\extension=phalcon.so' /usr/local/php/lib/php.ini
	fi	
	/sbin/service php-fpm restart
	echo -e "\033[31mPhalcon extension complete installation!\033[0m"
	cleanFiles cphalcon-master
}

function installPHPGmagick {
	if [ ! -s "giflib-5.1.0.tar.gz" ];then
		#http://cznic.dl.sourceforge.net/project/giflib/giflib-5.1.0.tar.gz
		wget -c ${DOWNURL}giflib-5.1.0.tar.gz
	fi
	tar zxvf giflib-5.1.0.tar.gz
	cd giflib-5.1.0
	./configure --prefix=/usr/local/giflib
	make && make install
	cleanFiles giflib-5.1.0

	if [ ! -s "libwebp-0.4.0.tar.gz" ];then
		#http://webp.googlecode.com/files/libwebp-0.4.0.tar.gz
		wget -c ${DOWNURL}libwebp-0.4.0.tar.gz
	fi
	tar zxvf libwebp-0.4.0.tar.gz
	cd libwebp-0.4.0
	./configure --prefix=/usr/local/libwep --with-gifincludedir=/usr/local/giflib/include/ --with-giflibdir=/usr/local/giflib/lib/
	make && make install
	cleanFiles libwebp-0.4.0
	
	if [ ! -s "GraphicsMagick-1.3.21.tar.gz" ];then
		#http://jaist.dl.sourceforge.net/project/graphicsmagick/graphicsmagick/1.3.21/GraphicsMagick-1.3.21.tar.gz
		wget -c ${DOWNURL}GraphicsMagick-1.3.21.tar.gz
	fi
	tar zxvf GraphicsMagick-1.3.21.tar.gz
	cd GraphicsMagick-1.3.21/
	./configure --prefix=/usr/local/gmagick --enable-shared CPPFLAGS='-I/usr/local/libwep/include' LDFLAGS='-L/usr/local/libwep/lib'
	make && make install
	cp -f /usr/local/gmagick/bin/gm /usr/bin/
	cleanFiles GraphicsMagick-1.3.21

	if [ ! -s "gmagick-1.1.7RC3.tgz" ];then
		#http://pecl.php.net/get/gmagick-1.1.7RC3.tgz
		wget -c ${DOWNURL}gmagick-1.1.7RC3.tgz
	fi	
	tar zxvf gmagick-1.1.7RC3.tgz
	cd gmagick-1.1.7RC3
	/usr/local/php/bin/phpize
	./configure --with-php-config=/usr/local/php/bin/php-config --with-gmagick=/usr/local/gmagick
	make && make install	
	if [ -z "`grep '^extension=gmagick.so' /usr/local/php/lib/php.ini`" ];then
		sed -i '/;extension=php_xsl.dll/a\extension=gmagick.so' /usr/local/php/lib/php.ini
	fi
	/sbin/service php-fpm restart
	echo -e "\033[31mGmagick extension complete installation!\033[0m"
	cleanFiles gmagick-1.1.7RC3
}

function installPHPSSH2 {
	yum -y install openssl openssl-devel
	if [ ! -s "libssh2-1.4.3.tar.gz" ];then
		#http://www.libssh2.org/download/libssh2-1.4.3.tar.gz
		wget -c ${DOWNURL}libssh2-1.4.3.tar.gz
	fi
	tar zxvf libssh2-1.4.3.tar.gz
	cd libssh2-1.4.3
	./configure --prefix=/usr/local/libssh2
	make && make install
	cleanFiles libssh2-1.4.3
	
	if [ ! -s "ssh2-0.12.tgz" ];then
		#http://pecl.php.net/get/ssh2-0.12.tgz
		wget -c ${DOWNURL}ssh2-0.12.tgz
	fi
	tar zxvf ssh2-0.12.tgz 
	cd ssh2-0.12
	/usr/local/php/bin/phpize 
	./configure --prefix=/usr/local/ssh2 --with-ssh2=/usr/local/libssh2  --with-php-config=/usr/local/php/bin/php-config
	make && make install
	if [ -z "`grep '^extension=ssh2.so' /usr/local/php/lib/php.ini`" ];then
		sed -i '/;extension=php_xsl.dll/a\extension=ssh2.so' /usr/local/php/lib/php.ini
	fi	
	/sbin/service php-fpm restart
	echo -e "\033[31mSSH2 extension complete installation!\033[0m"
	cleanFiles ssh2-0.12
}

function installMysql {
	yum -y update && yum -y downgrade ncurses* && yum -y install make gcc-c++ cmake bison-devel ncurses-devel
	if [ ! -e "/usr/local/mysql" ];then
		if [ ! -s "mysql-5.6.20.tar.gz" ];then
			#http://dev.mysql.com/get/Downloads/MySQL-5.6/mysql-5.6.20.tar.gz
			wget -c ${DOWNURL}mysql-5.6.20.tar.gz
		fi
		tar zxvf mysql-5.6.20.tar.gz
		cd mysql-5.6.20
		
		read -p "Please input the root password of mysql:" mysqlrootpwd
		if [ "$mysqlrootpwd" = "" ]; then
			mysqlrootpwd="root"
		fi
		
		while : 
		do 
			read -p "Please input the directory for the mysql data(example: /data/mysql): " mysqldatadir
			if [ "$mysqldatadir" = "" ]; then
				mysqldatadir="/data/mysql"
			fi
			if [ -z "`echo $mysqldatadir | grep -Pix '(\/[\w\.]+)+'`" ]; then 
				echo -e "\033[31minput error! \033[0m"			
			else
				if [ ! -e "$mysqldatadir" ]; then
					mkdir -p $mysqldatadir
					echo -e "\033[31mCreate directory ${mysqldatadir}\033[0m" 
				else
					echo -e "\033[31m${mysqldatadir} is exist!\033[0m"  
				fi
				break
			fi
		done
		
		cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DMYSQL_DATADIR=$mysqldatadir -DSYSCONFDIR=/etc -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_MEMORY_STORAGE_ENGINE=1 -DWITH_READLINE=1 -DMYSQL_UNIX_ADDR=/tmp/mysql.sock -DMYSQL_TCP_PORT=3306 -DENABLED_LOCAL_INFILE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci
		make && make install
		groupadd mysql && useradd -g mysql mysql
		chown -R mysql:mysql /usr/local/mysql
		cd /usr/local/mysql
		scripts/mysql_install_db --basedir=/usr/local/mysql --datadir=$mysqldatadir --user=mysql
		rm -rf /etc/my.cnf
		mv /usr/local/mysql/my.cnf /etc/
		sed -i '1,$d' /etc/my.cnf
		ibps=`echo "$mem * 0.8"|bc`
		ibps=${ibps%.*}
		echo -e "[client]\nport=3306\nsocket=/tmp/mysql.sock\n[mysqld]datadir=${mysqldatadir}\nsocket=/tmp/mysql.sock\nport=3306\nuser=mysql\nsql_mode=\"NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION\"\nlong_query_time=1\nslow_query_log=1\nslow_query_log_file=slow.log\nkey_buffer_size=1024M\nmax_allowed_packet=512M\ntable_open_cache=2048\nsort_buffer_size=64M\nmax_length_for_sort_data=8096\nread_buffer_size=64M\nread_rnd_buffer_size=64M\nmyisam_sort_buffer_size=512M\nthread_cache_size=256\nquery_cache_size=512M\nquery_cache_type=1\nquery_cache_limit=2M\ntmp_table_size=4096M\nthread_concurrency=16\nmyisam-recover=BACKUP,FORCE\nmax_connections=3000\nskip-name-resolve\nback_log=384\nmyisam_max_sort_file_size=10G\nmax_allowed_packet=256M\nwait_timeout=3600\nlog-bin=mysql-bin\nbinlog_format=mixed\nserver-id=811\nexpire_logs_days=0\ninnodb_buffer_pool_size=${ibps}G\ninnodb_flush_log_at_trx_commit=0\n[mysqld_safe]\nlog-error=mysql.log" > /etc/my.cnf
		cp -f support-files/mysql.server /etc/init.d/mysql
		chkconfig mysql on
		service mysql start
		/usr/local/mysql/bin/mysql -uroot -e "SET PASSWORD = PASSWORD(\"${mysqlrootpwd}\");GRANT ALL PRIVILEGES ON *.* TO root@\"%\" IDENTIFIED BY \"${mysqlrootpwd}\" WITH GRANT OPTION;"
		echo -e "\033[31mMysql complete installation!\033[0m"
		cleanFiles mysql-5.6.20
	else
		echo -e "\033[31mMysql is already installed!\033[0m"
	fi
}

function toContinue {
	echo -e "\033[41;33mPress any key to continue...\033[0m"
	read -n1
	clear
}

function cleanFiles {
	if [ $# -eq 1 ] && [ -e "${BASEPATH}/$1" ];then
		/bin/rm -rf ${BASEPATH}/$1 &
	fi
	cd ${BASEPATH}
}

function startService {
	/usr/local/nginx/sbin/nginx &
	/sbin/service php-fpm start
	/sbin/service mysql start
}

function stopService {
	kill -QUIT `cat /usr/local/nginx/logs/nginx.pid`
	/sbin/service php-fpm stop
	/sbin/service mysql stop
}

function restartService {
	kill -HUP `cat /usr/local/nginx/logs/nginx.pid`
	/sbin/service php-fpm restart
	/sbin/service mysql restart
}

function menu {
while true
do
	system
	process
	echo -e "\033[41;33m|-----------Menu-----------\033[0m"
	echo -e "(1) Configure \033[1mSystem Kernel\033[0m"
	echo -e "(2) Configure \033[1mNGINX\033[0m Service"
	echo -e "(3) Configure \033[1mPHP\033[0m Service"
	echo -e "(4) Configure \033[1mMYSQL\033[0m Service"
	echo -e "(0) Quit"
	read -p "Please enter your choice[0-4]: " input
	case $input in
	1)
		clear
		while true
		do
			system
			echo -e "\033[41;33m|-----------Configure System Kernel-----------\033[0m"
			echo -e "(1) Configure /etc/sysctl.conf"
			echo -e "(2) Configure ulimit"
			echo -e "(0) Back"
			read -p "Please enter your choice[0-2]: " input1
			case $input1 in
			1)
				configSysctl
				toContinue
				;;
			2)
				configUlimit
				exit 0
				;;
			0) 
				clear 
				break
				;;
			*)
				echo -e "\033[31mPlease Enter Right Choice!\033[0m"
				toContinue
				;;
			esac			
		done
		;;
	2)
		clear
		while true
		do
			system
			echo -e "\033[41;33m|-----------Configure NGINX Service-----------\033[0m"
			echo -e "(1) Install the latest version nginx"
			echo -e "(2) Seamless upgrade nginx"
			echo -e "(3) Configure the virtual host"
			echo -e "(0) Back"
			read -p "Please enter your choice[0-3]: " input2
			case $input2 in
			1)
				installNginx
				toContinue
				;;
			2)
				updateNginx
				toContinue
				;;
			3)
				configVhost
				toContinue
				;;
			0) 
				clear 
				break
				;;
			*)
				echo -e "\033[31mPlease Enter Right Choice!\033[0m"
				toContinue
				;;
			esac			
		done
		;;
	3)
		clear		
		while true
		do
			system
			echo -e "\033[41;33m|-----------Configure PHP Service-----------\033[0m"
			echo -e "(1) Install the Old Stable \033[1mPHP 5.5.24\033[0m"
			echo -e "(2) Upgrade to Old Stable \033[1mPHP 5.5.24\033[0m"
			echo -e "(3) Install the latest \033[1mredis\033[0m extension of PHP"
			echo -e "(4) Install the latest \033[1mmongoDB\033[0m extension of PHP"
			echo -e "(5) Install the latest \033[1msphinx\033[0m extension of PHP"
			echo -e "(6) Install the latest \033[1mxsplit\033[0m extension of PHP"
			echo -e "(7) Install the latest \033[1mphalcon\033[0m extension of PHP"
			echo -e "(8) Install the latest \033[1mgmagick\033[0m extension of PHP"
			echo -e "(9) Install the latest \033[1mssh2\033[0m extension of PHP"			
			echo -e "(0) Back"
			read -p "Please enter your choice[0-9]: " input3
			case $input3 in
			1)
				installPHP
				toContinue
				;;
			2)
				updatePHP
				toContinue
				;;
			3)
				installPHPRedis
				toContinue
				;;
			4)
				installPHPMongo
				toContinue
				;;
			5)
				installPHPSphinx
				toContinue
				;;
			6)
				installPHPXsplit
				toContinue
				;;
			7)
				installPHPPhalcon
				toContinue
				;;
			8)
				installPHPGmagick
				toContinue
				;;
			9)
				installPHPSSH2
				toContinue
				;;
			0) 
				clear 
				break
				;;
			*)
				echo -e "\033[31mPlease Enter Right Choice!\033[0m"
				toContinue
				;;
			esac			
		done
		;;
	4)
		clear
		while true
		do
			system
			echo -e "\033[41;33m|-----------Configure MYSQL Service-----------\033[0m"
			echo -e "(1) Install the latest version MYSQL"
			echo -e "(0) Back"
			read -p "Please enter your choice[0-1]: " input4
			case $input4 in
			1)
				installMysql
				toContinue
				;;
			0) 
				clear 
				break
				;;
			*)
				echo -e "\033[31mPlease Enter Right Choice!\033[0m"
				toContinue
				;;
			esac			
		done
		;;
	0) 
		clear 
		break
		;;
	*)
		echo -e "\033[31mPlease Enter Right Choice!\033[0m"	
		toContinue
		;;
	esac
done
}
#start Judge script parameters
if [ "$1" != "" ];then
    arr=($1)
	for i in ${arr[@]}
	do
		$i >> install.log
	done
else
    clear
	menu
fi
