FROM gliderlabs/alpine:3.3

RUN apk update && apk-install curl git go && rm -rf /var/cache/apk/*

ENV GOROOT /usr/lib/go
ENV GOPATH /gopath
ENV GOBIN /gopath/bin
ENV PATH $GOROOT/bin:$GOPATH/bin:$PATH

WORKDIR /gopath/src/github.com/mattmanning/geoip

RUN curl -O http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.mmdb.gz
RUN gunzip GeoLite2-City.mmdb.gz

COPY . /gopath/src/github.com/mattmanning/geoip

RUN go get github.com/gorilla/mux
RUN go get github.com/oschwald/geoip2-golang
RUN go install ./...

EXPOSE 8080

CMD ["geoip"]
