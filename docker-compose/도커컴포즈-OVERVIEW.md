

쿠버네티스 배포용도로 스프링 애플리케이션을 배포할 때 보통 Dockerfile을 작성하는 편이다. 오늘 정리할 내용은 이런 Dockerfile에 관련된 내용은 아니다. 테스트용도로 postgresql, mysql, rabbitmq 와 같은 컨테이너들을 여러개 띄워야 할 경우가 있다. 이 경우 docker run 명령어를 매번 입력하고, 컨테이너들을 일일이 하나씩 관리하기는 쉽지 않다. 이런 테스트환경을 구축할 때에는 docker-compose 를 사용하는 것이 좋은 것 같다는 생각이 든다. 



## 맛보기

```bash
# docker run -d --name mysql \
alicek106/composetest:mysql \
mysqld

# docker run -d -p 80:80 \
--link mysql:db --name web \
alicek106/compsetest:web \
apachectl -DFOREGROUND
```



위의 docker container 명령어를 docker compose 로 표현해보면 아래와 같다.<br>

에디터는 https://onlineyamltools.com/edit-yaml 을 사용했다.<br>

```yaml
version: '3.0'
services: 
  web:
    image: alicek106/composetest:web
    ports:
      - "80:80"
    links:
      - mysql:db
    command: apachectl -DFOREGROUND
  mysql:
    image: alicek106/composetest:mysql
    command: mysqld
```



- version

- - yaml 파일 포맷의 버전을 나타냄(1,2,2.1,3.0)
  - 도커 컴포즈 1.8 은 버전2, 도커 컴포즈 1.9 는 버전 2.1, 도커 컴포즈 1.10 은 버전 3.0을 사용한다. (버전 1은 사용되지 않는다.)
  - 도커 컴포즈의 버전은 도커 엔진 버전에 의존성이 있다. 도커엔진과 도커 컴포즈 버전 호환성에 리스트는 https://github.com/docker/compose/releases 에 있다.

- services

- - 생성될 컨테이너들을 묶어놓은 단위
  - 서비스 항목 아래에는 각 컨테이너들에 지정할 옵션들을 각각 지정하고 명세화한다.

- web, mysql

- - 생성될 서비스의 이름을 web, mysql 으로 명시했다.(사용자가 직접 이름을 정하는 것.)
  - 이 항목 아래에 컨테이너가 생성될 때 필요한 옵션을 지정할 수 있다.
  - docker run 명령어에서 주로 사용하는 옵션들 처럼 image, ports, links, command 등을 옵션으로 지정하는 것이 가능하다.



## 실행, 상태확인, 종료

docker-compose 를 실행, 상태확인, 종료하는 명령어는 아래와 같다.

docker-compose 실행

```bash
$ docker-compose up
```



docker-compose 상태확인

```bash
$ docker-compose ps
```



docker-compose 종료

```bash
$ docker-compose down
```



**docker-compose 에 프로젝트 명을 지정해서 실행하기**<br>

docker-compose를 프로젝트 명을 지정해서 실행하는 것이 가능하다. 같은 명세의 yaml 이라도 다른 별칭으로 OS 상에 띄우는 것이 가능하다. (우리가 Spring 애플리케이션을 생성할 때 비슷한 명세로 애플리케이션을 생성하지만, 만들때 프로젝트 명을 입력하는 것과 유사한 개념이라고 생각할 수 있다.)

```bash
$ docker-compose -p myproject up -d
```

<br>

**docker-compose 명령시 특정 위치의 yml 파일을 사용하기**<br>

-f 옵션을 사용하면 특정 디렉터리내의 yml 파일을 지정해서 컨테이너를 생성하는 것이 가능하다.

```bash
$ docker-compose -f /home/alicek106/my_compose_file.yml up -d
```

-f 옵션은 프로젝트의 이름을 지정하는 -p 옵션과도 사용가능하다. 이렇게 할 경우 -f 옵션을 먼저 사용해서 파일을 읽은뒤 -p 옵션으로 프로젝트의 이름을 명시할 수 있도록 해주어야 한다. 즉, -f, -p 옵션을 함께 사용할 경우 -f 옵션을 먼저 명시해주어야 한다.<br>

<br>

## docker-compose.yaml 옵션들

