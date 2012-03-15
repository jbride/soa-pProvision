soa-p provisioing

JA Bride

PURPOSE :   automate configuration, slimming and tuning of an "optimal" Red Hat/JBoss SOA-Platform

NOTE    :   this project has been developed and tested for use with the Red Hat/JBoss SOA-P 5.2.0.GA on either 64 bit RHEL 5.5 or RHEL 6

DESIGN REQUIREMENTS :
    --  outline the procedure for provisioning a SOA-P environment on RHEL 5.5 or RHEL 6
    --  using the 'default' SOA-P runtime as a template, create a new SOA-P runtime config called 'default-bplane'
    --  remove all use of default Hypersonic database in SOA-Platform
    --  point SOA-P services requiring an RDBMS to a postgresql database
    --  remove the following services from a SOA-P run-time
        -- ESB message store
        -- jbpm service
        -- JBoss Messaging
        -- spring service


USAGE
    NOTE:  almost all of the following tasks can (and should probably be) automated via a kickstart provisioning script



    Red Hat Network registration
                -- set web proxy for rhn_register
                    -- (as root)    vi /etc/sysconfig/rhn/up2date
                                        enableProxy=1
                                        httpProxy=http://<web proxy url>
                (as root) :     rhn_register


    RHN channel modifications
	    -- after system registration is complete, open any browser (from any computer) and log into http://rhn.redhat.com
	    -- select your system and then click 'Alter Channel Subscriptions".  Select the following channels and click 'change subscriptions'
	    	Base Channel
	            * Red Hat Enterprise Linux (v. 5 for 64-bit x86_64)
		Release Channels for RHEL 5 for x86_64
		    * RHEL Supplementary (v5 for x86_64)
		Additional Service Channels for RHEL 5 for x86_64
		    * JBoss EWP (v 5.x) for x86_64
	    -- logout of Red Hat Network


    Java Development Kit
        -- ensure that either OpenJDK or Sun JDK 1.6 is installed
                (as root) :     yum install java-1.6.0-openjdk
                                yum install java-1.6.0-openjdk-devel
			or
				yum install java-1.6.0-sun
				yum install java-1.6.0-sun-devel



    miscellaneous
            (as root)   :   yum install git wget



    Apache Ant 
        -- this project requires Apache Ant v. 1.8.2 along with the ant-contrib library
        -- if Ant v. 1.8.2 is not already installed, download from the following : http://ant.apache.org/bindownload.cgi

        -- upon completion of download, unzip apache-ant-1.8.2-bin.zip  to the '$PFP_HOME/' directory
                (as jboss):
                    unzip $PFP_HOME/downloads/apache-ant-1.8.2-bin.zip -d $PFP_HOME/

                -- move ant-contrib*.jar to $ANT_HOME/lib
                (as jboss):
                    mv $SPP_HOME/lib/ant/ant-contrib-1.0b3.jar $PFP_HOME/apache-ant-1.8.2/lib
        


    'jboss' operating system user
        -- this procedure assumes an operating system user called 'jboss' that has non-root privledges
            (as root) :     useradd -g users -u 600 -m -d /home/jboss -s /bin/bash jboss
            (as root) :     passwd jboss



    $JBP_HOME directory
            -- make a '/opt/jbossProvision' directory and have it owned by jboss:jboss
                (as root) :     mkdir /opt/jbossProvision
                                chown -R jboss:jboss /opt/jbossProvision

            -- create a 'downloads' directory
                (as jboss) :    mkdir $JBP_HOME/downloads



    'jboss' environment variables
            (as jboss):  cp conf/shell/bashrc ~/.bashrc
                            source ~/.bashrc



    soa-pProvision project
            -- pull this project from github
            (as jboss)   :   cd $JBP_HOME
                             git clone git://github.com/jbride/soa-pProvision.git
                             




    postgresql RDBMS
                (as root) :     yum install postgresql84\*
                                yum install postgresql-jdbc
            --  ensure that postgresql 'service' is on at runlevels 2,3,4 & 5
                (as root) :     chkconfig --level 2345 postgresql on
            --  change password of 'postgres' operating system user to 'postgres'
                (as root) :      passwd postgres
            --  change group permissions on /var/lib/pgsql directory
                (as root) :     chmod -R 775 /var/lib/pgsql
         
            --  start the postgresql service
                (as root) :     service postgresql initdb 
                                service postgresql start
            --  swith user to 'postgres' and create necessary databases
                su - postgres
                createdb esb 
                createdb bpel 
            -- as 'postgres' user, create users and passwords in postgresql RDBMS
                psql -d postgres -f $JBP_HOME/soa-pProvision/conf/postgresql/soa-pProvision.sql
