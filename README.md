# cigate
**cigate** is a multipurpose gateway image that can be used to proxy external traffic into the application ser ice network for testing purposes or when simulating environments using docker. It is based on the latest `alpine` image.

# content
the following programs & tools are included and enabled by default:

### privoxy as HTTP/HTTPS proxy
the privoxy server is listening & exposed on `port 8080` and preconfigured to forward other traffic via the internal **SOCKS5** proxy

### go-sock5 as SOCKS5 proxy
the socks5 server is listening & exposed on `port 1080`.


# usage

### example of use within a service
Here is an example of a `docker-compose` file hosting 2 application servers (each listening on port 8080) and our cigate proxy service:
```yaml
# PURPOSE: example compose file for use in a docker stack
version: "3"

# network definitions
# ===================
networks:
  my_internal_network:

# service definitions
# ===================
services:

  # internal application(s)
  appserver1:
    image: tomcat
    networks:
      - my_internal_network
  appserver2:
    image: tomcat
    networks:
      - my_internal_network

  # the cigate image
  cigate:
    image: docker4prime/cigate
    build: .
    networks:
      - my_internal_network
    ports:
    - "8080:8080"

```

Create and run the docker environment using:
```bash
docker-compose up
```

Now you'll just need to use `localhost:8080` as proxy server in order to access the internal app service from outside:
```bash
andrianaivo@NB-FIDY-2:~/WORKSPACE/prime/cigate$ curl -v --proxy localhost:8080 http://appserver1:8080/ |grep h1
* TCP_NODELAY set
* Connected to localhost (::1) port 8080 (#0)
> GET http://appserver1:8080/ HTTP/1.1
> Host: appserver1:8080
> User-Agent: curl/7.54.0
> Accept: */*
> Proxy-Connection: Keep-Alive
>
< HTTP/1.1 200
< Content-Type: text/html;charset=UTF-8
< Transfer-Encoding: chunked
< Date: Wed, 20 Feb 2019 18:25:05 GMT
< Connection: close
< Proxy-Connection: keep-alive
<
100 11266    0 11266    0     0   293k      0 --:--:-- --:--:-- --:--:--  297k
* Closing connection 0
                <h1>Apache Tomcat/8.5.38</h1>
```



### standalone container run
```bash
docker run -d docker4prime/cigate
```

### standalone container run (opening a shell session)
```bash
docker run docker4prime/cigate sh
```
