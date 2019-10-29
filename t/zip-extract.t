use strict;
use warnings;
use Test::More;

use lib "../lib";
use App::Zip::Extract;

diag( "Testing App::Zip::Extract $App::Zip::Extract::VERSION, Perl $], $^X" );


# path to the docx file
(my $docx = $0) =~ s[zip-extract\.t$][etc/zip-extract.docx];


# run, capturing STDOUT
close STDOUT;
open STDOUT, ">", \my $capture_stdout
  or die "could not redirect STDOUT: $!" ;
App::Zip::Extract->run("-x", -zip => $docx, -member => "word/document.xml");


# just 3 very simple tests
like $capture_stdout, qr/^<\?xml/,      "is XML content";
like $capture_stdout, qr/^  <w:body>/m, "is indented";
like $capture_stdout, qr/^    <w:p/m,  "is really indented";

# that's it
done_testing();
