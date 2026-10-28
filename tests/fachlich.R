library(bsikompendium)
faelle <- jsonlite::fromJSON('referenzfaelle.json', simplifyVector = FALSE)
for (fall in faelle) {
  vorher <- serialize(fall$eingaben, NULL)
  ergebnis <- tryCatch(do.call(getExportedValue('bsikompendium', fall$funktion), fall$eingaben),
    bsikompendium_eingabefehler = function(e) list(fehler = e$code))
  erwartet <- fall$erwartung
  if (!identical(ergebnis[[names(erwartet)]], erwartet[[1L]])) stop(fall$fall_id, ': ', paste(capture.output(str(ergebnis)), collapse=' '))
  stopifnot(identical(vorher, serialize(fall$eingaben,NULL)))
}
stopifnot(length(bausteine())==111L, length(anforderungen())==1835L,
          length(anforderungen(entfallen=TRUE))==2125L)
for (id in anforderungen()) {
  r <- anforderung(id)
  stopifnot(length(r$pdf_seiten)>0L, length(r$kriterien)>0L)
  bew <- setNames(lapply(r$kriterien, function(k) list(relevant=TRUE,umgesetzt=TRUE,wirksam=TRUE,angemessen=TRUE)),
                  vapply(r$kriterien, function(k) k$kriterium_id, character(1)))
  stopifnot(pruefe_anforderung(id,bew,TRUE)$befund=='ERFUELLT',
            pruefe_anforderung(id,list(),TRUE)$befund=='UNBEKANNT')
}
stopifnot('G 0.4' %in% unlist(gefaehrdungen('INF.2.A13')),
          'G 0.4' %in% unlist(gefaehrdungen('INF.2.A29')))
stopifnot(pruefe_http_datenschutz(list(vertrauliche_daten_im_body=NA))$befund=='UNBEKANNT')
stopifnot(pruefe_technische_grenzen('OPS.1.2.6.A11',list())$anwendbarkeit=='UNBEKANNT',
          pruefe_technische_grenzen('APP.4.4.A21',list())$anwendbarkeit=='UNBEKANNT')
for (x in list(c(TRUE,FALSE), 1, 'TRUE')) {
  e <- tryCatch(pruefe_http_datenschutz(list(vertrauliche_daten_im_body=x)), bsikompendium_eingabefehler=function(e)e)
  stopifnot(inherits(e,'bsikompendium_eingabefehler'))
}
for (x in c(Inf, -Inf, NaN)) {
  e <- tryCatch(pruefe_datensicherung(list(wiederherstellungsdauer=x)),bsikompendium_eingabefehler=function(e)e)
  stopifnot(inherits(e,'bsikompendium_eingabefehler'))
}
cat(length(faelle),'Referenzfälle und vollständiger Katalog erfolgreich.\n')
