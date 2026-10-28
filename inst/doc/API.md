# Öffentliche API

Version 0.2.0. Native, deterministische Offline-Funktionen in Python und R.

Individuelle Anforderungen werden mit `fachlicher_eingabevertrag()` und `pruefe_fachregel()` geprüft. Methodik und Bausteinmodellierung verwenden `methodischer_eingabevertrag()` und `pruefe_methodenschritt()`. Die folgenden Signaturen zeigen Python; R verwendet dieselben Argumentnamen und benannte bzw. unbenannte Listen. 0.2.0 umfasst alle 1.835 aktiven Anforderungen, 111 individuelle Modellierungen und 83 Standard-Methodenschritte. Die 194 IDs der Methodenengine bestehen aus den 111 Modellierungen und 83 Standardschritten. Alle Datenformen und die Dreiwertlogik sind in der mitgelieferten FACHLOGIK.md erläutert ([Fachlogik](FACHLOGIK.md)).

## pruefe_risikoverlauf

`pruefe_risikoverlauf(vorher, nachher, matrix, akzeptierte_kategorien, weitere_akzeptanzkriterien, angaben)`

Couple matrix results, acceptance criteria and a BSI-200-3 treatment check.

Planned effects remain separate from the risk actually incurred. The caller
must supply the institution's applicable acceptance criteria explicitly.

- `vorher`: Objekt mit haeufigkeit, schaden und eigenem bewertungsstand (KONZEPT oder UMGESETZT) für die erste Einstufung. Bereits hier dürfen Maßnahmen nur geplant sein; fehlender Ist-Bezug bleibt unbekannt.
- `nachher`: Objekt mit haeufigkeit, schaden und eigenem bewertungsstand (KONZEPT oder UMGESETZT) nach zusätzlicher Behandlung. Bei ausgeschlossener Ursache keine Risikokategorie angeben. Bei alleiniger AKZEPTANZ und geänderten Achsen ist neubewertungsgrund als konkrete Änderung der Umstände oder Datenlage erforderlich.
- `matrix`: Explizit BSI_200_3_BEISPIEL_2017 oder Objekt mit id, haeufigkeiten (Liste), schaeden (Liste), werte (Zeilen nach Schäden, Spalten nach Häufigkeiten). Jede Zelle: GERING, MITTEL, HOCH oder SEHR_HOCH. Beispiel ist keine allgemeine BSI-Vorgabe.
- `akzeptierte_kategorien`: Liste der ausdrücklich organisationsseitig akzeptierten Risikokategorien; keine automatische Grenze.
- `weitere_akzeptanzkriterien`: Sammlung mit objekte (je id und erfuellt) sowie vollstaendig. Alle zusätzlich zur Risikokategorie geltenden institutionellen Akzeptanzbedingungen konkret erfassen; ausdrücklich vollständig leere Menge nur, wenn keine weiteren Bedingungen gelten.
- `angaben`: Benanntes Tatsachenobjekt mit den funktionsspezifischen Feldern im Abschnitt Datenfelder. Fehlende zulässige Angaben sind unbekannt; unbekannte Feldnamen werden abgewiesen.

## methodenschritte

`methodenschritte() -> list[str]`

Return explicitly implemented method step IDs; not a completion claim.


## methodischer_eingabevertrag

`methodischer_eingabevertrag(schritt_id: str) -> dict`

Return facts, criteria and precise standard sections for a method step.

- `schritt_id`: ID eines individuell implementierten Methodenschritts aus methodenschritte(), etwa BSI2003.RICHTLINIE; separat von Kompendium-Anforderungs-IDs.

## pruefe_methodenschritt

`pruefe_methodenschritt(schritt_id: str, angaben: dict) -> dict`

Evaluate one method step; does not certify an entire risk assessment.

- `schritt_id`: ID eines individuell implementierten Methodenschritts aus methodenschritte(), etwa BSI2003.RICHTLINIE; separat von Kompendium-Anforderungs-IDs.
- `angaben`: Benanntes Tatsachenobjekt mit den funktionsspezifischen Feldern im Abschnitt Datenfelder. Fehlende zulässige Angaben sind unbekannt; unbekannte Feldnamen werden abgewiesen.

