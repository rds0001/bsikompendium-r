\name{bsikompendium}
\alias{bsikompendium}
\alias{anforderung}
\alias{anforderungen}
\alias{anforderungen_fuer}
\alias{baustein}
\alias{bausteine}
\alias{bestimme_schutzbedarf}
\alias{bewerte_risiko}
\alias{eingabevertrag}
\alias{gefaehrdungen}
\alias{pruefe_abweichung}
\alias{pruefe_anforderung}
\alias{pruefe_datensicherung}
\alias{pruefe_http_datenschutz}
\alias{pruefe_informationsverbund}
\alias{pruefe_modellierung}
\alias{pruefe_passwortgebrauch}
\alias{pruefe_risikoanalysebedarf}
\alias{pruefe_risikobehandlung}
\alias{risikomatrix}
\alias{pruefe_technische_grenzen}
\alias{fachlicher_eingabevertrag}
\alias{pruefe_fachregel}
\alias{methodenschritte}
\alias{methodischer_eingabevertrag}
\alias{pruefe_methodenschritt}
\alias{pruefe_checkentscheidung}
\alias{pruefe_risikoverlauf}
\alias{pruefe_checkabdeckung}
\title{Offline-Pruefungen nach BSI IT-Grundschutz}
\description{Native lokale Pruefungen mit expliziten fachlichen Nutzereingaben.
 Quellenstand: Kompendium 2023, Errata 26.03.2026, Standards 200-1/200-2/200-3 Version 1.0.
 Individuelle Vertraege fuer 1835 aktive Anforderungen, 111 Bausteinmodellierungen
 und 83 Methodenschritte. Keine automatische Erhebung realer Massnahmen oder BSI-Zertifizierung.}
