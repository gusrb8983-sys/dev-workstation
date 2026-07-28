# 개발 워크스테이션 구축 미션

## 1. 프로젝트 개요

터미널(Linux CLI), Docker(컨테이너), Git/GitHub(버전 관리 및 협업)를 직접 손으로 세팅하여,
"내 컴퓨터에서만 되는" 문제 없이 누구나 동일하게 실행·배포·디버깅할 수 있는 개발 환경 구성 과정을
검증 가능한 로그와 증거로 기록한다.

- 작업 디렉토리/권한 정리 (터미널)
- Docker 설치 점검 및 컨테이너 운영
- Dockerfile 기반 웹 서버 컨테이너화
- 포트 매핑을 통한 접속 확인
- 바인드 마운트 / 볼륨을 통한 변경 반영 및 데이터 영속성 검증
- Git 설정 및 GitHub/VSCode 연동

---

## 2. 실행 환경

| 항목 | 값 |
|---|---|
| OS | macOS 15.7.4 (Sequoia), Build 24G517 |
| CPU 아키텍처 | x86_64 |
| 쉘 | zsh 5.9 (/bin/zsh) |
| 터미널 | macOS 기본 Terminal |
| Git | git version 2.53.0 |
| Docker CLI | Docker version 28.5.2, build ecc6942 |
| Docker 런타임 | OrbStack (Docker Desktop 대체) |
| 에디터 | VSCode 1.112.0 |

확인에 사용한 명령:

```bash
sw_vers
echo $SHELL
zsh --version
git --version
docker --version
code --version
uname -m
```

출력 결과:

```
ProductName: macOS
ProductVersion: 15.7.4
BuildVersion: 24G517

/bin/zsh

zsh 5.9 (x86_64-apple-darwin24.0)

git version 2.53.0

Docker version 28.5.2, build ecc6942

1.112.0
07ff9d6178ede9a1bd12ad3399074d726ebe6e43
x64
```

---

## 3. 수행 항목 체크리스트

- [x] 터미널 기본 조작 (조회/이동/생성/복사/이동·이름변경/삭제/내용확인/빈파일생성)
- [x] 파일/디렉토리 권한 확인 및 변경 (각 1건 이상)
- [x] Docker 설치 점검 (`docker --version`, `docker info`)
- [x] Docker 기본 운영 (images/ps/ps -a/logs/stats)
- [x] hello-world 컨테이너 실행
- [x] ubuntu 컨테이너 실행 + 내부 명령 수행, attach/exec 차이 정리
- [x] Dockerfile 작성 및 커스텀 이미지 빌드
- [x] 포트 매핑 및 브라우저 접속 확인
- [x] 바인드 마운트로 변경 반영 검증
- [x] Docker 볼륨으로 데이터 영속성 검증 (컨테이너 삭제 전/후)
- [x] Git 사용자 정보/기본 브랜치 설정 및 `git config --list` 기록
- [x] GitHub 로그인 및 VSCode 연동 증거 첨부

---

## 4. 터미널 조작 로그

`~/Desktop/dev-workstation` 안에서 실습. 현재 위치 확인 → 목록 확인(숨김 포함) → 디렉토리 생성/이동 → 빈 파일 생성 → 내용 확인/작성 → 복사 → 이동/이름변경 → 삭제 순으로 수행.