## pruefe_checkentscheidung

`pruefe_checkentscheidung(anforderung_id: str, angaben: dict) -> dict`

Check a declared status against the actual catalogue category and threats.

The result assesses whether the chosen check status is justified, not whether
the underlying requirement is fulfilled. A justified NEIN can therefore pass
this decision check while explicitly documenting a substantive deficit.

- `anforderung_id`: Katalog-ID einer einzelnen Anforderung, etwa CON.10.A7.
- `angaben`: Benanntes Tatsachenobjekt mit den funktionsspezifischen Feldern im Abschnitt Datenfelder. Fehlende zulässige Angaben sind unbekannt; unbekannte Feldnamen werden abgewiesen.

## pruefe_checkabdeckung

`pruefe_checkabdeckung(vorgehen, modellierung, checks)`

Compare concrete block/object modelling with mandatory check records.

This validates completeness of recorded statuses, not substantive fulfilment.
Basis coverage requires B; Standard/Kern require B and S. The explicit Kern
restriction in BSI 200-2 section 7.7 remains visible for B/ENTBEHRLICH.

- `vorgehen`: Explizite Grundschutz-Vorgehensweise: BASIS, STANDARD oder KERN.
- `modellierung`: Vollstaendiger Bestand konkreter Baustein-/Zielobjekt-Zuordnungen mit objekte und vollstaendig.
- `checks`: Bestand konkreter Anforderungs-/Zielobjekt-Pruefstatus mit objekte und vollstaendig; eine Abdeckungspruefung ist keine Erfuellungspruefung.

## fachlicher_eingabevertrag

`fachlicher_eingabevertrag(anforderung_id: 'str') -> 'dict'`

Individuelle Felder, Bewertungsmaßstäbe, Nachweise und Kriterien abfragen.

- `anforderung_id`: Katalog-ID einer einzelnen Anforderung, etwa CON.10.A7.

## pruefe_fachregel

`pruefe_fachregel(anforderung_id: 'str', angaben: 'dict') -> 'dict'`

Konkrete Tatsachen anhand individueller BSI-Kriterien auswerten; offene Regeln bleiben offen.

- `anforderung_id`: Katalog-ID einer einzelnen Anforderung, etwa CON.10.A7.
- `angaben`: Benanntes Tatsachenobjekt mit den funktionsspezifischen Feldern im Abschnitt Datenfelder. Fehlende zulässige Angaben sind unbekannt; unbekannte Feldnamen werden abgewiesen.

## anforderung

`anforderung(anforderung_id: 'str') -> 'dict'`

Metadaten einer Anforderung, einschließlich entfallener Einträge.

- `anforderung_id`: Katalog-ID einer einzelnen Anforderung, etwa CON.10.A7.

## anforderungen

`anforderungen(baustein_id: 'str | None' = None, kategorie: 'str | None' = None, entfallen: 'bool' = False) -> 'list[str]'`

Katalog filtern; entfallen=True schließt historische Einträge mit ein.

- `baustein_id`: Katalog-ID eines Bausteins, etwa CON.10; bei Filterfunktionen optional.
- `kategorie`: Optionaler Filter B (Basis), S (Standard) oder H (erhöhter Schutzbedarf).
- `entfallen`: FALSE/False schließt entfallene Anforderungen aus; TRUE/True nimmt sie zusätzlich auf.

## anforderungen_fuer

`anforderungen_fuer(baustein_ids: 'list[str]', vorgehen: 'str', h_auswahl: 'list[str] | None' = None, kernbereich: 'bool | None' = None) -> 'list[str]'`

B für Basis; B/S für Standard bzw. expliziten Kernbereich; H nur ausgewählt.

- `baustein_ids`: Nichtleere Liste eindeutiger Baustein-IDs, die fachlich ausgewählt wurden.
- `vorgehen`: Explizite Grundschutz-Vorgehensweise: BASIS, STANDARD oder KERN.
- `h_auswahl`: Optionale Liste ausdrücklich ausgewählter aktiver H-Anforderungen aus den angegebenen Bausteinen.
- `kernbereich`: Bei KERN muss TRUE/True die vorherige fachliche Festlegung des Kernbereichs bestätigen.

