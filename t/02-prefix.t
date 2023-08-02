use strict;
use warnings;

use Test::More;

use Import::These "File::Spec::", "Functions"=>["catfile"];

my $res=eval {cannonpath( "a") };

ok $@,  "Unlisted import";

my $res=eval {catfile( "a","b","c") };

ok !$@,  "Listed import";
done_testing;
