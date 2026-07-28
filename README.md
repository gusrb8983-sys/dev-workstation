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

- [ ] 터미널 기본 조작 (조회/이동/생성/복사/이동·이름변경/삭제/내용확인/빈파일생성)
- [ ] 파일/디렉토리 권한 확인 및 변경 (각 1건 이상)
- [ ] Docker 설치 점검 (`docker --version`, `docker info`)
- [ ] Docker 기본 운영 (images/ps/ps -a/logs/stats)
- [ ] hello-world 컨테이너 실행
- [ ] ubuntu 컨테이너 실행 + 내부 명령 수행, attach/exec 차이 정리
- [ ] Dockerfile 작성 및 커스텀 이미지 빌드
- [ ] 포트 매핑 및 브라우저 접속 확인
- [ ] 바인드 마운트로 변경 반영 검증
- [ ] Docker 볼륨으로 데이터 영속성 검증 (컨테이너 삭제 전/후)
- [ ] Git 사용자 정보/기본 브랜치 설정 및 `git config --list` 기록
- [ ] GitHub 로그인 및 VSCode 연동 증거 첨부

---

## 4. 터미널 조작 로그

(다음 단계에서 채움)

---

## 5. 권한 실습

(다음 단계에서 채움)

---

## 6. Docker 설치 점검 및 기본 운영

(다음 단계에서 채움)

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

(다음 단계에서 채움 — VSCode Accounts 아이콘에서 GitHub 로그인 + Source Control 패널 스크린샷 예정)

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