```bash
$ pwd
/Users/gusrb89838983/Desktop/dev-workstation

$ ls -al
total 32
drwxr-xr-x   6 gusrb89838983  gusrb89838983   192  7 28 18:10 .
drwx------+ 19 gusrb89838983  gusrb89838983   608  7 28 18:03 ..
-rw-r--r--@  1 gusrb89838983  gusrb89838983  6148  7 28 18:03 .DS_Store
drwxr-xr-x  13 gusrb89838983  gusrb89838983   416  7 28 18:04 .git
drwxr-xr-x   4 gusrb89838983  gusrb89838983   128  7 28 18:03 images
-rw-r--r--@  1 gusrb89838983  gusrb89838983  5766  7 28 17:45 README.md

$ mkdir practice
$ cd practice
$ pwd
/Users/gusrb89838983/Desktop/dev-workstation/practice

$ touch memo.txt
$ ls -al
total 0
drwxr-xr-x  3 gusrb89838983  gusrb89838983   96  7 28 18:12 .
drwxr-xr-x  7 gusrb89838983  gusrb89838983  224  7 28 18:11 ..
-rw-r--r--  1 gusrb89838983  gusrb89838983    0  7 28 18:12 memo.txt

$ cat memo.txt
(빈 파일이므로 출력 없음)

$ echo "terminal practice" > memo.txt
$ cat memo.txt
terminal practice

$ cp memo.txt memo_copy.txt
$ ls -al
total 16
-rw-r--r--  1 gusrb89838983  gusrb89838983   18  7 28 18:14 memo_copy.txt
-rw-r--r--  1 gusrb89838983  gusrb89838983   18  7 28 18:13 memo.txt

$ mv memo_copy.txt memo_renamed.txt
$ ls -al
total 16
-rw-r--r--  1 gusrb89838983  gusrb89838983   18  7 28 18:14 memo_renamed.txt
-rw-r--r--  1 gusrb89838983  gusrb89838983   18  7 28 18:13 memo.txt

# mv로 "이동"까지 확인 (상위 폴더로 이동 후 다시 복귀)
$ mv memo_renamed.txt ../
$ cd ..
$ ls -al
... memo_renamed.txt 가 dev-workstation 폴더로 이동된 것 확인 ...
$ mv memo_renamed.txt practice/
$ cd practice
$ ls -al
total 16
-rw-r--r--  1 gusrb89838983  gusrb89838983   18  7 28 18:14 memo_renamed.txt
-rw-r--r--  1 gusrb89838983  gusrb89838983   18  7 28 18:13 memo.txt

$ rm memo_renamed.txt
$ ls -al
total 8
drwxr-xr-x  3 gusrb89838983  gusrb89838983   96  7 28 18:16 .
drwxr-xr-x  7 gusrb89838983  gusrb89838983  224  7 28 18:16 ..
-rw-r--r--  1 gusrb89838983  gusrb89838983   18  7 28 18:13 memo.txt
```

> 참고: 실습 중 `cat memo.txxt`, `mv memo.renamed.txt practice/` 등 오타로 인한 `No such file or directory` 에러를 실제로 겪었고, 파일명을 정확히 재입력하여 해결함. (별도 트러블슈팅 항목으로 분리하지 않고 로그 흐름 그대로 남김)

---

## 5. 권한 실습

`practice` 폴더 안에서 파일 1개, 디렉토리 1개에 대해 권한 변경 전/후 비교.

### 5-1. 파일 권한 (memo.txt)

```bash
$ ls -l memo.txt
-rw-r--r--  1 gusrb89838983  gusrb89838983  18  7 28 18:13 memo.txt

$ chmod 600 memo.txt
$ ls -l memo.txt
-rw-------  1 gusrb89838983  gusrb89838983  18  7 28 18:13 memo.txt
```

- 변경 전: `-rw-r--r--` (소유자 rw, 그룹 r, 기타 r)
- 변경 후: `-rw-------` (소유자만 rw, 그룹/기타 접근 불가)
- 명령: `chmod 600` → 소유자 read+write(4+2), 그룹/기타 없음(0)

### 5-2. 디렉토리 권한 (secret_dir)

```bash
$ mkdir secret_dir
$ ls -ld secret_dir
drwxr-xr-x  2 gusrb89838983  gusrb89838983  64  7 28 18:31 secret_dir

$ chmod 700 secret_dir
$ ls -ld secret_dir
drwx------  2 gusrb89838983  gusrb89838983  64  7 28 18:31 secret_dir
```

- 변경 전: `drwxr-xr-x` (그룹/기타도 읽기+진입 가능)
- 변경 후: `drwx------` (소유자만 읽기/쓰기/진입 가능, 그룹/기타 완전 차단)
- 명령: `chmod 700` → 소유자 read+write+execute(4+2+1), 그룹/기타 없음(0)

---

## 6. Docker 설치 점검 및 기본 운영

