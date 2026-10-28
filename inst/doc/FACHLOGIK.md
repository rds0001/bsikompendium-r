# Individuelle Fachprüfung

Version 0.2.0 enthält individuell hergeleitete Verträge für alle **1.835 aktiven
Kompendium-Anforderungen**, **111 Bausteinmodellierungen** und **83 Methodenschritte**
aus BSI 200-1, 200-2 und 200-3. Quellenstand ist Kompendium Edition 2023 mit Errata
vom 26.03.2026 sowie die drei Standards jeweils Version 1.0. Die fachlichen
Bereichsumsetzungen und unabhängigen Quellenreviews sind abgeschlossen;
Paket- und CRAN-Prüfergebnisse werden separat im versionierten
Abnahmebericht des Projekts geführt; Veröffentlichung und CRAN-Einreichung
sind nicht erfolgt.

`fachlicher_eingabevertrag(anforderung_id)` liefert den individuellen Vertrag;
`pruefe_fachregel(anforderung_id, angaben)` wertet dessen Einzelkriterien nativ
aus. Die Runtime ersetzt fehlende Verträge grundsätzlich nicht durch generische
Erfüllung. Entfallene Katalogeinträge sind keine aktiven Prüfpflichten.

## Einen Prüfablauf zusammenstellen

1. Den tatsächlichen Informationsverbund und seine Zielobjekte erheben.
2. Passende individuelle Modellierungen mit `BSIMODELL.*` prüfen. Die dadurch
   benannten weiteren Bausteine können zusätzliche Modellierungsregeln auslösen.
3. Für relevante Anforderungen den Eingabevertrag lesen und konkrete Tatsachen,
   Nachweise sowie eng abgegrenzte fachliche Prämissen erheben. Mit
   `pruefe_fachregel()` die Einzelpflichten und bekannten Mängel auswerten.
4. Die Durchführung und Dokumentation des Grundschutz-Checks mit den passenden
   BSI-200-2-Verträgen prüfen. `pruefe_checkabdeckung()` gleicht Zielobjekte und
   erforderliche Prüfstatus gegen den Katalog ab.
5. Analysebedarf, Risikomatrix und Behandlung ausdrücklich festlegen. Berechnete
   Risikokategorien, geplante Maßnahmen und tatsächlich umgesetzte Behandlung
   getrennt ausweisen; `pruefe_risikoverlauf()` verbindet diese Prüfungen.

Diese Funktionen erzeugen kein automatisches Gesamtzertifikat. Aufgabenspezifisch
werden die benötigten Ergebnisse und Nachweise zusammengeführt. Eine passende
Modellierung oder korrekt begründete Checkentscheidung kann erfüllt sein, während
eine einzelne Sicherheitsanforderung weiterhin einen Mangel aufweist.

Das Beispiel `individueller_pruefablauf` liegt im Python-Quellpaket unter
`examples/` und im R-Paket unter `inst/examples/` bzw. nach Installation unter
`system.file("examples", package="bsikompendium")`. Beide Programme verwenden
identische JSON-Eingaben und zeigen Modellierung, Analysebedarf, Matrixeinstufung
und `INF.11.A12` für ein synthetisches Dienstfahrzeug. Ein ungesichert abgestelltes
Fahrzeug ergibt den berechneten Mangel `INF.11.A12.K1`, obwohl die Alarmanlage
vorhanden ist. Die höhere Vertraulichkeit begründet den Analysebedarf auch dann,
wenn die hinreichende Gesamtmodellierung noch unbekannt ist. Das Beispiel
behauptet weder einen vollständigen Fahrzeug-Check noch eine Risikobehandlung.

## Tatsachen und präzise qualifizierte Prämissen

