# Web App

build:
	cd site && go build .

run: build
	# Note for local setup:
	# May want to run `$ sudo docker-machine ssh akillerqueen -fTNL 650:localhost:30650`
	# to setup local port forwarding w this port as well.

	PACHD_PORT_650_TCP_ADDR=localhost GIN_MODE=debug ./site/site

deploy-web: docker-webapp
	kubectl run dowager --image=sjezewski/dowager:latest --port=9080
	kubectl expose deployment dowager --type="LoadBalancer"

stop-web:
	kubectl delete --ignore-not-found deployment dowager
	kubectl delete --ignore-not-found service dowager

relaunch-web: stop-web deploy-web

update-web:
	# This doesn't work ... but a variant used to
	# k8s api probably changed
	kubectl rolling-update dowager --image=sjezewski/dowager:latest

# Pachyderm Pipelines

normalize-data:
	./code/normalize/normalize.rb

input-data: normalize-data
	pachctl create-repo scripts
	pachctl start-commit scripts master
	ls -1 data/normalized/* | while read -r file; do cat $$file | pachctl put-file scripts master `basename $$file`; done
	pachctl finish-commit scripts master

setup-pipelines: docker-analysis input-data
	pachctl create-pipeline -f code/analysis/pipeline.json

# Docker helpers

docker-webapp:
	docker build -t "sjezewski/dowager:latest" ./site
	docker push sjezewski/dowager:latest

docker-analysis:
	rm -rf ./code/analysis/pachyderm
	cp -R $(GOPATH)/src/github.com/pachyderm/pachyderm ./code/analysis
	# The Dockerfile needs the pachyderm src
	# the code on master at the moment doesn't work?
	# I know Derek added this as a work around
	# --
	# Also!
	# There is another bug right now where master is out of sync w versions
	# in terms of the jobshim's requirements. Checking out a specific version
	# so that you can install the right jobshim binary is important
	cd ./code/analysis/pachyderm && git checkout v1.2.2 && rm -rf .git
	docker build -t "sjezewski/dowager_rnn:2" ./code/analysis
	docker push sjezewski/dowager_rnn:2
	rm -rf ./code/analysis/pachyderm

docker: docker-webapp docker-analysis


# Pachyderm cluster

launch-pachyderm-cluster:
	which pachctl
	pachctl deploy --dry-run > build/pachyderm.json
	cat build/pachyderm.json | kubectl create -f -

clean-launch-pachyderm-cluster:
	cat build/pachyderm.json | kubectl delete --ignore-not-found -f -
