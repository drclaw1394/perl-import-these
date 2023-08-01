# NAME

Import::These -  Terse, Prefixed, Multiple imports

# SYNOPSIS

Any name ending with :: is a prefix. Any later names in the list will use the
prefix, until the prefix is set or otherwise modified

```perl
#Instead of this:
#
use Plack::Middleware::Session;
use Plack::Middleware::Static;
use Plack::Middleware::Lint;

use IO::Compress::Gzip;
use IO::Compress::Gunzip;
use IO::Compress::Deflate;
use IO::Compress::Inflate;


# Do this
use Import::These qw<
  Plack::Middleware:: Session Static Lint
  IO::Compress::      Gzip GunZip Defalte Inflate
>;
```

Any name exactly equal to   :: clears the prefix,

```perl
use Import::These "Prefix::", "Mod", "::", "Prefix::Another";
# Prefix::Mod
# Prefix::Another;
```

A name beginning with :: and ending with :: appends the name to the prefix

```perl
use Import::These "Plack::", "test", "::Middleware::", "Lint";
# Plack::Test,
# Plack::Middleware::Lint;
```

Supports default, named/tagged, and no import 

```perl
# Instead of this:
#
# use File::Spec::Functions;
# use File::Spec::Functions "catfile";
# use File::Spec::Functions ();

# Do This:
#
use Import::These "File::Spec::", Functions, 
                                  Functions=>["catfile"],
                                  Functions=>[]
```

# DESCRIPTION

A tiny Importer module for importing multiple modules in one statement.
Supports using prefix notation to reduce the repetition in importing modules in
similar name spaces. The prefix can be set, cleared, or appended to multiple
times in a list making long lists of imports much easier to type!

It works with any package providing a `import` subroutine. It also is
compatible with recursive exporters such as [Export::These](https://metacpan.org/pod/Export%3A%3AThese) manipulating the
export levels.

# USAGE

The usage is as per the synopsis example.

# LIMITATIONS

# TODO

Better tests

# COMPARISON

[import](https://metacpan.org/pod/import) works by loading ALL packages under a common prefix. Whether you need
them or not.  That could be a lot of disk access and memory usage.

[modules](https://metacpan.org/pod/modules) has automatic module installation using CPAN. However no
prefix/wildcard support and uses **a lot** of ram for basic importing

# REPOSITOTY and BUGS

Please report and feature requests or bugs via the github repo:

[https://github.com/drclaw1394/perl-import-these.git](https://github.com/drclaw1394/perl-import-these.git)

# AUTHOR

Ruben Westerberg, <drclaw@mac.com>

# COPYRIGHT AND LICENSE

Copyright (C) 2023 by Ruben Westerberg

Licensed under MIT

# DISCLAIMER OF WARRANTIES

THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES,
INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS FOR A PARTICULAR PURPOSE.
