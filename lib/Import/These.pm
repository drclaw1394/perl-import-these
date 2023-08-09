package Import::These;

use strict;
use warnings;


our $VERSION = 'v0.1.0';

# Marker is pushed to end of argument list to aid in processing.
# Make random to prevent collisions.
#
my $marker=join "", map int rand 26, 1..16;


sub import {
  no strict "refs";

  my $package=shift;

  my $prefix="";
  my $k;
  my $version;
  my $mod;
  my $prev_mod;
  my $list;

  my $execute;

  push @_, $marker;
  

  # Force export level to look at this subs caller, not this sub. But do it in a
  # relative way to allow support for recursive importing
  #
  local $Exporter::ExportLevel=($Exporter::ExportLevel||0)+1;
  my $i=0;
  while(@_){
    $k=shift;

    # Check if the next item is a ref,  or a scalar
    #
    my $r=ref $k;
    if($r eq "ARRAY"){
      $list=$k;
      $prev_mod=$mod if $mod; #version may have already shift this
      $mod=undef;
      $execute=1;
    }
    elsif($r eq ""){
      if($k eq $marker){
        # End processing if we hit the marker
        $prev_mod=$mod if $mod;
        $execute=!!$prev_mod;
      }
      elsif($k eq "::"){
        # Exact. Clear prefix
        $prefix="";
        $prev_mod=$mod;
        $mod=undef;
      }
      elsif($k =~ /^::.*?::$/){
        # Double ended. Append new portion to prefix
        $prefix.=substr $k, 2;
        $prev_mod=$mod;
        $mod=undef;
      }
      elsif($k =~/::$/){
        # At end. Update prefix
        $prefix=$k;
        $prev_mod=$mod;
        $mod=undef;
      }
      elsif($k =~ /^v|^\d/){
        # Test if it looks like a version. 
        unless($i){
          # Actually a perl version
          eval "use $k";
          die $@ if $@;
          next;
        }
        else {
          $version=$k;
          $prev_mod=$mod;
          $mod=undef;
        }
      }
      else {
        # Module name
        $prev_mod=$mod;
        $mod=$k;
        $execute=!!$prev_mod;
      }
    }
    else {
      die "Scalar or array ref only";
    }

    # Attempt to execute/load what we have
    
    
    if($execute){
      #DEBUG
      my @caller=caller $Exporter::ExportLevel;
      if($prev_mod){
        eval "require $prefix$prev_mod;";
        die "Could not require $prefix$prev_mod: $@" if $@;
      }

      if($version){
        "$prefix$prev_mod"->VERSION($version);
      }

      if($list and @$list){
        # List import
        "$prefix$prev_mod"->import(@$list);
      }
      elsif($list and @$list ==0){
        # no not import
      }
      else {
        # Default import
        "$prefix$prev_mod"->import();
      }
      $prev_mod=undef;
      $list=undef;
      $version=undef;
    }
    $i++;
  }
}

__PACKAGE__;

=head1 NAME

Import::These -  Terse, Prefixed and Multiple Imports with a Single Statement

=head1 SYNOPSIS

Any item ending with :: is a prefix. Any later items in the list will use the
prefix to create the full package name: 

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



Any item is exactly equal to  ::, the prefix is cleared: 

  use Import::These "Prefix::", "Mod", "::", "Prefix::Another";
  # Prefix::Mod
  # Prefix::Another;


A item beginning with :: and ending with :: appends the item to the prefix:

  use Import::These "Plack::", "test", "::Middleware::", "Lint";
  # Plack::Test,
  # Plack::Middleware::Lint;


Supports default, named/tagged, and no import 

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



=head1 DESCRIPTION

A tiny Importer module for importing multiple modules in one statement.
Supports using prefix notation to reduce the repetition in importing modules in
similar name spaces. The prefix can be set, cleared, or appended to multiple
times in a list making long lists of imports much easier to type!

It works with any package providing a C<import> subroutine. It also is
compatible with recursive exporters such as L<Export::These> manipulating the
export levels.


=head1 USAGE EXAMPLES

=head2 Simple Prefix

A single prefix used for  multiple packages:

  use Import::These qw<IO::Compress:: Gzip GunZip Defalte Inflate >;

  # Equivalent to:
  # use IO::Compress::Gzip
  # use IO::Compress::GunZip
  # use IO::Compress::Deflate
  # use IO::Compress::Inflate

=head2 Appending Prefix

Prefix is appended along the way:

  use Import::These qw<IO:: File ::Compress:: Gzip GunZip Defalte Inflate >;
  
  # Equivalent to:
  # use IO::File
  # use IO::Compress::Gzip
  # use IO::Compress::GunZip
  # use IO::Compress::Deflate
  # use IO::Compress::Inflate

=head2 Reset Prefix

Completely change (reset) prefix to something else:

  use Import::These qw<File::Spec Functions :: Compress:: Gzip GunZip Defalte Inflate >;

  # Equivalent to: 
  # use File::Spec::Functions
  # use IO::Compress::Gzip
  # use IO::Compress::GunZip
  # use IO::Compress::Deflate
  # use IO::Compress::Inflate


=head2 No Default Import

  use Import::These "File::Spec", "Functions"=>[];

  # Equivalent to:
  # use File::Spec::Functions ();
  
=head2 Import names/groups

  use Import::These "File::Spec", "Functions"=>["catfile"];

  # Equivalent to:
  # use File::Spec::Functions ("catfile");


=head2 With Perl Version

  use Import::These "v5.36", "File::Spec::", "Functions";

  # Equivalent to:
  # use v5.36;
  # use File::Spec::Functions;

=head2 With Module Version

  use Import::These "File::Spec::", "Functions", "v1.2";

  # Equivalent to:
  # use File::Spec::Functions v1.2;


=head2 All Together Now

  use Import::These qw<v5.36 File:: IO ::Spec:: Functions v1.2>, ["catfile"],  qw<:: IO::Compress:: Gzip GunZip Deflate Inflate>;

  # Equivalent to:
  # use v5.36;
  # use File::IO;
  # use File::Spec::Functions v1.2 "catfile"
  # use IO::Compress::Gzip;
  # use IO::Compress::GunZip;
  # use IO::Compress::Deflate;
  # use IO::Compress::Inflate;


=head1 COMPARISON TO OTHER MODULES

L<use> gives the ability to specify Perl and Module versions which this modules
currently does not. However it doesn't support prefixes and uses more RAM.


L<import> works by loading ALL packages under a common prefix. Whether you need
them or not.  That could be a lot of disk access and memory usage.

L<modules> has automatic module installation using CLAN. However no
prefix / wildcard support and uses B<a lot> of RAM for basic importing

L<Importer> has some nice features but not a 'simple' package prefix. It also
looks like it only handles a single package per invocation, which doesn't
address importing modules with a single statment.

=head1 REPOSITOTY and BUGS

Please report and feature requests or bugs via the github repo:

L<https://github.com/drclaw1394/perl-import-these.git>

=head1 AUTHOR

Ruben Westerberg, E<lt>drclaw@mac.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2023 by Ruben Westerberg

Licensed under MIT

=head1 DISCLAIMER OF WARRANTIES

THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES,
INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS FOR A PARTICULAR PURPOSE.

=cut
 

