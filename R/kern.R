.sort <- function(x) if (!length(x)) character() else sort(x, method = "radix")
# Native BSI-Pr\u00fcfungen. Keine Python-Laufzeit, kein Netz, keine Systemzeit.
.fassung <- "BSI_KOMPENDIUM_2023_ERRATA_2026_03_26"
.stufen <- c("NORMAL", "HOCH", "SEHR_HOCH")
.risiken <- c("GERING", "MITTEL", "HOCH", "SEHR_HOCH")
.grundwerte <- c("vertraulichkeit", "integritaet", "verfuegbarkeit")

.fehler <- function(text) {
  stop(structure(list(message = text, call = NULL, code = "EINGABE_UNGUELTIG"),
                 class = c("bsikompendium_eingabefehler", "error", "condition")))
}
.fordere <- function(b, text) if (!isTRUE(b)) .fehler(text)
.text <- function(x, name) .fordere(is.character(x) && length(x) == 1L && !is.na(x) &&
                                    nzchar(trimws(x)), paste0(name, ": Text erforderlich"))
.bool <- function(x, name) .fordere(is.null(x) || (is.logical(x) && length(x) == 1L),
                                    paste0(name, ": bool oder NULL erforderlich"))
.unbekannt <- function(x) is.null(x) || (length(x) == 1L && is.atomic(x) && is.na(x))
.logisch <- function(x) if (.unbekannt(x)) NULL else x
.wahl <- function(x, werte, name, unbekannt = FALSE) {
  .fordere((unbekannt && is.null(x)) || (is.character(x) && length(x) == 1L &&
            !is.na(x) && x %in% werte), paste0(name, ": unzul\u00e4ssiger Wert"))
}
.liste <- function(x, name, leer = TRUE) {
  .fordere(is.list(x) && (is.null(names(x)) || length(x) == 0L) && (leer || length(x) > 0L),
           paste0(name, ": unbenannte Liste erforderlich"))
}
.objekt <- function(x, erlaubt, name) {
  .fordere(is.list(x) && (length(x) == 0L || (!is.null(names(x)) &&
            all(nzchar(names(x))) && !anyDuplicated(names(x)))) &&
            all(names(x) %in% erlaubt), paste0(name, ": benanntes Objekt mit erlaubten Feldern erforderlich"))
}
.und <- function(x) {
  if (any(vapply(x, identical, logical(1), FALSE))) return(FALSE)
  if (any(vapply(x, .unbekannt, logical(1)))) return(NULL)
  TRUE
}
.oder <- function(x) {
  if (any(vapply(x, isTRUE, logical(1)))) return(TRUE)
  if (any(vapply(x, .unbekannt, logical(1)))) return(NULL)
  FALSE
}
.ergebnis <- function(regel, befund, begruendung, fehlend = character(), anwendbar = TRUE, ...) {
  c(list(regel_id = regel, quellenfassung = .fassung, status = "AUSGEWERTET",
         anwendbarkeit = if (.unbekannt(anwendbar)) "UNBEKANNT" else if (anwendbar) "WAHR" else "FALSCH",
         befund = befund, begruendung = begruendung,
         fehlende_angaben = as.list(.sort(unique(unlist(fehlend))))), list(...))
}
.befund <- function(werte) {
  fehlend <- .sort(names(werte)[vapply(werte, .unbekannt, logical(1))])
  maengel <- .sort(names(werte)[vapply(werte, identical, logical(1), FALSE)])
  befund <- if (length(fehlend)) "UNBEKANNT" else if (!length(werte)) "NICHT_ANWENDBAR" else
    if (!length(maengel)) "ERFUELLT" else if (length(maengel) == length(werte)) "NICHT_ERFUELLT" else "TEILWEISE_ERFUELLT"
  list(befund = befund, fehlend = fehlend, maengel = maengel)
}
.katalog <- local({
  daten <- NULL
  function() {
    if (is.null(daten)) {
      pfad <- system.file("extdata", "katalog.json", package = "bsikompendium")
      if (!nzchar(pfad)) stop("Installierte Katalogressource fehlt")
      daten <<- jsonlite::fromJSON(pfad, simplifyVector = FALSE)
    }
    daten
  }
})