### 6-1. 설치/버전 점검

```bash
$ docker --version
Docker version 28.5.2, build ecc6942

$ docker info
Client:
 Version:    28.5.2
 Context:    orbstack
 Debug Mode: false
Server:
 Containers: 3
  Running: 1
  Paused: 0
  Stopped: 2
 Images: 2
 Server Version: 28.5.2
 Storage Driver: overlay2
 Operating System: OrbStack
 OSType: linux
 Architecture: x86_64
 CPUs: 6
 Total Memory: 15.67GiB
 Docker Root Dir: /var/lib/docker
 Product License: Community Engine
```
*(전체 출력 중 핵심 항목만 발췌. Docker 런타임: OrbStack, Context: orbstack)*

- `docker --version` → CLI 정상 설치 확인
- `docker info` → 데몬이 정상 응답, 서버 정보(OS/아키텍처/스토리지 드라이버 등) 확인 → **Docker 정상 동작 확인 완료**

### 6-2. 기본 운영 명령

```bash
$ docker images
REPOSITORY    TAG       IMAGE ID       CREATED        SIZE
nginx         latest    4e5db4761e0f   12 days ago    161MB
hello-world   latest    e2ac70e7319a   4 months ago   10.1kB

$ docker ps
CONTAINER ID   IMAGE     COMMAND                   CREATED       STATUS       PORTS                                     NAMES
ba12d2199717   nginx     "/docker-entrypoint.…"   4 hours ago   Up 4 hours   0.0.0.0:8080->80/tcp, [::]:8080->80/tcp   my-nginx2

$ docker ps -a
CONTAINER ID   IMAGE         COMMAND                   CREATED       STATUS                   PORTS                                     NAMES
ba12d2199717   nginx         "/docker-entrypoint.…"   4 hours ago   Up 4 hours               0.0.0.0:8080->80/tcp, [::]:8080->80/tcp   my-nginx2
503ca04cd96f   nginx         "/docker-entrypoint.…"   4 hours ago   Exited (0) 4 hours ago                                             my-nginx
70e85841ecc0   hello-world   "/hello"                  4 hours ago   Exited (0) 4 hours ago                                             competent_margulis

$ docker logs my-nginx2
/docker-entrypoint.sh: Configuration complete; ready for start up
2026/07/28 05:55:15 [notice] 1#1: using the "epoll" event method
2026/07/28 05:55:15 [notice] 1#1: nginx/1.31.3
2026/07/28 05:55:15 [notice] 1#1: start worker process 29
...
192.168.215.1 - - [28/Jul/2026:06:21:27 +0000] "GET / HTTP/1.1" 200 216 ...
192.168.215.1 - - [28/Jul/2026:06:40:59 +0000] "GET / HTTP/1.1" 304 0 ...

$ docker stats --no-stream
CONTAINER ID   NAME        CPU %     MEM USAGE / LIMIT     MEM %     NET I/O           BLOCK I/O         PIDS
ba12d2199717   my-nginx2   0.00%     5.801MiB / 15.67GiB   0.04%     9.29kB / 4.74kB   28.1MB / 8.19kB   7
```

- `docker images` → 로컬에 nginx, hello-world 2개 이미지 존재 확인
- `docker ps` → 현재 실행 중인 컨테이너(`my-nginx2`) 1개 확인
- `docker ps -a` → 종료된 컨테이너까지 포함 총 3개 확인 (실행/중지 상태 구분됨)
- `docker logs` → nginx 시작 로그 + 실제 HTTP 접속 로그 확인
- `docker stats --no-stream` → CPU/메모리 실시간 사용량 1회 스냅샷 확인 (`--no-stream` 미사용 시 화면이 계속 갱신되어 로그로 남기기 어려움)

---

## 7. 컨테이너 실행 실습 (hello-world / ubuntu)

### 7-1. hello-world 실행

```bash
$ docker run hello-world
Hello from Docker!
This message shows that your installation appears to be working correctly.
...
```
→ 정상 실행 확인 (이미지 pull → 컨테이너 생성 → 메시지 출력 → 자동 종료)

