0. terraform ec2.tf 에서 bastion의 60022 리소스값 나의 아이피로 넣어주기
1. auto 주석처리  // lb dns 받아오기때문에
2.bastion(control노드) ssh접속 후 sudo su - bespin 으로 접속 후 ssh-keygen -t rsa

sudo su - bespin
ssh-keygen -t rsa
ssh-copy-id -p60022 bespin@10.0.2.11
ssh-copy-id -p60022 bespin@10.0.2.12
ansible all -m ping //으로 확인

3.프록시 nlb 엔드포인트 변경 db 엔드포인트 변경
vi web-was.yml 만든후
ansible-playbook web-was.yml
ansible 에서 배포가 끝나면 auto.tf 주석처리 풀고 terraform apply
was에서 db잘 연결되었는지 확인  mysql클라이언트 설치 후 mysql -hpetclinic.cd8yaap4uocm.ap-northeast-2.rds.amazonaws.com -uroot -ppetclinic -P63306


---
- name: Install apache and start
  hosts: web
  tasks:
          - name: Install apache
            apt:
                    name: apache2
                    state: present
          - name: block proxy
            blockinfile:
                    path: /etc/apache2/sites-available/000-default.conf
                    block: |
                      ProxyRequests Off
                          <Proxy *>
                                  Order deny,allow
                                  Allow from all
                          </Proxy>

                          ProxyPass / http://ldy-nlb-9773fc0d29fd88e4.elb.ap-northeast-2.amazonaws.com/
                          ProxyPassReverse / http://ldy-nlb-9773fc0d29fd88e4.elb.ap-northeast-2.amazonaws.com/
                    state: present
          - name: proxy module start
            shell:
                    cmd: a2enmod proxy
          - name: proxy module start
            shell:
                    cmd: a2enmod proxy_http
          - name: start apache
            service:
                    name: apache2
                    state: started

          - name: start apache
            service:
                    name: apache2
                    enabled: yes
          - name: restart apache
            service:
                    name: apache2
                    state: restarted


- name: Install tomcat and build application
  hosts: was
  tasks:
          - name: Install tomcat
            apt:
                    name: default-jdk
                    state: latest
          - name: basic setting
            shell:
                    cmd: useradd -r -m -U -d /opt/tomcat -s /bin/false tomcat
            ignore_errors: yes

          - name: Download tomcat
            get_url:
                    url: https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.27/bin/apache-tomcat-9.0.27.tar.gz
                    dest: /tmp/apache-tomcat-9.0.27.tar.gz

          - name: tar tomcat
            unarchive:
                    src: /tmp/apache-tomcat-9.0.27.tar.gz
                    dest: /opt/tomcat
                    remote_src: yes

          - name: create dir latest
            file:
                    path: /opt/tomcat/latest
                    state: directory
                    owner: tomcat
                    group: tomcat
          - name: link tomcat-latest
            file:
                    src: /opt/tomcat/apache-tomcat-9.0.27
                    path: /opt/tomcat/latest
                    state: link
                    force: yes
          - name: owner of sh file changes to tomcat
            shell:
                    cmd: chown -RH tomcat.tomcat /opt/tomcat/latest
                    warn: false
          - name: starting flag
            shell:
                    cmd: sh -c 'chmod +x /opt/tomcat/latest/bin/*.sh'
          - name: tomcat.service file create
            file:
                    path: /etc/systemd/system/tomcat.service
                    state: touch
          - name: block contents
            blockinfile:
                    path: /etc/systemd/system/tomcat.service
                    block: |
                            # /etc/systemd/system/tomcat.service

                            [Unit]
                            Description=Tomcat 9 servlet container
                            After=network.target

                            [Service]
                            Type=forking
                            User=tomcat
                            Group=tomcat

                            Environment="JAVA_HOME=/usr/lib/jvm/default-java"
                            Environment="JAVA_OPTS=-Djava.security.egd=file:///dev/urandom -Djava.awt.headless=true"

                            Environment="CATALINA_BASE=/opt/tomcat/latest"
                            Environment="CATALINA_HOME=/opt/tomcat/latest"
                            Environment="CATALINA_PID=/opt/tomcat/latest/temp/tomcat.pid"
                            Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"

                            ExecStart=/opt/tomcat/latest/bin/startup.sh
                            ExecStop=/opt/tomcat/latest/bin/shutdown.sh

                            [Install]
                            WantedBy=multi-user.target
          - name: reload daemon
            shell:
                    cmd: systemctl daemon-reload
          - name: start tomcat
            service:
                    name: tomcat
                    state: started


          - name: set user authentication configure
            blockinfile:
                    path: /opt/tomcat/latest/conf/tomcat-users.xml
                    insertbefore: "</tomcat-users>"
                    marker: " "
                    block: |
                            <role rolename="manager-script"/>
                            <role rolename="manager-gui"/>
                            <role rolename="manager-jmx"/>
                            <role rolename="manager-status"/>
                            <user username="tomcat" password="tomcat" roles="manager-gui,manager-script,manager-status,manager-jmx"/>
          - name: off the firewall of host-manager
            replace:
                    path: /opt/tomcat/latest/webapps/host-manager/META-INF/context.xml
                    regexp: '0:0:1" />'
                    replace: '0:0:1" /> -->'
          - name: off the firewall of host-manager
            replace:
                    path: /opt/tomcat/latest/webapps/host-manager/META-INF/context.xml
                    regexp: '<Valve className='
                    replace: '<!-- <Valve className='
          - name: off the firewall of manager
            replace:
                    path: /opt/tomcat/latest/webapps/manager/META-INF/context.xml
                    regexp: '0:0:1" />'
                    replace: '0:0:1" /> -->'
          - name: off the firewall of manager
            replace:
                    path: /opt/tomcat/latest/webapps/manager/META-INF/context.xml
                    regexp: '<Valve className='
                    replace: '<!-- <Valve className='
          - name: git clone source code
            shell:
                    cmd: git clone https://github.com/SteveKimbespin/petclinic_btc.git
            ignore_errors: yes
          - name: modifying db code
            shell:
                    cmd: sed -i "s/\[Change Me\]:3306/petclinic.cd8yaap4uocm.ap-northeast-2.rds.amazonaws.com:63306/g" /home/bespin/petclinic_btc/pom.xml
                    warn: false
          - name: build web app
            command:
                    cmd: ./mvnw tomcat7:deploy
                    chdir: /home/bespin/petclinic_btc/
            ignore_errors: yes
            notify: restart_tomcat
          - name: mysql web app
            command:
                    cmd: ./mvnw tomcat7:redeploy -P MySQL
                    chdir: /home/bespin/petclinic_btc/
            ignore_errors: yes
            notify: restart_tomcat
  handlers:
          - name: restart_tomcat
            service:
                    name: tomcat
                    state: restarted
                    enabled: yes
