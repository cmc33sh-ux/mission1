# mission1 - 개발자용 작업실 꾸미기

## 1) 프로젝트 개요
- 목표: 터미널(CLI), Docker, Git/GitHub로 개발 작업 환경을 직접 구성하고, 실행 결과(로그/접속/데이터 유지)로 검증한다.
- 모든 출력은 실제 실행 결과이며 `logs/` 아래에 파일로 저장했다. 이 문서에는 핵심 발췌와 링크를 둔다.

## 2) 실행 환경
| 항목 | 내용 |
|---|---|
| OS | Windows 11 Pro (10.0.26200) |
| 터미널/쉘 | Git Bash, PowerShell / 리눅스 명령 실습: WSL2 Ubuntu의 bash |
| Docker | Docker Desktop 4.98.0 / Docker Engine 29.9.2 |
| Git | git version 2.56.0.windows.2 |

## 3) 수행 항목 체크리스트
- [x] 터미널: 작업 폴더 구성, 위치/목록/이동/생성/복사/이름변경/삭제/내용확인/빈 파일
- [x] 권한: 파일 1개, 디렉토리 1개 변경 전/후
- [x] Docker: 설치·점검, 기본 운영 명령, `hello-world`, `ubuntu` 컨테이너
- [x] Dockerfile: 커스텀 이미지 빌드·실행
- [x] 포트: 포트 매핑 접속 (8080, 8081)
- [x] 마운트: 바인드 마운트 반영
- [x] 볼륨: Docker 볼륨 영속성
- [x] Git: 사용자 정보·기본 브랜치 설정, `git config --list`
- [x] GitHub: 저장소 `clone`, `commit`, `push`
- [ ] **미수행**: VSCode에서 GitHub 로그인·저장소 연동 증거(스크린샷)
- [ ] **미수행**: 브라우저 접속 화면(주소창 포함) 스크린샷 → `curl` 응답으로 대체
- [ ] **미수행**: `docker attach` 직접 관찰

## 4) 항목별 수행 내용과 검증

### 4-1. 터미널 (작업 폴더 구성 · 기본 조작)
검증: 폴더 생성과 파일 조작 결과를 `ls`, `cat`으로 확인. 로그: [00](logs/00_workspace_setup.txt), [04](logs/04_terminal_permission.txt)
```bash
# 작업 폴더 구성
$ cd /c/Users/user/Desktop
$ git clone https://github.com/cmc33sh-ux/mission1.git
$ cd mission1
$ pwd
/c/Users/user/Desktop/mission1
$ mkdir -p logs site bind-demo

# 리눅스 터미널(WSL2 Ubuntu): 현재 위치 / 목록(숨김 포함)
$ pwd
/root
$ ls -la
drwx------  4 root root 4096 Nov 10 21:39 .
-rw-r--r--  1 root root 3106 Apr 20  2026 .bashrc
...

# 생성 / 이동
$ mkdir -p ~/practice
$ cd ~/practice && pwd
/root/practice
$ cd .. && pwd
/root

# 파일 생성 / 내용 확인
$ touch empty.txt && ls -l empty.txt
-rw-r--r-- 1 root root 0 Nov 10 21:54 empty.txt
$ echo 'hello linux' > note.txt && cat note.txt
hello linux

# 복사 / 이동·이름 변경 / 삭제
$ cp note.txt copy.txt && ls
copy.txt
empty.txt
note.txt
$ mv copy.txt renamed.txt && ls
empty.txt
note.txt
renamed.txt
$ mkdir docs && mv renamed.txt docs/ && ls -R
$ rm docs/renamed.txt && ls -R
$ rmdir docs && ls
empty.txt
note.txt
```

### 4-2. 권한 (변경 전/후)
검증: `chmod` 전후에 `ls -l`, `ls -ld`로 비교. 로그: [04](logs/04_terminal_permission.txt)
```bash
# 파일
$ ls -l note.txt
-rw-r--r-- 1 root root 12 Nov 10 21:54 note.txt
$ chmod 755 note.txt && ls -l note.txt
-rwxr-xr-x 1 root root 12 Nov 10 21:54 note.txt
$ chmod 644 note.txt && ls -l note.txt
-rw-r--r-- 1 root root 12 Nov 10 21:54 note.txt
$ chmod 600 note.txt && ls -l note.txt
-rw------- 1 root root 12 Nov 10 21:54 note.txt

# 디렉토리
$ ls -ld a
drwxr-xr-x 3 root root 4096 Nov 10 21:54 a
$ chmod 700 a && ls -ld a
drwx------ 3 root root 4096 Nov 10 21:54 a
$ chmod 755 a && ls -ld a
drwxr-xr-x 3 root root 4096 Nov 10 21:54 a
```

