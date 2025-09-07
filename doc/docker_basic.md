## docker 초기셋팅

#### before docker install ( in ubuntu )
``` shell
sudo apt-get install -y ca-certificates curl  software-properties-common  apt-transport-https  gnupg   lsb-release
 
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  
echo \
	"deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
	$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  
sudo apt-get update
```

#### install docker
``` shell
sudo apt-get install docker-ce docker-ce-cli containerd.io

docker --version
```

#### setting docker compose ##
``` shell
#버전확인
docker-compose -v
Docker Compose version [설치된 버전]

#기존 설치 삭제
sudo apt remove docker-compose -y

#jq library 설치
sudo apt install jq -y

#최신 버전 설치
VERSION=$(curl --silent https://api.github.com/repos/docker/compose/releases/latest | jq .name -r) ;\
	DESTINATION=/usr/bin/docker-compose ;\
	sudo curl -L https://github.com/docker/compose/releases/download/${VERSION}/docker-compose-$(uname -s)-$(uname -m) -o $DESTINATION ;\
	sudo chmod 755 $DESTINATION

#설치 버전 확인
docker-compose -v
Docker Compose version [최신버전]
```
  
#### 사용자 권한 추가 (중요!!)
``` shell
#사용자 추가
adduser atensys
#ql
passwd atensys


sudo usermod -aG docker {사용자명}

#재로그 해야 적용됨   
logout

#su 권한 부여
#root 로 로그인후
vi /etc/sudoers

	root    ALL=(ALL)     ALL
	#아래 추가
    atensys ALL=(ALL)     ALL
```  
#### portainer 
``` shell
mkdir -p /data/portainer

docker run -d -p 9000:9000 \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v /data/portainer:/data \
	--restart=always \
	--name=portainer \
	portainer/portainer

```
#### portainer 2 : 주로 사용
``` shell
docker volume create --name portainer_data

docker run -d -p 9000:9000 \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v portainer_data:/data \
	--restart=always \
	--name=portainer \
	portainer/portainer
```

#### ctop
``` shell
docker run --rm -ti \
	-v /var/run/docker.sock:/var/run/docker.sock \
	--name=ctop \
	quay.io/vektorlab/ctop:latest

```
#### glances 
``` shell
docker run --rm -ti \
	-v /var/run/docker.sock:/var/run/docker.sock:ro \
	--pid host \
	--network host \
	--name=aten_glances \
	nicolargo/glances

```
#### mosquitto
``` shell
docker run -d -p 1883:1883 -p 9001:9001 \
	-v ~/mosquitto/conf/mosquitto.conf:/mosquitto/config/mosquitto.conf \
	-v /mosquitto/data \
	-v /mosquitto/log \
	--restart=always \
	--name=mosquitto \
	kyberpunk/mosquitto
```
#### adminer
``` shell
docker run -d -p 88:8080 \
	-e ADMINER_DESIGN='dracula' \
	--restart=always \
	--name adminer \
	adminer
```
- 디자인 https://github.com/vrana/adminer/tree/master/designs

#### nginx 
```shell
docker run -d -p 80:80 \
	-v /home/web/html:/usr/share/nginx/html:ro \
	-e TZ=Asia/Seoul \
	--restart=always \
	--name aten_nginx \
	nginx:latest
```

#### owncloud 
- 20230325 owncloud/server 최신버전(10.11) 안됨
```shell
docker run -d -p 8080:8080 \
-v /home/staff/owncloud:/var/www/html \
-v /mnt/data:/mnt/data/files/admin/files \
-e OWNCLOUD_TRUSTED_DOMAINS=192.168.0.xxx,localhost \
-e OWNCLOUD_DOMAIN=localhost:8080 \
-e OWNCLOUD_ADMIN_USERNAME=admin \
-e OWNCLOUD_ADMIN_PASSWORD=12345 \
-e TZ=Asia/Seoul \
--restart=always \
--name owncloud \
owncloud/server:10.8
```
- owncloud 에 외부 저장소 추가
```shell
#config.php에
'files_external_allow_create_new_local' => 'true',
```

#### registry-web
```shell
docker run -it -p 8088:8080 --name registry-web \
-e REGISTRY_URL=http://192.168.0.75:5000/v2 \
-e REGISTRY_TRUST_ANY_SSL=true \
hyper/docker-registry-web

docker run --name registry-browser -p 8088:8080 
-e REGISTRY_URL=http://192.168.0.75:5000/v2 klausmeyer/docker-registry-browser

docker run \
  -d \
  -e ENV_DOCKER_REGISTRY_HOST=192.168.0.75 \
  -e ENV_DOCKER_REGISTRY_PORT=5000 \
  -e ENV_MODE_BROWSE_ONLY=true \
  -e REGISTRY_STORAGE_DELETE_ENABLED=true \
  -p 8088:80 \
  konradkleine/docker-registry-frontend:v2
```

