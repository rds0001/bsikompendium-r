library(bsikompendium)
faelle <- unlist(lapply(list.files(pattern='^referenzen_.*[.]json[.]gz$'),function(p) {
    con <- gzfile(p,open='rb')
    on.exit(close(con))
    jsonlite::fromJSON(con,simplifyVector=FALSE)
}),recursive=FALSE)
for (f in faelle) {
  erg <- tryCatch(do.call(getExportedValue('bsikompendium',f$funktion),f$eingaben),
      bsikompendium_eingabefehler=function(e) list(fehler=e$code))
  for (k in names(f$erwartung)) {
    if (!identical(erg[[k]],f$erwartung[[k]])) stop(f$fall_id,': ',k,': ',paste(unlist(erg[[k]]),collapse=','))
  }
  for (k in names(f$kriterien_erwartung)) {
    erwartung <- f$kriterien_erwartung[[k]]
    if (is.character(erwartung)) erwartung <- list(befund=erwartung)
    for (feld in names(erwartung)) {
      if (!identical(erg$teilbefunde[[k]][[feld]],erwartung[[feld]])) stop(f$fall_id,': ',k,': ',feld,': Kriteriumsfeld falsch')
    }
  }
}
cat(length(faelle),'individuelle Fachreferenzen bestanden.\n')
vertrag <- fachlicher_eingabevertrag('ORP.3.A6')
vertrag$kriterien <- list(); vertrag$felder <- list()
erg <- pruefe_fachregel('ORP.3.A6',list(mitarbeitende=list(vollstaendig=TRUE,
  objekte=list(list(geschult_aufgaben=TRUE,geschult_verantwortung=FALSE)))))
stopifnot(erg$befund=='TEILWEISE_ERFUELLT',identical(erg$bekannte_maengel,list('ORP.3.A6.K2')))