docker-compose.yaml 에 기술하는 각 항목, 옵션들은 docker container 명령을 사용할때 사용하게 되는 옵션들에 대한 명세이다. go언어로 작성된 도커컴포즈 엔진은 이 yaml 파일에 명시한 명령어 옵션을 읽어들여서 docker 컨테이너를 구동하게 된다<br>

<br>

**version**<br>

yaml 파일 버전 은  1, 2, 2.1, 3 이 있다. 도커 컴포즈 버전 1.10 부터는 버전 3을 사용한다. 엄청 오랫동안 도커를 업데이트하지 않은 이상은 아마 대부분의 도커 버전에서는 버전 3을 사용할 것 같다. 버전 3는 도커 스웜모드와 호환되는 버전이다. 

ex)

```bash
version: '3.0'
```

<br>

**services**<br>

도커 컴포즈로 생성할 컨테이너의 옵션을 정의한다. services 항목에 쓰인 서비스는 컨테이너로 구현된다. 그리고 하나의 프로젝트로 도커 컴포즈에 의해 관리된다.

```bash
services:
  my_container_1:
    image: ...
  my_container_2:
    image: ...
```

<br>

**services.[컨테이너명].image**<br>

컨테이너 생성시 사용할 도커 이미지의 이름을 설정한다. 현재 디렉터리에 Dockerfile 이 없을 경우 docker hub 에서 자동으로 이미지를 pull 해온다. 

```bash
services:
  my_container_1:
    image: alicek106/composetest:mysql
```

<br>

**services.[컨테이너명].links**<br>

docker run 명령어에 사용하는 --link 옵션과 같은 역할을 한다. 다른 서비스에 서비스명 만으로 접근할 수 있도록 정의한다. [SERVICE:ALIAS] 의 형식을 사용하면 서비스에 별칭으로도 접근할 수 있다.

```bash
services:
  web:
    links:
      - db
      - db:database
      - redis
```

<br>

**services.[컨테이너명].environment**<br>

docker run 명령어의 -env, -e 와 같은 역할을 하는 옵션이다. 딕셔너리 또는 배열 형태를 모두 사용가능하다.

```yaml
services:
  web:
    environment:
      - MYSQL_ROOT_PASSWORD=mypassword
      - MYSQL_DATABASE_NAME=mydb
#    또는 
    environment:
      MYSQL_ROOT_PASSWORD: mypassword
      MYSQL_DATABASE_NAME: mydb
```

<br>

**services.[컨테이너명].command**<br>

컨테이너가 실행될 때 실행할 커맨드(명령어)를 지정하는 옵션이다.<br>

docker run 명령어의 마지막에 붙는 커맨드와 같은 옵션이다.<br>

Dockerfile 내의 RUN 과 같은 배열 형태로도 사용할 수 있다.<br>

```yaml
services:
  web:
    image: alicek106/composetest:web
    command: apachectl -DFOREGROUND
#    또는
  web:
    image: alicek106/composetest:web
    command [apachectl, -DFOREGROUND]
```

<br>

**services.[컨테이너명].depends_on**<br>

특정 컨테이너에 대한 의존관계를 depends_on 필드에 명시한다.<br>

depends_on 에 명시한 컨테이너가 먼저 생성되고 실행되게 된다.<br>

(link 도 depends_on 과 같이 컨테이너의 생성순서와 실행 순서를 정의하지만, depends_on 은 서비스 이름으로만 접근할 수 잇다는 점이 다르다.)<br>

아래 예제에서는 web 컨테이너보다 mysql 이 먼저 생성되게 된다.<br>

<br>

```yaml
services:
  web:
    image: alicek106/compsetest:web
    depends_on:
      - mysql
  mysql:
    image: alicek106/composetest:web
```

<br>

**특정 컨테이너만 생성, 의존성 없는 컨테이너 생성**<br>

의존성이 없는 컨테이너를 생성하려면 --no-deps 옵션을 사용한다.<br>

```bash
$ docker-compose up --no-deps web
```

<br>