#### dotnet
```shell
docker run -d -p 8000:80 \
	-v /home/web/dotnet:/app \
	-e TZ=Asia/Seoul \
	--restart=always \
	--name aspnetcore_sample \
	mcr.microsoft.com/dotnet/samples:aspnetapp
```
- 호스트 경로 공유 방법 모르겠음 20230414

#### gitlab/gitlab-ce 
- 20230425 너무 느려서 못쓰겠음
```shell
export GITLAB_HOME=/srv/gitlab

docker run -d \
--publish 443:443 --publish 80:80 --publish 23:22 \
--volume $GITLAB_HOME/config:/etc/gitlab \
--volume $GITLAB_HOME/logs:/var/log/gitlab \
--volume $GITLAB_HOME/data:/var/opt/gitlab \
--shm-size 256m \
--restart=always \
--name gitlab \
gitlab/gitlab-ce:latest
```

#### gitlab
```shell
docker pull gitlab/gitlab-ce

docker run --detach \
--name gitlab \
--hostname gitlab.example.com \
--publish 4000:80 \
--restart always \
--volume ./gitlab/config:/etc/gitlab \
--volume ./gitlab/logs:/var/log/gitlab \
--volume ./gitlab/data:/var/opt/gitlab \
gitlab/gitlab-ce
```
- cmd_docker_gitlab.txt 상세 ##

#### jupyter
```shell
docker pull jupyter/minimal-notebook

docker run -d -p 8888:8888 \
	-v "${PWD}":/home/jovyan/work \
	-e TZ=Asia/Seoul \
	-e GRANT_SUDO=yes \
	--user root \
	--restart=always \
	--name jupyter-notebook \
	jupyter/minimal-notebook

jupyter server list

```
- ex) docker console
	- Currently running servers:
	- http://ee13a4c57eec:8888/?token=6d1ae138a895417c3a437558b670499a71d773ebc3fb979e :: /home/jovyan
		- token 	: 6d1ae138a895417c3a437558b670499a71d773ebc3fb979e
		- new pwd 	: 26766498

- svn checkout 시 선행작업
```shell
chown jovyan work/ 
svn checkout http://ip:port/scm/repo/ohyt/svnGasanJupyter
```
#### node-red
```shell
docker run -d -p 1880:1880 \
	-v ~/node_red/data:/data \
	-e TZ=Asia/Seoul \
	--restart=always \
	--name node_red \
	nodered/node-red
```
- 실행안될때
```shell
node:internal/fs/utils:347
    throw err;
    ^
Error: EACCES: permission denied, copyfile '/usr/src/node-red/node_modules/node-red/settings.js' -> '/data/settings.js'
    at Object.copyFileSync (node:fs:2847:3)
    at copyFile (/usr/src/node-red/node_modules/fs-extra/lib/copy/copy-sync.js:73:6)

# 아래 권한 부여
chown -R 1000:1000 ~/node_red

docker restart

#http://10.28.25.16:1880/ 로 확인함
```
#### scm-manager
- 실행시 -d 옵션은 제거함 : 로그에서 토큰 확인해야 함
```shell
docker run -p 8080:8080 \
	-v scm-home:/var/lib/scm \
	--restart=always \
	--name scm-manager \
	scmmanager/scm-manager

#이후는 #cmd_docker_scmmanager.txt 참고
```
#### rabbitmq:management
```shell
docker run -d -p 5672:5672 -p 15672:15672 \
	--hostname aten-rabbit \
	-e RABBITMQ_DEFAULT_USER=aten \
	-e RABBITMQ_DEFAULT_PASS=028623360 \
	--restart=always \
	--name aten_rabbitmq \
	rabbitmq:management

#http://host-ip:15672
```
- RabbitMQ에 대해 주목해야 할 중요한 사항 중 하나는 기본적으로 호스트 이름을 사용하는 "노드 이름"을  기반으로 데이터를 저장한다는 것입니다. Docker에서 사용 시 이것이 의미하는 바는 임의의 호스트 이름을 얻지 않고 데이터를 추적할 수 있도록 각 데몬에 -h/를 명시적으로 지정해야 한다는 것입니다 .--hostname

#### redhat/ubi
```shell
# System has not been booted with systemd as init system (PID 1). Can't operate.
# Failed to connect to bus: Host is down
# >>
# systemctl 사용 권한을 갖기 위해 필요한 부분은 --privileged=true 와 /sbin/init 이다
docker run -d -it \
	-p 122:22 \
	--privileged=true \
	-v "${PWD}":/home/host \
	--name redhat8.6 \
	redhat/ubi8:8.6 \
	/sbin/init

docker exec -it redhat8.6 /bin/bash
```
- 업데이트
```shell
# 동시에 업데이트도 됨
dnf update -y

#ssh : S
dnf install openssh-server

systemctl enable sshd
systemctl start sshd
systemctl status sshd

dnf install vim net-tools 

vi /etc/ssh/sshd_configd_conf
PermitRootLogin yes

systemctl restart sshd

#root 암호 변경 : root / 12345
passwd

#ssh : E

#docker rhel 접속

## redhat8.6 Commit ##
docker commit redhat8.6 redhat8.6:NW_v1

## images tag ##
docker tag redhat8.6:NW_v1 112.221.107.90:7550/redhat8.6:NW_v1

## images push ##
docker push 112.221.107.90:7550/redhat8.6:NW_v1

##푸시한 이미지로 교체

docker run -d -it \
	-p 122:22 \
	--privileged=true \
	-v "${PWD}":/home/host \
	--name redhat8.6 \
	redhat8.6:NW_v1 \
	/sbin/init
```
#### n8n
```shell
docker run -d -p 5678:5678 \
	-v ~/.n8n:/home/node/.n8n \
	--name n8n \
	docker.n8n.io/n8nio/n8n
```