Felder nennen Bedeutung, Datentyp und erforderlichen Nachweis. Fachlich wertende
Prämissen nennen zusätzlich einen Maßstab. Beispielsweise ist die dokumentierte
Eignung einer Schulung anhand konkreter Aufgaben eine Prämisse; eine pauschale
Bestätigung „Anforderung erfüllt“ ist keine zulässige Ersatzprüfung. Die Software
öffnet Nachweisreferenzen nicht und verifiziert keine reale Maßnahme durch bloße
Existenz eines Dateinamens. Nachweise müssen außerhalb des Rechenkerns prüfbar
zugeordnet und erhoben sein.

Fehlende Felder und `null` (R: `NULL`) bedeuten unbekannt. `false` bedeutet einen
bekannt falschen Sachverhalt. Leere Mengen sind nur bei ausdrücklich bestätigter
Vollständigkeit als tatsächlich leer bekannt. Ungültige Typen und unbekannte
Feldnamen erzeugen `EINGABE_UNGUELTIG`, keine günstigen Ersatzwerte.

## Datenformen

| Typ | Eingabe |
| --- | --- |
| bool | Python `True`/`False`/`None`; R `TRUE`/`FALSE`/`NULL`, logisches `NA` ebenfalls unbekannt |
| text | Nichtleerer Text |
| textliste | Liste eindeutiger nichtleerer Texte |
| kategorie | Einer der im konkreten Feldvertrag angegebenen Werte |
| zahl | Endliche Zahl, keine booleschen Werte |
| anzahl | Nichtnegative ganze Zahl |
| datum | Gültiges Kalenderdatum `YYYY-MM-DD` |
| zeitpunkt | Gültiger UTC-Zeitpunkt `YYYY-MM-DDTHH:MM:SSZ` |
| liste | Objekt mit `objekte` und `vollstaendig` |
| regelmaessigkeit | Genau eine der beiden unten erläuterten Zeitvarianten |

Eine Sammlung hat beispielsweise die Form
`{"objekte": [{"geschult_aufgaben": true}], "vollstaendig": false}`.
`vollstaendig` beschreibt die tatsächliche Erhebung im vertraglichen Geltungsbereich,
nicht bloß die Vollständigkeit einer übermittelten Datei. Verschachtelte Sammlungen
haben jeweils eine eigene Vollständigkeitsangabe. Ein bekanntes Gegenbeispiel
widerlegt eine ALL-Pflicht auch bei unvollständiger Erhebung; ein bekanntes Beispiel
kann eine EXISTS-Pflicht bestätigen. Vollständig leere anlassbezogene Grundmengen
führen für die betreffenden Teilpflichten zu `NICHT_ANWENDBAR`. Ausdrückliche
Existenzpflichten werden gesondert geprüft und dadurch nicht aufgehoben.

## Fristen und Regelmäßigkeit

Die Regelmäßigkeitsangabe verwendet entweder Kalenderdaten:

```json
{"letztes_datum":"2026-10-01","bezugsdatum":"2026-10-26",
 "intervall_tage":30,"intervall_begruendet":true}
```

oder genaue UTC-Zeitpunkte, etwa für stündliche Sicherungen:

```json
{"letzter_zeitpunkt":"2026-10-26T10:00:00Z",
 "bezugszeitpunkt":"2026-10-26T11:00:00Z",
 "intervall_sekunden":3600,"intervall_begruendet":true}
```

Die Varianten dürfen nicht vermischt werden. Intervalle sind positive ganze
Zahlen. Die fachliche Begründung muss zur Quelle, Risikolage und gegebenenfalls
zum verbindlichen Plan passen. Die Quelle nennt nicht für jede Regelmäßigkeit
eine feste Frist. Die Library erfindet keine solche Grenze. Ausdrückliche
BSI-Obergrenzen gelten zusätzlich zum eigenen Intervall. Kalenderjahresgrenzen
beziehen sich auf Kalenderdaten; der Jahrestag des 29. Februars fällt in einem
Nichtschaltjahr auf den 28. Februar. Eine Stundenfrist endet einschließlich der
exakten Sekundengrenze. Die Systemzeit wird nicht implizit verwendet.