## baustein

`baustein(baustein_id: 'str') -> 'dict'`

Metadaten eines Bausteins mit Zielobjekttypen und Bearbeitungsreihenfolge.

- `baustein_id`: Katalog-ID eines Bausteins, etwa CON.10; bei Filterfunktionen optional.

## bausteine

`bausteine() -> 'list[str]'`

Alle 111 Baustein-IDs in stabiler Reihenfolge.


## bestimme_schutzbedarf

`bestimme_schutzbedarf(werte: 'list[str | None]', grundwert: 'str', anpassung: 'str | None' = None, effekt: 'str | None' = None, begruendung: 'str' = '') -> 'dict'`

Maximum je Grundwert; fachlich begründete Effekte ausdrücklich übergeben.

- `werte`: Nichtleere Liste relevanter Ausgangseinstufungen: NORMAL, HOCH, SEHR_HOCH oder unbekannt.
- `grundwert`: vertraulichkeit, integritaet oder verfuegbarkeit; jede Dimension separat berechnen.
- `anpassung`: Optionale fachlich ermittelte Zielstufe NORMAL, HOCH oder SEHR_HOCH; nur gemeinsam mit effekt und Begründung.
- `effekt`: KUMULATION darf bekannte Einstufungen nicht senken; VERTEILUNG darf das bekannte Maximum nicht erhöhen.
- `begruendung`: Konkrete nichtleere fachliche Begründung bei Ausschluss, Abweichung oder Schutzbedarfsanpassung; sonst optional.

## bewerte_risiko

`bewerte_risiko(haeufigkeit: 'str | None', schaden: 'str | None', matrix: 'str | dict') -> 'dict'`

Explizite Matrix nachschlagen, nicht ordinale Werte multiplizieren.

- `haeufigkeit`: Achsenwert der explizit gewählten Matrix oder unbekannt.
- `schaden`: Schadensachse der explizit gewählten Matrix oder unbekannt.
- `matrix`: Explizit BSI_200_3_BEISPIEL_2017 oder Objekt mit id, haeufigkeiten (Liste), schaeden (Liste), werte (Zeilen nach Schäden, Spalten nach Häufigkeiten). Jede Zelle: GERING, MITTEL, HOCH oder SEHR_HOCH. Beispiel ist keine allgemeine BSI-Vorgabe.

## eingabevertrag

`eingabevertrag(anforderung_id: 'str') -> 'dict'`

Quellenbezogene Bewertungsblöcke; keine automatische Interpretation des Freitexts.

- `anforderung_id`: Katalog-ID einer einzelnen Anforderung, etwa CON.10.A7.

## gefaehrdungen

`gefaehrdungen(anforderung_id: 'str') -> 'list[str]'`

Direkte Gefährdungszuordnungen, mit Errata; keine Risikogewichte.

- `anforderung_id`: Katalog-ID einer einzelnen Anforderung, etwa CON.10.A7.

## pruefe_abweichung

`pruefe_abweichung(anforderung_id: 'str', art: 'str', begruendung: 'str', gefaehrdungsbewertungen: 'dict', leitung_zustimmung: 'bool | None' = None, alternativmassnahme: 'str' = '', gleichwertig: 'bool | None' = None, basis_ausnahme_begruendet: 'bool | None' = None) -> 'dict'`

Begründung einer Abweichung prüfen, ohne sie in Erfüllung umzudeuten.

