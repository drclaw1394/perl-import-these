package Import::These;

use strict;
use warnings;


our $VERSION = 'v0.1.0';

my $marker=join "", map int rand 26, 1..16;
sub import {
  no strict "refs";

  my $package=shift;
  #my $target=$package eq __PACKAGE__ ? caller: $package;

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
  local $Exporter::ExportLevel=$Exporter::ExportLevel+1;
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
        $prev_mod=$mod;
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
  #$Exporter::ExportLevel=$prev;
}

__PACKAGE__;

=head1 NAME

Import::These -  Terse, Prefixed, Multiple imports

=head1 SYNOPSIS

Any name ending with :: is a prefix. Any later names in the list will use the
prefix, until the prefix is set or otherwise modified

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



Any name exactly equal to  :: clears the prefix,

  use Import::These "Prefix::", "Mod", "::", "Prefix::Another";
  # Prefix::Mod
  # Prefix::Another;


A name beginning with :: and ending with :: appends the name to the prefix

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


=head1 USAGE

The usage is as per the synopsis example.

=head1 LIMITATIONS


=head1 TODO

Possibly add module version support.


=head1 COMPARISON TO OTHER MODULES

L<use> gives the ability to specify Perl and Module versions which this modules
currently does not. However it doesn't support prefixes and uses more RAM.


L<import> works by loading ALL packages under a common prefix. Whether you need
them or not.  That could be a lot of disk access and memory usage.

L<modules> has automatic module installation using CPAN. However no
prefix/wildcard support and uses B<a lot> of RAM for basic importing


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
 

