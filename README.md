# Testing Container Images

This sample project shows how to test container images with different tools:

* [Bash Automated Testing System](https://bats-core.readthedocs.io/)
* [Goss](https://goss.rocks/)
* [Serverspec](https://serverspec.org/)
* [Testcontainers](https://www.testcontainers.org/) with [JBang](https://www.jbang.dev/)
* [Testinfra](https://testinfra.readthedocs.io/)

Each sample performs the same tests on `myimage` ([Dockerfile](docker/Dockerfile)), if supported:

* Testing that nginx is installed.
* Ensuring that nginx workers do not run as root.
* Testing that nginx is properly exposed and serves a welcome page by checking it on the host.
* Checking that the container only exposes port 80 by default by inspecting the image configuration. 

While the whole sample is obviously contrived, it gives a good idea of the capabilities of each tool and shows how to use them (see [workflows](.github/workflows/)).
