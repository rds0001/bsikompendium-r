# Method steps are separate from the catalogue requirement count.
.methoden <- local({
  daten <- NULL
  function() {
    if (is.null(daten)) {
      con <- gzfile(system.file('extdata','methodik.json.gz',package='bsikompendium'),open='rb')
      on.exit(close(con))
      daten <<- jsonlite::fromJSON(con,simplifyVector=FALSE)
    }
    daten
  }
})
methodenschritte <- function() as.list(.sort(names(.methoden()$schritte)))
.methodenvertrag <- function(schritt_id) {
  .fordere(is.character(schritt_id)&&length(schritt_id)==1L&&!is.na(schritt_id)&&
    schritt_id %in% names(.methoden()$schritte),'Unbekannter Methodenschritt.')
  .methoden()$schritte[[schritt_id]]
}
methodischer_eingabevertrag <- function(schritt_id) .methodenvertrag(schritt_id)
pruefe_methodenschritt <- function(schritt_id,angaben) {
  vertrag <- .methodenvertrag(schritt_id)
  erg <- .pruefe_vertrag(schritt_id,angaben,vertrag)
  erg$quellenfassung <- vertrag$quellenfassung
  erg$quellenabschnitte <- vertrag$quellenabschnitte
  if (!is.null(vertrag$geltungshinweis)) erg$geltungshinweis <- vertrag$geltungshinweis
  erg
}