anforderung <- function(anforderung_id) {
  .text(anforderung_id, "anforderung_id")
  .fordere(anforderung_id %in% names(.katalog()$anforderungen), "Unbekannte Anforderung")
  .katalog()$anforderungen[[anforderung_id]]
}
baustein <- function(baustein_id) {
  .text(baustein_id, "baustein_id")
  .fordere(baustein_id %in% names(.katalog()$bausteine), "Unbekannter Baustein")
  .katalog()$bausteine[[baustein_id]]
}
bausteine <- function() as.list(.sort(names(.katalog()$bausteine)))
anforderungen <- function(baustein_id = NULL, kategorie = NULL, entfallen = FALSE) {
  .fordere(is.logical(entfallen) && length(entfallen) == 1L && !is.na(entfallen), "entfallen: bool erforderlich")
  if (!is.null(baustein_id)) baustein(baustein_id)
  .wahl(kategorie, c("B", "S", "H"), "kategorie", TRUE)
  alle <- .katalog()$anforderungen
  passt <- vapply(alle, function(r) (is.null(baustein_id) || r$baustein_id == baustein_id) &&
                    (is.null(kategorie) || r$kategorie == kategorie) && (entfallen || !r$entfallen), logical(1))
  as.list(.sort(names(alle)[passt]))
}
anforderungen_fuer <- function(baustein_ids, vorgehen, h_auswahl = NULL, kernbereich = NULL) {
  .liste(baustein_ids, "baustein_ids", FALSE)
  for (id in baustein_ids) baustein(id)
  .fordere(!anyDuplicated(unlist(baustein_ids)), "Doppelte Bausteine")
  .wahl(vorgehen, c("BASIS", "STANDARD", "KERN"), "vorgehen")
  .bool(kernbereich, "kernbereich")
  if (vorgehen == "KERN") .fordere(isTRUE(kernbereich), "Kernbereich muss ausdr\u00fccklich festgelegt sein")
  if (is.null(h_auswahl)) h_auswahl <- list()
  .liste(h_auswahl, "h_auswahl")
  for (id in h_auswahl) {
    r <- anforderung(id)
    .fordere(!r$entfallen && r$kategorie == "H" && r$baustein_id %in% unlist(baustein_ids), "H-Auswahl passt nicht")
  }
  .fordere(!anyDuplicated(unlist(h_auswahl)), "Doppelte H-Anforderungen")
  ids <- unlist(lapply(baustein_ids, anforderungen))
  kategorien <- if (vorgehen == "BASIS") "B" else c("B", "S")
  ids <- ids[vapply(ids, function(id) anforderung(id)$kategorie %in% kategorien, logical(1))]
  as.list(.sort(unique(c(ids, unlist(h_auswahl)))))
}
eingabevertrag <- function(anforderung_id) {
  r <- anforderung(anforderung_id)
  list(anforderung_id = anforderung_id, quellenfassung = .fassung,
       pdf_seiten = r$pdf_seiten, kriterien = r$kriterien,
       felder_je_kriterium = as.list(c("relevant", "umgesetzt", "wirksam", "angemessen", "begruendung")),
       bewertungsumfang = "Qualifizierte Bewertung aller Teilanforderungen des bezeichneten Quellenabsatzes; keine Dokumentenpr\u00fcfung.",
       unbekannt = "null", nichtrelevanz = "relevant=false verlangt eine Begr\u00fcndung.")
}
gefaehrdungen <- function(anforderung_id) anforderung(anforderung_id)$gefaehrdungen