### 4-3. Docker 설치·점검·기본 운영
검증: 버전, 데몬(`docker info`), 운영 명령 결과 확인. 로그: [01](logs/01_docker_check.txt), [02](logs/02_docker_ops.txt)
```bash
$ docker --version
Docker version 29.9.2, build a82e528
$ docker info          # Server Version: 29.9.2 출력으로 데몬 동작 확인

$ docker pull nginx:alpine
$ docker images
IMAGE          ID             DISK USAGE   CONTENT SIZE   EXTRA
nginx:alpine   713fc2ebfd92       94.5MB         27.3MB

$ docker run -d --name ops-nginx nginx:alpine
$ docker ps
CONTAINER ID   IMAGE          COMMAND                   CREATED                  STATUS                  PORTS     NAMES
69cefa817dab   nginx:alpine   "/docker-entrypoint.…"   Less than a second ago   Up Less than a second   80/tcp    ops-nginx

$ docker logs ops-nginx          # nginx 시작 로그 출력
$ docker stats --no-stream
CONTAINER ID   NAME        CPU %     MEM USAGE / LIMIT    MEM %     NET I/O        BLOCK I/O     PIDS
69cefa817dab   ops-nginx   0.00%     19.7MiB / 15.41GiB   0.12%     1.7kB / 126B   0B / 8.19kB   23

$ docker stop ops-nginx
$ docker ps -a
... Exited (0) Less than a second ago ... ops-nginx
$ docker rm ops-nginx
```
- `docker ps`는 실행 중인 컨테이너만, `docker ps -a`는 종료된 컨테이너까지 보여준다.

### 4-4. 컨테이너 실습 (hello-world, ubuntu)
검증: 정상 메시지, 내부 명령 결과, 종료/유지 차이. 로그: [03](logs/03_containers.txt)
```bash
$ docker run --rm hello-world
Hello from Docker!
This message shows that your installation appears to be working correctly.

$ docker run --name ubuntu-once ubuntu bash -c "ls / && echo hello-from-ubuntu"
(루트 디렉토리 목록: bin, boot, dev, etc, home, lib, ... var)
hello-from-ubuntu

$ docker run -d --name ubuntu-keep ubuntu sleep infinity
$ docker exec ubuntu-keep ls /
$ docker exec ubuntu-keep echo hello-exec
```
| 실행 방식 | 결과 | 이유 |
|---|---|---|
| `docker run ubuntu bash -c "ls / && echo ..."` | 명령이 끝나자 `Exited (0)` | 컨테이너는 메인 프로세스가 끝나면 종료됨 |
| `docker run -d ubuntu sleep infinity` | 계속 `Up` | 메인 프로세스가 계속 실행 중 |
| `docker exec <컨테이너> <명령>` | `exec`가 끝나도 컨테이너 유지 | 실행 중인 컨테이너 안에 새 프로세스를 추가로 실행하는 것 |

### 4-5. Dockerfile 커스텀 이미지
- 선택한 기존 베이스: 공식 `nginx:alpine` (웹 서버 베이스 이미지 활용 + 정적 콘텐츠 교체)

| 지시어 | 목적 |
|---|---|
| `LABEL` | 이미지 메타데이터(이름, 설명) 기록 |
| `ENV APP_ENV=dev` | 설정 값을 코드와 분리 (`docker inspect`에서 `APP_ENV=dev` 확인) |
| `COPY site/ /usr/share/nginx/html/` | 기본 nginx 페이지를 직접 만든 페이지로 교체 |
| `HEALTHCHECK` | 컨테이너 응답 점검 (`health: starting` → `healthy`) |

검증: 빌드 성공, 컨테이너 실행 성공. 로그: [05](logs/05_dockerfile_portmap.txt)
```bash
$ docker build -t mission1-web:1.0 .
$ docker images mission1-web
IMAGE              ID             DISK USAGE   CONTENT SIZE   EXTRA
mission1-web:1.0   ece525cf8c8e       93.7MB         26.4MB
```

### 4-6. 포트 매핑
검증: `-p 호스트:컨테이너`로 접속되고, 매핑이 없으면 접속되지 않음. 로그: [05](logs/05_dockerfile_portmap.txt)
```bash
$ docker run -d -p 8080:80 --name web-8080 mission1-web:1.0
$ docker run -d -p 8081:80 --name web-8081 mission1-web:1.0
$ docker ps
... Up 3 seconds (health: starting)   0.0.0.0:8081->80/tcp, [::]:8081->80/tcp   web-8081
... Up 4 seconds (health: starting)   0.0.0.0:8080->80/tcp, [::]:8080->80/tcp   web-8080

$ curl -s http://localhost:8080
<h1>Hello from mission1-web</h1>
<p>version: 1.0 / served by nginx on Docker</p>
$ curl -s -o /dev/null -w "HTTP %{http_code}\n" http://localhost:8080
HTTP 200

# 포트 매핑 없이 실행하면 호스트에서 접속 불가
$ docker run -d --name web-nomap mission1-web:1.0
$ curl -s -m 3 -o /dev/null -w "HTTP %{http_code}\n" http://localhost:80
HTTP 000
```

