function setup() {
    find /usr/local -name shelly | xargs rm -rf
}

@test "installer runs" {
    run /code/bin/install.sh 
    [ "$status" -eq 0 ]
    ls /usr/local/bin/shelly 
    [ "$status" -eq 0 ]
}

@test "test shelly command is available after installation" {
    run /code/bin/install.sh 
    run shelly 
    [ "$status" -eq 0 ]
    [ "$output" = "Usage: shelly command" ]
}
