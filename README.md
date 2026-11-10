# mission1 - 개발자용 작업실 꾸미기 (터미널 · Docker · Git)

## 1) 프로젝트 개요
- 목표: 터미널(CLI), Docker, Git/GitHub로 개발 작업 환경을 직접 구성하고, 실행 결과(로그/접속/데이터 유지)로 검증한다.
- 범위: 터미널 기본 조작·권한 → Docker 설치·점검·운영 → Dockerfile 커스텀 이미지 → 포트 매핑 → 바인드 마운트·볼륨 → Git 설정.
- 원칙: 모든 출력은 실제 실행 결과를 `logs/` 아래 파일로 저장하고, 이 문서에는 핵심 발췌와 링크를 둔다.

## 2) 실행 환경
| 항목 | 내용 |
|---|---|
| OS | Windows 11 Pro (10.0.26200) |
| 터미널/쉘 | Git Bash(MSYS2 UCRT64), PowerShell. 리눅스 명령 실습은 `ubuntu` 컨테이너의 bash |
| Docker | Docker Desktop 4.98.0 / Docker Engine 29.9.2 (WSL2 백엔드) |
| Git | git version 2.56.0.windows.2 |
| 기타 | WSL2 + Ubuntu 설치됨 |

- 근거: [logs/01_docker_check.txt](logs/01_docker_check.txt), [logs/07_git_config.txt](logs/07_git_config.txt)

## 3) 수행 체크리스트
- [x] 터미널 기본 조작 (위치/목록/이동/생성/복사/이름변경/삭제/내용확인/빈 파일)
- [x] 권한 변경 실습 (파일 1개, 디렉토리 1개, 변경 전/후)
- [x] Docker 설치·점검 (`docker --version`, `docker info`)
- [x] Docker 기본 운영 (`images`, `pull`, `ps`, `ps -a`, `logs`, `stats`, `stop`, `rm`)
- [x] `hello-world` 실행
- [x] `ubuntu` 컨테이너 실행 + 내부 명령(`ls`, `echo`)
- [x] Dockerfile 커스텀 이미지 빌드·실행
- [x] 포트 매핑 접속 (8080, 8081 두 컨테이너, `curl` 응답)
- [x] 바인드 마운트 반영
- [x] Docker 볼륨 영속성
- [x] Git 사용자 정보·기본 브랜치 설정 및 `git config --list` 기록
- [ ] **미수행**: VSCode에서 GitHub 로그인·저장소 연동 증거(스크린샷)
- [ ] **미수행**: 브라우저 접속 화면(주소창 포함) 스크린샷 → `curl` 응답으로 대체함
- [ ] **미수행**: `docker attach` 직접 관찰 (아래 6) 참고)

## 4) 검증 방법과 결과 위치
| 확인 항목 | 사용한 명령 | 확인한 내용 | 결과 위치 |
|---|---|---|---|
| Docker 설치 | `docker --version` | 버전 출력 | [01](logs/01_docker_check.txt) |
| 데몬 동작 | `docker info`, `docker version` | Server 정보(Engine 29.9.2) 출력 | [01](logs/01_docker_check.txt) |
| 이미지/컨테이너 운영 | `docker images`, `pull`, `ps`, `ps -a`, `logs`, `stats`, `stop`, `rm` | 상태 변화(Up → Exited) 확인 | [02](logs/02_docker_ops.txt) |
| 컨테이너 실습 | `docker run hello-world`, `docker run ubuntu ...`, `docker exec` | 정상 출력, 종료/유지 차이 | [03](logs/03_containers.txt) |
| 터미널·권한 | `pwd`, `ls -la`, `mkdir`, `cp`, `mv`, `rm`, `chmod`, `ls -l` | 변경 전/후, `Permission denied` | [04](logs/04_terminal_permission.txt) |
| 커스텀 이미지·포트 | `docker build`, `docker run -p`, `curl` | HTTP 200, 응답 본문 | [05](logs/05_dockerfile_portmap.txt) |
| 바인드 마운트·볼륨 | `docker run -v`, `docker volume`, `docker exec` | 수정 반영, 삭제 후 데이터 유지 | [06](logs/06_mount_volume.txt) |
| Git 설정 | `git config --list` | 이름·기본 브랜치 설정 | [07](logs/07_git_config.txt) |

