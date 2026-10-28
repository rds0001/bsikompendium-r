# Belegte technische Teilkriterien; keine freie Regel-DSL.
.technikfelder <- list(
  "APP.2.2.A1" = c("funktionsebene_jahr"),
  "OPS.1.2.6.A11" = c("genauigkeit_erheblich", "unabhaengige_ntp_server"),
  "DER.3.2.A5" = c("teammitglieder"),
  "APP.3.6.A2" = c("zusaetzliche_secondary_server"),
  "APP.4.4.A21" = c("erhoehtes_fremdeinwirkungsrisiko", "schutzbedarf_sehr_hoch", "pod_laufzeit_stunden"),
  "SYS.3.2.1.A29" = c("passwortlaenge"),
  "IND.3.2.A6" = c("sicherheitskomponenten_ot"),
  "NET.1.1.A4" = c("firewall_stufen", "paketfilter_externe_dmz"),
  "NET.1.2.A28" = c("managementclients_intern", "managementclients_extern"),
  "INF.1.A18" = c("begehungen_im_jahr", "vorgabe_pro_jahr"),
  "INF.2.A9" = c("loesch_oder_brandvermeidungsanlage", "brandfrueherkennung", "personal_geschult", "reaktionsplaene", "reaktionszeit_sekunden"),
  "INF.2.A17" = c("automatische_schutzreaktion", "stelle_staendig_besetzt", "kontrollzeit_sekunden"),
  "INF.5.A13" = c("feuer_minuten", "rauch_minuten"),
  "INF.5.A25" = c("feuer_minuten", "rauch_minuten", "zuleitung_minuten"),
  "OPS.1.2.2.A19" = c("letzte_pruefung", "bezugsdatum"),
  "INF.1.A36" = c("letzte_pruefung", "bezugsdatum"),
  "INF.12.A10" = c("aenderungsdatum", "abschlussdatum", "arbeitsdoku_aktualisiert", "stammdoku_aktualisiert", "letzte_pruefung", "bezugsdatum")
)
.technikbool <- c("genauigkeit_erheblich", "erhoehtes_fremdeinwirkungsrisiko", "schutzbedarf_sehr_hoch",
  "loesch_oder_brandvermeidungsanlage", "brandfrueherkennung", "personal_geschult", "reaktionsplaene",
  "automatische_schutzreaktion", "stelle_staendig_besetzt")
.technikdatum <- c("letzte_pruefung", "bezugsdatum", "aenderungsdatum", "abschlussdatum", "arbeitsdoku_aktualisiert", "stammdoku_aktualisiert")
.technikganzzahl <- c("funktionsebene_jahr", "unabhaengige_ntp_server", "teammitglieder", "zusaetzliche_secondary_server",
  "passwortlaenge", "sicherheitskomponenten_ot", "firewall_stufen", "paketfilter_externe_dmz",
  "managementclients_intern", "managementclients_extern", "begehungen_im_jahr", "vorgabe_pro_jahr")