### 7-2. ubuntu 컨테이너 진입 + 내부 명령 수행

```bash
$ docker run -it ubuntu bash
Unable to find image 'ubuntu:latest' locally
latest: Pulling from library/ubuntu
Status: Downloaded newer image for ubuntu:latest
root@69be7369b8b2:/# ls
bin   dev  home  lib64  mnt  proc  run   srv  tmp  var
boot  etc  lib   media  opt  root  sbin  sys  usr
root@69be7369b8b2:/# echo "hello from inside container"
hello from inside container
root@69be7369b8b2:/# cat /etc/os-release
PRETTY_NAME="Ubuntu 26.04 LTS"
NAME="Ubuntu"
...
root@69be7369b8b2:/# exit
```
→ macOS 호스트와 별개로, 컨테이너 내부는 독립된 Ubuntu 26.04 리눅스 환경임을 `/etc/os-release`로 확인 (격리된 실행 환경 검증)

### 7-3. attach vs exec 차이 관찰

같은 컨테이너(`ubuntu_test`, 백그라운드 실행)를 `exec`와 `attach` 두 방식으로 각각 진입하여 `ps aux`로 프로세스 목록 비교.

**exec로 진입 (`docker exec -it ubuntu_test bash`)**
```bash
root@bffccc4f16d5:/# ps aux
USER   PID  COMMAND
root     1  bash      ← 컨테이너 생성 시 시작된 원본(메인) 프로세스
root     8  bash      ← exec로 새로 생성된 프로세스
root    15  ps aux
root@bffccc4f16d5:/# exit
$ docker ps
... ubuntu_test ... Up About a minute ...   ← exit 이후에도 컨테이너 계속 실행 중
```

**attach로 진입 (`docker attach ubuntu_test`)**
```bash
root@bffccc4f16d5:/# ps aux
USER   PID  COMMAND
root     1  bash      ← 원본 메인 프로세스에 직접 연결됨 (새 프로세스 생성 없음)
root    19  ps aux
root@bffccc4f16d5:/# exit
$ docker ps -a
... ubuntu_test ... Exited (0) 9 seconds ago ...   ← exit 이후 컨테이너 자체가 종료됨
```

**관찰 결론:**
- `exec -it`는 컨테이너 안에 **새 프로세스를 추가로 생성**하여 연결한다. 그 셸을 `exit`해도 원본 메인 프로세스(PID 1)는 살아있으므로 컨테이너는 계속 실행된다.
- `attach`는 컨테이너의 **메인 프로세스(PID 1)에 직접 연결**한다. 이 상태에서 `exit`하면 메인 프로세스 자체가 종료되어 컨테이너 전체가 멈춘다.
- 따라서 컨테이너를 계속 살려둔 채 잠깐 들여다보고 싶다면 `exec`가 안전하고, `attach`를 쓸 경우 반드시 `Ctrl+P, Ctrl+Q`로 detach해야 한다 (본 실습 환경에서는 해당 키 조합이 동작하지 않아 `exit`로 종료하며 차이를 직접 확인함).

---

## 8. Dockerfile 기반 커스텀 이미지

### 선택한 방식

**(A) 웹서버 베이스 이미지 활용 + 정적 콘텐츠/설정 교체** — `nginx:alpine`을 베이스로 사용.

### Dockerfile

```dockerfile
# 베이스 이미지: 공식 nginx (Alpine 경량 버전)
FROM nginx:alpine

# 커스텀 포인트 1: 이미지 메타데이터 (관리자 정보, 앱 이름)
LABEL maintainer="HyunJun Choi <gusrb8983@gmail.com>"
ENV APP_NAME="dev-workstation-mission"

# 커스텀 포인트 2: 기본 nginx 환영 페이지를 자기소개 정적 페이지로 교체
COPY app/ /usr/share/nginx/html/

# 커스텀 포인트 3: 헬스체크 - 30초마다 웹서버가 응답하는지 자동 점검
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost/ || exit 1

EXPOSE 80
```

### 커스텀 포인트별 목적