\usage{
anforderung(anforderung_id) 
NULL
anforderungen(baustein_id = NULL, kategorie = NULL, 
    entfallen = FALSE) 
NULL
anforderungen_fuer(baustein_ids, vorgehen, h_auswahl = NULL, 
    kernbereich = NULL) 
NULL
baustein(baustein_id) 
NULL
bausteine() 
NULL
bestimme_schutzbedarf(werte, grundwert, anpassung = NULL, 
    effekt = NULL, begruendung = "") 
NULL
bewerte_risiko(haeufigkeit, schaden, matrix) 
NULL
eingabevertrag(anforderung_id) 
NULL
gefaehrdungen(anforderung_id) 
NULL
pruefe_abweichung(anforderung_id, art, begruendung, 
    gefaehrdungsbewertungen, leitung_zustimmung = NULL, 
    alternativmassnahme = "", gleichwertig = NULL, 
    basis_ausnahme_begruendet = NULL) 
NULL
pruefe_anforderung(anforderung_id, bewertungen, anwendbar = NULL, 
    begruendung = "") 
NULL
pruefe_datensicherung(angaben) 
NULL
pruefe_http_datenschutz(angaben) 
NULL
pruefe_informationsverbund(objekte) 
NULL
pruefe_modellierung(objekte, zuordnungen, institution = NULL, 
    unterliegt_vsa = NULL) 
NULL
pruefe_passwortgebrauch(angaben) 
NULL
pruefe_risikoanalysebedarf(schutzbedarf, hinreichend_modelliert, 
    typisches_szenario) 
NULL
pruefe_risikobehandlung(option, restrisiko, akzeptierte_kategorien, 
    angaben) 
NULL
risikomatrix() 
NULL
pruefe_technische_grenzen(anforderung_id, angaben) 
NULL
fachlicher_eingabevertrag(anforderung_id) 
NULL
pruefe_fachregel(anforderung_id, angaben) 
NULL
methodenschritte() 
NULL
methodischer_eingabevertrag(schritt_id) 
NULL
pruefe_methodenschritt(schritt_id, angaben) 
NULL
pruefe_checkentscheidung(anforderung_id, angaben) 
NULL
pruefe_risikoverlauf(vorher, nachher, matrix, akzeptierte_kategorien, 
    weitere_akzeptanzkriterien, angaben) 
NULL
pruefe_checkabdeckung(vorgehen, modellierung, checks) 
NULL
}
\arguments{
\item{anforderung_id}{Katalog-ID einer einzelnen Anforderung, etwa CON.10.A7.}
\item{baustein_id}{Katalog-ID eines Bausteins, etwa CON.10; bei Filterfunktionen optional.}
\item{baustein_ids}{Nichtleere Liste eindeutiger Baustein-IDs, die fachlich ausgewählt wurden.}
\item{kategorie}{Optionaler Filter B (Basis), S (Standard) oder H (erhöhter Schutzbedarf).}
\item{entfallen}{FALSE/False schließt entfallene Anforderungen aus; TRUE/True nimmt sie zusätzlich auf.}
\item{vorgehen}{Explizite Grundschutz-Vorgehensweise: BASIS, STANDARD oder KERN.}
\item{h_auswahl}{Optionale Liste ausdrücklich ausgewählter aktiver H-Anforderungen aus den angegebenen Bausteinen.}
\item{kernbereich}{Bei KERN muss TRUE/True die vorherige fachliche Festlegung des Kernbereichs bestätigen.}
\item{bewertungen}{Objekt mit Kriterium-IDs aus eingabevertrag als Schlüsseln. Je Block: relevant, umgesetzt, wirksam, angemessen (bool oder unbekannt) und optionale begruendung. Alle enthaltenen Quellsätze fachlich bewerten. relevant=false verlangt eine Begründung.}
\item{anwendbar}{Explizite fachliche Anwendbarkeit: TRUE/True, FALSE/False oder NULL/None. Ausschluss verlangt begruendung.}
\item{begruendung}{Konkrete nichtleere fachliche Begründung bei Ausschluss, Abweichung oder Schutzbedarfsanpassung; sonst optional.}
\item{art}{NICHT_RELEVANT, ALTERNATIVMASSNAHME oder RISIKOAKZEPTANZ. Der Abweichungsbefund ist keine Umsetzung der ursprünglichen Anforderung.}
\item{gefaehrdungsbewertungen}{Objekt mit den IDs aus gefaehrdungen. true bestätigt je Gefährdung die fachlich begründete Nichtrelevanz, die ausreichende alternative Abdeckung beziehungsweise die dokumentierte Risikobewertung, passend zur art; false widerspricht dieser Begründung, null lässt sie offen.}
\item{leitung_zustimmung}{Explizite Zustimmung der Leitung (bool oder unbekannt), bei Risikoakzeptanz erforderlich.}
\item{alternativmassnahme}{Nichtleere Beschreibung der tatsächlich vorgesehenen gleichwertigen Alternative.}
\item{gleichwertig}{Fachlich bestätigte Gleichwertigkeit der Alternativmaßnahme (bool oder unbekannt).}
\item{basis_ausnahme_begruendet}{Bei alternativer Umsetzung einer B-Anforderung: ausdrückliche fachliche Ausnahmebegründung bestätigt (bool oder unbekannt).}
\item{werte}{Nichtleere Liste relevanter Ausgangseinstufungen: NORMAL, HOCH, SEHR_HOCH oder unbekannt.}
\item{grundwert}{vertraulichkeit, integritaet oder verfuegbarkeit; jede Dimension separat berechnen.}
\item{anpassung}{Optionale fachlich ermittelte Zielstufe NORMAL, HOCH oder SEHR_HOCH; nur gemeinsam mit effekt und Begründung.}
\item{effekt}{KUMULATION darf bekannte Einstufungen nicht senken; VERTEILUNG darf das bekannte Maximum nicht erhöhen.}
\item{schutzbedarf}{Objekt mit vertraulichkeit, integritaet und verfuegbarkeit; je NORMAL, HOCH, SEHR_HOCH oder unbekannt. Fehlende Dimensionen sind unbekannt.}
\item{hinreichend_modelliert}{Fachliche Aussage, ob das Zielobjekt durch die Bausteine hinreichend modelliert ist (bool oder unbekannt).}
\item{typisches_szenario}{Fachliche Aussage, ob das Zielobjekt im vorgesehenen typischen Einsatzszenario betrieben wird (bool oder unbekannt).}
\item{haeufigkeit}{Achsenwert der explizit gewählten Matrix oder unbekannt.}
\item{schaden}{Schadensachse der explizit gewählten Matrix oder unbekannt.}
\item{matrix}{Explizit BSI_200_3_BEISPIEL_2017 oder Objekt mit id, haeufigkeiten (Liste), schaeden (Liste), werte (Zeilen nach Schäden, Spalten nach Häufigkeiten). Jede Zelle: GERING, MITTEL, HOCH oder SEHR_HOCH. Beispiel ist keine allgemeine BSI-Vorgabe.}
\item{option}{VERMEIDUNG, REDUKTION, TRANSFER oder AKZEPTANZ.}
\item{restrisiko}{Aktuell fachlich bewertetes Restrisiko GERING, MITTEL, HOCH, SEHR_HOCH oder unbekannt; bei VERMEIDUNG nicht benötigt.}
\item{akzeptierte_kategorien}{Liste der ausdrücklich organisationsseitig akzeptierten Risikokategorien; keine automatische Grenze.}
\item{angaben}{Benanntes Tatsachenobjekt mit den funktionsspezifischen Feldern im Abschnitt Datenfelder. Fehlende zulässige Angaben sind unbekannt; unbekannte Feldnamen werden abgewiesen.}
\item{objekte}{Nichtleere Liste mit id, typ und optional abhaengigkeiten (Liste bestehender IDs). Typ: Informationsverbund, Prozess, Information, Anwendung, IT-System, Netz, Gebäude/Raum, Kommunikationsverbindung. Keine automatische Inventarvollständigkeit.}
\item{zuordnungen}{Liste mit objekt_id, baustein_id und fachlich_passend (bool oder unbekannt). Direkte Zuordnung auf Zielobjekttypen aus baustein; prozessübergreifende Bausteine gehören auf den Informationsverbund. Abhängigkeiten ersetzen keine direkte Zuordnung.}
\item{institution}{Für CON.11.1: BUNDESBEHOERDE, BUNDESUNMITTELBARE_EINRICHTUNG, LANDESBEHOERDE, UNTERNEHMEN oder SONSTIGE; optional/unbekannt.}
\item{unterliegt_vsa}{Für CON.11.1 zusätzlich bestätigte Unterstellung unter die VSA (bool oder unbekannt).}
\item{schritt_id}{ID eines individuell implementierten Methodenschritts aus methodenschritte(), etwa BSI2003.RICHTLINIE; separat von Kompendium-Anforderungs-IDs.}
\item{vorher}{Objekt mit haeufigkeit, schaden und eigenem bewertungsstand (KONZEPT oder UMGESETZT) für die erste Einstufung. Bereits hier dürfen Maßnahmen nur geplant sein; fehlender Ist-Bezug bleibt unbekannt.}
\item{nachher}{Objekt mit haeufigkeit, schaden und eigenem bewertungsstand (KONZEPT oder UMGESETZT) nach zusätzlicher Behandlung. Bei ausgeschlossener Ursache keine Risikokategorie angeben. Bei alleiniger AKZEPTANZ und geänderten Achsen ist neubewertungsgrund als konkrete Änderung der Umstände oder Datenlage erforderlich.}
\item{weitere_akzeptanzkriterien}{Sammlung mit objekte (je id und erfuellt) sowie vollstaendig. Alle zusätzlich zur Risikokategorie geltenden institutionellen Akzeptanzbedingungen konkret erfassen; ausdrücklich vollständig leere Menge nur, wenn keine weiteren Bedingungen gelten.}
\item{modellierung}{Vollstaendiger Bestand konkreter Baustein-/Zielobjekt-Zuordnungen mit objekte und vollstaendig.}
\item{checks}{Bestand konkreter Anforderungs-/Zielobjekt-Pruefstatus mit objekte und vollstaendig; eine Abdeckungspruefung ist keine Erfuellungspruefung.}
}
\value{Katalogfunktionen liefern Listen von IDs, Metadaten oder Eingabevertraegen.
 Pruefungen liefern benannte Listen mit regel_id, quellenfassung, status,
 anwendbarkeit, befund, begruendung und fehlende_angaben sowie diagnosespezifischen
 Zusatzfeldern. Individuelle Fachpruefungen enthalten bekannte_maengel und
 teilbefunde mit Kriterien-ID, Modalitaet und Anwendbarkeit. Fehlende individuelle
 Regelvertraege wuerden REGEL_UNGEKLAERT ohne Fachbefund liefern; alle aktiven
 Anforderungen der angegebenen Edition besitzen individuelle Vertraege.
 UNBEKANNT ist keine Erfuellung. Ungueltige Eingaben signalisieren
 die Condition bsikompendium_eingabefehler mit code EINGABE_UNGUELTIG.}