.datum <- function(v) {
  if (is.null(v)) return(NULL)
  .fordere(is.character(v) && length(v) == 1L && !is.na(v) &&
             grepl("^[0-9]{4}-[0-9]{2}-[0-9]{2}$", v) && substr(v, 1, 4) != "0000", "Datum muss YYYY-MM-DD sein")
  d <- suppressWarnings(as.Date(v, format = "%Y-%m-%d"))
  .fordere(!is.na(d) && sprintf("%04d-%s", as.integer(format(d, "%Y")), format(d, "%m-%d")) == v, "Ung\u00fcltiges Kalenderdatum")
  d
}
.jahresfrist <- function(start, ende, jahre) {
  if (is.null(start) || is.null(ende)) return(NULL)
  .fordere(start <= ende, "Letzte Pr\u00fcfung darf nicht nach Bezugsdatum liegen")
  jahr <- as.integer(format(start, "%Y")) + jahre
  .fordere(jahr <= 9999L, "Kalendergrenze \u00fcberschritten")
  monat <- as.integer(format(start, "%m")); tag <- as.integer(format(start, "%d"))
  schaltjahr <- jahr %% 4L == 0L && (jahr %% 100L != 0L || jahr %% 400L == 0L)
  tage <- c(31L, if (schaltjahr) 29L else 28L, 31L, 30L, 31L, 30L, 31L, 31L, 30L, 31L, 30L, 31L)
  frist <- .datum(sprintf("%04d-%02d-%02d", jahr, monat, min(tag, tage[monat])))
  ende <= frist
}
pruefe_technische_grenzen <- function(anforderung_id, angaben) {
  .wahl(anforderung_id, names(.technikfelder), "anforderung_id")
  .objekt(angaben, .technikfelder[[anforderung_id]], "angaben")
  f <- list()
  for (k in .technikfelder[[anforderung_id]]) {
    v <- angaben[[k]]
    if (k %in% .technikbool) {
      .bool(v, k); v <- .logisch(v)
    } else if (k %in% .technikdatum) v <- .datum(v) else {
      .fordere(is.null(v) || (is.numeric(v) && length(v) == 1L && is.finite(v) && v >= 0 &&
                  (!k %in% .technikganzzahl || v == floor(v))), paste0(k, ": nichtnegative Zahl erforderlich"))
    }
    f[k] <- list(v)
  }
  mind <- function(k, n) if (is.null(f[[k]])) NULL else f[[k]] >= n
  hoech <- function(k, n) if (is.null(f[[k]])) NULL else f[[k]] <= n
  a <- anforderung_id; w <- list()
  if (a == "APP.2.2.A1") w <- list(funktionsebene_mindestens_2016 = mind("funktionsebene_jahr", 2016))
  else if (a == "OPS.1.2.6.A11") {
    if (identical(f$genauigkeit_erheblich, FALSE)) return(.ergebnis(a, "NICHT_ANWENDBAR", "Bedingung dieses Teilkriteriums trifft nicht zu.", anwendbar = FALSE,
      pruefumfang = "Nur die bezeichneten Zahlen-/Zeitkriterien; \u00fcbrige Anforderung separat pr\u00fcfen."))
    w <- list(vier_unabhaengige_ntp_server = if (is.null(f$genauigkeit_erheblich)) NULL else mind("unabhaengige_ntp_server", 4))
  } else if (a == "DER.3.2.A5") w <- list(mindestens_zwei_personen = mind("teammitglieder", 2))
  else if (a == "APP.3.6.A2") w <- list(zusaetzlicher_secondary = mind("zusaetzliche_secondary_server", 1))
  else if (a == "APP.4.4.A21") {
    gilt <- .und(list(f$erhoehtes_fremdeinwirkungsrisiko, f$schutzbedarf_sehr_hoch))
    if (identical(gilt, FALSE)) return(.ergebnis(a, "NICHT_ANWENDBAR", "Bedingung dieses Teilkriteriums trifft nicht zu.", anwendbar = FALSE,
      pruefumfang = "Nur die bezeichneten Zahlen-/Zeitkriterien; \u00fcbrige Anforderung separat pr\u00fcfen."))
    w <- list(pod_hoechstens_24_stunden = if (is.null(gilt)) NULL else hoech("pod_laufzeit_stunden", 24))
  } else if (a == "SYS.3.2.1.A29") w <- list(passwort_eins_bis_64_stellen = .und(list(mind("passwortlaenge", 1), hoech("passwortlaenge", 64))))
  else if (a == "IND.3.2.A6") w <- list(sicherheitskomponente_ot = mind("sicherheitskomponenten_ot", 1))
  else if (a == "NET.1.1.A4") w <- list(zweistufige_firewall = mind("firewall_stufen", 2), filter_externe_dmz = mind("paketfilter_externe_dmz", 1))
  else if (a == "NET.1.2.A28") w <- list(client_intern = mind("managementclients_intern", 1), client_extern = mind("managementclients_extern", 1))
  else if (a == "INF.1.A18") {
    .fordere(is.null(f$vorgabe_pro_jahr) || f$vorgabe_pro_jahr %in% c(1, 2), "Vorgabe ein oder zwei Begehungen erforderlich")
    w <- list(begehungszahl = if (is.null(f$vorgabe_pro_jahr) || is.null(f$begehungen_im_jahr)) NULL else f$begehungen_im_jahr >= f$vorgabe_pro_jahr)
  } else if (a == "INF.2.A9") w <- list(brandbekaempfung = .oder(list(f$loesch_oder_brandvermeidungsanlage,
    .und(list(f$brandfrueherkennung, f$personal_geschult, f$reaktionsplaene, hoech("reaktionszeit_sekunden", 180))))))
  else if (a == "INF.2.A17") w <- list(schutzreaktion = .oder(list(f$automatische_schutzreaktion, .und(list(f$stelle_staendig_besetzt, hoech("kontrollzeit_sekunden", 180))))))
  else if (a %in% c("INF.5.A13", "INF.5.A25")) {
    grenze <- if (a == "INF.5.A13") 30 else 90
    w <- setNames(lapply(.technikfelder[[a]], function(k) mind(k, grenze)), .technikfelder[[a]])
  } else if (a %in% c("OPS.1.2.2.A19", "INF.1.A36")) w <- list(pruefintervall = .jahresfrist(f$letzte_pruefung, f$bezugsdatum, if (startsWith(a, "OPS")) 1 else 3))
  else if (a == "INF.12.A10") {
    w <- list(dokumentationstreue = .jahresfrist(f$letzte_pruefung, f$bezugsdatum, 4))
    for (key in c("arbeitsdoku_aktualisiert", "stammdoku_aktualisiert")) {
      tage <- if (key == "arbeitsdoku_aktualisiert") 0 else 28
      start <- if (tage == 0) f$aenderungsdatum else f$abschlussdatum
      ende <- f[[key]]
      w[key] <- list(if (is.null(start) || is.null(ende)) NULL else as.numeric(ende - start) >= 0 && as.numeric(ende - start) <= tage)
    }
  }
  erg <- .teilpruefung(a, w)
  if ((a == "OPS.1.2.6.A11" && is.null(f$genauigkeit_erheblich)) ||
      (a == "APP.4.4.A21" && is.null(gilt))) erg$anwendbarkeit <- "UNBEKANNT"
  erg$pruefumfang <- "Nur die bezeichneten Zahlen-/Zeitkriterien; \u00fcbrige Anforderung separat pr\u00fcfen."
  erg
}
