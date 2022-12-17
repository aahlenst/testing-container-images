import subprocess
import urllib.request

import docker
import pytest
import testinfra


# See https://docs.pytest.org/en/7.2.x/how-to/fixtures.html#fixture-scopes for
# supported scopes and their meaning.
@pytest.fixture(scope="session")
def client():
    return docker.from_env()


@pytest.fixture(scope="session")
def host(request, client):
    container = client.containers.run("myimage", detach=True, auto_remove=True,
        ports={'80/tcp': ('127.0.0.1', 8080)})

    # Return the Docker container as host to Testinfra.
    yield testinfra.get_host("docker://" + container.id)

    # Stop the container at the end of the test.
    container.stop()


def test_nginx_is_installed(host):
    nginx = host.package("nginx")
    assert nginx.is_installed


def test_nginx_workers_do_not_run_as_root(host):
    master = host.process.get(user="root", comm="nginx")
    workers = host.process.filter(ppid=master.pid, user="www-data")
    assert len(workers) >= 1


def test_nginx_says_welcome(host):
    with urllib.request.urlopen("http://localhost:8080/") as f:
        page_content = f.read().decode('utf-8')
        assert "Welcome to nginx!" in page_content


def test_container_exposes_http_only(host, client):
    image = client.images.get('myimage')
    exposed_ports = image.attrs['Config']['ExposedPorts'].keys()

    assert len(exposed_ports) == 1
    assert "80/tcp" in exposed_ports
