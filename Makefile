
init-env:
	gcloud config set account seanwjezewski@gmail.com
	gcloud config set project personal
	gcloud auth login
	# above should work ... but only `gcloud init` seems to work for me
	kubectl config use-context gke_personal-141021_us-central1-b_pachyderm
	export ADDRESS=`gcloud compute instances list | head -n 2 | tail -n 1 | cut -d " " -f 20`
	# ADDRESS is used for pachctl to connect to pachd

normalize-data:
	./code/normalize/normalize.rb

launch-cluster:

clean-launch-cluster:

input-data: normalize-data
	pachctl create-repo scripts
	mkdir -p tmp
	pachctl start-commit scripts > tmp/commitID
	ls -1 data/noramlized/* | while read -r file; do cat $$file | pachctl put-file scripts `cat tmp/commitID` `basename $$file`; done
	pachctl finish-commit scripts `cat tmp/commitID`
	rm tmp/commitID

docker-build:
	docker build -t lstm_rnn_model ./code/analysis

setup:
	pachctl create-pipeline -f code/analysis/pipeline.json