Optional kann `durchgefuehrt` in beiden Intervallvarianten ergänzt werden.
`false` bezeichnet eine nachweislich ausgebliebene erforderliche Durchführung
und ergibt einen bekannten Mangel, auch ohne letzten Termin. Ein gleichzeitig
angegebener Durchführungstermin ist dann widersprüchlich und ungültig. `true`
mit unbekanntem Termin bleibt zeitlich ungeklärt. Explizites `null` bedeutet
unbekannte Durchführung; ohne das optionale Feld wird wie bisher aus einem
angegebenen Termin auf die Durchführung geschlossen. Ob eine Pflicht überhaupt
schon fällig bzw. anwendbar ist, ergibt sich aus dem jeweiligen Fachvertrag.

Ein noch unbekannter Ereigniszeitpunkt belegt keine ausgebliebene Handlung.
Konkrete Ereignisfakten unterscheiden deshalb bei entsprechenden Pflichten
„nicht erfolgt“ von „erfolgt, Zeitpunkt noch unbekannt“. Wo die Quelle eine konkrete
Zeitspanne vorgibt, wird sie aus den tatsächlichen Zeitpunkten berechnet: Kalenderdaten
ergeben Kalendertage, UTC-Zeitpunkte Sekunden. Eine negative Reihenfolge kann keinen
fristgerechten Vollzug belegen. Ob eine erste Handlung bereits fällig ist, entscheidet
der jeweilige Vertrag anhand ausdrücklich angegebener Tatsachen und Termine.

## Ergebnisse

Ergebnisse enthalten Regel-ID, Quellenfassung, technischen Status,
Anwendbarkeit, Befund, Begründung und fehlende Angaben. Individuelle Prüfungen
liefern außerdem Einzelbefunde mit Kriterien-ID, Quellenmodalität, Anwendbarkeit
und bekannten Mängeln. Eine Mischung positiver und negativer bekannter
Teilpflichten führt zu `TEILWEISE_ERFUELLT`. Ungeklärte entscheidungsrelevante
Tatsachen führen zu `UNBEKANNT`; bekannte Mängel bleiben separat sichtbar.
Inaktive Kriterien verbessern den Gesamtbefund nicht.

Ein positiver Befund beruht auf den angegebenen Tatsachen und den konkreten
qualifizierten Prämissen. Abweichungen, Risikoakzeptanz und Alternativmaßnahmen
werden gesondert beurteilt und nicht still in ursprüngliche Erfüllung umgedeutet.
Die alte Aggregation von Absatz-Selbstauskünften (`pruefe_anforderung`) ist nicht
die individuelle Fachprüfung. Testparität zwischen Python und R ist eine
technische Prüfung; unabhängige Quellen- und Referenzprüfung bleibt erforderlich.

## Methodenprüfung nach den BSI-Standards

`methodenschritte()` nennt 194 individuell implementierte IDs: 83 Methodenschritte
der drei Standards und 111 individuelle Bausteinmodellierungen.
`methodischer_eingabevertrag(schritt_id)` liefert ihre konkreten Felder, Maßstäbe
und Quellenabschnitte. `pruefe_methodenschritt(schritt_id, angaben)` verwendet
für diese Verträge dieselbe native, dreiwertige Auswertung wie die Fachregeln.
Unbekannte Schritt-IDs sind ungültige Eingaben. Die Methodenverträge behandeln
unter anderem Sicherheitsorganisation, Vorgehensauswahl, Struktur- und
Schutzbedarfsanalyse, Grundschutz-Check, Maßnahmenrealisierung, Dokumentation,
Managementbewertung und Risikoanalyse/-behandlung. Ihre gesonderte Anzahl zählt
nicht zu den 1.835 aktiven Kompendium-Anforderungen.

Die Methodenverträge prüfen die angegebenen konkreten Verfahrens- und
Nachweistatsachen. Eine fachliche Prämisse zur richtigen Matrixanwendung ersetzt
keinen rechnerischen Matrixnachschlag. `bewerte_risiko()` berechnet die Kategorie
anhand der ausdrücklich gewählten Matrix; `pruefe_risikoanalysebedarf()` prüft
die drei in BSI 200-3 genannten Analyseauslöser. Diese Teilprüfungen allein sind
keine vollständige Abnahme eines Informationssicherheitsprozesses.

