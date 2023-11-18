sha := $(shell git rev-parse --short=7 HEAD)
release_version = `cat VERSION`
build_date ?= $(shell git show -s --date=iso8601-strict --pretty=format:%cd $$sha)
branch = $(shell git branch | grep \* | cut -f2 -d' ')
epoch := $(shell date +"%s")
AR_REPO ?= codecov/relay
DOCKERHUB_REPO ?= codecov/relay
VERSION := ${release_version}-${sha}
export DOCKER_BUILDKIT=1


shell:
	RELAY_DOCKER_REPO=${AR_REPO} RELAY_DOCKER_VERSION=${VERSION} docker-compose exec relay sh
up:
	RELAY_DOCKER_REPO=${AR_REPO} RELAY_DOCKER_VERSION=${VERSION} docker-compose up -d
logs:
	RELAY_DOCKER_REPO=${AR_REPO} RELAY_DOCKER_VERSION=${VERSION} docker-compose logs

refresh:
	$(MAKE) build
	$(MAKE) up

build:
	make build.app

build.app:
	docker build . -t ${AR_REPO}:${VERSION} -t ${AR_REPO}:${release_version}-latest -t ${DOCKERHUB_REPO}:rolling \
		--label "org.label-schema.build-date"="$(build_date)" \
		--label "org.label-schema.name"="Relay" \
		--label "org.label-schema.vendor"="Codecov" \
		--label "org.label-schema.version"="${release_version}-${sha}" \
		--label "org.vcs-branch"="$(branch)" \
		--build-arg COMMIT_SHA="${sha}" \
		--build-arg VERSION="${release_version}"

save.app:
	docker save -o app.tar ${AR_REPO}:${VERSION}

tag.rolling:
	docker tag ${AR_REPO}:${VERSION} ${DOCKERHUB_REPO}:rolling

push.rolling:
	docker push ${DOCKERHUB_REPO}:rolling

tag.release:
	docker tag ${AR_REPO}:${VERSION} ${DOCKERHUB_REPO}:${release_version}
	docker tag ${AR_REPO}:${VERSION} ${DOCKERHUB_REPO}:latest-stable
	docker tag ${AR_REPO}:${VERSION} ${DOCKERHUB_REPO}:latest-calver

push.release:
	docker push ${DOCKERHUB_REPO}:${release_version}
	docker push ${DOCKERHUB_REPO}:latest-stable
	docker push ${DOCKERHUB_REPO}:latest-calver

tag.production:
	docker tag ${AR_REPO}:${VERSION} ${AR_REPO}:production-${VERSION}
	docker tag ${AR_REPO}:${VERSION} ${AR_REPO}:production-latest

push.production:
	docker push ${AR_REPO}:production-${VERSION}
	docker push ${AR_REPO}:production-latest

tag.latest:
	docker tag ${AR_REPO}:${VERSION} ${AR_REPO}:latest

push.latest:
	docker push ${AR_REPO}:latest


helm.template: # Used to template helm
	@helm template --set relay.host=github.com codecov-relay-test --namespace codecov ./charts/codecov-relay --debug > template-chart.yaml

helm.lint: # Used to lint helm
	@ct lint --target-branch main --config ./.github/configs/ct-lint.yaml --lint-conf ./.github/configs/lintconf.yaml