pruefe_risikoverlauf <- function(vorher,nachher,matrix,akzeptierte_kategorien,
                                weitere_akzeptanzkriterien,angaben) {
  .objekt(vorher,c('haeufigkeit','schaden','bewertungsstand'),'vorher')
  .objekt(nachher,c('haeufigkeit','schaden','bewertungsstand','neubewertungsgrund'),'nachher')
  .wahl(vorher$bewertungsstand,c('KONZEPT','UMGESETZT'),'vorher.bewertungsstand',TRUE)
  .wahl(nachher$bewertungsstand,c('KONZEPT','UMGESETZT'),'nachher.bewertungsstand',TRUE)
  if (!is.null(nachher$neubewertungsgrund)) .text(nachher$neubewertungsgrund,'nachher.neubewertungsgrund')
  .liste(akzeptierte_kategorien,'akzeptierte_kategorien')
  for (v in akzeptierte_kategorien) .wahl(v,.risiken,'akzeptierte_kategorien')
  .fordere(!anyDuplicated(unlist(akzeptierte_kategorien)),'Doppelte akzeptierte Kategorien.')
  schema <- list(weitere_akzeptanzkriterien=list(typ='liste',eindeutiges_feld='id',
    element=list(id=list(typ='text'),erfuellt=list(typ='bool'))))
  data <- list(weitere_akzeptanzkriterien=weitere_akzeptanzkriterien)
  .fach_validiere(data,schema)
  extra <- .fach_auswerten(list(op='alle',liste='weitere_akzeptanzkriterien',
    praedikat=list(op='feld',name='erfuellt')),data,schema)
  before <- bewerte_risiko(vorher$haeufigkeit,vorher$schaden,matrix)
  after <- bewerte_risiko(nachher$haeufigkeit,nachher$schaden,matrix)
  initial <- if (before$befund=='UNBEKANNT') NULL else before$befund
  residual <- if (after$befund=='UNBEKANNT') NULL else after$befund
  derived <- c('risikokategorie','eingegangenes_risiko','restrisiko_vorhanden','akzeptanz_erreicht','vorher_nachher','bewertungsstand')
  vertrag <- .methodenvertrag('BSI2003.RISIKOBEHANDLUNG')
  .objekt(angaben,setdiff(names(vertrag$felder),derived),'angaben')
  .fach_validiere(angaben,vertrag$felder)
  facts <- angaben; options <- facts$optionen; phase <- nachher$bewertungsstand
  changed <- !is.null(initial)&&!is.null(residual)&&
    (!identical(vorher$haeufigkeit,nachher$haeufigkeit)||!identical(vorher$schaden,nachher$schaden))
  unbegruendete_neubewertung <- identical(unlist(options),'AKZEPTANZ')&&changed&&is.null(nachher$neubewertungsgrund)
  avoidance <- if (is.null(options)) NULL else 'VERMEIDUNG'%in%unlist(options)
  removal <- if (is.null(phase)) NULL else .logisch(facts[[if (phase=='KONZEPT') 'vermeidung_wirksam_geplant' else 'ursache_ausgeschlossen']])
  absent <- .und(list(avoidance,removal))
  .fordere(!isTRUE(absent)||is.null(residual),'Ausgeschlossene Risikoursache und bekannte verbleibende Risikokategorie widersprechen sich.')
  remains <- if (isTRUE(absent)) FALSE else if (identical(absent,FALSE)||!is.null(residual)) TRUE else NULL
  category_ok <- if (identical(remains,FALSE)) TRUE else if (is.null(residual)) NULL else residual%in%unlist(akzeptierte_kategorien)
  actual <- if (identical(phase,'KONZEPT')&&identical(vorher$bewertungsstand,'UMGESETZT')) initial else if (identical(phase,'UMGESETZT')) residual else NULL
  ist_belegt <- if (identical(phase,'KONZEPT')) FALSE else NULL
  if (identical(phase,'UMGESETZT')) {
    implemented <- if (is.null(options)) list(NULL) else list()
    fields <- c(REDUKTION='reduktionsmassnahmen_umgesetzt',TRANSFER='transfer_wirksam',VERMEIDUNG='ursache_ausgeschlossen')
    for (option in names(fields)) if (!is.null(options)&&option%in%unlist(options))
      implemented <- c(implemented,list(.logisch(facts[[fields[[option]]]])))
    ist_belegt <- .und(implemented)
    if (!isTRUE(ist_belegt)) actual <- NULL
  }
  if (unbegruendete_neubewertung) {
    if (identical(phase,'UMGESETZT')) {
      actual <- NULL
      ist_belegt <- NULL
    }
  }
  if (is.null(phase)||(identical(phase,'UMGESETZT')&&!isTRUE(ist_belegt))||unbegruendete_neubewertung) category_ok <- NULL
  acceptance <- .und(list(category_ok,extra$wert))
  facts['risikokategorie'] <- list(initial); facts['eingegangenes_risiko'] <- list(actual)
  facts['restrisiko_vorhanden'] <- list(remains); facts['akzeptanz_erreicht'] <- list(acceptance)
  facts['bewertungsstand'] <- list(phase)
  facts['vorher_nachher'] <- list(if (!is.null(initial)&&(!is.null(residual)||identical(remains,FALSE))&&
    (identical(phase,'KONZEPT')||isTRUE(ist_belegt))) TRUE else NULL)
  erg <- pruefe_methodenschritt('BSI2003.RISIKOBEHANDLUNG',facts)
  erg$regel_id <- 'BSI2003.RISIKOVERLAUF'
  erg$begruendung <- 'Gekoppelte Matrix- und Behandlungspr\u00fcfung; Ma\u00dfnahmenannahmen und zus\u00e4tzliche Akzeptanzkriterien bleiben explizit.'
  erg$einstufung_vorher <- before$befund
  erg$einstufung_nachher <- if (identical(remains,FALSE)) 'RISIKO_VERMIEDEN' else after$befund
  erg['tatsaechlich_eingegangenes_risiko'] <- list(actual)
  erg$matrix_id <- before$matrix_id; erg['bewertungsstand'] <- list(phase)
  erg['nachher_als_ist_belegt'] <- list(ist_belegt)
  erg['neubewertungsgrund'] <- list(nachher$neubewertungsgrund)
  erg['kategorienkriterium_erfuellt'] <- list(category_ok)
  erg['weitere_akzeptanzkriterien_erfuellt'] <- list(extra$wert)
  erg['akzeptanz_erreicht'] <- list(acceptance)
  erg$abgeleitete_fakten <- facts[.sort(derived)]
  fehlend <- c(unlist(erg$fehlende_angaben),
    if (unbegruendete_neubewertung) 'nachher.neubewertungsgrund' else character(),
    if (is.null(phase)) 'nachher.bewertungsstand' else character(),
    if (identical(phase,'KONZEPT')&&is.null(vorher$bewertungsstand)) 'vorher.bewertungsstand' else character(),
    if (length(before$fehlende_angaben)) paste0('vorher.',unlist(before$fehlende_angaben)) else character(),
    if (!identical(remains,FALSE)&&length(after$fehlende_angaben)) paste0('nachher.',unlist(after$fehlende_angaben)) else character(),extra$fehlend)
  erg$fehlende_angaben <- as.list(.sort(unique(fehlend)))
  erg
}

