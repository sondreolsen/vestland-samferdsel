# Samferdselsprosjekter i Vestland – interaktivt kart

Åpne `vestland_samferdselskart.html` i en nettleser (dobbeltklikk). Filen er selvstendig: all geometri og alle prosjektfakta ligger inne i filen. Bakgrunnskart (Kartverket/OpenStreetMap) og Leaflet-biblioteket lastes fra nett, så du trenger internett.

## Innhold

| Fil / mappe | Hva |
|---|---|
| `vestland_samferdselskart.html` | Kartet. Prosjektfakta ligger i `PROJECTS`-lista øverst i `<script>`-delen og kan redigeres direkte. |
| `data.js` | Samme geometri som ligger inne i HTML-filen, som egen fil (GeoJSON i WGS84). Genereres av byggeskriptet. |
| `geodata/*.geojson` | Én GeoJSON-fil per prosjekt, pluss fylkesgrensen for Vestland. Kan åpnes i QGIS, ArcGIS, geojson.io osv. |
| `hordfast_simplified.geojson`, `e39_bokn_bomlafjorden_alt1_simplified.geojson` | Dine opprinnelige filer. Bokn-linja brukes i kartet; Hordfast er erstattet av Statens vegvesens offisielle linje. |

## Geometrikilder (kvalitet)

**Offisiell geometri fra Statens vegvesen (ArcGIS FeatureServer, NTP 2025–2036 prosjektportefølje):**
E39 Ådland–Svegatjørn (Hordfast), E39 Vågsbotn–Klauvaneset, E39 Storehaugen–Førde, E134 Røldal–Seljestad, E16 Hylland–Slæen, E39 Klakegg–Byrkjelo, E16 Arna–Stanghelle (veg), E39 Fløyfjelltunnelen, Rv 555 Sotrasambandet.
Endepunkt: `https://services-eu1.arcgis.com/Omqj1DhF7kfdN8lE/ArcGIS/rest/services/NTP_2025_2036_Prosjektportefolje_View/FeatureServer/0` og `.../NTP_Prosjekt_Dashboard/FeatureServer/0` (sistnevnte har også kostnad, netto nytte og reisetidsendring per prosjekt).

**Offisielt anleggsbelte (80 m) for E39 Bokn–Bømlafjorden alternativ 1:**
`https://services3.arcgis.com/NqGokVvI0NQ6O9Jf/arcgis/rest/services/E39B_BF_Anleggsbelte_Tiltaksomr_Alternativ1/FeatureServer/0`

**OpenStreetMap (planlagte traséer tegnet av OSM-bidragsytere etter plankart):**
Vossebanen Arna–Stanghelle (dobbeltspor), Bybanen til Åsane, Rv 5 Erdal–Naustdal, E39 Bogstunnelen–Gaular grense, E39 Byrkjelo–Grodås, Stad skipstunnel, nordre del av Rv 13 Vikafjellstunnelen, dagens E39 ved Gullkista.

**Skisser (omtrentlige, ingen vedtatt trasé):**
E39 Ringveg øst Fjøsanger–Arna, Rv 15 Strynefjellet (KVU-konsept B1), tunnelen på Rv 13 Vikafjellet (Hola–Bøadalen).

## Tallkilder

Kostnad, statlig andel, bompenger, lengde, reisetid og netto nytte er hentet fra stortingsproposisjoner (Prop. 97 S 2024–2025 Arna–Stanghelle, Prop. 44 S 2023–2024 Røldal–Seljestad, Prop. 41 S 2017–2018 Sotrasambandet, Prop. 228 S 2020–2021 Hordfast), NTP 2025–2036 (Meld. St. 14 (2023–2024)), Statens vegvesens planomtaler og porteføljeprioritering (mai 2025), Kystverket og NRK. Lenker ligger under «Kilder» i hvert prosjekt i kartet. Prisår er oppgitt der det er kjent; tallene er ikke omregnet til felles prisnivå.

Ikke funnet: bompengeandel for Hordfast i 2026-planen og for Bokn–Bømlafjorden (ikke fastsatt), netto nytte for Bybanen, Hylland–Slæen, Klakegg–Byrkjelo, Gullkista og Bogstunnelen, kostnad for Fjøsanger–Arna og Klakegg–Byrkjelo.

## Oppdatere

Redigér `PROJECTS` i HTML-filen for å endre tekst og tall. For ny geometri: legg en GeoJSON-fil i `geodata/`, lim geometrien inn i `window.PROJ_GEO` i HTML-filen (eller i `data.js`) med en nøkkel, og legg nøkkelen i `geo:[...]` for prosjektet.
