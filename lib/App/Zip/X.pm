package App::Zip::X;

use strict;
use warnings;

use Getopt::Long    qw(GetOptionsFromArray);
use Archive::Zip    qw(AZ_OK);
use XML::LibXML;

# integers to specify indentation modes -- see L<XML::LibXML>
use constant XML_NO_INDENT     => 0;
use constant XML_SIMPLE_INDENT => 1;

our $VERSION = '1.0';


sub run {
  my ($class, @args) = @_;

  my $self = bless {}, $class;

  GetOptionsFromArray \@args, $self,
    'unzip!',        # unzip mode (default)
    'zip!',          # zip mode
    'xml_indent!',   # handle indentation of XML extracted files (default)

    'archive=s',     # archive name (or first arg on command line)
    'member=s',      # member to extract (or second arg on command line)
  ;

  # other syntax : archive name and member name on command line without options
  $self->{archive} //= shift @args  or die "unspecified ZIP archive";
  $self->{member}  //= shift @args  or die "unspecified member to extract from $self->{zip}";

  # defaults and consistency check
  !($self->{zip} && $self->{unzip})    or die "options -zip and -unzip are mutually exclusive";
  $self->{unzip} //= 1 unless $self->{zip};

  # open ZIP archive
  $self->{zipper} = Archive::Zip->new;
  $self->{zipper}->read($self->{archive}) == AZ_OK
      or die "cannot open ZIP archive $self->{archive}";

  # decide what to do
  if    ($self->{unzip}) { $self->extract() }
  elsif ($self->{zip})   { $self->replace() }
  else                   { die "neither -zip nor -unzip .. not clear what you want to do"}

}



sub extract {
  my ($self) = @_;

  # get contents
  my $contents = $self->{zipper}->contents($self->{member})
    or die "no member named '$self->{member}' in $self->{archive}";

  # add XML indentation if necessary
  if ($self->{xml_indent} && ($self->{member} =~ /\.xml$/i || $contents =~ /^<\?xml/)) {
    my $dom   = XML::LibXML->load_xml(string => $contents);
    $contents = $dom->toString(XML_SIMPLE_INDENT); # already utf8-encoded 
  }

  # write on STDOUT
  binmode STDOUT, ':raw';
  print $contents;
}


sub replace {
  my ($self) = @_;

  # slurp file contents
  local $/;
  open my $fh, "<:raw", $self->{member} or die "open $self->{member}: $!";
  my $contents = <$fh>;
  close $fh;

  # remove XML indentation if necessary
  if ($self->{xml_indent} && ($self->{member} =~ /\.xml$/i || $contents =~ /^<\?xml/)) {
    my $dom   = XML::LibXML->load_xml(string => $contents);
    $contents = $dom->toString(XML_NO_INDENT);
  }

  # replace member in archive
  my $zipper = $self->{zipper};
  $zipper->removeMember($self->{member});
  $zipper->addString($contents, $self->{member});
  $zipper->overwrite;
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