Die Modalität `VERFAHREN` kennzeichnet eine beschriebene methodische Handlung,
deren Quelle kein eindeutiges normatives Modalverb verwendet. Sie ist nicht mit
`MUSS` gleichgesetzt. Bei Kompendiumstellen bleiben das tatsächlich verwendete
`SOLL` und indikative Verpflichtungen (`VERPFLICHTEND`) gesondert sichtbar;
auch die originale Formulierung „DÜRFTEN NICHT“ in NET.4.3.A1 wird als
`DUERFTEN_NICHT` erhalten und nicht still zu einem anderen Modalverb korrigiert.
Originalwortlaut und Auslegung stehen im konkreten Vertrag. Ein technischer
Gesamtbefund gewichtet unterschiedliche Modalitäten nicht zu einem Zertifizierungsurteil.

## Identitäten in Sammlungen

Ein Vertragsfeld kann `eindeutiges_feld` vorgeben, beispielsweise `server_id`.
Bekannte doppelte Identitäten sind ungültig. Fehlende Identitäten bleiben unbekannt
und verhindern eine positive vollständige Prüfung des identifizierbaren Bestands.
Eine Anzahl aus einer Objektsammlung ist nur bei bestätigter Vollständigkeit und
bekannten erforderlichen Identitäten bestimmt. Mindestzahlen werden im jeweiligen
Kriterium geprüft; sie werden nicht als zusätzliche Pflichten anderer Kriterien
über denselben Bestand ausgegeben.

## Gekoppelte Risikoentscheidung

`pruefe_risikoverlauf(vorher, nachher, matrix, akzeptierte_kategorien,
weitere_akzeptanzkriterien, angaben)` verbindet den tatsächlichen Matrixnachschlag
mit dem Methodenschritt `BSI2003.RISIKOBEHANDLUNG`. Beide Szenarien enthalten
`haeufigkeit`, `schaden` und ihren eigenen `bewertungsstand` (`KONZEPT` oder
`UMGESETZT`). Bereits die erste Einstufung darf geplante Maßnahmen annehmen.
Die Funktion behandelt sie deshalb nur bei ausdrücklich belegtem Ist-Bezug als
tatsächlich eingegangenes Risiko.

`angaben` enthält die übrigen konkreten Tatsachen des Behandlungsvertrags.
Die aus Szenarien und Akzeptanzbedingungen abgeleiteten Felder `risikokategorie`,
`eingegangenes_risiko`, `restrisiko_vorhanden`, `akzeptanz_erreicht`,
`vorher_nachher` und `bewertungsstand` dürfen dort nicht überschrieben werden.
Die Kategorie des Restrisikos wird mit den ausdrücklich angegebenen zulässigen
Kategorien verglichen. Zusätzlich werden alle Einträge in
`weitere_akzeptanzkriterien` geprüft: eine Sammlung aus `objekte` (je `id` und
`erfuellt`) und `vollstaendig`. Eine vollständig leere Sammlung bedeutet, dass
keine weiteren institutionellen Akzeptanzbedingungen gelten. Unvollständige
Erhebung oder eine unbekannte Bedingung können keine positive Akzeptanz begründen.

Bei einem Konzept-Nachher bleibt ein belegtes tatsächliches Vorher-Risiko
maßgeblich für die Frage, welches Risiko aktuell eingegangen wird. Ein behauptetes
Ist-Nachher setzt die tatsächliche Umsetzung bzw. Wirkung der gewählten
Behandlungsarten voraus. Ohne diesen Nachweis ist auch die erreichte
Ist-Akzeptanz ungeklärt. Die rechnerische Nachher-Kategorie bleibt als Ergebnis
der angegebenen Annahmen sichtbar; `nachher_als_ist_belegt` kennzeichnet die
zusätzliche Grenze. Ein unverändertes Kategorienergebnis ist nicht automatisch
eine unwirksame Behandlung: qualitative Kategorien können reale Verbesserungen
innerhalb derselben Kategorie enthalten.