#### openproject : 설치되나 최소 casaos 에선 안됨
- 버전표시! openproject/community:13
``` shell
docker run -d -p 8080:80 \
	-v ~/openproject/pgdata:/var/openproject/pgdata \
	-v ~/openproject/assets:/var/openproject/assets \
	-e SECRET_KEY_BASE=secret \
	-e OPENPROJECT_HTTPS=false \
	-e OPENPROJECT_DEFAULT__LANGUAGE=en \
	--restart=always \
	--name openproject \
	openproject/community:13
```
#### grafana
```shell
docker run -d -p 3000:3000 \
	--restart=always \
	--name grafana \
	grafana/grafana
```

## redmine
```shell
#sqlite3
#docker run -d --name some-redmine redmine
docker run -d -p 3000:3000 \
	-v ~/redmine/files:/usr/src/redmine/files \
	--restart=always \
	--name redmine \
	redmine

#postgres : 테스트전
docker run -d -p 3000:3000 \
	-v ~/redmine/files:/usr/src/redmine/files \
	-e REDMINE_DB_POSTGRES=192.168.0.131 \
	-e REDMINE_DB_PORT=5432 \
	-e REDMINE_DB_DATABASE=redmine \
	-e REDMINE_DB_USERNAME=postgres \
	-e REDMINE_DB_PASSWORD=028623360 \
	--restart=always \
	--name redmine \
	redmine

```
- sqlite3 백업 : container내 /usr/src/redmine/sqlite
- /my/own/datadir:/usr/src/redmine/files
- 3000 포트추가후 > 192.168.0.131:3000 > admin/admin  > 패스워드 변경 028623360



# docker run 옵션 
- ex) docker run -d -it -p 80:80 --restart always

	-i, --interactive
		표준 입력(stdin)을 활성화하며, 컨테이너와 연결(attach)되어 있지 않더라도 표준 입력을 유지합니다.
		보통 이 옵션을 사용하여 Bash 에 명령을 입력합니다.
	-t, --tty
		TTY 모드(pseudo-TTY)를 사용합니다.
		Bash를 사용하려면 이 옵션을 설정해야 합니다.
		이 옵션을 설정하지 않으면 명령을 입력할 수는 있지만, 셸이 표시되지 않습니다.
	--name
		컨테이너 이름을 설정합니다.
	-d, --detach
		Detached 모드입니다.
		보통 데몬 모드라고 부르며, 컨테이너가 백그라운드로 실행됩니다.
	-p, --publish
		호스트와 컨테이너의 포트를 연결합니다. (포트포워딩)
		<호스트 포트>:<컨테이너 포트>
		-p 80:80
	--privileged
		컨테이너 안에서 호스트의 리눅스 커널 기능(Capability)을 모두 사용합니다.
		호스트의 주요 자원에 접근할 수 있습니다.
	--rm
		프로세스 종료시 컨테이너 자동 제거
	--restart
		컨테이너 종료 시, 재시작 정책을 설정합니다.
		--restart="always"
	-v, --volume
		데이터 볼륨을 설정입니다.
		호스트와 컨테이너의 디렉토리를 연결하여, 파일을 컨테이너에 저장하지 않고 호스트에 바로 저장합니다. (마운트)
	-u, --user
		컨테이너가 실행될 리눅스 사용자 계정 이름 또는 UID를 설정합니다.
		--user root
	-e, --env
		컨테이너 내에서 사용할 환경 변수를 설정합니다.
		보통 설정 값이나 비밀번호를 전달할 때 사용합니다.
		-e GRANT_SUDO=yes
	--link
		컨테이너끼리 연결합니다.
		[컨테이너명 : 별칭]
		--link="db:db"
	-h, --hostname
		컨테이너의 호스트 이름을 설정합니다.
	-w, --workdir
		컨테이너 안의 프로세스가 실행될 디렉터리를 설정합니다.

```shell
#중지된 컨테이너 전부 삭제
docker container prune

#이름 없는 모든 이미지 삭제 : 주로 사용
docker image prune

#사용되고 있지 않은 네트워크 삭제
docker network prune

#컨테이너가 사용하지 않는 도커 볼륨 삭제
docker volume prune

#한꺼번에 전부 정리 : 주로 사용
docker system prune -a 
```