use strict;
use warnings;

use Test::More;

use Import::These "File::Spec::Functions"=>[];
use Import::These "File::Spec::", "Functions"=>["catfile"];
use Import::These feature=>["say"], "Plack::Middleware::", "Session", "Static";
use Import::These qw<Plack::Middleware:: Session Static Lint>;
use Import::These qw<Plack:: ::Middleware:: Session :: Plack::Middleware:: Static Lint>;
#print catfile "kjhasdf","dfsdf";
#say "hello";

ok 1;
done_testing;
