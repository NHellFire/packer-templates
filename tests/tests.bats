#!/usr/bin/env bats
if [ -z "$BOX" ]; then
	# shellcheck disable=SC2016
	echo 'Tests must be ran with `make test`'
	exit 1
fi

ubuntu_codename=${BOX%%-*}

BOXNAME="test-$(date +%Y%m%d)-$BOX"
BOXPATH="$BATS_TEST_DIRNAME/../output/$BOX.box"
skip_tests=
if [ ! -s "$BOXPATH" ]; then
	skip_tests="Box not built"
fi

cd "$TESTDIR" || exit $?

_ssh() {
	# shellcheck disable=SC2029
	ssh -F "$BATS_TMPDIR/ssh-config" default "$@"
}

@test "Import vagrant box" {
	if [ -n "$skip_tests" ]; then
		skip "$skip_tests"
	fi

	run vagrant box add --force --provider "libvirt" --name "$BOXNAME" "$BOXPATH"
	echo "$output" >&2
	[ $status -eq 0 ]
}

@test "Create Vagrantfile" {
	if [ -n "$skip_tests" ]; then
		skip "$skip_tests"
	fi

	run vagrant init "$BOXNAME"
	[ $status -eq 0 ]
}

@test "Boot vagrant box" {
	if [ -n "$skip_tests" ]; then
		skip "$skip_tests"
	fi

	run vagrant up
	echo "$output"
	[ $status -eq 0 ]
}

@test "Get SSH config" {
	if [ -n "$skip_tests" ]; then
		skip "$skip_tests"
	fi

	vagrant ssh-config > "$BATS_TMPDIR/ssh-config" 2>/dev/null
}

@test "Check Ubuntu version" {
	if [ -n "$skip_tests" ]; then
		skip "$skip_tests"
	fi

	run _ssh 'lsb_release --short --codename'

	[ $status -eq 0 ]
	[ "${lines[-1]}" = "$ubuntu_codename" ]
}

@test "Check GCC is functional" {
	if [ -n "$skip_tests" ]; then
		skip "$skip_tests"
	fi

	run _ssh "cat > hello.c" <<'EOF'
#include <stdio.h>
void main() { printf("Hello World\n"); }
EOF
	[ $status -eq 0 ]

	run _ssh "gcc hello.c -o hello"
	[ $status -eq 0 ]

	run _ssh "./hello"
	[ "$output" = "Hello World" ]
}


@test "Destroy vagrant box" {
	if [ -n "$skip_tests" ]; then
		skip "$skip_tests"
	fi

	run vagrant destroy
	rm -f Vagrantfile
	rm -f "$BATS_TMPDIR/ssh-config"

	[ $status -eq 0 ]

	volume=$(virsh vol-list default | awk "/$BOXNAME"'_vagrant_box_image_0.img/ {print $2}')
	if [ -n "$volume" ]; then
		run virsh vol-delete "$volume"
		[ $status -eq 0 ]
	fi
}


@test "Remove box from vagrant" {
	if [ -n "$skip_tests" ]; then
		skip "$skip_tests"
	fi

	run vagrant box remove --force --provider "libvirt" "$BOXNAME"
	[ $status -eq 0 ]
}