pruefe_anforderung <- function(anforderung_id, bewertungen, anwendbar = NULL, begruendung = "") {
  r <- anforderung(anforderung_id)
  .bool(anwendbar, "anwendbar")
  .fordere(is.character(begruendung) && length(begruendung) == 1L && !is.na(begruendung), "begruendung: Text erforderlich")
  ids <- vapply(r$kriterien, function(k) k$kriterium_id, character(1))
  .objekt(bewertungen, ids, "bewertungen")
  for (id in names(bewertungen)) {
    d <- bewertungen[[id]]
    .objekt(d, c("relevant", "umgesetzt", "wirksam", "angemessen", "begruendung"), id)
    for (k in c("relevant", "umgesetzt", "wirksam", "angemessen")) .bool(d[[k]], paste0(id, ".", k))
    if ("begruendung" %in% names(d)) .fordere(is.character(d$begruendung) && length(d$begruendung) == 1L && !is.na(d$begruendung), "Begr\u00fcndung muss Text sein")
    if (identical(d$relevant, FALSE)) .text(d$begruendung, paste0(id, ".begruendung"))
  }
  if (r$entfallen) return(.ergebnis(anforderung_id, "NICHT_ANWENDBAR", "Anforderung ist in der Quelle entfallen.", anwendbar = FALSE))
  if (identical(anwendbar, FALSE)) {
    .text(begruendung, "begruendung")
    return(.ergebnis(anforderung_id, "NICHT_ANWENDBAR", begruendung, anwendbar = FALSE))
  }
  if (.unbekannt(anwendbar)) return(.ergebnis(anforderung_id, "UNBEKANNT", "Anwendbarkeit nicht entschieden.", "anwendbar", NULL))
  werte <- list(); fehlend <- character()
  for (id in .sort(ids)) {
    d <- bewertungen[[id]]
    if (identical(d$relevant, FALSE)) next
    if (.unbekannt(d$relevant)) {
      werte[id] <- list(NULL)
      fehlend <- c(fehlend, paste0(id, ".relevant")); next
    }
    vals <- lapply(c("umgesetzt", "wirksam", "angemessen"), function(k) .logisch(d[[k]]))
    werte[id] <- list(.und(vals))
    if (is.null(werte[[id]])) for (k in c("umgesetzt", "wirksam", "angemessen")) {
      if (.unbekannt(d[[k]])) fehlend <- c(fehlend, paste0(id, ".", k))
    }
  }
  if (!length(ids)) return(.ergebnis(anforderung_id, "UNBEKANNT", "Kein automatischer Pr\u00fcfumfang spezifiziert.", "fachliche_pruefung"))
  b <- .befund(werte)
  teile <- lapply(werte, function(v) if (.unbekannt(v)) "UNBEKANNT" else if (v) "ERFUELLT" else "NICHT_ERFUELLT")
  if (!length(teile)) teile <- structure(list(), names = character())
  .ergebnis(anforderung_id, b$befund, "Bewertung der relevanten Quellenbl\u00f6cke nach BSI 200-2, 8.4.2.",
             fehlend, length(werte) > 0L, bekannte_maengel = as.list(b$maengel), teilbefunde = teile)
}

pruefe_abweichung <- function(anforderung_id, art, begruendung, gefaehrdungsbewertungen,
                             leitung_zustimmung = NULL, alternativmassnahme = "", gleichwertig = NULL,
                             basis_ausnahme_begruendet = NULL) {
  r <- anforderung(anforderung_id)
  .wahl(art, c("NICHT_RELEVANT", "ALTERNATIVMASSNAHME", "RISIKOAKZEPTANZ"), "art")
  .text(begruendung, "begruendung")
  .bool(leitung_zustimmung, "leitung_zustimmung"); .bool(gleichwertig, "gleichwertig")
  .bool(basis_ausnahme_begruendet, "basis_ausnahme_begruendet")
  .fordere(is.character(alternativmassnahme) && length(alternativmassnahme) == 1L && !is.na(alternativmassnahme), "alternativmassnahme: Text erforderlich")
  .objekt(gefaehrdungsbewertungen, unlist(r$gefaehrdungen), "gefaehrdungsbewertungen")
  for (k in names(gefaehrdungsbewertungen)) .bool(gefaehrdungsbewertungen[[k]], k)
  if (r$entfallen) return(.ergebnis(anforderung_id, "NICHT_ANWENDBAR", "Entfallene Anforderung.", anwendbar = FALSE))
  if (art == "RISIKOAKZEPTANZ" && (r$kategorie == "B" || any(vapply(r$kriterien, function(k) k$strikt, logical(1))))) {
    return(.ergebnis(anforderung_id, "NICHT_ZULAESSIG", "Basis-/MUSS-Anforderungen nicht durch Risikoakzeptanz ersetzen."))
  }
  werte <- setNames(lapply(r$gefaehrdungen, function(k) .logisch(gefaehrdungsbewertungen[[k]])), unlist(r$gefaehrdungen))
  if (art == "ALTERNATIVMASSNAHME") {
    .text(alternativmassnahme, "alternativmassnahme")
    werte["gleichwertig"] <- list(.logisch(gleichwertig))
    if (r$kategorie == "B") werte["basis_ausnahme_begruendet"] <- list(.logisch(basis_ausnahme_begruendet))
  }
  if (art == "RISIKOAKZEPTANZ") werte["leitung_zustimmung"] <- list(.logisch(leitung_zustimmung))
  e <- .und(werte)
  .ergebnis(anforderung_id, if (is.null(e)) "UNBEKANNT" else if (e) "ZULAESSIG_BEGRUENDET" else "NICHT_ZULAESSIG",
             "Einzelfallnachweise; keine Aussage \u00fcber Umsetzung der urspr\u00fcnglichen Anforderung.",
             names(werte)[vapply(werte, .unbekannt, logical(1))], abweichungsart = art)
}