> 참고: 로그 파일의 `$ ...` 명령 줄은 따옴표가 생략되어 표시된다. 실제 실행한 명령은 아래 5)의 코드블록이 정확한 형태이다.

## 5) 수행 로그 (발췌)

### 5-1. Docker 점검
```bash
$ docker --version
Docker version 29.9.2, build a82e528
```
`docker info`에서 `Server Version: 29.9.2`가 출력되어 데몬이 동작함을 확인했다. (전체: [01](logs/01_docker_check.txt))

### 5-2. Docker 기본 운영
```bash
$ docker run -d --name ops-nginx nginx:alpine
$ docker ps
CONTAINER ID   IMAGE          COMMAND                   CREATED                  STATUS                  PORTS     NAMES
69cefa817dab   nginx:alpine   "/docker-entrypoint.…"   Less than a second ago   Up Less than a second   80/tcp    ops-nginx

$ docker stats --no-stream
CONTAINER ID   NAME        CPU %     MEM USAGE / LIMIT    MEM %     NET I/O        BLOCK I/O     PIDS
69cefa817dab   ops-nginx   0.00%     19.7MiB / 15.41GiB   0.12%     1.7kB / 126B   0B / 8.19kB   23

$ docker stop ops-nginx
$ docker ps -a
... Exited (0) Less than a second ago ... ops-nginx
```
- `docker ps`는 실행 중인 컨테이너만, `docker ps -a`는 종료된 컨테이너까지 보여준다.

### 5-3. 컨테이너 실습 (hello-world, ubuntu)
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

### 5-4. 터미널 조작·권한 (비root 사용자 `nobody`, ubuntu 컨테이너)
```bash
$ pwd
/tmp/practice_work
$ mkdir practice && cd practice && pwd
/tmp/practice_work/practice
$ ls -la
-rw-r--r-- 1 nobody nogroup   12 Nov 10 12:40 note.txt

# 파일 권한 변경 (변경 전/후)
$ ls -l note.txt
-rw-r--r-- 1 nobody nogroup 12 Nov 10 12:40 note.txt
$ chmod 755 note.txt && ls -l note.txt
-rwxr-xr-x 1 nobody nogroup 12 Nov 10 12:40 note.txt
$ chmod 600 note.txt && ls -l note.txt
-rw------- 1 nobody nogroup 12 Nov 10 12:40 note.txt
$ chmod u-w note.txt && ls -l note.txt
-r-------- 1 nobody nogroup 12 Nov 10 12:40 note.txt
$ echo test >> note.txt
note.txt: Permission denied

# 디렉토리 권한 변경 (변경 전/후)
$ ls -ld a
drwxr-xr-x 3 nobody nogroup 4096 Nov 10 12:40 a
$ chmod 000 a && ls -ld a
d--------- 3 nobody nogroup 4096 Nov 10 12:40 a
$ ls a
ls: cannot open directory 'a': Permission denied
$ chmod 755 a && ls a
b
```
복사·이동·삭제·내용 확인(`cp`, `mv`, `rm`, `rmdir`, `cat`)과 빈 파일 생성(`touch`) 전체 로그는 [04](logs/04_terminal_permission.txt)에 있다.

### 5-5. Dockerfile 커스텀 이미지 + 포트 매핑
```bash
$ docker build -t mission1-web:1.0 .
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
```
포트 매핑 없이 실행한 컨테이너는 호스트에서 접속되지 않았다. (비교 실험, [05](logs/05_dockerfile_portmap.txt))
```bash
$ docker run -d --name web-nomap mission1-web:1.0
$ curl -s -m 3 -o /dev/null -w "HTTP %{http_code}\n" http://localhost:80
HTTP 000
```

