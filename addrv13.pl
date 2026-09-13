use strict; use warnings; use JSON::PP; use utf8;
binmode STDOUT, ":encoding(UTF-8)";
my ($osm, $datajs, $geodir) = @ARGV;
my $J = JSON::PP->new->utf8;
sub slurp { open my $f,'<:raw',$_[0] or die "$_[0]: $!"; local $/; my $c=<$f>; close $f; $c }

# Rekkefølge sør→nord: Djupevik → anleggsstrekning → Kviturtunnelen sørportal
my @ORDER = (1391319043, 1391319040, 1391319041, 1391319038, 1391319039, 1391319036, 1391319037, 1391319033, 679132685);
my %BYGG  = map { $_ => 1 } (1391319043, 1391319040, 1391319041, 1391319038, 1391319039, 1391319036, 1391319037, 1391319033);

my $d = $J->decode(slurp($osm));
my %w = map { $_->{id} => $_ } grep { $_->{type} eq 'way' } @{$d->{elements}};

my (@coords, $prev);
for my $id (@ORDER) {
  my $way = $w{$id} or die "mangler way $id";
  for my $p (@{$way->{geometry}}) {
    my $c = [ 0+sprintf("%.5f",$p->{lon}), 0+sprintf("%.5f",$p->{lat}) ];
    next if $prev && $prev->[0] == $c->[0] && $prev->[1] == $c->[1];
    push @coords, $c; $prev = $c;
  }
}
# Lengde langs linja
my $len = 0;
for my $i (1..$#coords) {
  my $dx = ($coords[$i][0]-$coords[$i-1][0]) * cos(60.08*3.14159265/180) * 111.32;
  my $dy = ($coords[$i][1]-$coords[$i-1][1]) * 111.32;
  $len += sqrt($dx*$dx + $dy*$dy);
}
printf "rv13_djupevik: %d punkt, %.2f km, fra %.4f,%.4f til %.4f,%.4f\n",
  scalar(@coords), $len, $coords[0][1], $coords[0][0], $coords[-1][1], $coords[-1][0];

my $geom = { type=>'MultiLineString', coordinates=>[ \@coords ] };
my $kilde = 'OpenStreetMap: anleggsstrekninga på rv 13 (highway=construction) frå Djupevik, forlenga til sørportalen på Kviturtunnelen';

# geodata-fil
open my $g, '>:raw', "$geodir/rv13_djupevik.geojson" or die;
print $g JSON::PP->new->canonical->encode({ type=>'FeatureCollection', features=>[
  { type=>'Feature', properties=>{ id=>'rv13_djupevik', kilde=>$kilde }, geometry=>$geom } ] });
close $g;

# legg inn i data.js
my $js = slurp($datajs);
my $gj = JSON::PP->new->canonical->encode($geom);
my $sj = JSON::PP->new->canonical->encode($kilde);
die "rv13_djupevik finst alt i data.js\n" if $js =~ /"rv13_djupevik"/;
$js =~ s/(window\.PROJ_GEO = \{)/$1"rv13_djupevik":$gj,/ or die "fann ikkje PROJ_GEO";
$js =~ s/(window\.GEO_SRC = \{)/$1"rv13_djupevik":$sj,/ or die "fann ikkje GEO_SRC";
open my $o, '>:raw', $datajs or die; print $o $js; close $o;
print "la rv13_djupevik inn i data.js og geodata/\n";
