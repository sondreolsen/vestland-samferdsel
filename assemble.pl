use strict; use warnings;
# Bruk: perl assemble.pl template.html projects.js ut.html data.js adt.js
my ($tpl,$proj,$out,@data)=@ARGV;
die "Bruk: perl assemble.pl <template> <projects.js> <ut.html> <datafil> [datafil ...]\n" unless $out && @data;
sub slurp{ open my $f,'<:raw',$_[0] or die "$_[0]: $!"; local $/; my $c=<$f>; close $f; $c }
my $t=slurp($tpl); my $p=slurp($proj);
my $d=join "\n", map { slurp($_) } @data;
$t =~ s/<!--PROJECTS-->/$p/ or die "fant ikke <!--PROJECTS--> i malen";
$t =~ s/<!--DATA-->/<script>\n$d<\/script>/ or die "fant ikke <!--DATA--> i malen";
open my $o,'>:raw',$out or die; print $o $t; close $o;
print "skrev $out (", length($t), " bytes) fra ", scalar(@data), " datafiler\n";
