package App::Zip::X;

use strict;
use warnings;

use Getopt::Long    qw(GetOptionsFromArray);
use Archive::Zip    qw(AZ_OK);
use Encode;

use XML::LibXML;
use constant XML_SIMPLE_INDENT => 1;

our $VERSION = '1.0';

sub run {
  my ($class, @args) = @_;

  GetOptionsFromArray \@args, \my %opt,
    'zip=s',         # zip archive
    'member=s',      # member to extract
    'xml_indent!',   # want pretty indentation of XML extracted files
  ;

  $opt{zip}    //= shift @args  or die "unspecified ZIP file";
  $opt{member} //= shift @args  or die "unspecified member to extract from $opt{zip}";

  my $zip = Archive::Zip->new;
  $zip->read($opt{zip}) == AZ_OK
      or die "cannot open ZIP file $opt{zip}";

  my $contents = $zip->contents($opt{member})
      or die "no member named '$opt{member}' in $opt{zip}";

  if ($opt{xml_indent} && ($opt{member} =~ /\.xml$/i || $contents =~ /^<\?xml/)) {
    my $dom   = XML::LibXML->load_xml(string => $contents);
    $contents = $dom->toString(XML_SIMPLE_INDENT);
  }


  binmode STDOUT, ':raw';
  print $contents;

}


1; # End of App::Zip::X

__END__



=head1 NAME

App::Zip::X - Extract a single member of a ZIP archive, indent the XML, and print it on STDOUT

=head1 VERSION

Version 1.0

=head1 SYNOPSIS

See L<zip-x>

=head1 DESCRIPTION

See L<zip-x>


=head1 AUTHOR

DAMI, C<< <dami at cpan.org> >>

=head1 LICENSE AND COPYRIGHT

This software is Copyright (c) 2019 by DAMI.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)

=cut