pruefe_checkentscheidung <- function(anforderung_id,angaben) {
  .text(anforderung_id,'anforderung_id')
  requirement <- .katalog()$anforderungen[[anforderung_id]]
  .fordere(!is.null(requirement)&&!isTRUE(requirement$entfallen),'Aktive Anforderung erforderlich.')
  vertrag <- .methodenvertrag('BSI2002.CHECKENTSCHEIDUNG')
  derived <- c('basis','kreuzreferenzen_identifiziert')
  .objekt(angaben,setdiff(names(vertrag$felder),derived),'angaben')
  .fach_validiere(angaben,vertrag$felder)
  facts <- angaben
  expected <- unlist(requirement$gefaehrdungen)
  collection <- facts$zugehoerige_gefaehrdungen
  complete <- NULL
  if (!is.null(collection)&&!is.null(collection$objekte)) {
    ids <- lapply(collection$objekte,function(o) o$id)
    known <- unlist(ids)
    .fordere(all(known%in%expected),'Gefaehrdung gehoert nicht zur konkreten Anforderung.')
    if (isTRUE(collection$vollstaendig)&&!any(vapply(ids,is.null,logical(1))))
      complete <- setequal(known,expected)
  }
  facts$basis <- requirement$kategorie=='B'
  facts['kreuzreferenzen_identifiziert'] <- list(complete)
  erg <- pruefe_methodenschritt('BSI2002.CHECKENTSCHEIDUNG',facts)
  erg$regel_id <- 'BSI2002.KATALOG_CHECKENTSCHEIDUNG'
  erg$anforderung_id <- anforderung_id
  erg$katalogfassung <- .katalog()$quellenfassung
  erg['gepruefter_status'] <- list(facts$status)
  erg$zugehoerige_gefaehrdungen <- as.list(.sort(expected))
  erg$abgeleitete_fakten <- facts[.sort(derived)]
  erg$begruendung <- 'Pruefung der Begruendbarkeit des gewaehlten Check-Status; ERFUELLT bestaetigt die Statusentscheidung, nicht die Umsetzung der Anforderung.'
  erg
}