- `anforderung_id`: Katalog-ID einer einzelnen Anforderung, etwa CON.10.A7.
- `art`: NICHT_RELEVANT, ALTERNATIVMASSNAHME oder RISIKOAKZEPTANZ. Der Abweichungsbefund ist keine Umsetzung der ursprünglichen Anforderung.
- `begruendung`: Konkrete nichtleere fachliche Begründung bei Ausschluss, Abweichung oder Schutzbedarfsanpassung; sonst optional.
- `gefaehrdungsbewertungen`: Objekt mit den IDs aus gefaehrdungen. true bestätigt je Gefährdung die fachlich begründete Nichtrelevanz, die ausreichende alternative Abdeckung beziehungsweise die dokumentierte Risikobewertung, passend zur art; false widerspricht dieser Begründung, null lässt sie offen.
- `leitung_zustimmung`: Explizite Zustimmung der Leitung (bool oder unbekannt), bei Risikoakzeptanz erforderlich.
- `alternativmassnahme`: Nichtleere Beschreibung der tatsächlich vorgesehenen gleichwertigen Alternative.
- `gleichwertig`: Fachlich bestätigte Gleichwertigkeit der Alternativmaßnahme (bool oder unbekannt).
- `basis_ausnahme_begruendet`: Bei alternativer Umsetzung einer B-Anforderung: ausdrückliche fachliche Ausnahmebegründung bestätigt (bool oder unbekannt).

## pruefe_anforderung

`pruefe_anforderung(anforderung_id: 'str', bewertungen: 'dict', anwendbar: 'bool | None' = None, begruendung: 'str' = '') -> 'dict'`

Grundschutz-Check aus unabhängigen Maßnahmenbewertungen je Quellenblock.

- `anforderung_id`: Katalog-ID einer einzelnen Anforderung, etwa CON.10.A7.
- `bewertungen`: Objekt mit Kriterium-IDs aus eingabevertrag als Schlüsseln. Je Block: relevant, umgesetzt, wirksam, angemessen (bool oder unbekannt) und optionale begruendung. Alle enthaltenen Quellsätze fachlich bewerten. relevant=false verlangt eine Begründung.
- `anwendbar`: Explizite fachliche Anwendbarkeit: TRUE/True, FALSE/False oder NULL/None. Ausschluss verlangt begruendung.
- `begruendung`: Konkrete nichtleere fachliche Begründung bei Ausschluss, Abweichung oder Schutzbedarfsanpassung; sonst optional.

## pruefe_datensicherung

`pruefe_datensicherung(angaben: 'dict') -> 'dict'`

CON.3.A5/A15; Zeitgrenze stammt ausdrücklich aus dem eigenen Sicherungsplan.

- `angaben`: Benanntes Tatsachenobjekt mit den funktionsspezifischen Feldern im Abschnitt Datenfelder. Fehlende zulässige Angaben sind unbekannt; unbekannte Feldnamen werden abgewiesen.

## pruefe_http_datenschutz

`pruefe_http_datenschutz(angaben: 'dict') -> 'dict'`

CON.10.A7 einschließlich korrigierter Body-Regel, ohne feste HTTP-Methode.

- `angaben`: Benanntes Tatsachenobjekt mit den funktionsspezifischen Feldern im Abschnitt Datenfelder. Fehlende zulässige Angaben sind unbekannt; unbekannte Feldnamen werden abgewiesen.

## pruefe_informationsverbund

`pruefe_informationsverbund(objekte: 'list[dict]') -> 'dict'`

IDs, Typen und lokale Beziehungen prüfen; keine automatische Asset-Erkennung.

- `objekte`: Nichtleere Liste mit id, typ und optional abhaengigkeiten (Liste bestehender IDs). Typ: Informationsverbund, Prozess, Information, Anwendung, IT-System, Netz, Gebäude/Raum, Kommunikationsverbindung. Keine automatische Inventarvollständigkeit.

## pruefe_modellierung

`pruefe_modellierung(objekte: 'list[dict]', zuordnungen: 'list[dict]', institution: 'str | None' = None, unterliegt_vsa: 'bool | None' = None) -> 'dict'`

Zielobjekttypen, fachliche Zuordnung und korrigierte VSA-Abgrenzung prüfen.

