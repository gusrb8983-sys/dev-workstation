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
- [ ] hello-world 컨테이너 실행
- [ ] ubuntu 컨테이너 실행 + 내부 명령 수행, attach/exec 차이 정리
- [ ] Dockerfile 작성 및 커스텀 이미지 빌드
- [ ] 포트 매핑 및 브라우저 접속 확인
- [ ] 바인드 마운트로 변경 반영 검증
- [ ] Docker 볼륨으로 데이터 영속성 검증 (컨테이너 삭제 전/후)
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

(다음 단계에서 채움)

---

## 8. Dockerfile 기반 커스텀 이미지

(다음 단계에서 채움)

---

## 9. 포트 매핑 및 접속 증거

(다음 단계에서 채움)

---

## 10. 바인드 마운트 검증

(다음 단계에서 채움)

---

## 11. 볼륨 영속성 검증

(다음 단계에서 채움)

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

(나머지는 다음 단계에서 채움)

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

### 트러블슈팅 2

- 문제:
- 원인 가설:
- 확인:
- 해결/대안:

---

## 14. 참고

- 본 문서는 macOS + OrbStack 환경 기준으로 작성됨. 다른 OS/Docker 런타임 사용 시 명령어는 동일하나 데몬 관리 방식(Docker Desktop UI 등)만 다를 수 있음.
