use strict;
use warnings;

use Test::More;

use Import::These "File::Spec::", "Functions", "v1.3", ["catfile"];

my $res=eval {cannonpath( "a") };

ok $@,  "Unlisted import";

$res=eval {catfile( "a","b","c") };
print STDERR $res;
sleep 1;

ok !$@,  "Listed import";
done_testing;
