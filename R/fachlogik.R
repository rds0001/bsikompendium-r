# Native evaluation of individually authored BSI requirement contracts.
.fachvertraege <- local({
  daten <- NULL
  function() {
    if (is.null(daten)) {
      con <- gzfile(system.file('extdata','fachregeln.json.gz',package='bsikompendium'),open='rb')
      on.exit(close(con))
      daten <<- jsonlite::fromJSON(con,simplifyVector=FALSE)
    }
    daten
  }
})
fachlicher_eingabevertrag <- function(anforderung_id) {
  anforderung(anforderung_id)
  r <- .fachvertraege()$anforderungen[[anforderung_id]]
  if (is.null(r)) return(list(anforderung_id=anforderung_id,status='REGEL_UNGEKLAERT',
                            felder=structure(list(),names=character()),kriterien=list()))
  r
}
.fach_zeitpunkt <- function(v,pfad) {
  if (is.null(v)) return(NULL)
  .text(v,pfad)
  .fordere(grepl('^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$',v),paste0(pfad,': UTC-Zeitpunkt erforderlich'))
  d <- .datum(substr(v,1,10))
  h <- as.integer(substr(v,12,13)); m <- as.integer(substr(v,15,16)); sec <- as.integer(substr(v,18,19))
  .fordere(h<24L&&m<60L&&sec<60L,paste0(pfad,': ungueltiger UTC-Zeitpunkt'))
  as.numeric(d)*86400+h*3600+m*60+sec
}
.fach_sekundentakt <- function(v) any(c('letzter_zeitpunkt','bezugszeitpunkt','intervall_sekunden') %in% names(v))
.fach_validiere <- function(daten,schema,pfad='angaben') {
  .objekt(daten,names(schema),pfad)
  for (name in names(schema)) {
    v <- daten[[name]]; vertrag <- schema[[name]]; p <- paste0(pfad,'.',name)
    if (is.null(v)) next
    typ <- vertrag$typ
    if (typ=='bool') .bool(v,p)
    else if (typ=='datum') .datum(v)
    else if (typ=='zeitpunkt') .fach_zeitpunkt(v,p)
    else if (typ=='zahl') .fordere(is.numeric(v)&&length(v)==1L&&is.finite(v),paste0(p,': endliche Zahl erforderlich'))
    else if (typ=='anzahl') .fordere(is.numeric(v)&&length(v)==1L&&is.finite(v)&&v>=0&&v==floor(v),paste0(p,': nichtnegative ganze Anzahl erforderlich'))
    else if (typ=='kategorie') .wahl(v,unlist(vertrag$werte),p)
    else if (typ=='text') .text(v,p)
    else if (typ=='textliste') {
      .liste(v,p)
      for (x in v) .text(x,p)
      .fordere(!anyDuplicated(unlist(v)),paste0(p,': doppelte Eintraege'))
      if (!is.null(vertrag$werte)) .fordere(all(unlist(v)%in%unlist(vertrag$werte)),paste0(p,': unzulaessiger Textlistenwert'))
    } else if (typ=='liste') {
      .objekt(v,c('objekte','vollstaendig'),p); .bool(v$vollstaendig,paste0(p,'.vollstaendig'))
      if (!is.null(v$objekte)) {
        .liste(v$objekte,paste0(p,'.objekte'))
        for (i in seq_along(v$objekte)) .fach_validiere(v$objekte[[i]],vertrag$element,paste0(p,'.objekte[',i-1L,']'))
        if (!is.null(vertrag$eindeutiges_feld)) {
          ids <- unlist(lapply(v$objekte,function(o)o[[vertrag$eindeutiges_feld]]))
          .fordere(!anyDuplicated(ids),paste0(p,': doppelte Objektidentitaet'))
        }
      }
    } else if (typ=='regelmaessigkeit') {
      sek <- .fach_sekundentakt(v)
      namen <- if (sek) c('letzter_zeitpunkt','bezugszeitpunkt','intervall_sekunden') else c('letztes_datum','bezugsdatum','intervall_tage')
      .objekt(v,c(namen,'intervall_begruendet','durchgefuehrt'),p)
      .bool(v$intervall_begruendet,paste0(p,'.intervall_begruendet'))
      .bool(v$durchgefuehrt,paste0(p,'.durchgefuehrt'))
      start <- if (sek) .fach_zeitpunkt(v[[namen[1]]],p) else .datum(v[[namen[1]]])
      ende <- if (sek) .fach_zeitpunkt(v[[namen[2]]],p) else .datum(v[[namen[2]]])
      .fordere(!identical(v$durchgefuehrt,FALSE)||is.null(start),paste0(p,': ausgebliebene Durchfuehrung hat keinen Durchfuehrungstermin'))
      n <- v[[namen[3]]]
      .fordere(is.null(n)||(is.numeric(n)&&length(n)==1L&&is.finite(n)&&n>0&&n==floor(n)),paste0(p,': positives ganzzahliges Intervall erforderlich'))
      .fordere(is.null(start)||is.null(ende)||start<=ende,paste0(p,': letzter Termin liegt nach Bezugsdatum'))
    } else stop('Unbekannter Vertragstyp: ',typ)
    if (typ %in% c('zahl','anzahl') && !is.null(vertrag$werte))
      .fordere(v %in% unlist(vertrag$werte),paste0(p,': Zahl ausserhalb des zulaessigen Wertebereichs'))
  }
}
.fach_auswerten <- function(e,daten,schema,pfad='angaben',eltern=list()) {
  paar <- function(v,f=character()) list(wert=v,fehlend=f)
  op <- e$op
  if (op=='wert') return(paar(e$wert))
  if (op=='feld') {
    v <- daten[[e$name]]
    if (is.logical(v)) v <- .logisch(v)
    return(paar(v,if (is.null(v)) paste0(pfad,'.',e$name) else character()))
  }
  if (op=='oberfeld') {
    parent <- eltern[[length(eltern)-e$ebenen+1L]]
    v <- parent$daten[[e$name]]
    if (is.logical(v)) v <- .logisch(v)
    return(paar(v,if (is.null(v)) paste0(parent$pfad,'.',e$name) else character()))
  }
  if (op=='zeitdifferenz') {
    namen <- c(e$von,e$bis)
    fehlt <- vapply(namen,function(n)is.null(daten[[n]]),logical(1))
    if (any(fehlt)) return(paar(NULL,.sort(unique(paste0(pfad,'.',namen[fehlt])))))
    if (schema[[e$von]]$typ=='datum')
      return(paar(as.numeric(.datum(daten[[e$bis]])-.datum(daten[[e$von]]))))
    return(paar(.fach_zeitpunkt(daten[[e$bis]],paste0(pfad,'.',e$bis))-
                 .fach_zeitpunkt(daten[[e$von]],paste0(pfad,'.',e$von))))
  }
  if (op=='jahresdatum') {
    tiefe <- if (is.null(e$ebenen)) 0L else e$ebenen
    bezug <- if (tiefe>0L) eltern[[length(eltern)-tiefe+1L]] else list(daten=daten,pfad=pfad)
    v <- bezug$daten[[e$feld]]
    if (is.null(v)) return(paar(NULL,paste0(bezug$pfad,'.',e$feld)))
    start <- .datum(v)
    jahr <- as.integer(format(start,'%Y'))+e$jahre
    .fordere(jahr<=9999L,'Kalendergrenze ueberschritten')
    monat <- as.integer(format(start,'%m')); tag <- as.integer(format(start,'%d'))
    schaltjahr <- jahr%%4L==0L&&(jahr%%100L!=0L||jahr%%400L==0L)
    tage <- c(31L,if (schaltjahr) 29L else 28L,31L,30L,31L,30L,31L,31L,30L,31L,30L,31L)
    return(paar(sprintf('%04d-%02d-%02d',jahr,monat,min(tag,tage[monat]))))
  }
  if (op %in% c('und','oder')) {
    teile <- lapply(e$args,function(x) .fach_auswerten(x,daten,schema,pfad,eltern))
    v <- (if (op=='und') .und else .oder)(lapply(teile,function(x)x$wert))
    return(paar(v,if (is.null(v)) .sort(unique(unlist(lapply(teile,function(x)x$fehlend)))) else character()))
  }
  if (op=='nicht') {
    a <- .fach_auswerten(e$arg,daten,schema,pfad,eltern)
    return(paar(if (is.null(a$wert)) NULL else !a$wert,a$fehlend))
  }
  if (op=='wenn') {
    a <- .fach_auswerten(e$bedingung,daten,schema,pfad,eltern)
    b <- .fach_auswerten(e$folge,daten,schema,pfad,eltern)
    v <- .oder(list(if (is.null(a$wert)) NULL else !a$wert,b$wert))
    return(paar(v,if (is.null(v)) .sort(unique(c(a$fehlend,b$fehlend))) else character()))
  }
  if (op=='vergleich') {
    a <- .fach_auswerten(e$links,daten,schema,pfad,eltern)
    b <- .fach_auswerten(e$rechts,daten,schema,pfad,eltern)
    if (is.null(a$wert)||is.null(b$wert)) return(paar(NULL,.sort(unique(c(a$fehlend,b$fehlend)))))
    if (e$operator=='mengen==') return(paar(setequal(unlist(a$wert),unlist(b$wert))))
    # JSON text lists need one structural result, preserving order and length,
    # just as Python list equality does; R's atomic == cannot compare lists.
    if (is.list(a$wert)&&is.list(b$wert)&&e$operator %in% c('==','!=')) {
      gleich <- identical(a$wert,b$wert)
      return(paar(if (e$operator=='==') gleich else !gleich))
    }
    v <- switch(e$operator,'<='=a$wert<=b$wert,'<'=a$wert<b$wert,'>='=a$wert>=b$wert,'=='=a$wert==b$wert,'>'=a$wert>b$wert,'!='=a$wert!=b$wert,stop('Unbekannter Vergleich'))
    return(paar(v))
  }
  if (op=='enthaelt') {
    v <- daten[[e$feld]]
    return(if (is.null(v)) paar(NULL,paste0(pfad,'.',e$feld)) else paar(all(unlist(e$werte)%in%unlist(v))))
  }
  if (op=='vorhanden') {
    v <- daten[[e$feld]]
    return(if (is.null(v)) paar(NULL,paste0(pfad,'.',e$feld)) else paar(length(v)>0L))
  }
  if (op=='anzahl') {
    v <- daten[[e$feld]]
    p <- paste0(pfad,'.',e$feld)
    if (schema[[e$feld]]$typ=='liste') {
      if (is.null(v)) return(paar(NULL,p))
      if (is.null(v$objekte)) return(paar(NULL,paste0(p,'.objekte')))
      offen <- if (isTRUE(v$vollstaendig)) character() else paste0(p,'.vollstaendig')
      key <- schema[[e$feld]]$eindeutiges_feld
      if (!is.null(key)) for (i in seq_along(v$objekte)) {
        if (is.null(v$objekte[[i]][[key]])) offen <- c(offen,paste0(p,'.objekte[',i-1L,'].',key))
      }
      attr <- e$attribut
      if (!is.null(attr)) for (i in seq_along(v$objekte)) {
        if (is.null(v$objekte[[i]][[attr]])) offen <- c(offen,paste0(p,'.objekte[',i-1L,'].',attr))
      }
      if (length(offen)) return(paar(NULL,.sort(unique(offen))))
      return(paar(if (is.null(attr)) length(v$objekte) else length(unique(unlist(lapply(v$objekte,function(o)o[[attr]]))))))
    }
    return(if (is.null(v)) paar(NULL,paste0(pfad,'.',e$feld)) else paar(length(v)))
  }
  if (op=='disjunkt') {
    n <- c(e$links,e$rechts)
    fehlt <- n[vapply(n,function(k)is.null(daten[[k]]),logical(1))]
    if (length(fehlt)) return(paar(NULL,paste0(pfad,'.',fehlt)))
    return(paar(!length(intersect(unlist(daten[[e$links]]),unlist(daten[[e$rechts]])))))
  }
  if (op %in% c('alle','irgendein','mindestanteil')) {
    name <- e$liste
    tiefe <- if (is.null(e$ebenen)) 0L else e$ebenen
    bezug <- if (tiefe>0L) eltern[[length(eltern)-tiefe+1L]] else list(daten=daten,schema=schema,pfad=pfad)
    mengenschema <- bezug$schema[[name]]
    p <- paste0(bezug$pfad,'.',name); menge <- bezug$daten[[name]]
    if (is.null(menge)) return(paar(NULL,p))
    if (is.null(menge$objekte)) return(paar(NULL,paste0(p,'.objekte')))
    # Fused, non-throwing selector for explicit catalogue completeness checks:
    # EXISTS(row.id == literal AND row.fact == row.fact). Input validation has
    # already checked every row. Preserve all three-valued/missing-path results.
    pred <- e$praedikat
    if (op=='irgendein'&&identical(pred$op,'und')&&length(pred$args)==2L) {
      sel <- pred$args[[1L]]; known <- pred$args[[2L]]
      if (identical(sel$op,'vergleich')&&identical(sel$operator,'==')&&
          identical(sel$links$op,'feld')&&identical(sel$rechts$op,'wert')&&
          is.character(sel$rechts$wert)&&length(sel$rechts$wert)==1L&&
          identical(known$op,'vergleich')&&identical(known$operator,'==')&&
          identical(known$links$op,'feld')&&identical(known$rechts$op,'feld')&&
          identical(known$links$name,known$rechts$name)) {
        selector <- sel$links$name; fact <- known$links$name
        if (mengenschema$element[[selector]]$typ %in% c('text','kategorie')&&
            mengenschema$element[[fact]]$typ %in% c('bool','text','kategorie','datum','zeitpunkt','zahl','anzahl')) {
          selector_values <- vapply(menge$objekte,function(o) {
            if (is.null(o[[selector]])) NA_character_ else o[[selector]]
          },character(1))
          present <- vapply(menge$objekte,function(o) {
            v <- o[[fact]]
            !is.null(v)&&!(is.logical(v)&&is.na(v))
          },logical(1))
          matches <- !is.na(selector_values)&selector_values==sel$rechts$wert
          if (any(matches&present)) return(paar(TRUE))
          unknown <- is.na(selector_values)|(matches&!present)
          if (!any(unknown)&&isTRUE(menge$vollstaendig)) return(paar(FALSE))
          paths <- unlist(lapply(which(unknown),function(i) {
            c(if (is.na(selector_values[i])) paste0(p,'.objekte[',i-1L,'].',selector),
              if (!present[i]) paste0(p,'.objekte[',i-1L,'].',fact))
          }))
          if (!isTRUE(menge$vollstaendig)) paths <- c(paths,paste0(p,'.vollstaendig'))
          return(paar(NULL,.sort(unique(paths))))
        }
      }
    }
    teile <- lapply(seq_along(menge$objekte),function(i) .fach_auswerten(e$praedikat,menge$objekte[[i]],mengenschema$element,paste0(p,'.objekte[',i-1L,']'),c(eltern,list(list(daten=daten,schema=schema,pfad=pfad)))))
    voll <- isTRUE(menge$vollstaendig)
    min <- mengenschema$mindestelemente
    minimum <- is.null(min)||length(menge$objekte)>=min
    key <- mengenschema$eindeutiges_feld
    unbekannte_ids <- if (is.null(key)) character() else unlist(lapply(seq_along(menge$objekte),function(i) {
      if (is.null(menge$objekte[[i]][[key]])) paste0(p,'.objekte[',i-1L,'].',key) else character()
    }))
    v <- if (op=='mindestanteil') {
      if (!voll||length(unbekannte_ids)) NULL else {
        sicher <- sum(vapply(teile,function(x)isTRUE(x$wert),logical(1)))
        moeglich <- sicher+sum(vapply(teile,function(x)is.null(x$wert),logical(1)))
        erforderlich <- length(menge$objekte)*e$zaehler
        if (sicher*e$nenner>=erforderlich) TRUE else if (moeglich*e$nenner<erforderlich) FALSE else NULL
      }
    } else if (op=='irgendein') .oder(c(lapply(teile,function(x)x$wert),list(if (voll) FALSE else NULL))) else
      .und(c(lapply(teile,function(x)x$wert),list(if (voll) TRUE else NULL,
                    if (minimum) TRUE else if (voll) FALSE else NULL,
                    if (length(unbekannte_ids)) NULL else TRUE)))
    offen <- .sort(unique(unlist(lapply(teile,function(x)x$fehlend))))
    if (op %in% c('alle','mindestanteil')) offen <- .sort(unique(c(offen,unbekannte_ids)))
    if (!voll) offen <- c(offen,paste0(p,'.vollstaendig'))
    return(paar(v,if (is.null(v)) offen else character()))
  }
  if (op=='frist') {
    p <- paste0(pfad,'.',e$feld); f <- daten[[e$feld]]
    if (is.null(f)) return(paar(NULL,p))
    sek <- .fach_sekundentakt(f)
    namen <- if (sek) c('letzter_zeitpunkt','bezugszeitpunkt','intervall_sekunden') else c('letztes_datum','bezugsdatum','intervall_tage')
    start <- if (sek) .fach_zeitpunkt(f[[namen[1]]],p) else .datum(f[[namen[1]]])
    ende <- if (sek) .fach_zeitpunkt(f[[namen[2]]],p) else .datum(f[[namen[2]]])
    delta <- if (is.null(start)||is.null(ende)) NULL else as.numeric(ende-start)
    vals <- list(.logisch(f$intervall_begruendet),if ('durchgefuehrt'%in%names(f)) .logisch(f$durchgefuehrt) else TRUE,
                 if (is.null(delta)||is.null(f[[namen[3]]])) NULL else delta<=f[[namen[3]]])
    if (!is.null(e$max_tage)) vals <- c(vals,list(if (is.null(delta)) NULL else delta<=e$max_tage*(if (sek) 86400 else 1)))
    if (!is.null(e$jahre)) {
      ds <- if (is.null(start)) NULL else if (sek) as.Date(floor(start/86400),origin='1970-01-01') else start
      de <- if (is.null(ende)) NULL else if (sek) as.Date(floor(ende/86400),origin='1970-01-01') else ende
      vals <- c(vals,list(.jahresfrist(ds,de,e$jahre)))
    }
    v <- .und(vals)
    n <- c(namen,'intervall_begruendet',if ('durchgefuehrt'%in%names(f)) 'durchgefuehrt')
    fehlend <- paste0(p,'.',n[vapply(n,function(k) .unbekannt(f[[k]]),logical(1))])
    if (!any(vapply(n,function(k) .unbekannt(f[[k]]),logical(1)))) fehlend <- character()
    return(paar(v,if (is.null(v)) fehlend else character()))
  }
  stop('Unbekannte fachliche Operation: ',op)
}
pruefe_fachregel <- function(anforderung_id,angaben) {
  original <- anforderung(anforderung_id)
  if (original$entfallen) return(.ergebnis(anforderung_id,'NICHT_ANWENDBAR','Anforderung ist entfallen.',anwendbar=FALSE))
  vertrag <- .fachvertraege()$anforderungen[[anforderung_id]]
  if (is.null(vertrag)) {
    erg <- .ergebnis(anforderung_id,NULL,'Individuelle Fachlogik noch nicht vollst\u00e4ndig erarbeitet.',anwendbar=NULL)
    erg$status <- 'REGEL_UNGEKLAERT'; return(erg)
  }
  .pruefe_vertrag(anforderung_id,angaben,vertrag)
}
.pruefe_vertrag <- function(anforderung_id,angaben,vertrag) {
  .fach_validiere(angaben,vertrag$felder)
  app <- .fach_auswerten(vertrag$anwendbarkeit,angaben,vertrag$felder)
  if (!isTRUE(app$wert)) return(.ergebnis(anforderung_id,if (is.null(app$wert)) 'UNBEKANNT' else 'NICHT_ANWENDBAR',
    'Anwendungsvoraussetzungen des Fachvertrags.',app$fehlend,app$wert,bekannte_maengel=list(),teilbefunde=structure(list(),names=character())))
  teile <- list(); maengel <- character(); offen <- character()
  for (k in vertrag$kriterien) {
    ka <- .fach_auswerten(k$anwendbarkeit,angaben,vertrag$felder)
    a <- .fach_auswerten(k$ausdruck,angaben,vertrag$felder)
    if (identical(ka$wert,FALSE)) {
      teile[[k$kriterium_id]] <- list(befund='NICHT_ANWENDBAR',anwendbarkeit='FALSCH',modalitaet=k$modalitaet,fehlende_angaben=list())
      next
    }
    if (is.null(ka$wert)) a <- list(wert=NULL,fehlend=.sort(unique(c(ka$fehlend,a$fehlend))))
    teile[[k$kriterium_id]] <- list(befund=if (is.null(a$wert)) 'UNBEKANNT' else if (a$wert) 'ERFUELLT' else 'NICHT_ERFUELLT',
                                  anwendbarkeit=if (is.null(ka$wert)) 'UNBEKANNT' else 'WAHR',modalitaet=k$modalitaet,fehlende_angaben=as.list(a$fehlend))
    if (identical(a$wert,FALSE)) maengel <- c(maengel,k$kriterium_id)
    if (is.null(a$wert)) offen <- c(offen,a$fehlend)
  }
  befunde <- vapply(teile,function(x)x$befund,character(1))
  befunde <- befunde[befunde!='NICHT_ANWENDBAR']
  befund <- if (!length(befunde)) 'NICHT_ANWENDBAR' else if ('UNBEKANNT'%in%befunde) 'UNBEKANNT' else if (!length(maengel)) 'ERFUELLT' else
    if (length(maengel)==length(befunde)) 'NICHT_ERFUELLT' else 'TEILWEISE_ERFUELLT'
  .ergebnis(anforderung_id,befund,'Individuelle Kriterienpr\u00fcfung; Abweichungen und Risiko separat bewerten.',offen,
     anwendbar=length(befunde)>0L,bekannte_maengel=as.list(maengel),teilbefunde=teile,fachvertrag_status=vertrag$status)
}