bestimme_schutzbedarf <- function(werte, grundwert, anpassung = NULL, effekt = NULL, begruendung = "") {
  .liste(werte, "werte", FALSE); .wahl(grundwert, .grundwerte, "grundwert")
  for (v in werte) .wahl(v, .stufen, "schutzbedarf", TRUE)
  .wahl(anpassung, .stufen, "anpassung", TRUE)
  .wahl(effekt, c("KUMULATION", "VERTEILUNG"), "effekt", TRUE)
  .fordere(identical(is.null(anpassung), is.null(effekt)), "Anpassung und Effekt gemeinsam angeben")
  bekannt <- unlist(lapply(werte, function(v) if (is.null(v)) NULL else match(v, .stufen)))
  maximum <- if (length(bekannt)) max(bekannt) else 0L
  if (!is.null(anpassung)) {
    .text(begruendung, "begruendung")
    if (effekt == "KUMULATION") .fordere(match(anpassung, .stufen) >= maximum, "Kumulation darf nicht senken")
    if (effekt == "VERTEILUNG") .fordere(maximum > 0L && match(anpassung, .stufen) <= maximum, "Verteilung braucht Ausgangseinstufung")
  }
  offen <- any(vapply(werte, is.null, logical(1))) && maximum < 3L
  if (offen) return(.ergebnis("SCHUTZBEDARF", "UNBEKANNT", "Ausgangseinstufungen unvollst\u00e4ndig.", "werte", grundwert = grundwert))
  .ergebnis("SCHUTZBEDARF", if (is.null(anpassung)) .stufen[maximum] else anpassung,
             "Maximumprinzip; Anpassung nur als begr\u00fcndete fachliche Vorgabe.", grundwert = grundwert, effekt = effekt)
}

pruefe_risikoanalysebedarf <- function(schutzbedarf, hinreichend_modelliert, typisches_szenario) {
  .objekt(schutzbedarf, .grundwerte, "schutzbedarf")
  for (v in schutzbedarf) .wahl(v, .stufen, "schutzbedarf", TRUE)
  .bool(hinreichend_modelliert, "hinreichend_modelliert"); .bool(typisches_szenario, "typisches_szenario")
  werte <- setNames(lapply(.grundwerte, function(k) if (is.null(schutzbedarf[[k]])) NULL else schutzbedarf[[k]] != "NORMAL"), .grundwerte)
  werte["hinreichend_modelliert"] <- list(if (.unbekannt(hinreichend_modelliert)) NULL else !hinreichend_modelliert)
  werte["typisches_szenario"] <- list(if (.unbekannt(typisches_szenario)) NULL else !typisches_szenario)
  bedarf <- .oder(werte)
  .ergebnis("RISIKOANALYSEBEDARF", if (is.null(bedarf)) "UNBEKANNT" else if (bedarf) "ERFORDERLICH" else "KEIN_ZUSAETZLICHER_ANLASS",
             "BSI 200-3, 1.2; keine Sicherheits- oder Vollst\u00e4ndigkeitsgarantie.",
             names(werte)[vapply(werte, .unbekannt, logical(1))],
             ausloeser = as.list(.sort(names(werte)[vapply(werte, isTRUE, logical(1))])))
}

