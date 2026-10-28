# Ausgewählte native Modellierungs-, Risiko- und Fachprüfung gleicher JSON-Eingaben.
library(bsikompendium)
args <- commandArgs(trailingOnly=TRUE)
pfad <- if (length(args)) args[[1]] else system.file(
  'examples', 'individueller_pruefablauf.json', package='bsikompendium')
d <- jsonlite::fromJSON(pfad, simplifyVector=FALSE)

# Verträge vor der Erhebung lesen: Felder, Maßstäbe und Quellenanker.
invisible(methodischer_eingabevertrag(d$modellierung$schritt_id))
invisible(fachlicher_eingabevertrag(d$fachpruefung$anforderung_id))
ergebnisse <- list(
  zielobjekt_id=d$zielobjekt_id,
  modellierung=do.call(pruefe_methodenschritt, d$modellierung),
  analysebedarf=do.call(pruefe_risikoanalysebedarf, d$analysebedarf),
  risikoeinstufung=do.call(bewerte_risiko, d$risikoeinstufung),
  fachpruefung=do.call(pruefe_fachregel, d$fachpruefung))
# Der eigene Ergebnisbefund wurde nicht als Eingabe geliefert.
stopifnot(ergebnisse$modellierung$befund == 'ERFUELLT',
          ergebnisse$analysebedarf$befund == 'ERFORDERLICH',
          ergebnisse$risikoeinstufung$befund == 'HOCH',
          ergebnisse$fachpruefung$befund == 'TEILWEISE_ERFUELLT',
          identical(ergebnisse$fachpruefung$bekannte_maengel,
                    list('INF.11.A12.K1')))
cat(jsonlite::toJSON(ergebnisse, auto_unbox=TRUE, null='null', pretty=TRUE), '\n')