- `objekte`: Nichtleere Liste mit id, typ und optional abhaengigkeiten (Liste bestehender IDs). Typ: Informationsverbund, Prozess, Information, Anwendung, IT-System, Netz, Gebäude/Raum, Kommunikationsverbindung. Keine automatische Inventarvollständigkeit.
- `zuordnungen`: Liste mit objekt_id, baustein_id und fachlich_passend (bool oder unbekannt). Direkte Zuordnung auf Zielobjekttypen aus baustein; prozessübergreifende Bausteine gehören auf den Informationsverbund. Abhängigkeiten ersetzen keine direkte Zuordnung.
- `institution`: Für CON.11.1: BUNDESBEHOERDE, BUNDESUNMITTELBARE_EINRICHTUNG, LANDESBEHOERDE, UNTERNEHMEN oder SONSTIGE; optional/unbekannt.
- `unterliegt_vsa`: Für CON.11.1 zusätzlich bestätigte Unterstellung unter die VSA (bool oder unbekannt).

## pruefe_passwortgebrauch

`pruefe_passwortgebrauch(angaben: 'dict') -> 'dict'`

ORP.4.A8: Tatsachen prüfen, keine echten Passwörter entgegennehmen.

- `angaben`: Benanntes Tatsachenobjekt mit den funktionsspezifischen Feldern im Abschnitt Datenfelder. Fehlende zulässige Angaben sind unbekannt; unbekannte Feldnamen werden abgewiesen.

## pruefe_risikoanalysebedarf

`pruefe_risikoanalysebedarf(schutzbedarf: 'dict', hinreichend_modelliert: 'bool | None', typisches_szenario: 'bool | None') -> 'dict'`

Drei Anlässe der ergänzenden Risikoanalyse, BSI 200-3 Abschnitt 1.2.

- `schutzbedarf`: Objekt mit vertraulichkeit, integritaet und verfuegbarkeit; je NORMAL, HOCH, SEHR_HOCH oder unbekannt. Fehlende Dimensionen sind unbekannt.
- `hinreichend_modelliert`: Fachliche Aussage, ob das Zielobjekt durch die Bausteine hinreichend modelliert ist (bool oder unbekannt).
- `typisches_szenario`: Fachliche Aussage, ob das Zielobjekt im vorgesehenen typischen Einsatzszenario betrieben wird (bool oder unbekannt).

## pruefe_risikobehandlung

`pruefe_risikobehandlung(option: 'str', restrisiko: 'str | None', akzeptierte_kategorien: 'list[str]', angaben: 'dict') -> 'dict'`

Optionenspezifische Behandlung, Restbewertung und Leitungszustimmung prüfen.

- `option`: VERMEIDUNG, REDUKTION, TRANSFER oder AKZEPTANZ.
- `restrisiko`: Aktuell fachlich bewertetes Restrisiko GERING, MITTEL, HOCH, SEHR_HOCH oder unbekannt; bei VERMEIDUNG nicht benötigt.
- `akzeptierte_kategorien`: Liste der ausdrücklich organisationsseitig akzeptierten Risikokategorien; keine automatische Grenze.
- `angaben`: Benanntes Tatsachenobjekt mit den funktionsspezifischen Feldern im Abschnitt Datenfelder. Fehlende zulässige Angaben sind unbekannt; unbekannte Feldnamen werden abgewiesen.

## risikomatrix

`risikomatrix() -> 'dict'`

BSI-Beispielmatrix, ausdrücklich kein universelles Organisationsmodell.


## pruefe_technische_grenzen

`pruefe_technische_grenzen(anforderung_id: 'str', angaben: 'dict') -> 'dict'`

Belegte Zahlen-/Zeitteilkriterien; keine vollständige technische Anforderungsabnahme.

- `anforderung_id`: Katalog-ID einer einzelnen Anforderung, etwa CON.10.A7.
- `angaben`: Benanntes Tatsachenobjekt mit den funktionsspezifischen Feldern im Abschnitt Datenfelder. Fehlende zulässige Angaben sind unbekannt; unbekannte Feldnamen werden abgewiesen.

## Ergebnisse und Fehler

Katalogfunktionen liefern IDs oder Metadaten. Individuelle Eingabeverträge
enthalten konkrete Felddefinitionen, Maßstäbe, Quellenanker und ausführbare Kriterien.
Prüfungen liefern `regel_id`, `quellenfassung`, `status`, `anwendbarkeit`, `befund`,
`begruendung`, `fehlende_angaben` und funktionsspezifische Zusatzfelder.
`AUSGEWERTET` bestätigt die Ausführung; `UNBEKANNT` bedeutet keine Erfüllung.
`bekannte_maengel` nennt bereits festgestellte Mängel auch bei weiteren unbekannten
Angaben. `teilbefunde` enthält Kriterien-ID, Modalität, Anwendbarkeit und Befund.

