FROM ubuntu:14.04

RUN apt-get update -y && apt-get install -y curl git

RUN curl -O https://storage.googleapis.com/golang/go1.5.3.linux-amd64.tar.gz 
RUN tar -C /usr/local -xzf go1.5.3.linux-amd64.tar.gz
RUN rm go1.5.3.linux-amd64.tar.gz

ENV GOROOT /usr/local/go
ENV GOPATH /go
ENV PATH $GOROOT/bin:$GOPATH/bin:$PATH

WORKDIR /go/src/github.com/mattmanning/geoip

RUN curl -O http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.mmdb.gz
RUN gunzip GeoLite2-City.mmdb.gz

COPY . /go/src/github.com/mattmanning/geoip

RUN go get github.com/gorilla/mux
RUN go get github.com/oschwald/geoip2-golang
RUN go install ./...

EXPOSE 8080

CMD ["geoip"]
