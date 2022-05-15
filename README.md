# docker-react-app 구축 및 실행해보기

## A. docker를 활용하여 리액트 앱 띄우기

### 1. Dockerfile.dev 작성

> - 만약 개발과 상용을 분리하기 위해 Dockerfile.dev를 작성하려 한다면 단순히 _**docker build ./**_ 명령어 만으로는 적용이 안됨. (Dockerfile만 자동으로 캐치하기 때문)
> - 다음과 같은 형식 필요
> - _**docker build -f {도커파일명} ./**_
> - ex) _**docker build -f Dockerfile.dev ./**_

<br/>

### 2. 생성한 도커 이미지로 리액트 앱 실행하기

> - docker run {이미지 아이디 혹은 이미지 이름} 을 입력해주면 컨테이너 생성 및 실행이 가능
> - 단, 몇가지 옵션을 잘 넣어줘야 함.
>   - 옵션 1: 리액트 앱은 -it 옵션을 사용해줘야 실행가능함.
>     - 참고로 -it은 더 좋은 포맷으로 결과값을 보기 위한 옵션이다.
>   - 옵션 2: -p 옵션으로 포트 연결을 잘해줘야 함. (로컬 포트와 컨테이너 포트 매핑)
> - ex) _**docker run -it -p 3000:3000 bakumando/docker-react-app**_

<br/>

### 3. Docker Volume 활용하여 어플리케이션 소스 코드 변경점 적용

> - 소스 코드가 변경될때마다 항상 재빌드하여 컨테이너에 파일을 복사해주는 것은 비효율적인 일임.
> - Volume을 활용하면 재빌드 없이 로컬 파일을 컨테이너에 다이렉트로 매핑하여 소스 코드 변경사항을 반영할 수 있음.
> - ex) _**docker run -p 3000:3000 -v /usr/src/app/node_modules -v $(pwd):/usr/src/app bakumando/docker-react-app**_

<br/>

### 4. Docker Compose를 활용하여 앱 실행의 편의성을 더욱 높여보기

> - Docker Volume이 좋은 건 알겠는데 너무 길다. Docker Compose를 활용하면 이걸 해소해줄 수 있음.
> - docker-compose.yml 파일 작성 및 내용 설명
> - **version**: 도커 컴포즈의 버전
> - **services**: 하위에 실행하려는 컨테이너들을 정의
>   - **react**: 컨테이너 이름
>     - **build**: 보통은 현 디렉토리에 있는 Dockerfile 사용
>       - **context**: 도커 이미지를 구성하기 위한 파일과 폴더들이 있는 경로
>       - **dockerfile**: 도커 파일명을 기입 (도커 파일을 직접 지정할때 쓰는 옵션)
>     - **ports**: 포트 매핑 {로컬 포트}:{컨테이너 포트}
>     - **volumes**: 로컬-컨테이너 간에 매핑하지 않을 파일과 매핑할 파일 지정
>     - **stdin_open**: 리액트 앱을 종료할 때 활용 (없으면 버그 발생)
> - 이제 아래 명령어 한번이면 끝!
> - ex) _**docker-compose up**_
>
> ---
>
> - 참고사항: 만약에 앱의 중요한 환경 설정 변동이나 Dockerfile 혹은 yml 파일의 변동이 있는 경우엔 volume 옵션만으로는 즉각적인 반영이 불가능하다. 그렇다면 다시 docker-compose up을 수행해서 이미지를 재빌드해줘야 하는데 재빌드를 위한 옵션인 **--build**를 알아야 한다.
>   - _**docker-compose up**_: 이미지가 없을때만 이미지를 빌드하고 컨테이너를 시작한다.
>   - _**docker-compose up --build**_: 이미지가 있든 없든 다시 이미지를 빌드하고 컨테이너를 시작한다.
>   - 즉, 반드시 재빌드가 필요할 수 있는 상황에는 --build를 추가하면 된다.

<br/>

### 5. docker 환경에서 react 테스트 커맨드 실행하기

> - 바로 형식 및 예시를 확인해보자.
> - _**docker run -it {이미지 이름} npm run test**_
> - ex) _**docker run -it bakumando/docker-react-app npm run test**_ > ![스크린샷 2022-05-15 오후 3 11 38](https://user-images.githubusercontent.com/83815628/168459718-3d9c9fda-73d3-4d03-86ba-6ba6eda1c3b8.png)
> - 성공하였다!
>
> ---
>
> - docker-compose.yml과 volume을 활용하여 즉각적으로 테스트 코드의 변경사항도 반영되도록 해보자.
> - 적용은 간단하다. 우선 yml파일에 아래 코드를 추가해준다.
>   ![스크린샷 2022-05-15 오후 3 16 26](https://user-images.githubusercontent.com/83815628/168459847-f2841d6d-5d30-4ea1-b736-15023f722459.png)
> - 수정사항이 생긴만큼 --build를 넣어 커맨드를 실행한다.
> - ex) _**docker-compose up --build**_
> - App.test.js를 수정해서 테스트 코드를 두개 추가하고 저장해보자.
>   ![스크린샷 2022-05-15 오후 3 22 09](https://user-images.githubusercontent.com/83815628/168460044-d2540eb3-a90a-4877-ab56-d05a24829d5a.png)
> - 바로 결과가 반영되었음을 알 수 있는 출력문이 추가!

<br/>

### 6. 운영환경을 위한 Dockerfile 작성 및 실행해보기

> - 운영환경을 위한 Dockerfile을 요약하자면 2가지 단계로 이루어져있다.
>   - Build stage: 첫번째 단계이며, 빌드 파일들을 생성한다.
>   - Run Stage: 두번째 단계이며, 여기선 Nginx를 가동하고, Build stage에서 생성된 빌드폴더의 파일들을 웹 브라우저의 요청에 따라 제공하여 준다.
> - Run stage 부분만 자세한 내용 설명
>   - _**--from=builder**_: build stage에서 as준 builder를 가져오겠다는 걸 명시한 것.
>     - 즉 --from=의 우항엔 다른 stage에 있는 복사할 대상을 기입하게 되는데, 기입할 이름은 다른 stage의 이름이라는 걸 알 수 있음
>   - /usr/src/app/build /usr/share/nginx/html: build stage에서 생성된 파일들은 /usr/src/app/build에 들어가게 되며, 그곳에 저장된 파일들을 /usr/share/nginx/html에 복사하겠다는 것.
>     - 이러면 niginx가 웹 브라우저의 http 요청이 올때마다 알맞은 파일을 전해줄 수 있게 됨
>     - 즉, /usr/share/nginx/html 경로에 파일들을 복사시켜주는 이유는, 여기에 파일을 넣어 두면 nginx가 알아서 client 요청이 들어올 때 알맞은 정적파일을 제공해주기 때문이라는 거임. 참고로 이 경로는 설정을 통해서 바꿀 수도 있음.
>
> ---
>
> - 직접 운영환경 Dockerfile을 활용하여 이미지를 생성해보자.
> - 이제 _**docker build ./**_ 만 입력해도 Dockerfile이 자동감지되긴 하는데 네이밍을 위해 아래처럼 실행해보자.
> - ex) _**docker build -t bakumando/docker-react-app ./**_ > ![스크린샷 2022-05-15 오후 3 57 25](https://user-images.githubusercontent.com/83815628/168461223-da8e4c88-b749-45b1-b4eb-80e6f4e67652.png)

---

> - 운영환경 컨테이너를 생성 및 실행해보자.
> - ex) _**docker run -p 8080:80 bakumando/docker-react-app**_
>   ![스크린샷 2022-05-15 오후 4 00 53](https://user-images.githubusercontent.com/83815628/168461272-a971fbe4-e995-4c3c-ba53-ac9793dbc23b.png)
>   - 8080은 로컬 포트니까 어떤 걸 지정해도 괜찮지만, 컨테이너 포트는 80으로 설정한 이유 -> _**nginx는 80이 기본 포트이기 때문!**_
>   - 그리고 보면 알겠지만, 페이지 접속하면 `172.17.0.1 - - [15/May/2022:06:59:51 +0000] "GET / HTTP/1.1" 304 0 "-" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.64 Safari/537.36" "-"` 같은 컨테이너 상태 및 하드웨어 정보 로그도 확인 가능