| 포인트 | 내용 | 목적 |
|---|---|---|
| 정적 콘텐츠 교체 | `app/index.html`(자기소개 페이지)을 nginx 기본 웹 루트로 복사 | nginx 기본 환영 페이지 대신 원하는 콘텐츠 서비스 |
| 메타데이터 (`LABEL`/`ENV`) | 관리자 정보, 앱 이름 명시 | 이미지 관리/식별 용이 |
| 헬스체크 | 30초 주기로 `wget`으로 자체 응답 확인 | 컨테이너가 살아있어도 서비스가 죽었는지(예: nginx 프로세스 이상)까지 자동 감지 → `docker ps`에 healthy/unhealthy로 표시 |

### 빌드 / 실행 로그

```bash
$ docker build -t my-intro-page .
[+] Building 6.9s (7/7) FINISHED
 => [internal] load build definition from Dockerfile
 => [internal] load metadata for docker.io/library/nginx:alpine
 => [internal] load build context
 => [1/2] FROM docker.io/library/nginx:alpine@sha256:4a73073bd557c65b759505da037898b...
 => [2/2] COPY app/ /usr/share/nginx/html/
 => exporting to image
 => => naming to docker.io/library/my-intro-page

$ docker images
REPOSITORY      TAG       IMAGE ID       CREATED          SIZE
my-intro-page   latest    f69970a35cbe   32 seconds ago   62.4MB
nginx           latest    4e5db4761e0f   12 days ago      161MB
ubuntu          latest    de7345b16e94   2 weeks ago      100MB
hello-world     latest    e2ac70e7319a   4 months ago     10.1kB

$ docker run -d --name intro-page -p 8888:80 my-intro-page
50c8568d851dabff1b3c88a96505662aeb128b577e13901008c7328fc0a3d181

$ docker ps
CONTAINER ID   IMAGE           COMMAND                   CREATED         STATUS                   PORTS                                     NAMES
50c8568d851d   my-intro-page   "/docker-entrypoint.…"   6 seconds ago   Up 5 seconds (healthy)   0.0.0.0:8888->80/tcp, [::]:8888->80/tcp   intro-page
```

- 빌드 성공, 이미지 크기 62.4MB (alpine 기반이라 nginx:latest의 161MB보다 훨씬 가벼움)
- 실행 즉시 `STATUS`에 `(healthy)` 표시 → HEALTHCHECK 정상 작동 확인

---

## 9. 포트 매핑 및 접속 증거

`docker run -d --name intro-page -p 8888:80 my-intro-page` 로 호스트 8888번 포트를 컨테이너 80번 포트(nginx)로 매핑.

브라우저에서 `http://localhost:8888` 접속 결과 (주소창 + 응답 화면):

[images/port-mapping-localhost8888.png](images/port-mapping-localhost8888.png)

정상적으로 자기소개 페이지가 렌더링됨을 확인.

---

## 10. 바인드 마운트 검증

호스트의 `app/` 폴더를 컨테이너의 nginx 웹 루트(`/usr/share/nginx/html`)에 바인드 마운트하여, 호스트 파일 수정이 재빌드 없이 즉시 컨테이너에 반영되는지 검증. 대조군으로 마운트 없이(이미지에 파일이 고정된) 실행 중인 `intro-page`(8888)와 비교.

```bash
# 바인드 마운트로 컨테이너 실행
$ docker run -d --name intro-page-mounted -p 9999:80 \
    -v ~/Desktop/dev-workstation/app:/usr/share/nginx/html my-intro-page
$ docker ps
CONTAINER ID   IMAGE           STATUS                    PORTS                     NAMES
3225f32ce75c   my-intro-page   Up (health: starting)     0.0.0.0:9999->80/tcp     intro-page-mounted
50c8568d851d   my-intro-page   Up (healthy)               0.0.0.0:8888->80/tcp     intro-page

# 변경 전 확인
$ curl http://localhost:9999 | grep "HyunJun"
<title>HyunJun Choi | dev-workstation</title>
    <h1>HyunJun Choi</h1>

# 호스트 파일 직접 수정 (Docker 명령 아님, 순수 파일 편집)
$ sed -i '' 's/HyunJun Choi/HyunJun Choi (BIND MOUNT TEST)/' app/index.html
$ cat app/index.html | grep "BIND MOUNT"
<title>HyunJun Choi (BIND MOUNT TEST) | dev-workstation</title>
    <h1>HyunJun Choi (BIND MOUNT TEST)</h1>

# 재빌드/재시작 없이 마운트된 컨테이너 재확인 → 변경 즉시 반영됨
$ curl http://localhost:9999 | grep "BIND MOUNT"
<title>HyunJun Choi (BIND MOUNT TEST) | dev-workstation</title>
    <h1>HyunJun Choi (BIND MOUNT TEST)</h1>

# 대조군: 마운트 없는 컨테이너는 영향 없음 (이미지에 파일이 고정되어 있음)
$ curl http://localhost:8888 | grep "HyunJun"
<title>HyunJun Choi | dev-workstation</title>
    <h1>HyunJun Choi</h1>
```

