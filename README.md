# relay


## Configuration

* Note the only required configuration is `RELAY_HOST`. This must be set for proper operation.

| Environment Variable          | Default    | Description                                                                                                       | Required |
|-------------------------------|------------|-------------------------------------------------------------------------------------------------------------------|----------|
| CODECOV_BIND_PORT             | 8000       | IP that the relay binds to listen and forward traffic to Codecov                                                  | false    |
| RELAY_BIND_PORT               | 8080       | IP that the relay binds to listen and forward traffic to internal services                                        | false    |
| CODECOV_HOST                  | codecov.io | Codecov host to forward traffic to. Typically you will want to change this.                                       | false    |
| RELAY_HOST                    | null       | Host to forward relay traffic to. This is usually your code host or some other gateway.                           | true     |
| RELAY_PORT                    | 443        | Port to forward relay traffic on                                                                                  | false    |
| CODECOV_RELAY_DISABLED        | null       | When set, will disable the Codecov side of the relay. This is used when you only need one way usage of the relay. | false    |
| CODECOV_RELAY_CHROOT_DISABLED | null       | When set, will disable chroot on haproxy. This is used when your container env cannot support chroot.             | false    |