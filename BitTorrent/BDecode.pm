# - Based on vesion 0.1.0.3-BETA of TorrentSpy from http://torrentspy.sf.net/
#   Original copyright unknown, SourceForge claims "MIT License"

package BitTorrent::BDecode;
use Carp;
use base 'Exporter';
use strict;
our @EXPORT_OK = qw(bdecode);

sub bdecode {
  my ($dataref) = @_;
  unless(ref($dataref) eq 'SCALAR') {
    die('Function bdecode takes a scalar ref!');
  } # unless
  my $p = 0;
  return benc_parse_hash($dataref,\$p);
} # sub bdecode

sub benc_parse_hash {
  my ($data, $p) = @_;
  my $c = substr($$data,$$p,1);
  my $r = undef;
  if($c eq 'd') { # hash
#    print "Found a hash\n";
    %{$r} = ();
    ++$$p;
    while(($$p < length($$data)) && (substr($$data, $$p, 1) ne 'e')) {
      my $k = benc_parse_string($data, $p);
      my $start = $$p;
      $r->{'_' . $k . '_start'} = $$p if($k eq 'info');
      my $v = benc_parse_hash($data, $p);
      $r->{'_' . $k . '_length'} = ($$p - $start)  if($k eq 'info');
#      print "\t{$k} => $v\n";
      $r->{$k} = $v;
    } # while
    ++$$p;
#    print "End of Hash\n";
  } elsif($c eq 'l') { # list
    @{$r} = \();
    ++$$p;
#    print "Found a list\n";
    while(substr($$data, $$p, 1) ne 'e') {
      push(@{$r},benc_parse_hash($data, $p));
#      print "\t[@{$r}] = $$r[-1]\n";
    } # while
    ++$$p;
  } elsif($c eq 'i') { # number
    $r = 0;
    my $c;
    ++$$p;
    while(($c = substr($$data,$$p,1)) ne 'e') {
      $r *= 10;
      $r += int($c);
      ++$$p;
    }  # while
    ++$$p;
#    print "Found an int: $r\n";
  } elsif($c =~ /\d/) { # string
    $r = benc_parse_string($data, $p);
#    print "Found a string: ", length($r), "\n";
  } else {
    die("Unknown token '$c' at $p!");
  } # case
  return $r;
} # benc_parse

sub benc_parse_string {
  my ($data, $p) = @_;
  my $l = 0;
  my $c = undef;
  my $s;
  while(($c = substr($$data,$$p,1)) ne ':') {
#    print "Char: $c, ", int($c), "\n";
    $l *= 10;
    $l += int($c);
    ++$$p;
  }  # while
  ++$$p;
#  print "Length: $l\n";
  $s = substr($$data,$$p,$l);
  $$p += $l;
#  print "Returning length $l = ", length($s), " ($s)\n";
  return $s;
} # benc_parse_string


1;