Ungültige Typen, Kategorien, IDs und zusätzliche Felder ergeben in Python
`Eingabefehler` (Unterklasse von `ValueError`), in R eine Condition
`bsikompendium_eingabefehler`; beide mit `code=EINGABE_UNGUELTIG`.
Die Prüffunktionen verändern ihre Eingaben nicht. Sie greifen weder auf das Netz
noch auf Nachweisdateien zu und schreiben keine Nutzerdaten.

Die älteren Funktionen `pruefe_anforderung`, `pruefe_technische_grenzen` und die
weiteren spezialisierten Teilfunktionen bleiben verfügbar. Absatz-Selbstauskünfte
und ausgewählte Grenzprüfungen ersetzen keine vollständige individuelle Fachprüfung.
Die folgenden Datenfeldbeschreibungen dieser Teilfunktionen benennen ihren Umfang.

## Datenfelder

Objekte werden in Python als `dict`, Arrays als `list` übergeben; in R als benannte
beziehungsweise unbenannte `list`. Boolesche Werte sind strikt `True/False/None`
beziehungsweise `TRUE/FALSE/NULL`; R akzeptiert zusätzlich logisches `NA` als
unbekannt. Keine Umwandlung von 0/1 oder Zeichenketten in boolesche Werte.
Kategorien sind exakt geschrieben. Zahlen müssen endlich sein; der Fachvertrag
unterscheidet allgemeine Zahlen (etwa auch negative Temperaturen) von nichtnegativen
Anzahlen. Die älteren technischen Teilfunktionen verwenden nichtnegative Größen.
Datumsfelder verwenden gültige Kalendertage `YYYY-MM-DD`.
Fehlende Werte werden nicht durch günstige Standardannahmen ersetzt.

`pruefe_risikobehandlung`: `begruendung` (Text), `leitung_zustimmung`,
`konsolidiert` (im Sicherheitskonzept berücksichtigt), `basis_muss_offen`
(noch unerledigte Basis-/MUSS-Anforderungen). Jeweils boolesche Tatsachen:
bei VERMEIDUNG `ursache_entfallen`; bei REDUKTION/TRANSFER `umgesetzt`,
`wirkung_geprueft`; bei TRANSFER außerdem `vertrag_geprueft`. Andere Optionen
benötigen ein akzeptiertes Restrisiko. Ein falscher Nachweis hält die Behandlung
offen; unbekannte Angaben liefern UNBEKANNT, sofern kein Widerspruch entscheidet.

`pruefe_http_datenschutz` (CON.10.A7): `vertrauliche_daten_im_body`,
`client_cache_verhindert`, `formulardaten_maskiert`,
`unerwartetes_browser_speichern_verhindert`, `zugangsdaten_salted_hash`,
`quelltextabruf_geschuetzt`. Alle sind boolesche Feststellungen zum jeweils
benannten Schutz. Die Errata verlangen den Request-Body, keine feste HTTP-Methode.
Für neue Prüfabläufe `pruefe_fachregel("CON.10.A7", angaben)` und dessen
individuellen Eingabevertrag verwenden. Die hier beschriebene Teilfunktion
bleibt eine begrenzte Legacy-Hilfe.

`pruefe_datensicherung` (CON.3.A5/A15): boolesche Tatsachen `plan_eingehalten`,
`mitarbeitende_informiert`, `aufgaben_bekannt`, `tests_regelmaessig`,
`wiederherstellung_erfolgreich`; `wiederherstellungsdauer` und `maximale_dauer`
in derselben selbst gewählten Zeiteinheit. Die Höchstdauer stammt aus dem
institutseigenen Sicherungsplan; keine erfundene allgemeine BSI-Zeitgrenze.