Reine Risikoakzeptanz senkt das Risiko nicht selbst. Bei geänderten Vorher-/Nachher-
Achsen unter alleiniger `AKZEPTANZ` ist deshalb `nachher.neubewertungsgrund`
erforderlich: konkrete geänderte Umstände oder neue Daten, die eine Neubewertung
begründen. Ohne diese Erläuterung bleibt die neue Akzeptanz ungeklärt. Eine
wirksam ausgeschlossene Risikoursache darf nicht gleichzeitig mit einer bekannten
verbleibenden Nachher-Risikokategorie angegeben werden.

## Grundschutz-Check mit Katalogbezug

`pruefe_checkentscheidung(anforderung_id, angaben)` prüft die Begründbarkeit des
angegebenen Status `JA`, `TEILWEISE`, `NEIN` oder `ENTBEHRLICH` für eine aktive
Kataloganforderung. Die Eingaben entsprechen dem Methodenschritt
`BSI2002.CHECKENTSCHEIDUNG`, ausgenommen `basis` und
`kreuzreferenzen_identifiziert`: Diese beiden Felder werden aus der konkreten
Kataloganforderung und dem abgeglichenen Gefährdungsbestand abgeleitet und dürfen
nicht überschrieben werden. Die Objektzuordnung muss sich aus dem konkreten
Prüfvorgang und seinen Nachweisen ergeben.

`zugehoerige_gefaehrdungen` enthält eine Sammlung mit `objekte` und
`vollstaendig`. Jedes Objekt hat eine eindeutige Gefährdungs-ID sowie die konkreten
Tatsachen zur pauschalen Akzeptanz bzw. zur begründeten Wirkung von Alternativen.
Die Funktion gleicht IDs gegen die Kreuzreferenzen der gewählten Anforderung ab.
Fremde oder doppelte IDs sind ungültig. Eine als vollständig bezeichnete Liste,
in der zugehörige Gefährdungen fehlen, begründet keine Entbehrlichkeit. Bei
unbekannter Vollständigkeit oder Identität bleibt der Abgleich unbekannt.

Hier bedeutet `befund=ERFUELLT`, dass die Statusentscheidung nach den angegebenen
Tatsachen begründet ist. Ein korrekt dokumentiertes `NEIN` kann diesen Befund
haben und bezeichnet weiterhin eine nicht erfüllte Anforderung. Das Ergebnis
führt deshalb `gepruefter_status` ausdrücklich separat. Diese Funktion ersetzt
weder die individuelle Fachprüfung noch die organisatorische Durchführung und
Dokumentation des Grundschutz-Checks.

## Quoten und Kalenderjahre

Quoten werden anhand des vollständigen konkreten Bestands mit ganzzahligen
Verhältnissen geprüft. Bei einer Mindestquote von 30 Prozent genügen zwei von
acht Objekten nicht; drei genügen. Ein unbekannter Nenner darf keine positive
Quote liefern. Bei bekanntem Nenner können unbekannte Auswahlentscheidungen
unerheblich sein, wenn bereits genügend Objekte nachweislich ausgewählt wurden,
oder selbst bei Auswahl aller verbleibenden Objekte die Quote nicht erreichbar ist.

Fristen in Kalenderjahren verwenden das entsprechende Kalenderdatum und keine
pauschale Anzahl von Tagen. Für den 29. Februar gilt in einem Nichtschaltjahr der
28. Februar. Verschachtelte Nachweise können auf ein Datum ihres übergeordneten
Vorgangs Bezug nehmen; fehlende Daten werden am tatsächlichen Eingabepfad benannt.

## Abdeckung des Grundschutz-Checks