risikomatrix <- function() .katalog()$risikomatrix
.matrix <- function(matrix) {
  if (is.character(matrix)) {
    .wahl(matrix, "BSI_200_3_BEISPIEL_2017", "matrix")
    return(risikomatrix())
  }
  .objekt(matrix, c("id", "haeufigkeiten", "schaeden", "werte"), "matrix")
  .text(matrix$id, "matrix.id")
  for (key in c("haeufigkeiten", "schaeden")) {
    vals <- matrix[[key]]; .liste(vals, key, FALSE)
    for (v in vals) .text(v, key)
    .fordere(!anyDuplicated(unlist(vals)), "Doppelte Achsenwerte")
  }
  .liste(matrix$werte, "werte", FALSE)
  .fordere(length(matrix$werte) == length(matrix$schaeden), "Falsche Zeilenzahl")
  for (row in matrix$werte) {
    .liste(row, "Matrixzeile")
    .fordere(length(row) == length(matrix$haeufigkeiten), "Falsche Spaltenzahl")
    for (v in row) .wahl(v, .risiken, "Risikokategorie")
  }
  matrix
}
bewerte_risiko <- function(haeufigkeit, schaden, matrix) {
  m <- .matrix(matrix)
  .wahl(haeufigkeit, unlist(m$haeufigkeiten), "haeufigkeit", TRUE)
  .wahl(schaden, unlist(m$schaeden), "schaden", TRUE)
  fehlend <- c(if (is.null(haeufigkeit)) "haeufigkeit", if (is.null(schaden)) "schaden")
  wert <- if (length(fehlend)) "UNBEKANNT" else m$werte[[match(schaden, unlist(m$schaeden))]][[match(haeufigkeit, unlist(m$haeufigkeiten))]]
  .ergebnis("RISIKOEINSTUFUNG", wert, "Einstufung nach ausdr\u00fccklich ausgew\u00e4hlter Matrix.", fehlend, matrix_id = m$id)
}

pruefe_risikobehandlung <- function(option, restrisiko, akzeptierte_kategorien, angaben) {
  .wahl(option, c("VERMEIDUNG", "REDUKTION", "TRANSFER", "AKZEPTANZ"), "option")
  .wahl(restrisiko, .risiken, "restrisiko", TRUE)
  .liste(akzeptierte_kategorien, "akzeptierte_kategorien")
  for (v in akzeptierte_kategorien) .wahl(v, .risiken, "akzeptierte_kategorien")
  .fordere(!anyDuplicated(unlist(akzeptierte_kategorien)), "Doppelte Risikokategorien")
  felder <- c("begruendung", "leitung_zustimmung", "konsolidiert", "umgesetzt", "wirkung_geprueft",
              "vertrag_geprueft", "ursache_entfallen", "basis_muss_offen")
  .objekt(angaben, felder, "angaben")
  for (k in setdiff(felder, "begruendung")) .bool(angaben[[k]], k)
  .text(angaben$begruendung, "begruendung")
  werte <- list(leitung_zustimmung = .logisch(angaben$leitung_zustimmung), konsolidiert = .logisch(angaben$konsolidiert))
  werte["basis_muss_offen"] <- list(if (.unbekannt(angaben$basis_muss_offen)) NULL else !angaben$basis_muss_offen)
  if (option == "VERMEIDUNG") werte["ursache_entfallen"] <- list(.logisch(angaben$ursache_entfallen)) else {
    werte["restrisiko"] <- list(if (is.null(restrisiko)) NULL else restrisiko %in% unlist(akzeptierte_kategorien))
  }
  if (option %in% c("REDUKTION", "TRANSFER")) for (k in c("umgesetzt", "wirkung_geprueft")) werte[k] <- list(.logisch(angaben[[k]]))
  if (option == "TRANSFER") werte["vertrag_geprueft"] <- list(.logisch(angaben$vertrag_geprueft))
  e <- .und(werte)
  .ergebnis("RISIKOBEHANDLUNG", if (is.null(e)) "UNBEKANNT" else if (e) "NACHVOLLZIEHBAR_ABGESCHLOSSEN" else "BEHANDLUNG_OFFEN",
             "Dokumentierte Bewertung, keine Garantie der realen Wirksamkeit.", names(werte)[vapply(werte, .unbekannt, logical(1))], option = option)
}