`pruefe_passwortgebrauch` (ORP.4.A8): boolesche Tatsachen `verbindlich_geregelt`,
`zusatzverfahren_geprueft`, `mehrfach_verwendet`, `leicht_erratbar`,
`geheim_gehalten`, `unbeobachtet_eingegeben`, `auf_funktionstasten_gespeichert`,
`schriftlich_fixiert`, `notfallhinterlegung`, `sicher_aufbewahrt`,
`passwortmanager_geprueft`, `drittanbieter_sync_vorhanden`,
`drittanbieter_sync_deaktiviert`, `kompromittierung_oder_verdacht`,
`passwort_gewechselt`. Mehrfachverwendung, leichte Erratbarkeit und Speicherung
auf Funktionstasten sind negative Tatsachen. Schriftliche Fixierung verlangt
Notfallzweck und sichere Aufbewahrung; vorhandene Drittsynchronisation ihre
Deaktivierung; Kompromittierung oder Verdacht einen Wechsel. Echte Passwörter
werden weder benötigt noch gespeichert.

`pruefe_technische_grenzen`: ausschließlich die nachstehend benannten Teilkriterien,
keine Gesamtfreigabe der genannten Anforderungen. Den fachlichen Anwendungsbereich
vorher bestimmen. Z. B. gilt das Brandbekämpfungskriterium INF.2.A9 hier für ein
Rechenzentrum; Feuerlöscher in Serverräumen sind nicht Teil dieser Grenzprüfung.
Anforderung SYS.3.2.1.A29 betrifft das APN-Authentisierungspasswort, keine allgemeine
Passwortlängenregel. Komplexität und CHAP werden separat fachlich beurteilt.

| Anforderung | Geprüfter Umfang |
|---|---|
| APP.2.2.A1 | AD-Funktionsebene mindestens Windows Server 2016 |
| OPS.1.2.6.A11 | Bei erheblicher Genauigkeitsanforderung mindestens vier unabhängige NTP-Server |
| DER.3.2.A5 | Revisionsteam mindestens zwei Personen |
| APP.3.6.A2 | Mindestens ein zusätzlicher Secondary-DNS-Server |
| APP.4.4.A21 | Bei erhöhtem Fremdeinwirkungsrisiko und sehr hohem Schutzbedarf Pod-Laufzeit höchstens 24 Stunden |
| SYS.3.2.1.A29 | Nichtleeres APN-Passwort mit höchstens 64 Stellen; keine Komplexitätsbewertung |
| IND.3.2.A6 | Mindestens eine dedizierte OT-Sicherheitskomponente |
| NET.1.1.A4 | Zwei Firewall-Stufen und mindestens ein Filter zwischen Internet und externer DMZ |
| NET.1.2.A28 | Je mindestens ein interner und externer Management-Client |
| INF.1.A18 | Explizit gewählte Vorgabe von einer oder zwei Begehungen pro Jahr |
| INF.2.A9 | Lösch-/Brandvermeidungsanlage oder Brandfrüherkennung, geschultes Personal, Reaktionspläne und Reaktion innerhalb 180 Sekunden |
| INF.2.A17 | Automatische Schutzreaktion oder ständig besetzte Stelle mit Kontrolle/Reaktion innerhalb 180 Sekunden |
| INF.5.A13 | Feuer- und Rauchwiderstand jeweils mindestens 30 Minuten |
| INF.5.A25 | Feuer- und Rauchwiderstand sowie Zuleitungsfunktion jeweils mindestens 90 Minuten |
| OPS.1.2.2.A19 | Prüfung spätestens nach einem Kalenderjahr |
| INF.1.A36 | Prüfung spätestens nach drei Kalenderjahren |
| INF.12.A10 | Dokumentationstreue binnen vier Kalenderjahren, Arbeitsdokumentation am Änderungstag, Stammdokumentation binnen 28 Tagen nach Abschluss |

Jahresfristen: gleicher Kalendertag im Folgejahr; 29. Februar wird bei fehlendem
Schalttag auf 28. Februar begrenzt. Die Library liest keine Systemzeit: Bezugsdatum
explizit angeben. Frühere Dokumentationsdaten als der jeweilige Änderungsvorgang
gelten nicht als dessen dokumentierte Erledigung.