pruefe_checkabdeckung <- function(vorgehen,modellierung,checks) {
  .wahl(vorgehen,c('BASIS','STANDARD','KERN'),'vorgehen')
  catalog <- .katalog()
  active <- Filter(function(r)!isTRUE(r$entfallen),catalog$anforderungen)
  schema <- list(modellierung=list(typ='liste',element=list(
    baustein_id=list(typ='kategorie',werte=as.list(names(catalog$bausteine))),zielobjekt_id=list(typ='text'))),
    checks=list(typ='liste',element=list(anforderung_id=list(typ='kategorie',werte=as.list(names(active))),
      zielobjekt_id=list(typ='text'),status=list(typ='kategorie',werte=as.list(c('JA','TEILWEISE','NEIN','ENTBEHRLICH'))))))
  data <- list(modellierung=modellierung,checks=checks)
  .fach_validiere(data,schema)
  missing <- character(); indexed <- list()
  for (name in c('modellierung','checks')) {
    id_field <- if (name=='modellierung') 'baustein_id' else 'anforderung_id'
    collection <- data[[name]]; rows <- collection$objekte; index <- list()
    if (is.null(collection)) missing <- c(missing,name) else if (is.null(rows)) missing <- c(missing,paste0(name,'.objekte')) else {
      for (i in seq_along(rows)) {
        row <- rows[[i]]
        absent <- c(id_field,'zielobjekt_id')[vapply(c(id_field,'zielobjekt_id'),function(f)is.null(row[[f]]),logical(1))]
        if (length(absent)) missing <- c(missing,paste0(name,'.objekte[',i-1L,'].',absent)) else {
          key <- paste0(row[[id_field]],'\037',row$zielobjekt_id)
          .fordere(is.null(index[[key]]),'Doppelte Anforderungs-/Baustein-Zielobjekt-Zuordnung.')
          index[[key]] <- row
        }
      }
    }
    indexed[[name]] <- index
  }
  expected <- list()
  for (row in indexed$modellierung) {
    for (ident in names(active)) {
      req <- active[[ident]]
      if (req$baustein_id==row$baustein_id&&req$kategorie%in%c('B',if (vorgehen!='BASIS') 'S')) {
        key <- paste0(ident,'\037',row$zielobjekt_id)
        expected[[key]] <- list(anforderung_id=ident,zielobjekt_id=row$zielobjekt_id)
      }
    }
  }
  received <- indexed$checks
  absent_keys <- .sort(setdiff(names(expected),names(received)))
  shared <- intersect(names(expected),names(received))
  open_keys <- .sort(shared[vapply(shared,function(k)is.null(received[[k]]$status),logical(1))])
  forbidden <- .sort(shared[vapply(shared,function(k) vorgehen=='KERN'&&
    active[[received[[k]]$anforderung_id]]$kategorie=='B'&&identical(received[[k]]$status,'ENTBEHRLICH'),logical(1))])
  for (i in seq_along(checks$objekte)) {
    row <- checks$objekte[[i]]
    if (!is.null(row$anforderung_id)&&!is.null(row$zielobjekt_id)&&
        paste0(row$anforderung_id,'\037',row$zielobjekt_id)%in%open_keys)
      missing <- c(missing,paste0('checks.objekte[',i-1L,'].status'))
  }
  if (!is.null(modellierung)&&!isTRUE(modellierung$vollstaendig)) missing <- c(missing,'modellierung.vollstaendig')
  if (length(absent_keys)&&!is.null(checks)&&!isTRUE(checks$vollstaendig)) missing <- c(missing,'checks.vollstaendig')
  checks_complete <- !is.null(checks)&&isTRUE(checks$vollstaendig)
  known_absent <- if (checks_complete) absent_keys else character()
  finding <- if (length(missing)) 'UNBEKANNT' else if (!length(expected)) 'NICHT_ANWENDBAR' else
    if (length(known_absent)||length(forbidden)) 'NICHT_ERFUELLT' else 'ERFUELLT'
  pick <- function(keys) unname(expected[keys])
  extras <- .sort(setdiff(names(received),names(expected)))
  .ergebnis('BSI2002.CHECKABDECKUNG',finding,
    'Pruefung der Vollstaendigkeit dokumentierter Check-Status; keine Aussage zur Erfuellung der Anforderungen. Kern-Sonderregel fuer Basis-Anforderungen gemaess Abschnitt 7.7.',
    missing,vorgehen=vorgehen,quellenabschnitte=as.list(c('6.3','7.7','8.4.2')),
    erforderliche_checks=pick(.sort(names(expected))),fehlende_checks=pick(known_absent),
    ungeklaerte_checks=pick(if (!checks_complete) absent_keys else character()),
    offene_status=pick(open_keys),kern_unzulaessig_entbehrlich=pick(forbidden),
    zusaetzliche_checks=lapply(extras,function(k)list(anforderung_id=received[[k]]$anforderung_id,zielobjekt_id=received[[k]]$zielobjekt_id)))
}
