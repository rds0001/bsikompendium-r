# bsikompendium 0.2.0

Native Offline-Prüfungen für BSI IT-Grundschutz: **1.835 aktive Anforderungen**,
**111 individuelle Bausteinmodellierungen** und **83 Methodenschritte** nach
BSI 200-1/200-2/200-3 sind implementiert und auf Bereichsebene unabhängig gegen
Quellen geprüft. Paket- und CRAN-Prüfergebnisse werden im versionierten Abnahmebericht des
Projekts geführt. Keine Veröffentlichung oder CRAN-Einreichung ist erfolgt. R ab 4.1 mit `jsonlite`; keine Python-Laufzeit erforderlich.

## Lokal installieren und prüfen

Nach Bereitstellung von `jsonlite`, aus dem übergeordneten Verzeichnis:

```sh
R CMD INSTALL bsikompendium-r
```

```r
library(bsikompendium)
vertrag <- fachlicher_eingabevertrag("ORP.3.A6")
befund <- pruefe_fachregel("ORP.3.A6", list(
  mitarbeitende=list(vollstaendig=TRUE, objekte=list(
    list(geschult_aufgaben=TRUE, geschult_verantwortung=FALSE)))))
stopifnot(befund$befund == "TEILWEISE_ERFUELLT")
stopifnot(identical(befund$bekannte_maengel, list("ORP.3.A6.K2")))
```

Die Tatsachen beziehen sich auf Schulungsinhalt, Aufgaben und Verantwortung der
konkreten Mitarbeitenden. Die Library berechnet den Befund aus den Einzelpflichten;
ein pauschales Nutzer-Endurteil wird nicht verlangt. Felddefinitionen nennen
Nachweisgegenstand und gegebenenfalls fachlichen Bewertungsmaßstab.

## Modellierung, Methodik und Risiko

`methodenschritte()` liefert 194 IDs: 111 `BSIMODELL.*`-Modelle und 83 Schritte
der Standards `BSI2001.*`, `BSI2002.*`, `BSI2003.*`.
`methodischer_eingabevertrag(id)` beschreibt ihre Eingaben;
`pruefe_methodenschritt(id, angaben)` prüft sie nativ in R.
`bewerte_risiko()` schlägt Häufigkeit und Schaden in der ausdrücklich gewählten
Matrix nach. Die mitgelieferte BSI-Beispielmatrix ist keine allgemeine Vorgabe
für jede Institution. `pruefe_risikoverlauf()` verbindet die Berechnung mit
tatsächlicher bzw. erst geplanter Risikobehandlung.

Das installierte Beispiel `individueller_pruefablauf` verbindet
Fahrzeugmodellierung, Analysebedarf, Matrixeinstufung und die konkrete
Diebstahlschutzpflicht `INF.11.A12`:

```r
source(system.file("examples", "individueller_pruefablauf.R",
                   package="bsikompendium"))
```

Alternativ aus dem Paketquellverzeichnis, mit optionalem eigenen JSON-Pfad:

```sh
Rscript inst/examples/individueller_pruefablauf.R inst/examples/individueller_pruefablauf.json
```

Die Eingabe ist identisch zum Python-Beispiel. Erwartet werden erfüllte
Modellierung, erforderliche zusätzliche Risikoanalyse, Risikokategorie `HOCH`
und teilweise erfüllte Fachpflicht mit Mangel `INF.11.A12.K1`. Das ist eine
ausgewählte Prüfung, kein Gesamturteil über die Fahrzeugsicherheit.

## Daten und Grenzen

JSON mit `jsonlite::fromJSON(pfad, simplifyVector=FALSE)` laden. Objekte sind
benannte Listen, Arrays unbenannte Listen. `NULL`, logisches `NA` oder fehlende
Angaben bedeuten unbekannt; `FALSE` ist ein bekannter falscher Sachverhalt.
Objektmengen enthalten `objekte` und die ausdrückliche Angabe `vollstaendig`.
Bekannte Mängel bleiben auch bei weiteren unbekannten Angaben sichtbar.
Ungültige Daten lösen eine Condition `bsikompendium_eingabefehler` mit
`code="EINGABE_UNGUELTIG"` aus.

Nach Installation sind die ausführlichen Dokumente verfügbar über:

```r
system.file("doc", "FACHLOGIK.md", package="bsikompendium")
system.file("doc", "API.md", package="bsikompendium")
```

`eingabevertrag()` und `pruefe_anforderung()` sind **Legacy-Funktionen** für
Absatz-Selbstauskünfte. Das alte Beispiel `kundenportal` verwendet diesen Ablauf;
es gehört nicht zur individuellen Anforderungsabdeckung von 0.2.
Spezialisierte Teilprüfungen ersetzen ebenfalls keine vollständige Fachregel.

Quellenstand: Kompendium 2023 mit Errata vom 26.03.2026; BSI-Standards
200-1/200-2/200-3 jeweils Version 1.0 und dokumentierte ergänzende Verweise.
Die Library läuft ohne Netzbetrieb oder Telemetrie, liest keine Nachweisdateien
und schreibt keine Nutzerdaten. Die Beispielprogramme lesen ausdrücklich ihre
JSON-Eingabe. Ein positiver Befund beruht auf den erhobenen Tatsachen und ist
keine BSI-Zertifizierung.

Lizenz: Apache-2.0. Copyright RiskDataScience GmbH.
Maintainer: Dr. Dimitrios Geromichalos, riskdatascience@web.de.
