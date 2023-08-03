use strict;
use warnings;

use Test::More;

use Import::These "File::Spec::Functions";
eval {catfile "a","b","c"};

ok !$@,  "Default import";

done_testing;