### 4-7. 바인드 마운트
검증: 호스트에서 파일을 수정하면 컨테이너 재시작 없이 응답이 바뀜. 로그: [06](logs/06_mount_volume.txt)
```bash
$ docker run -d --name bind-test -p 8090:80 -v "C:\Users\user\Desktop\mission1\bind-demo:/usr/share/nginx/html:ro" nginx:alpine
$ curl -s http://localhost:8090
<h1>bind mount BEFORE</h1>

# 호스트에서 bind-demo/index.html 수정
$ curl -s http://localhost:8090
<h1>bind mount AFTER (edited on host)</h1>
```

### 4-8. Docker 볼륨 영속성
검증: 컨테이너를 삭제한 뒤 새 컨테이너에 같은 볼륨을 연결해 데이터 확인. 로그: [06](logs/06_mount_volume.txt)
```bash
$ docker volume create mydata
$ docker run -d --name vol-test -v mydata:/data ubuntu sleep infinity
$ docker exec vol-test bash -c "echo 'hi from volume' > /data/hello.txt && cat /data/hello.txt"
hi from volume

$ docker rm -f vol-test          # 컨테이너 삭제
$ docker volume ls               # 볼륨은 남아 있음
local     mydata

$ docker run -d --name vol-test2 -v mydata:/data ubuntu sleep infinity
$ docker exec vol-test2 cat /data/hello.txt
hi from volume                   # 삭제 전과 같은 데이터

# 볼륨 없이 쓴 파일은 컨테이너와 함께 사라짐
$ docker run --rm ubuntu bash -c "ls /tmp/temp.txt"
ls: cannot access '/tmp/temp.txt': No such file or directory
```

### 4-9. Git 설정
검증: `git config --list`에서 사용자 정보·기본 브랜치 확인(이메일은 마스킹). 로그: [07](logs/07_git_config.txt)
```bash
$ git config --global init.defaultBranch main
$ git config --list
user.name=Ted
user.email=***masked***
init.defaultbranch=main
```
- 시스템 설정에 `init.defaultbranch=master`가 먼저 있었고, 사용자 설정(`main`)이 나중에 적용되어 `main`이 기본 브랜치가 된다.

### 4-10. GitHub
검증: 저장소를 `clone`하고 변경을 `commit`·`push`해 GitHub에서 확인.
```bash
$ git clone https://github.com/cmc33sh-ux/mission1.git
$ git remote -v
origin	https://github.com/cmc33sh-ux/mission1.git (fetch)
origin	https://github.com/cmc33sh-ux/mission1.git (push)
$ git push origin main
```
- VSCode에서의 GitHub 로그인·연동 증거는 위 체크리스트에 미수행으로 표시했다.

## 5) 트러블슈팅
1. **`docker` 명령이 인식되지 않음**
   - 문제: PowerShell에서 `docker info` 실행 시 "'docker' 용어가 cmdlet, 함수, 스크립트 파일 또는 실행할 수 있는 프로그램 이름으로 인식되지 않습니다".
   - 원인 가설: Docker가 설치되지 않았거나 PATH에 없음.
   - 확인: `C:\Program Files\Docker` 폴더와 Docker 프로세스가 없었다.
   - 해결: Docker Desktop을 설치하고, 열려 있던 터미널을 닫고 새로 열어 다시 실행.
2. **Docker Desktop 실행 시 "WSL not installed" 오류**
   - 문제: 설치 후 재부팅까지 했는데도 Docker Desktop이 "WSL not installed" 오류를 표시함.
   - 원인 가설: Docker Desktop은 WSL2 위에서 동작하는데 WSL 자체가 설치되지 않음.
   - 확인: 오류 창의 안내 문구(`wsl --install`을 관리자 PowerShell에서 실행 후 재부팅)와 `wsl --list --verbose`로 설치 상태 확인.
   - 해결: 관리자 PowerShell에서 `wsl --install` 실행 후 재부팅, Docker Desktop 재실행. 이후 `docker --version`과 `docker info`가 정상 출력됨.
3. **터미널이 작업 폴더가 아닌 다른 폴더에서 시작됨**
   - 문제: 새 터미널을 열면 `mission1`이 아닌 다른 폴더에서 시작되어 `git` 작업이 엉뚱한 위치에 적용될 수 있었음.
   - 원인 가설: 터미널의 시작 위치가 작업 폴더로 고정되어 있음.
   - 확인: `pwd`로 현재 위치를 확인.
   - 해결: 작업 전에 `cd`로 `mission1`로 이동하고 `pwd`로 확인한 뒤 작업.