**결론:** 바인드 마운트된 컨테이너는 호스트 파일 변경이 즉시(재빌드/재시작 불필요) 반영되지만, 이미지에 `COPY`로 고정된 컨테이너는 호스트 파일이 바뀌어도 영향받지 않음. 개발 중 코드 변경을 즉시 확인하고 싶을 때 바인드 마운트가 유용한 이유가 실증됨.

---

## 11. 볼륨 영속성 검증

Docker 볼륨을 생성하여 컨테이너에 연결하고, 컨테이너를 완전히 삭제한 뒤에도 데이터가 유지되는지 검증.

```bash
# 1. 볼륨 생성
$ docker volume create mydata
$ docker volume ls
DRIVER    VOLUME NAME
local     mydata

# 2. 볼륨을 연결한 컨테이너 실행 + 데이터 기록
$ docker run -d --name vol-test -v mydata:/data ubuntu sleep infinity
$ docker exec vol-test bash -c 'echo "persistent data test" > /data/message.txt'
$ docker exec vol-test cat /data/message.txt
persistent data test

# 3. 컨테이너 완전 삭제
$ docker stop vol-test
$ docker rm vol-test
$ docker ps -a
(vol-test가 목록에서 완전히 사라짐 확인)

# 4. 삭제 후에도 볼륨 자체는 남아있음
$ docker volume ls
DRIVER    VOLUME NAME
local     mydata

# 5. 새 컨테이너로 같은 볼륨을 재연결하여 데이터 확인
$ docker run --rm -v mydata:/data ubuntu cat /data/message.txt
persistent data test
```

**결론:** `vol-test` 컨테이너를 `docker rm`으로 완전히 삭제했음에도, 이후 생성한 전혀 다른 컨테이너에서 동일 볼륨(`mydata`)을 연결하니 이전에 저장한 데이터(`persistent data test`)가 그대로 유지됨을 확인. 컨테이너(임시적, 언제든 삭제 가능)와 볼륨(영속적 데이터 저장소)이 분리되어 있다는 Docker의 핵심 설계 원칙이 실증됨.

---

## 12. Git 설정 및 GitHub/VSCode 연동

### 12-1. 사용자 정보 확인

```bash
$ git config --global user.name
HyunJun Choi
$ git config --global user.email
gusrb8983@gmail.com
$ git config --list
credential.helper=osxkeychain
user.name=HyunJun Choi
user.email=gusrb8983@gmail.com
```

### 12-2. 로컬 저장소 초기화 및 원격 연결

```bash
$ cd ~/Desktop/dev-workstation
$ git init
/Users/gusrb89838983/Desktop/dev-workstation/.git/ 안의 기존 깃 저장소를 다시 초기화했습니다
$ git status
현재 브랜치 main
아직 커밋이 없습니다
추적하지 않는 파일:
  README.md

$ git remote add origin https://github.com/gusrb8983-sys/dev-workstation.git
$ git branch -M main
$ git add README.md
$ git commit -m "docs: init readme"
[main (최상위-커밋) bf5a7d9] docs: init readme
 1 file changed, 156 insertions(+)
 create mode 100644 README.md
$ git push -u origin main
Username for 'https://github.com': gusrb8983-sys
Password for 'https://gusrb8983-sys@github.com':
오브젝트 나열하는 중: 3, 완료.
오브젝트 개수 세는 중: 100% (3/3), 완료.
Delta compression using up to 6 threads
오브젝트 압축하는 중: 100% (2/2), 완료.
오브젝트 쓰는 중: 100% (3/3), 1.75 KiB | 1.75 MiB/s, 완료.
Total 3 (delta 0), reused 0 (delta 0), pack-reused 0 (from 0)
To https://github.com/gusrb8983-sys/dev-workstation.git
 * [new branch]      main -> main
branch 'main' set up to track 'origin/main'.
```

