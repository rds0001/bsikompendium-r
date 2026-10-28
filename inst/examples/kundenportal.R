# Legacy-Beispiel: Absatz-Selbstauskunft, keine individuelle Fachprüfung von 0.2.
# Individuelle Quellenverträge zeigt individueller_pruefablauf.R.
library(bsikompendium)
args <- commandArgs(trailingOnly=TRUE)
pfad <- if (length(args)) args[[1]] else system.file('examples','kundenportal.json',package='bsikompendium')
d <- jsonlite::fromJSON(pfad,simplifyVector=FALSE)
ergebnisse <- list(
  inventar=pruefe_informationsverbund(d$objekte),
  modellierung=pruefe_modellierung(d$objekte,d$zuordnungen),
  risikoanalyse=pruefe_risikoanalysebedarf(d$schutzbedarf,d$hinreichend_modelliert,d$typisches_szenario),
  risiko=bewerte_risiko(d$haeufigkeit,d$schaden,d$matrix),
  anforderung=pruefe_anforderung(d$anforderung_id,d$bewertungen,TRUE))
stopifnot(ergebnisse$inventar$befund=='STRUKTURELL_KONSISTENT',
          ergebnisse$modellierung$befund=='ZUORDNUNGEN_BESTAETIGT',
          ergebnisse$risikoanalyse$befund=='ERFORDERLICH',
          ergebnisse$risiko$befund=='HOCH',
          ergebnisse$anforderung$befund=='TEILWEISE_ERFUELLT')
cat(jsonlite::toJSON(ergebnisse,auto_unbox=TRUE,null='null',pretty=TRUE))