### 5-6. 바인드 마운트
```bash
$ docker run -d --name bind-test -p 8090:80 -v "C:\Users\user\Desktop\mission1\bind-demo:/usr/share/nginx/html:ro" nginx:alpine
$ curl -s http://localhost:8090
<h1>bind mount BEFORE</h1>

# 호스트에서 bind-demo/index.html 수정 (컨테이너 재시작 없음)
$ curl -s http://localhost:8090
<h1>bind mount AFTER (edited on host)</h1>
```

### 5-7. Docker 볼륨 영속성
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
```
볼륨 없이 쓴 파일은 컨테이너와 함께 사라졌다.
```bash
$ docker run --rm ubuntu bash -c "ls /tmp/temp.txt"
ls: cannot access '/tmp/temp.txt': No such file or directory
```

### 5-8. Git 설정
```bash
$ git config --global init.defaultBranch main
$ git config --list      # user.email 값은 마스킹
user.name=Ted
user.email=***masked***
init.defaultbranch=main
```
- 시스템 설정에 `init.defaultbranch=master`가 먼저 있었고, 사용자 설정(`main`)이 나중에 적용되어 `main`이 기본 브랜치가 된다. (전체: [07](logs/07_git_config.txt))

## 6) 컨테이너 종료/유지 관찰
| 실행 방식 | 결과 | 이유 |
|---|---|---|
| `docker run ubuntu bash -c "ls / && echo ..."` | 명령이 끝나자 컨테이너가 `Exited (0)` | 컨테이너는 **메인 프로세스(PID 1)가 끝나면 종료**됨 |
| `docker run -d ubuntu sleep infinity` | 계속 `Up` | 메인 프로세스(`sleep infinity`)가 계속 실행 중 |
| `docker exec <컨테이너> <명령>` | `exec`가 끝나도 컨테이너는 유지 | 실행 중인 컨테이너 안에 **새 프로세스**를 추가로 실행하는 것이라 메인 프로세스와 무관 |
- `docker attach`(메인 프로세스의 입출력에 직접 연결)는 대화형 터미널이 필요해 이번 자동 실행에서는 관찰하지 못했다. 위 체크리스트에 미수행으로 표시했다.

## 7) Dockerfile 커스텀 설명 (방식 A: 웹 서버 베이스 이미지 활용)
- 선택한 기존 베이스: 공식 `nginx:alpine`
- 커스텀 포인트와 목적

  | 지시어 | 목적 |
  |---|---|
  | `LABEL` | 이미지가 무엇인지 메타데이터로 남김 |
  | `ENV APP_ENV=dev` | 설정 값을 코드와 분리 (`docker inspect`에서 `APP_ENV=dev` 확인) |
  | `COPY site/ /usr/share/nginx/html/` | 기본 nginx 페이지를 내가 만든 정적 콘텐츠로 교체 |
  | `HEALTHCHECK` | 컨테이너가 응답하는지 점검 (`health: starting` → `healthy` 확인) |
- 빌드/실행 결과: 5-5 참고, [05](logs/05_dockerfile_portmap.txt)

## 8) 핵심 개념 정리
- **절대 경로 vs 상대 경로**: 절대 경로는 루트(`/`)부터 전체를 적음(`/tmp/practice_work/practice/note.txt`). 상대 경로는 현재 위치 기준(`./note.txt`).
- **권한 r/w/x와 755·644**: r=4, w=2, x=1을 더한 값을 소유자·그룹·기타 순서로 적는다. `755`=`rwxr-xr-x`, `644`=`rw-r--r--`. 디렉토리는 `x`가 없으면 안으로 들어갈 수 없다(`chmod 000` 후 `ls` 거부로 확인).
- **포트 매핑이 필요한 이유**: 컨테이너는 격리된 네트워크라 호스트에서 바로 접속할 수 없다. `-p 호스트:컨테이너`로 연결해야 하며, 매핑이 없으면 접속이 안 됨을 5-5에서 확인했다. 같은 이미지를 호스트 포트만 바꿔 여러 개 실행할 수 있다.
- **바인드 마운트 vs 볼륨**: 바인드 마운트는 호스트의 특정 폴더를 컨테이너에 연결(호스트에서 수정하면 즉시 반영). 볼륨은 Docker가 관리하는 저장소로, 컨테이너를 삭제해도 데이터가 유지된다.
- **Git vs GitHub**: Git은 내 컴퓨터에서 변경 이력을 관리하는 도구(로컬 버전 관리), GitHub는 그 저장소를 올려 공유·협업하는 원격 플랫폼이다.

## 9) 트러블슈팅
1. **`docker` 명령이 인식되지 않음**
   - 문제: PowerShell에서 `docker info` 실행 시 "'docker' 용어가 cmdlet, 함수, 스크립트 파일 또는 실행할 수 있는 프로그램 이름으로 인식되지 않습니다".
   - 원인 가설: Docker가 설치되지 않았거나 PATH에 없음.
   - 확인: `C:\Program Files\Docker` 폴더와 Docker 프로세스가 없었다. 설치 후 Docker Desktop 실행 시 "WSL not installed" 오류가 표시됨.
   - 해결: 관리자 PowerShell에서 `wsl --install` 후 재부팅, Docker Desktop 재실행. 이후 `docker --version`과 `docker info`가 정상 출력됨.
2. **권한 실습용 비root 계정**
   - 문제: 권한 실험에는 root가 아닌 일반 사용자가 필요한데, WSL의 `nobody` 계정으로 직접 로그인하면 "This account is currently not available" 오류가 남.
   - 원인 가설: `nobody`는 로그인 쉘이 없는 시스템 계정이라 로그인 세션을 만들 수 없음.
   - 확인: `wsl -d Ubuntu -u nobody -- bash ...` 실행 시 위 메시지 확인.
   - 대안: 컨테이너 안에서 `docker run --user nobody ubuntu bash ...`로 실행(로그인 쉘 없이 bash만 실행). 이후 `whoami`가 `nobody`로 출력되고 `Permission denied`가 정상 재현됨.
3. **로그 스크립트에서 명령이 빈 줄로 출력됨**
   - 문제: 여러 명령을 한 스크립트로 실행했더니 로그에 `$ ` 만 찍히고 출력이 비어 있었다.
   - 원인 가설: 쉘(Git Bash)에서 `wsl -- bash -c "..."`로 긴 스크립트를 넘길 때 따옴표·특수문자가 전달 중 깨짐.
   - 확인: 스크립트를 파일로 저장해 `bash 파일경로`로 실행하니 정상 출력됨.
   - 해결: 긴 명령은 인라인 인자 대신 스크립트 파일로 전달.

## 10) 파일 구조
```
mission1/
├─ README.md            # 이 문서
├─ Dockerfile           # 커스텀 nginx 이미지
├─ site/index.html      # 이미지에 복사되는 정적 페이지
├─ bind-demo/index.html # 바인드 마운트 실습용 파일
├─ docker_log.txt       # 초기 hello-world 실행 기록
├─ test.txt             # 초기 테스트용 빈 파일
└─ logs/
   ├─ 01_docker_check.txt
   ├─ 02_docker_ops.txt
   ├─ 03_containers.txt
   ├─ 04_terminal_permission.txt
   ├─ 05_dockerfile_portmap.txt
   ├─ 06_mount_volume.txt
   └─ 07_git_config.txt
```

## 11) 재현 방법
```bash
git clone https://github.com/cmc33sh-ux/mission1.git
cd mission1
docker build -t mission1-web:1.0 .
docker run -d -p 8080:80 --name web-8080 mission1-web:1.0
curl http://localhost:8080
```
- 경로가 Windows 사용자 폴더에 종속된 부분은 바인드 마운트 예시(`C:\Users\user\Desktop\mission1\bind-demo`)이다. 다른 PC에서는 본인의 `bind-demo` 절대 경로로 바꿔 실행한다.

## 12) 보안·개인정보
- `git config --list`의 이메일은 마스킹했다.
- 로그에는 토큰, 비밀번호, 개인키를 포함하지 않았다.
