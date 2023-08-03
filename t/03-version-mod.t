use strict;
use warnings;

use Test::More;

use Import::These "File::Spec::", "Functions", "v1.3", ["catfile"];

my $res=eval {cannonpath( "a") };

ok $@,  "Unlisted import";

$res=eval {catfile( "a","b","c") };

ok !$@,  "Listed import";
done_testing;
