FROM golang:1.7

ADD . /go/src/github.com/sjezewski/dowager
RUN go install -v github.com/sjezewski/dowager/site

# Change working directory for template file reads
WORKDIR "/go/src/github.com/sjezewski/dowager/site"

ENTRYPOINT /go/bin/site
EXPOSE 80
