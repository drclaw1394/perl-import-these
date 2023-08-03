#use strict;
#use warnings;

use Test::More;

use Import::These;
our $res;

BEGIN {
  $res=eval { Import::These->import("v1000", "File::Spec::", "Functions", "v1.3", ["catfile"]) ; 1};
}

ok !$res, "Perl version check";
sleep 1;
done_testing;
