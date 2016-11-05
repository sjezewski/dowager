FROM tensorflow/tensorflow:0.10.0
MAINTAINER jdoliner@pachyderm.io

# Install FUSE
RUN \
  apt-get update -yq && \
  apt-get install -yq --no-install-recommends \
    git \
    ca-certificates \
    curl \
    fuse && \
  apt-get clean && \
  rm -rf /var/lib/apt

# Install Go 1.6.0
RUN \
  curl -sSL https://storage.googleapis.com/golang/go1.6.linux-amd64.tar.gz | tar -C /usr/local -xz && \
  mkdir -p /go/bin
ENV PATH /usr/local/go/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin
ENV GOPATH /go
ENV GOROOT /usr/local/go

# Add the code files

ADD . /code

# Add source code
ADD pachyderm /go/src/github.com/pachyderm/pachyderm

# Install Pachyderm job-shim

# Had to fork this, as there was a change on master that was needed that wasn't on 1.2.3
# Specifically the PPS_POD_NAME wasn't set and was causing errors on pjob pods like:
# `env key not set when required: PPS_POD_NAME main.appEnv`

# To construct the fork, I did a replace of the domain imports a la:
# 
# LANG=C find ./src/ -type f -exec sed -i '' 's/pachyderm\/pachyderm/sjezewski\/pachyderm/g' {} +
# 
# and then I have to copy the client symlink (or there are vendor conflicts) by doing:
#
# mv src/server/vendor/github.com/pachyderm src/server/vendor/github.com/sjezewski
#

# Also,
# this meant that I needed to use a local build of pachctl to generate the manifest,
# which in turn meant that it referenced a pachd image that DNE on pachyderm's account
# So I had to build the image locally, then push to my account, AND update the manifest manually

#RUN go get github.com/sjezewski/pachyderm/src/server/cmd/job-shim && \
#    cp $GOPATH/bin/job-shim /job-shim

RUN cd /go/src/github.com/pachyderm/pachyderm && \
	ls ./src/client

RUN cd /go/src/github.com/pachyderm/pachyderm && \
	go install ./src/server/cmd/job-shim && \
	cp $GOPATH/bin/job-shim /job-shim