`pruefe_checkabdeckung(vorgehen, modellierung, checks)` gleicht konkrete
Baustein-/Zielobjekt-Zuordnungen mit dem aktiven Katalog ab. Beide Bestände enthalten
`objekte` und `vollstaendig`. Modellierungsobjekte bestehen aus `baustein_id` und
`zielobjekt_id`; Checkobjekte aus `anforderung_id`, `zielobjekt_id` und `status`
(`JA`, `TEILWEISE`, `NEIN`, `ENTBEHRLICH`). Doppelte Zuordnungen sind ungültig.

Für `BASIS` sind alle aktiven B-Anforderungen der modellierten Bausteine je Zielobjekt
erforderlich; für `STANDARD` und `KERN` zusätzlich alle S-Anforderungen.
H-Anforderungen werden durch diesen Abgleich nicht automatisch verpflichtend.
Bekannt fehlende Datensätze, bei unvollständiger Erhebung ungeklärte Datensätze,
offene Status und zusätzliche Prüfungen werden getrennt ausgegeben. Eine Prüfung
für Zielobjekt A ersetzt keine Prüfung derselben Anforderung für Zielobjekt B.

Die besondere Formulierung des BSI-Standards 200-2 Abschnitt 7.7 wird für `KERN`
explizit berücksichtigt: Ein Basis-Checkstatus `ENTBEHRLICH` wird dort als
unzulässig ausgewiesen. Abschnitt 8.4.2 beschreibt demgegenüber die allgemeine
Entbehrlichkeit durch Nichtrelevanz oder angemessene Alternativmaßnahmen.
Diese textliche Besonderheit wird nicht still auf die übrigen Vorgehensweisen
übertragen. Die allgemeine Begründungsprüfung nach Abschnitt 8.4.2 erfolgt mit
`pruefe_checkentscheidung`; sie ersetzt den zusätzlichen Kern-Abgleich nicht.

`ERFUELLT` bedeutet hier vollständige Erfassung der geforderten Prüfstatus und
Einhaltung dieser Kern-Sonderregel. Auch vollständig dokumentierte `NEIN`-Status
können diesen Abdeckungsbefund erfüllen. Die tatsächliche Anforderungserfüllung
muss mit den fachlichen Prüfungen beurteilt werden. Leere vollständige Modellierung
liefert `NICHT_ANWENDBAR`, keine fiktive Erfüllung eines Informationsverbunds.

Sammlungsprüfungen können auf andere Bestände im übergeordneten Eingabeobjekt
Bezug nehmen. Damit werden beispielsweise Netzendpunkte, Anwendungssysteme und
physische VM-Hosts an konkrete inventarisierte Objekte gebunden. Externe
Netzgegenstellen bleiben explizit von internen Zielobjekten unterscheidbar.

Die Dokumentationsschritte zu BSI 200-2 Abschnitt 5.2 liefern zusätzlich einen
`geltungshinweis`. Die dort beschriebenen idealtypischen Aspekte werden an die
Institution und Vorgehensweise angepasst, insbesondere bei Basis-Absicherung.
Im Zertifizierungskontext sind sie verbindlich; außerhalb davon beschreibt der
Standard sie als Best Practices. Die Modalitäten der einzelnen Quellenpassagen
bleiben erkennbar. Ein Befund für einen ausgewählten Dokumentationsschritt ist
keine pauschale Pflicht, jedes Dokumentationsdetail unverändert einzuführen.
Geeignete Wiki-Einträge, Tabellen und vorhandene Dokumente können genügen.

Individuelle Bausteinmodellierungen werden über dieselbe Methodenengine geprüft:
`pruefe_methodenschritt("BSIMODELL.APP.1.1", angaben)` prüft beispielsweise lokale
Office-Produkte, ihre Abgrenzung zu E-Mail und reinen Cloud-Angeboten sowie die
konkret erforderlichen Ergänzungen. `methodischer_eingabevertrag()` beschreibt
den jeweils benötigten vollständigen Objektbestand. Die IDs `BSIMODELL.*` gehören
zur separat ausgewiesenen Modellierungsabdeckung, weder zu den 1.835
Anforderungen noch zu den Schritten der BSI-Standards 200-1/2/3. Für jeden der 111 Bausteine ist ein individueller Modellierungsvertrag vorhanden;
eine generische Ersatzregel wird nicht verwendet.