원격 저장소: https://github.com/gusrb8983-sys/dev-workstation

### 12-3. VSCode GitHub 연동

VSCode에서 `~/Desktop/dev-workstation` 폴더를 열고 Source Control 패널에서 로컬 커밋 그래프와 원격(GitHub) 연동 상태(클라우드 아이콘)를 확인. 이어서 좌하단 계정 메뉴에서 GitHub 계정(`gusrb8983-sys`)으로 로그인되어 있음을 확인.

- Source Control 패널 (커밋 그래프 + main 브랜치 + 원격 연동 아이콘): [images/vscode-source-control.png](images/vscode-source-control.png)
- 계정 메뉴 (`gusrb8983-sys (GitHub)` 로그인 상태): [images/vscode-github-account.png](images/vscode-github-account.png)

---

## 13. 트러블슈팅

### 트러블슈팅 1: `git push` 시 인증 실패

- 문제: `git push -u origin main` 실행 시 Username/Password를 요구했고, GitHub 비밀번호를 그대로 입력하면 인증이 거부됨
- 원인 가설: GitHub가 2021.08부터 HTTPS 원격 저장소에 대한 비밀번호 인증(Password Authentication)을 폐지하고 Personal Access Token(PAT) 또는 SSH 키만 허용함
- 확인: GitHub 공식 문서(Token authentication requirements) 및 비밀번호 입력 시 인증 실패 재현으로 확인
- 해결: Settings → Developer settings → Personal access tokens에서 `repo` 스코프의 classic 토큰을 발급하여 Password 자리에 입력. `credential.helper=osxkeychain` 설정으로 이후 macOS 키체인에 자동 저장되어 재인증 불필요해짐
- (토큰 값 자체는 보안상 기록하지 않음)

### 트러블슈팅 2: `docker attach` detach 키 조합(`Ctrl+P, Ctrl+Q`) 미동작

- 문제: `docker attach`로 컨테이너에 연결한 뒤, 컨테이너를 종료시키지 않고 빠져나오는 표준 키 조합인 `Ctrl+P` → `Ctrl+Q`를 입력했으나 반응이 없었음
- 원인 가설: 사용 중인 터미널 애플리케이션 또는 macOS 키보드/단축키 설정에서 해당 다중 키 시퀀스가 다른 기능에 선점되어 있거나 전달되지 않는 것으로 추정
- 확인: 여러 차례 재시도했으나 동일하게 반응 없음을 확인. 대신 `docker exec`로 진입했을 때는 별도 프로세스가 생성되어 `exit`로 나가도 컨테이너가 유지된다는 점을 이용해, 목적(컨테이너를 살려둔 채 내부 확인)은 `exec`로 우회 가능함을 파악
- 해결/대안: 당장은 `attach` 상태에서 `exit`로 나가 컨테이너가 실제로 종료되는 것을 그대로 관찰 자료로 활용함 (attach와 exec의 차이를 증명하는 데이터로 전환). 컨테이너를 살려둔 채 내부를 확인할 때는 `exec -it`를 기본으로 사용하고, `attach`가 꼭 필요하다면 iTerm2 등 다른 터미널 앱이나 `tmux`/`screen` 세션 안에서 시도하는 것을 대안으로 고려

---

## 14. 참고

- 본 문서는 macOS + OrbStack 환경 기준으로 작성됨. 다른 OS/Docker 런타임 사용 시 명령어는 동일하나 데몬 관리 방식(Docker Desktop UI 등)만 다를 수 있음.
