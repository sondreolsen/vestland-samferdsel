use strict; use warnings;
my ($tpl,$proj,$data,$out)=@ARGV;
sub slurp{ open my $f,'<:raw',$_[0] or die "$_[0]: $!"; local $/; my $c=<$f>; close $f; $c }
my $t=slurp($tpl); my $p=slurp($proj); my $d=slurp($data);
$t =~ s/<!--PROJECTS-->/$p/ or die "no PROJECTS placeholder";
$t =~ s/<!--DATA-->/<script>\n$d<\/script>/ or die "no DATA placeholder";
open my $o,'>:raw',$out or die; print $o $t; close $o;
print "wrote $out (", length($t), " bytes)\n";
