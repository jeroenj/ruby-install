. ./test/helper.sh

function setUp()
{
	patches=()
	configure_opts=()
	make_opts=()

	unset ruby
	unset ruby_version
	unset src_dir
	unset install_dir
}

function test_parse_options_with_no_arguments()
{
	parse_options >/dev/null 2>&1

	assertEquals "did not return 1" 1 $?
}

function test_parse_options_with_invalid_options()
{
	parse_options "--foo" "ruby" >/dev/null 2>&1

	assertEquals "did not return 1" 1 $?
}

function test_parse_options_with_one_argument()
{
	local expected="jruby"

	parse_options "$expected"

	assertEquals "did not set \$ruby" "$expected" "$ruby"
}

function test_parse_options_with_two_arguments()
{
	local expected_ruby="jruby"
	local expected_version="1.7.4"

	parse_options "$expected_ruby" "$expected_version"

	assertEquals "did not set \$ruby" "$expected_ruby" "$ruby"
	assertEquals "did not set \$ruby_version" "$expected_version" \
		     				  "$ruby_version"
}

function test_parse_options_with_more_than_two_arguments()
{
	parse_options "jruby" "1.7.4" "foo" >/dev/null 2>&1

	assertEquals "did not return 1" 1 $?
}

function test_parse_options_with_install_dir()
{
	local expected="/usr/local/"

	parse_options "--install-dir" "$expected" "ruby"

	assertEquals "did not set \$install_dir" "$expected" "$install_dir"
}

function test_parse_options_with_system()
{
	local expected="/usr/local"

	parse_options "--system"

	assertEquals "did not set \$install_dir to $expected" "$expected" \
		                                              "$install_dir"
}

function test_parse_options_with_src_dir()
{
	local expected="~/src/"

	parse_options "--src-dir" "$expected" "ruby"

	assertEquals "did not set \$src_dir" "$expected" "$src_dir"
}

function test_parse_options_with_jobs()
{
	local expected="--jobs"

	parse_options "$expected" "ruby"

	assertEquals "did not set \$make_opts" "$expected" "${make_opts[0]}"
}

function test_parse_options_with_jobs_and_arguments()
{
	local expected="--jobs=4"

	parse_options "$expected" "ruby"

	assertEquals "did not set \$make_opts" "$expected" "${make_opts[0]}"
}

function test_parse_options_with_patches()
{
	local expected=(patch1.diff patch2.diff)

	parse_options "--patch" "${expected[0]}" \
		      "--patch" "${expected[1]}" "ruby"

	assertEquals "did not set \$patches" $expected $patches
}

function test_parse_options_with_mirror()
{
	local mirror="http://www.mirrorservice.org/sites/ftp.ruby-lang.org/pub/ruby"

	parse_options "--mirror" "$mirror" "ruby"

	assertEquals "did not set \$ruby_mirror" "$mirror" "$ruby_mirror"
}

function test_parse_options_with_url()
{
	local url="http://mirror.s3.amazonaws.com/downloads/ruby-1.2.3.tar.gz"

	parse_options "--url" "$url" "ruby"

	assertEquals "did not set \$ruby_url" "$url" "$ruby_url"
}

function test_parse_options_with_md5()
{
	local md5="5d41402abc4b2a76b9719d911017c592"

	parse_options "--md5" "$md5" "ruby"

	assertEquals "did not set \$ruby_md5" "$md5" "$ruby_md5"
}

function test_parse_options_with_no_download()
{
	parse_options "--no-download" "ruby"

 	assertEquals "did not set \$no_download" 1 $no_download
}

function test_parse_options_with_no_verify()
{
	parse_options "--no-verify" "ruby"

 	assertEquals "did not set \$no_verify" 1 $no_verify
}

function test_parse_options_with_no_install_deps()
{
	parse_options "--no-install-deps" "ruby"

 	assertEquals "did not set \$no_install_deps" 1 $no_install_deps
}

function test_parse_options_with_no_reinstall()
{
	parse_options "--no-reinstall" "ruby"

	assertEquals "did not set to \$no_reinstall" 1 $no_reinstall
}

function test_parse_options_with_additional_options()
{
	local expected=(--enable-shared CFLAGS="-03")

	parse_options "ruby" "--" $expected

	assertEquals "did not set \$configure_opts" $expected $configure_opts
}

function test_parse_options_with_additional_options_with_spaces()
{
	parse_options "ruby" "--" --enable-shared CFLAGS="-march=auto -O2"

	assertEquals "did not word-split \$configure_opts correctly" \
          'CFLAGS=-march=auto -O2' "${configure_opts[1]}"
}

SHUNIT_PARENT=$0 . $SHUNIT2
