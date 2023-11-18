# Codecov Relay
[![CI](https://github.com/codecov/relay/actions/workflows/ci.yml/badge.svg)](https://github.com/codecov/relay/actions/workflows/ci.yml)
[![Chart CI](https://github.com/codecov/relay/actions/workflows/chart-ci.yml/badge.svg)](https://github.com/codecov/relay/actions/workflows/chart-ci.yml)
## Purpose
Provide a relay for Codecov traffic. Meant to serve as a bridge between your code host and Codecov. This is designed to run in a container and can be deployed via Kubernetes/Helm.

Run the relay at the edge of your network to allow Codecov to send traffic to your internal network. This is useful for when you want to use Codecov but do not want to directly expose a service on your internal network to the internet.

## Usage

### Simple
Deploy and configure with the `RELAY_HOST` set to the host you want to send traffic to. Codecov will send your traffic to this relay via split DNS (most likely).

### Bidirectional
Configure `CODECOV_RELAY_ENABLED` and `CODECOV_HOST`. The relay will then send Codecov traffic as well. This is useful for when you want to use the relay to route traffic to a self hosted or Dedicated instance of Codecov. You will likely need to send Codecov traffic to the relay via split DNS.

Please contact your Codecov representative for more information.

## Configuration

* Note the only required configuration is `RELAY_HOST`. This must be set for proper operation.

| Environment Variable  | Default    | Description                                                                                            | Required |
|-----------------------|------------|--------------------------------------------------------------------------------------------------------|----------|
| CODECOV_BIND_PORT     | 8000       | IP that the relay binds to listen and forward traffic to Codecov                                       | false    |
| RELAY_BIND_PORT       | 8080       | IP that the relay binds to listen and forward traffic to internal services                             | false    |
| CODECOV_HOST          | codecov.io | Codecov host to forward traffic to. Typically you will want to change this.                            | false    |
| CODECOV_PORT          | 443        | Port to forward Codecov traffic on. This should be 443 in most cases.                                  | false    |
| RELAY_HOST            | null       | Host to forward relay traffic to. This is usually your code host or some other gateway.                | true     |
| RELAY_PORT            | 443        | Port to forward relay traffic on                                                                       | false    |
| CODECOV_RELAY_ENABLED | null       | When set, will enable the Codecov side of the relay. This is used when you need bidirectional routing. | false    |
| CHROOT_DISABLED       | null       | When set, will disable chroot on haproxy. This is used when your container env cannot support chroot.  | false    |
| HEALTH_CHECK_PORT     | 8100       | Port to respond to the health check on                                                                 | false    |


## Installation

Install the Codecov Helm Repo
```shell
helm repo add codecov https://helm.codecov.io
helm repo update
```

### Install
```shell
helm install --set relay.host=YOURHOST codecov-relay codecov/codecov-relay
```

### Upgrade

```shell
helm upgrade --reuse-values codecov-relay codecov/codecov-relay
```