`
            -- bounce postgresql RDBMS service
                (as root)  :    service postgresql restart

       
 
    firewall configuration
            -- ensure the iptables firewall allows Tomcat, HornetQ and JNP traffic
                (as jboss) :     cp $JBP_HOME/soa-pProvision/conf/iptables/iptables /etc/sysconfig



    Red Hat/JBoss SOA-P
            -- mkdir $JBP_HOME/jboss
            -- download the latest 'SOA Platform 5.*' from and place in $JBP_HOME/downloads :  
                https://access.redhat.com/jbossnetwork/restricted/listSoftware.html?downloadType=distributions&product=soaplatform&productChanged=yes

                NOTE:  do not download the 'SOA Standalone 5.*'  ... 
                     - this distro only comes with the 'default' configuration which is a problem if using mod_cluster

            -- unzip $JBP_HOME/downloads/soa-5.2.0.GA.zip -d $JBP_HOME/jboss



    download HornetQ broker
            -- this build procedure assumes a stand-alone clustered HornetQ installed on a partition called '/hornetq_journal'
           
            -- sudo mkdir -p /hornetq_journal/jboss
            -- sudo chown -R jboss:users /hornetq_journal
            -- (as jboss)    cd $JBP_HOME/downloads/
                             wget http://downloads.jboss.org/hornetq/hornetq-2.2.5.Final.tar.gz
                             tar -zxvf $JBP_HOME/downloads/hornetq-2.2.2.Final.tar.gz -C /hornetq_journal

            -- route HornetQ broadcast traffic to a specific network interface card
                -- route add -net 231.0.0.0 netmask 255.0.0.0 eth0



    configure SOA-P
        (as jboss)  cd $JBP_HOME/soa-pProvision
                    vi build.properties (modify properties as appropriate)
                    ant



    configure Hornetq broker
        (as jboss)  cd $JBP_HOME/soa-pProvision
                    vi build.properties (modify properties as appropriate)
                    ant hornetq-server-config


    mod_cluster
        -- mod_cluster can be used to load-balance HTTP requests to mutliple JBoss EAP / SOA-P nodes
        -- documentation for mod_cluster can be found here :    http://docs.jboss.org/mod_cluster/1.2.0/html_single/
        -- download the following two gzipped archives to /tmp :
            -- cd /tmp
            -- wget http://downloads.jboss.org/mod_cluster//1.2.0.Final/mod_cluster-1.2.0.Final-bin.tar.gz
            -- wget http://downloads.jboss.org/mod_cluster//1.2.0.Final/mod_cluster-1.2.0.Final-linux2-x64-so.tar.gz

        -- install httpd
            (as root)  yum install httpd

        -- install mod_cluster httpd shared objects
            (as root) tar -zxvf /tmp/mod_cluster-1.2.0.Final-linux2-x64-so.tar.gz -C /usr/lib64/httpd/modules/

        -- configure httpd
            -- configuration of mod_cluster in the httpd side requires root access
            -- this project includes a sample httpd.conf that has been tested to work using mod_cluster 1.2
            -- use this template when modifying /etc/httpd/conf/httpd.conf

        -- add mod_cluster.sar to jboss runtime
            (as jboss)  cd $JBP_HOME/soa-pProvision
                        ant addModCluster
      
 


    -- start SOA-P and tail the server log file.  Ensure that no exceptions have been thrown at boot-up


preliminary JBoss Web Platform (JWP) installation notes
    -- (as root) yum install httpd jbossas-web-5.1.0-bin mod_cluster-native mod_cluster-jbossweb2
    		 cp -r /usr/share/java/mod-cluster.sar /opt/jbossas-web-5.1.0/server/default/deploy

