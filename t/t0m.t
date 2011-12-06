use strict;
use warnings;
use Test::More 0.88;

use Catalyst::Test 'ShinyCMS';

is request('/fileserver/auth/foo/sekrit2')->code, 403;
ok request('/fileserver/auth/foo/sekrit')->is_success;
is request('/fileserver/auth/foo/sekrit')->content, "blagh\n";
is request('/fileserver/auth/blargh/sekrit')->code, 404;
is request('/fileserver/auth/blargh/sekrit')->content, 'File not found.';

done_testing;

