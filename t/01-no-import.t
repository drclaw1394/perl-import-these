use strict;
use warnings;

use Test::More;

use Import::These "File::Spec::Functions"=>[];
my $res=eval { catfile( "a","b","c") };

ok $@,  "No imports";

done_testing;