Die Bausteinlisten sind kataloggebundene Mengen pro Zielobjekt. Leere Listen
bedeuten bekannte fehlende Zuordnung, fehlende Angaben bleiben unbekannt.
Die Liste `bausteine` benennt tatsächlich berücksichtigte Bausteine. Bei
Systembausteinen ist dies die direkte Modellierung im jeweiligen Geltungsbereich.
Ein verbundweiter Prozessbaustein wird einmal am zuständigen Informationsverbund
modelliert; ein konkretes Gerät oder ein Teilbereich kann über diesen Prozess
nachweislich einbezogen sein. Seine Nennung beim Gerät verlangt keine zusätzliche
direkte Prozessmodellierung pro Gerät. Eine bloße ID ohne zuständigen Prozess und
prüfbaren Einbezug genügt nicht; konkrete Objektbindungen und Einbezugsfelder des
jeweiligen Vertrags bleiben verbindlich.

Zusätzliche Bausteine können eigene weitere Modellierungsregeln auslösen.
Ein positives Modellierungsergebnis belegt keine Erfüllung ihrer Anforderungen
und keine vollständige technische Erkennung aller vorhandenen Systeme.

## Quellenanker und veröffentlichbare Ressourcen

Alle individuellen Verträge behalten Quellenfassung, Anforderungs-/Abschnitts-ID
und die jeweiligen Kriterienanker. Die vollständigen Originalpassagen der
Modellierungsabschnitte bleiben im lokalen Quellenaudit; die Paketressourcen
enthalten dafür die Abschnittsanker und die eigenständig abgeleitete Fachlogik.
Diese Trennung ändert weder Kriterien noch Eingabefelder oder Ergebnisse.

Normen- und Fremdrechtsverweise wie DIN-Klassen oder Arbeitsschutzvorgaben werden
mit dem konkreten Nachweisgegenstand und dem Quellenstand ausgewiesen. Ein
qualifizierter Nachweis für die tatsächlich geforderte Eigenschaft ersetzt keine
vollständige Implementierung oder Zertifizierung des referenzierten Regelwerks.

## Legacy-API und Versionswechsel

`eingabevertrag()` und `pruefe_anforderung()` betreffen weiterhin die ältere
Absatz-Selbstauskunft. Ein Benutzer bestätigt dort Umsetzung, Wirksamkeit und
Angemessenheit ganzer Quellblöcke. Diese Prüfung wird nicht als individuelle
Anforderungsumsetzung von 0.2 gezählt. Das vorhandene Beispiel `kundenportal`
veranschaulicht ausschließlich diesen Legacy-Ablauf samt älteren Teilprüfungen.
Für neue fachliche Prüfabläufe sind die individuellen Eingabeverträge maßgeblich.

Auch `pruefe_technische_grenzen()` und die älteren spezialisierten Funktionen
prüfen nur ihren ausdrücklich dokumentierten Teilumfang. Ein Ergebnis daraus
ersetzt die übrigen Kriterien einer vollständigen Anforderung nicht. Die native
Risikomatrixberechnung und die neuen gekoppelten Verfahrensprüfungen bleiben
eigenständige nutzbare Funktionen; die Bezeichnung Legacy bezieht sich nicht
pauschal auf jede bereits früher vorhandene API.

Öffentliche Vertragsmetadaten kennzeichnen die individuelle Spezifikation.
Eine releasebezogene fachliche/technische Freigabe ist davon getrennt im
Abnahmenachweis dokumentiert. Quellenreview, Referenzprüfung, R-/Python-Parität
und CRAN-Prüfung sind unterschiedliche Nachweise und werden nicht miteinander
verwechselt.