pruefe_informationsverbund <- function(objekte) {
  .liste(objekte, "objekte", FALSE); ids <- character()
  typen <- c("Informationsverbund", "Prozess", "Information", "Anwendung", "IT-System", "Netz", "Geb\u00e4ude/Raum", "Kommunikationsverbindung")
  for (o in objekte) {
    .objekt(o, c("id", "typ", "abhaengigkeiten"), "objekt")
    .text(o$id, "id"); .wahl(o$typ, typen, "typ"); ids <- c(ids, o$id)
    a <- if ("abhaengigkeiten" %in% names(o)) o$abhaengigkeiten else list()
    .liste(a, "abhaengigkeiten")
    for (v in a) .text(v, "abhaengigkeit")
    .fordere(!anyDuplicated(unlist(a)), "Doppelte Beziehung")
  }
  .fordere(!anyDuplicated(ids), "Doppelte Objekt-ID")
  fehlende <- .sort(setdiff(unique(unlist(lapply(objekte, function(o) o$abhaengigkeiten))), ids))
  .ergebnis("INFORMATIONSVERBUND", if (length(fehlende)) "BEZIEHUNG_FEHLT" else "STRUKTURELL_KONSISTENT",
             "Pr\u00fcft nur \u00fcbergebene Objekte; reale Inventarvollst\u00e4ndigkeit ist nicht automatisch feststellbar.", fehlende)
}

pruefe_modellierung <- function(objekte, zuordnungen, institution = NULL, unterliegt_vsa = NULL) {
  basis <- pruefe_informationsverbund(objekte); .liste(zuordnungen, "zuordnungen")
  .wahl(institution, c("BUNDESBEHOERDE", "BUNDESUNMITTELBARE_EINRICHTUNG", "LANDESBEHOERDE", "UNTERNEHMEN", "SONSTIGE"), "institution", TRUE)
  .bool(unterliegt_vsa, "unterliegt_vsa")
  ids <- vapply(objekte, function(o) o$id, character(1)); index <- setNames(objekte, ids)
  teile <- list(); paare <- character(); belegt <- character()
  for (z in zuordnungen) {
    .objekt(z, c("objekt_id", "baustein_id", "fachlich_passend"), "zuordnung")
    .text(z$objekt_id, "objekt_id"); .fordere(z$objekt_id %in% ids, "Zielobjekt fehlt")
    b <- baustein(z$baustein_id); .bool(z$fachlich_passend, "fachlich_passend")
    key <- paste0(z$objekt_id, ":", z$baustein_id)
    .fordere(!key %in% paare, "Doppelte Bausteinzuordnung"); paare <- c(paare, key)
    typ <- index[[z$objekt_id]]$typ
    passend <- any(vapply(b$zielobjekttypen, function(v) typ == v ||
                           (typ == "Informationsverbund" && startsWith(v, "Informationsverbund/")), logical(1)))
    werte <- list(passend, .logisch(z$fachlich_passend))
    if (z$baustein_id == "CON.11.1") werte <- c(werte, list(if (is.null(institution)) NULL else
      institution %in% c("BUNDESBEHOERDE", "BUNDESUNMITTELBARE_EINRICHTUNG"), .logisch(unterliegt_vsa)))
    teile[key] <- list(.und(werte)); if (isTRUE(teile[[key]])) belegt <- c(belegt, z$objekt_id)
  }
  offen <- .sort(setdiff(ids, belegt))
  befund <- if (any(vapply(teile, .unbekannt, logical(1)))) "UNBEKANNT" else
    if (length(offen) || any(vapply(teile, identical, logical(1), FALSE)) || basis$befund != "STRUKTURELL_KONSISTENT")
      "MODELLIERUNGSLUECKEN" else "ZUORDNUNGEN_BESTAETIGT"
  .ergebnis("MODELLIERUNG", befund, "Typkompatibilit\u00e4t und explizite Fachbewertung; kein automatischer Vollst\u00e4ndigkeitsbeweis.",
             names(teile)[vapply(teile, .unbekannt, logical(1))], unbestaetigte_objekte = as.list(offen),
             unpassende_zuordnungen = as.list(.sort(names(teile)[vapply(teile, identical, logical(1), FALSE)])))
}

