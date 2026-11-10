# mission1 - 개발자용 작업실 꾸미기

## 1) 프로젝트 개요
터미널(CLI), Docker, Git/GitHub로 개발 작업 환경을 직접 구성하고, 터미널에 입력한 명령과 출력 결과로 검증한다. 출력 전체는 `logs/`에 저장했다.

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

## 4) 검증 방법과 결과
| 항목 | 입력한 명령 | 확인 내용 | 로그 |
|---|---|---|---|
| 작업 폴더 구성 | `cd /c/Users/user/Desktop` → `git clone https://github.com/cmc33sh-ux/mission1.git` → `cd mission1` → `mkdir -p logs site bind-demo` → `pwd` | `mission1` 폴더 위치와 하위 폴더 생성 | [00](logs/00_workspace_setup.txt) |
| 터미널 조작 | `pwd`, `ls -la`, `mkdir -p ~/practice`, `cd ~/practice`, `touch empty.txt`, `echo 'hello linux' > note.txt`, `cat note.txt`, `cp note.txt copy.txt`, `mv copy.txt renamed.txt`, `rm`, `rmdir` | 생성·복사·이동·이름 변경·삭제 결과가 `ls`와 `cat`에 반영됨 | [04](logs/04_terminal_permission.txt) |
| 권한 | `ls -l note.txt` → `chmod 755 note.txt` → `chmod 644 note.txt` → `chmod 600 note.txt` / `ls -ld a` → `chmod 700 a` → `chmod 755 a` | 변경 전/후 권한 문자열 비교 (`-rw-r--r--` → `-rwxr-xr-x` → `-rw-------`, 디렉토리 `drwxr-xr-x` → `drwx------`) | [04](logs/04_terminal_permission.txt) |
| Docker 설치·점검 | `docker --version`, `docker info` | `Docker version 29.9.2`, `Server Version: 29.9.2` 출력 (데몬 동작) | [01](logs/01_docker_check.txt) |
| Docker 기본 운영 | `docker images`, `docker pull nginx:alpine`, `docker run -d --name ops-nginx nginx:alpine`, `docker ps`, `docker logs ops-nginx`, `docker stats --no-stream`, `docker stop ops-nginx`, `docker ps -a`, `docker rm ops-nginx` | 실행 중(`Up`) → 종료(`Exited (0)`) 상태 변화, 로그·자원 사용량 확인 | [02](logs/02_docker_ops.txt) |
| 컨테이너 실습 | `docker run --rm hello-world`, `docker run --name ubuntu-once ubuntu bash -c "ls / && echo hello-from-ubuntu"`, `docker run -d --name ubuntu-keep ubuntu sleep infinity`, `docker exec ubuntu-keep ls /` | `Hello from Docker!` 출력, ubuntu 내부 명령 결과 확인 | [03](logs/03_containers.txt) |
| Dockerfile 빌드 | `docker build -t mission1-web:1.0 .`, `docker images mission1-web` | 빌드 성공, 이미지 `mission1-web:1.0` 생성 | [05](logs/05_dockerfile_portmap.txt) |
| 포트 매핑 | `docker run -d -p 8080:80 --name web-8080 mission1-web:1.0`, `docker run -d -p 8081:80 --name web-8081 mission1-web:1.0`, `curl -s http://localhost:8080` | 두 포트 모두 `HTTP 200`과 페이지 응답. 매핑 없이 실행한 컨테이너는 `HTTP 000`(접속 불가) | [05](logs/05_dockerfile_portmap.txt) |
| 바인드 마운트 | `docker run -d --name bind-test -p 8090:80 -v "C:\Users\user\Desktop\mission1\bind-demo:/usr/share/nginx/html:ro" nginx:alpine`, `curl -s http://localhost:8090` (호스트에서 `index.html` 수정 전/후) | 컨테이너 재시작 없이 응답이 `BEFORE` → `AFTER`로 변경 | [06](logs/06_mount_volume.txt) |
| 볼륨 영속성 | `docker volume create mydata`, `docker run -d --name vol-test -v mydata:/data ubuntu sleep infinity`, `docker rm -f vol-test`, `docker run -d --name vol-test2 -v mydata:/data ubuntu sleep infinity`, `docker exec vol-test2 cat /data/hello.txt` | 컨테이너 삭제 후에도 `hi from volume` 유지 | [06](logs/06_mount_volume.txt) |
| Git 설정 | `git config --global init.defaultBranch main`, `git config --list` | `user.name`, `init.defaultbranch=main` 확인 (이메일은 마스킹) | [07](logs/07_git_config.txt) |
| GitHub | `git clone`, `git remote -v`, `git push origin main` | 원격 저장소 `origin` 연결과 push 반영 | [00](logs/00_workspace_setup.txt) |

- **컨테이너 종료/유지**: `docker run ... bash -c "..."`는 명령이 끝나면 컨테이너도 종료(`Exited (0)`)된다. `sleep infinity`로 실행한 컨테이너는 계속 `Up`이고, `docker exec`는 그 안에 명령을 추가로 실행하므로 끝나도 컨테이너가 유지된다.
- **Dockerfile 커스텀**: 기존 베이스 `nginx:alpine`에 `LABEL`(이미지 정보), `ENV APP_ENV=dev`(설정 분리), `COPY site/ ...`(기본 페이지 교체), `HEALTHCHECK`(응답 점검)를 추가했다.

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