> 참고)<br>links, depends_on 은 컨테이너 생성 순서를 명시하기는 하지만, 컨테이너 내부의 애플리케이션이 모두 로딩되었는지를 확인하지는 않는다. 예를 들면, mysql 컨테이너를 web 컨테이너를 올리기전에 실행하게끔 해두었다고 해보자. mysql 컨테이너가 로딩되고, web 컨테이너를 로딩했다. 그런데 mysql 컨테이너 내부의 데이터베이스 초기화 작업은 끝나지 않은 상태이다. 이 경우 web 컨테이너가 에러를 낼 가능성이 있을 수 있다. <br>
>
> 이 경우 컨테이너에 쉘 스크립트를 entrypoint 로 지정하는 방법이 있다. YAML 파일의 entrypoint 에 아래와 같이 지정한다.<br>
>
> ```yaml
> services:
>   web:
>     ...
>     entrypoint: ./sync_script.sh mysql:3306
> ```

<br>

entrypoint 에 지정된 sync_script.sh 는 아래와 같은 형식을 가진다.<br>

```bash
until (상태체크 명령어); do
  echo "depend container is not available yet"
  sleep 1
done
echo "depends_on container ready"
```

<br>

**ports**<br>

docker container run 명령어에서의 -p 옵션과 같은 역할을 한다. 단일 호스트 환경에서 80:80 과 같은 호스트의 포트를 컨테이너의 포트로 연결할 때 ㅇocker-compose scale aㅕㅇ령어로 서비스 컨테이너의 수를 늘리는 것은 불가능하다.<br>

```yaml
services:
  web:
    images: alicek106/compsetest:web
      ports:
        - "8080"
        - "8081-8085"
        - "80:80"
.....
```

<br>

**build**<br>

도커 파일에서 이미지를 빌드해서 서비스의 컨테이너를 생성하도록 설정<br>

아래 예제는 ./composetest 디렉터리 내의 도커파일로 이미지를 빌드해 컨테이너를 생성한다.<br>

새로 빌드될 이미지의 이름은 image 항목에 정의된 이름인 alice106/composetest:web 이 된다.<br>

```yaml
services:
  web:
    build: ./composetest
    image: alicek106/composetest:web
```

<br>

build 옵션 내에서는 도커 파일에서 사용할 컨텍스트, 도커파일명, 도커파일에서 사용할 인자값을 설정할 수 있다.<br>

아래와 같이 image 항목을 설정하지 않으면 이미지의 이름은 [프로젝트명]:[서비스명] 이 된다.<br>

```yaml
services:
  web:
    build: ./composetest
    context: ./composetest
    dockerfile: myDockerfile
    args:
      HOST_NAME: web
      HOST_CONFIG: self_config
```

<br>

만약 이미 이미지 또는 도커 컴포즈 프로젝트가 생성된 상태에서 위의 ㅇocker-compose.yml 을 실행시키면 이미지가 다시 빌드되지 않느다. 이때는 --build 옵션을 추가하여 명령을 준다. 예를 들면 docker-compose up -d --build 와 같은 방식이다.<br>

```bash
docker-compose up -d --build
docker-compose build [yml 파일에서 빌드할 서비스 이름]
```

<br>

**extends**<br>

다른 YAML 파일이나 현재 yaml 파일에서 서비스 속성을 상속받도록 설정한다.<br>

아래의 docker-compose.yml 의 경우 docker-compose.yml 의 web 서비스는 extend_compose.yml 의 extend_web 서비스의 옵션을 그대로 갖게 된다. (즉, web 서비스의 컨테이너는 ubuntu:14.04 이미지의 80:80 포트로 지정된다.)<br>

**docker-compose.yml**<br>

```yaml
version: '3.0'
  services:
    web:
      extends:
        file: extend_compose.yml
        service: extend_web
```

<br>

**extend-compose.yml**<br>

```yaml
version: '3.0'
  services:
    extend_web:
    image: ubuntu:14.04
    ports:
      - "80:80"
```

<br>

아래의 경우 web 서비스가 현재 YAML 파일의 extend_web 서비스의 옵션을 물려받는다.<br>

```yaml
version: '3.0'
  services:
    web:
      extends:
        service: extend-web
    extend_web:
      image: ubuntu:14.04
      ports:
        - "80:80"
```

<br>

참고로 depends_on, links, volumes_from 옵션은 컨테이너 간의 의존성이 있어서 extends 로 상속받는 것은 불가능하다.<br>

(도커컴포즈의 일부 버전에서는 extends 가 동작하지 않는ㄴ다. 이것을 해결하려면 최신 버전의 도커컴포즈를 사용하거나 version 항목을 3.0 이 아닌 2.x 로 내려 사용해야 한다.)<br>