### APP.2.2.A1: Felder der technischen Teilprüfung

- `funktionsebene_jahr`: nichtnegative ganze Zahl oder unbekannt.

### OPS.1.2.6.A11: Felder der technischen Teilprüfung

- `genauigkeit_erheblich`: bool oder unbekannt.
- `unabhaengige_ntp_server`: nichtnegative ganze Zahl oder unbekannt.

### DER.3.2.A5: Felder der technischen Teilprüfung

- `teammitglieder`: nichtnegative ganze Zahl oder unbekannt.

### APP.3.6.A2: Felder der technischen Teilprüfung

- `zusaetzliche_secondary_server`: nichtnegative ganze Zahl oder unbekannt.

### APP.4.4.A21: Felder der technischen Teilprüfung

- `erhoehtes_fremdeinwirkungsrisiko`: bool oder unbekannt.
- `schutzbedarf_sehr_hoch`: bool oder unbekannt.
- `pod_laufzeit_stunden`: nichtnegative Zahl oder unbekannt.

### SYS.3.2.1.A29: Felder der technischen Teilprüfung

- `passwortlaenge`: nichtnegative ganze Zahl oder unbekannt.

### IND.3.2.A6: Felder der technischen Teilprüfung

- `sicherheitskomponenten_ot`: nichtnegative ganze Zahl oder unbekannt.

### NET.1.1.A4: Felder der technischen Teilprüfung

- `firewall_stufen`: nichtnegative ganze Zahl oder unbekannt.
- `paketfilter_externe_dmz`: nichtnegative ganze Zahl oder unbekannt.

### NET.1.2.A28: Felder der technischen Teilprüfung

- `managementclients_intern`: nichtnegative ganze Zahl oder unbekannt.
- `managementclients_extern`: nichtnegative ganze Zahl oder unbekannt.

### INF.1.A18: Felder der technischen Teilprüfung

- `begehungen_im_jahr`: nichtnegative ganze Zahl oder unbekannt.
- `vorgabe_pro_jahr`: nichtnegative ganze Zahl oder unbekannt.

### INF.2.A9: Felder der technischen Teilprüfung

- `loesch_oder_brandvermeidungsanlage`: bool oder unbekannt.
- `brandfrueherkennung`: bool oder unbekannt.
- `personal_geschult`: bool oder unbekannt.
- `reaktionsplaene`: bool oder unbekannt.
- `reaktionszeit_sekunden`: nichtnegative Zahl oder unbekannt.

### INF.2.A17: Felder der technischen Teilprüfung

- `automatische_schutzreaktion`: bool oder unbekannt.
- `stelle_staendig_besetzt`: bool oder unbekannt.
- `kontrollzeit_sekunden`: nichtnegative Zahl oder unbekannt.

### INF.5.A13: Felder der technischen Teilprüfung

- `feuer_minuten`: nichtnegative Zahl oder unbekannt.
- `rauch_minuten`: nichtnegative Zahl oder unbekannt.

### INF.5.A25: Felder der technischen Teilprüfung

- `feuer_minuten`: nichtnegative Zahl oder unbekannt.
- `rauch_minuten`: nichtnegative Zahl oder unbekannt.
- `zuleitung_minuten`: nichtnegative Zahl oder unbekannt.

### OPS.1.2.2.A19: Felder der technischen Teilprüfung

- `letzte_pruefung`: Datum oder unbekannt.
- `bezugsdatum`: Datum oder unbekannt.

### INF.1.A36: Felder der technischen Teilprüfung

- `letzte_pruefung`: Datum oder unbekannt.
- `bezugsdatum`: Datum oder unbekannt.

### INF.12.A10: Felder der technischen Teilprüfung

- `aenderungsdatum`: Datum oder unbekannt.
- `abschlussdatum`: Datum oder unbekannt.
- `arbeitsdoku_aktualisiert`: Datum oder unbekannt.
- `stammdoku_aktualisiert`: Datum oder unbekannt.
- `letzte_pruefung`: Datum oder unbekannt.
- `bezugsdatum`: Datum oder unbekannt.