.fakten <- function(angaben, felder) {
  .objekt(angaben, felder, "angaben")
  for (k in felder) .bool(angaben[[k]], k)
  setNames(lapply(.sort(felder), function(k) .logisch(angaben[[k]])), .sort(felder))
}
.teilpruefung <- function(regel, werte) {
  b <- .befund(werte)
  .ergebnis(regel, b$befund, "Direkte Teilkriterienpr\u00fcfung im dokumentierten Umfang.", b$fehlend,
             bekannte_maengel = as.list(b$maengel))
}
pruefe_http_datenschutz <- function(angaben) {
  .teilpruefung("CON.10.A7", .fakten(angaben, c("vertrauliche_daten_im_body", "client_cache_verhindert",
    "formulardaten_maskiert", "unerwartetes_browser_speichern_verhindert", "zugangsdaten_salted_hash", "quelltextabruf_geschuetzt")))
}
pruefe_datensicherung <- function(angaben) {
  felder <- c("plan_eingehalten", "mitarbeitende_informiert", "aufgaben_bekannt", "tests_regelmaessig", "wiederherstellung_erfolgreich")
  .objekt(angaben, c(felder, "wiederherstellungsdauer", "maximale_dauer"), "angaben")
  for (k in felder) .bool(angaben[[k]], k)
  for (k in c("wiederherstellungsdauer", "maximale_dauer")) {
    v <- angaben[[k]]
    .fordere(is.null(v) || (is.numeric(v) && length(v) == 1L && is.finite(v) && v >= 0), "Endliche nichtnegative Zahl erforderlich")
  }
  werte <- setNames(lapply(felder, function(k) .logisch(angaben[[k]])), felder)
  d <- angaben$wiederherstellungsdauer; m <- angaben$maximale_dauer
  werte["zeitgrenze_eingehalten"] <- list(if (is.null(d) || is.null(m)) NULL else d <= m)
  .teilpruefung("CON.3.A5+CON.3.A15", werte)
}
pruefe_passwortgebrauch <- function(angaben) {
  felder <- c("verbindlich_geregelt", "zusatzverfahren_geprueft", "mehrfach_verwendet", "leicht_erratbar",
    "geheim_gehalten", "unbeobachtet_eingegeben", "auf_funktionstasten_gespeichert", "schriftlich_fixiert",
    "notfallhinterlegung", "sicher_aufbewahrt", "passwortmanager_geprueft", "drittanbieter_sync_vorhanden",
    "drittanbieter_sync_deaktiviert", "kompromittierung_oder_verdacht", "passwort_gewechselt")
  f <- .fakten(angaben, felder)
  nicht <- function(v) if (is.null(v)) NULL else !v
  wenn <- function(a, b) .oder(list(nicht(a), b))
  werte <- f[c("verbindlich_geregelt", "zusatzverfahren_geprueft", "geheim_gehalten", "unbeobachtet_eingegeben", "passwortmanager_geprueft")]
  for (k in c("mehrfach_verwendet", "leicht_erratbar", "auf_funktionstasten_gespeichert")) werte[k] <- list(nicht(f[[k]]))
  werte["schriftliche_hinterlegung"] <- list(wenn(f$schriftlich_fixiert, .und(list(f$notfallhinterlegung, f$sicher_aufbewahrt))))
  werte["drittanbieter_sync"] <- list(wenn(f$drittanbieter_sync_vorhanden, f$drittanbieter_sync_deaktiviert))
  werte["wechsel_bei_kompromittierung"] <- list(wenn(f$kompromittierung_oder_verdacht, f$passwort_gewechselt))
  .teilpruefung("ORP.4.A8", werte)
}