\details{Objekte sind benannte Listen, Arrays unbenannte Listen. Logische
 Tatsachen sind TRUE, FALSE oder NULL; logisches NA gilt ebenfalls als unbekannt.
 Die vollstaendigen funktionsspezifischen Datenfelder und technischen Grenzen
 stehen in doc/FACHLOGIK.md und doc/API.md. fachlicher_eingabevertrag beschreibt
 individuell hergeleitete Felder, Massstaebe und Kriterien; pruefe_fachregel
 wertet diese aus. Sammlungen enthalten objekte und vollstaendig. Regelmaessigkeit
 verwendet entweder Kalenderdaten mit intervall_tage oder UTC-Zeitpunkte mit
 intervall_sekunden; eine Mischung ist ungueltig. pruefe_anforderung aggregiert
 aeltere Absatz-Selbstauskuenfte und ersetzt keine individuelle Fachpruefung.
 Ein positiver technischer Teilbefund bestaetigt nicht die ganze Anforderung.
 methodenschritte liefert 194 IDs: 111 BSIMODELL-Modellierungen und 83 Schritte
 der Standards 200-1/200-2/200-3. methodischer_eingabevertrag beschreibt die
 konkreten methodischen Felder; pruefe_methodenschritt wertet diese nativ aus.
 Modellierungserfuellung ist keine Erfuellung aller zugeordneten Anforderungen.
 Die Beispielsrisikomatrix ist keine universelle BSI-Vorgabe.
 Das Beispiel individueller_pruefablauf verarbeitet dieselbe JSON-Datei wie
 Python. kundenportal ist ein Legacy-Beispiel fuer Absatz-Selbstauskuenfte.}
\references{Bundesamt fuer Sicherheit in der Informationstechnik:
 IT-Grundschutz-Kompendium Edition 2023; BSI-Standards 200-1, 200-2 und 200-3.
 \url{https://www.bsi.bund.de/grundschutz}}
\examples{
bestimme_schutzbedarf(list("NORMAL", "HOCH"), "verfuegbarkeit")
bewerte_risiko("HAEUFIG", "BETRAECHTLICH", "BSI_200_3_BEISPIEL_2017")
pruefe_fachregel("ORP.3.A6", list(mitarbeitende=list(vollstaendig=TRUE,
  objekte=list(list(geschult_aufgaben=TRUE, geschult_verantwortung=FALSE)))))
length(methodenschritte())
system.file("examples", "individueller_pruefablauf.R", package="bsikompendium")
system.file("doc", "API.md", package="bsikompendium")
}
