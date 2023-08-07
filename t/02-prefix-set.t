use strict;
use warnings;

use lib "t/lib";
use Test::More;

use Import::These "IO::", "File", "::", "Import::", "::These::", "InternalTest"=>["default_sub"];

my $res=eval {unimported( "a") };

ok $@,  "Unlisted import";

$res=eval {default_sub};

ok !$@,  "Listed import";
ok $res==1, "Listed import";
done_testing;
