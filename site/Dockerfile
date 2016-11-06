FROM golang:1.7

ADD . /go/src/github.com/sjezewski/dowager/site

RUN ls /go/src/github.com/sjezewski/dowager
RUN ls /go/src/github.com/sjezewski/dowager/site

RUN cd /go/src/github.com/sjezewski/dowager && \
    go install -v ./site

# Change working directory for template file reads
WORKDIR "/go/src/github.com/sjezewski/dowager/site"

ENTRYPOINT /go/bin/site
EXPOSE 80
