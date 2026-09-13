use strict; use warnings; use JSON::PP; use utf8;
binmode STDOUT, ":utf8";
my ($datajs, $out) = @ARGV;

# Vegsystemreferanse-filter per prosjekt. undef = ikke relevant (ingen veg).
my %REF = (
  hordfast=>'EV39', bokn=>'EV39', gullkista=>'EV39', arna=>'EV16', vagsbotn=>'EV39',
  fjosanger=>'EV39', bybanen=>'EV39', floyfjell=>'EV39', sotra=>'RV555', storehaugen=>'EV39',
  vikafjellet=>'RV13', erdal=>'RV5', bogstunnelen=>'EV39', roldal=>'EV134', hylland=>'EV16',
  klakegg=>'EV39', strynefjellet=>'RV15', byrkjelo_grodas=>'EV39', rv13_djupevik=>'RV13', stad=>undef,
);
# Hvilken geometri bbox skal regnes fra (utelat anleggsbelte o.l.)
my %GEO = (
  hordfast=>['hordfast'], bokn=>['bokn'], gullkista=>['gullkista'], arna=>['arna_veg'],
  vagsbotn=>['vagsbotn'], fjosanger=>['fjosanger_arna'], bybanen=>['bybanen'], floyfjell=>['floyfjell'],
  sotra=>['sotra'], storehaugen=>['storehaugen'], vikafjellet=>['vikafjellet'], erdal=>['erdal'],
  bogstunnelen=>['bogstunnelen'], roldal=>['roldal'], hylland=>['hylland'], klakegg=>['klakegg'],
  strynefjellet=>['strynefjellet'], byrkjelo_grodas=>['byrkjelo_grodas'], rv13_djupevik=>['rv13_djupevik'],
);
my $BUF = 0.02; # ca 1–2 km buffer rundt traséen

my $js = do { open my $f,'<:raw',$datajs or die; local $/; <$f> };
$js =~ /window\.PROJ_GEO = (.*?);\n/s or die "fant ikke PROJ_GEO";
my $geo = JSON::PP->new->utf8->decode($1);

sub lines_of { my $g=shift;
  return $g->{type} eq 'MultiLineString' ? @{$g->{coordinates}}
       : $g->{type} eq 'LineString' ? ($g->{coordinates})
       : $g->{type} eq 'MultiPolygon' ? map { @$_ } @{$g->{coordinates}}
       : $g->{type} eq 'Polygon' ? @{$g->{coordinates}} : ();
}
sub bbox { my @keys=@_; my ($x0,$y0,$x1,$y1)=(999,999,-999,-999);
  for my $k (@keys) { my $g=$geo->{$k} or next;
    for my $l (lines_of($g)) { for my $c (@$l) { $x0=$c->[0] if $c->[0]<$x0; $x1=$c->[0] if $c->[0]>$x1; $y0=$c->[1] if $c->[1]<$y0; $y1=$c->[1] if $c->[1]>$y1 } } }
  return ($x0-$BUF, $y0-$BUF, $x1+$BUF, $y1+$BUF);
}

my %res;
for my $id (sort keys %REF) {
  my $ref = $REF{$id};
  unless (defined $ref) { $res{$id} = { na => 1 }; print "$id: ikke relevant\n"; next }
  my @b = bbox(@{$GEO{$id}});
  my $url = sprintf("https://nvdbapiles.atlas.vegvesen.no/vegobjekter/540?srid=4326&inkluder=egenskaper,lokasjon&antall=1000&kartutsnitt=%.4f,%.4f,%.4f,%.4f&vegsystemreferanse=%s", @b, $ref);
  my $tmp = "$out.tmp";
  system('curl','-s','-m','90','-H','X-Client: NHO-Vestland-kart','-H','Accept: application/json',$url,'-o',$tmp) == 0 or die "curl feilet for $id";
  my $d = eval { JSON::PP->new->utf8->decode(do { open my $f,'<:raw',$tmp or die; local $/; <$f> }) };
  unless ($d && $d->{objekter}) { print "$id: INGEN SVAR\n"; $res{$id}={na=>1}; next }
  my ($sw,$sl,$slw,$sll) = (0,0,0,0); my @segs; my %years;
  for my $x (@{$d->{objekter}}) {
    my %e = map { $_->{id} => $_->{verdi} } @{$x->{egenskaper}||[]};
    my $vs = $x->{lokasjon}{vegsystemreferanser}[0]{kortform} // '';
    # Bare hovedlinja: E/R-veg, delstrekning 1, og ingen kryssdel (KD) eller sideanlegg (SD) bak
    next unless $vs =~ /^[ER]V\d+ S\d+D1 m[\d-]+$/;
    my $len = $x->{lokasjon}{lengde} // 0;
    next unless defined $e{4623} && $len > 0;
    push @segs, { adt=>$e{4623}, len=>$len, vs=>$vs };
    $sw += $e{4623}*$len; $sl += $len;
    if (defined $e{4624}) { $slw += $e{4624}*$len; $sll += $len }
    $years{$e{4621}} += $len if defined $e{4621};
  }
  unless (@segs) { print "$id: ingen treff ($ref)\n"; $res{$id}={na=>1}; next }
  my ($year) = sort { $years{$b} <=> $years{$a} } keys %years;
  # Spenn beregnes over segmenter på minst 1 km, for å unngå korte stubber
  my @long = grep { $_->{len} >= 1000 } @segs; @long = @segs unless @long;
  my @sorted = sort { $a->{adt} <=> $b->{adt} } @long;
  $res{$id} = {
    adt   => int($sw/$sl + .5),
    min   => $sorted[0]{adt}, max => $sorted[-1]{adt},
    lange => $sll ? sprintf("%.0f", $slw/$sll) + 0 : undef,
    km    => sprintf("%.1f", $sl/1000) + 0,
    n     => scalar(@segs), ar => $year+0, ref => $ref,
  };
  printf "%-16s %-6s ÅDT %6d  (%d–%d)  lange %2s%%  %5.1f km  %2d segm  %s\n",
    $id, $ref, $res{$id}{adt}, $res{$id}{min}, $res{$id}{max}, $res{$id}{lange}//'-', $res{$id}{km}, $res{$id}{n}, $year;
  unlink $tmp;
}
open my $o,'>:encoding(UTF-8)',$out or die;
print $o "// Reserveverdier for ÅDT, hentet fra Statens vegvesens NVDB ".scalar(localtime)."\n";
print $o "// Kartet henter ferske tall fra API-et ved visning; disse brukes hvis API-et ikke svarer.\n";
print $o "window.ADT_FALLBACK = ", JSON::PP->new->canonical->encode(\%res), ";\n";
close $o;
print "\nskrev $out\n";
