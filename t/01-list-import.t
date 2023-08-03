use strict;
use warnings;

use Test::More;

use Import::These "File::Spec::Functions"=>["catfile"];

my $res=eval {cannonpath( "a") };

ok $@,  "Unlisted import";

$res=eval {catfile( "a","b","c") };

print $@ if $@;
ok !$@,  "Listed import";
done_testing;
