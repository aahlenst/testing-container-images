setup_file() {
    CONTAINER_ID=$(docker run --rm -d -p 8080:80 myimage)
    export CONTAINER_ID
}

setup() {
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'
}

@test "nginx is installed" {
    run docker exec -i $CONTAINER_ID dpkg -s nginx
    assert_output -p 'Status: install ok installed'
}

@test "nginx workers do not run as root" {
    MASTER_PID=$(docker exec -i $CONTAINER_ID ps -ouser=,pid= -C nginx | awk '($1=="root"){print $2}')
    RESULT=$(docker exec -e MASTER_PID=$MASTER_PID -i $CONTAINER_ID bash -c 'ps -ouser= --ppid $MASTER_PID | uniq')
    assert_equal "$RESULT" "www-data"
}

@test "nginx says welcome" {
    run curl http://127.0.0.1:8080
    assert_output -p 'Welcome to nginx!'
}

@test "container exposes HTTP only" {
    IMAGE_CONFIG=$(docker image inspect myimage)

    run jq -j '.[0].Config.ExposedPorts | keys | length' <<< "$IMAGE_CONFIG"
    assert_output '1'

    run jq -j '.[0].Config.ExposedPorts | keys | .[0]' <<< "$IMAGE_CONFIG"
    assert_output '80/tcp'
}

teardown_file() {
    docker stop $CONTAINER_ID
}
