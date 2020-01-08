dh-up: 
	docker-machine create --driver google \
	--google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
	--google-machine-type n1-standard-1 \
	--google-zone europe-west2-b \
	docker-host;
	docker-machine ip docker-host

dh-destroy:
	docker-machine rm -f docker-host

.PHONY: dh-up dh-destroy
