setup() {
    cd /work/tests/ubuntu
}

@test "Ubuntu builds" {
    vagga _build trusty
    link=$(readlink .vagga/trusty)
    [[ $link = ".roots/trusty.641967e7/root" ]]
}

@test "Ubuntu i386 builds" {
    vagga _build xenial-i386
    link=$(readlink .vagga/xenial-i386)
    [[ $link = ".roots/xenial-i386.58d98fb0/root" ]]
}

@test "Run echo command" {
    run vagga echo-cmd hello
    printf "%s\n" "${lines[@]}"
    [[ $status = 0 ]]
    [[ $output = hello ]]
    run vagga echo-cmd world
    printf "%s\n" "${lines[@]}"
    [[ $status = 0 ]]
    [[ $output = world ]]
}

@test "Run echo shell" {
    run vagga echo-shell
    printf "%s\n" "${lines[@]}"
    [[ $status = 0 ]]
    [[ $output = "" ]]
    run vagga echo-shell hello
    printf "%s\n" "${lines[@]}"
    [[ $status = 122 ]]
    [[ $output =~ "Unexpected argument" ]]
}

@test "Run echo shell with arguments" {
    run vagga echo-shell-arg
    printf "%s\n" "${lines[@]}"
    [[ $status = 0 ]]
    [[ $output = "" ]]
    run vagga echo-shell-arg hello
    printf "%s\n" "${lines[@]}"
    [[ $status = 0 ]]
    [[ $output = "hello" ]]
}

@test "Run absent command" {
    run vagga test something
    printf "%s\n" "${lines[@]}"
    [[ $status -eq 121 ]]
    [[ $output =~ "Command test not found." ]]
}

@test "Check arch support" {
    run vagga check-arch
    printf "%s\n" "${lines[@]}"
    [[ $status = 0 ]]
    [[ $output = i386 ]]
}

@test "Run trusty bc" {
    run vagga trusty-calc 100*24
    printf "%s\n" "${lines[@]}"
    [[ $status -eq 0 ]]
    [[ ${lines[${#lines[@]}-1]} = "2400" ]]
    link=$(readlink .vagga/trusty-calc)
    [[ $link = ".roots/trusty-calc.2b2c058e/root" ]]
}

@test "Run xenial bc" {
    run vagga xenial-calc 23*7+3
    printf "%s\n" "${lines[@]}"
    [[ $status -eq 0 ]]
    [[ ${lines[${#lines[@]}-1]} = "164" ]]
    link=$(readlink .vagga/xenial-calc)
    [[ $link = ".roots/xenial-calc.eacf2878/root" ]]
}

@test "Test VAGGAENV_* vars" {
    VAGGAENV_TESTVAR=testvalue run vagga _run trusty printenv TESTVAR
    [[ $status -eq 0 ]]
    [[ $output = testvalue ]]
}

@test "Test set env" {
    run vagga --environ TESTVAR=1value1 _run trusty printenv TESTVAR
    [[ $status -eq 0 ]]
    [[ $output = 1value1 ]]
}

@test "Test propagate env" {
    TESTVAR=2value2 run vagga --use-env TESTVAR _run trusty printenv TESTVAR
    [[ $status -eq 0 ]]
    [[ $output = 2value2 ]]
}

@test "The chfn just works (i.e. a no-op)" {
    run vagga rename-me
    [[ $status -eq 0 ]]
    [[ $output = "" ]]
}

@test "ubuntu: builddeps needed for other packages" {
    run vagga checkinstall -v
    printf "%s\n" "${lines[@]}"
    [[ $status -eq 0 ]]
    [[ $output != "" ]]
    link=$(readlink .vagga/dependency-conflict)
    [[ $link = ".roots/dependency-conflict.af32461f/root" ]]
}

@test "ubuntu: install from ppa" {
    run vagga _run ppa redis-cli --version
    printf "%s\n" "${lines[@]}"
    printf "Status: %d\n" "$status"
    [[ $status -eq 0 ]]
    [[ $output != "" ]]
    link=$(readlink .vagga/ppa)
    [[ $link = ".roots/ppa.73b33181/root" ]]
}
