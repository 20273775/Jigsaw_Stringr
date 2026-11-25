# Nettoyer une liste de lecture avec stringr

Projet de l'activité Jigsaw Classroom « Aller plus loin dans le Tidyverse ». Il présente quatre fonctions du paquetage `stringr` appliquées à une liste de lecture Spotify désordonnée.

## Pour les coéquipiers : l'essentiel en bref

Le problème : les titres de la liste ne sont pas propres. La même chanson apparaît sous plusieurs formes (« Devil Woman » et « Devil Woman - 2001 Remaster »), les collaborations sont écrites de plusieurs façons (« feat. », « ft. », « with », « Featuring »), certains titres sont en majuscules, et certains contiennent des caractères invisibles. Tant qu'on ne nettoie pas le texte, on ne peut ni compter les chansons distinctes, ni répondre aux questions de l'émission (époque, rééditions, collaborations).

La démarche suit quatre fonctions de `stringr`, dans cet ordre :

1. **`str_replace_all()`** : nettoyer les titres et obtenir un titre « de base ». Elle remplace tout ce qui correspond à un motif (caractères invisibles, collaborations entre parenthèses, suffixes après un tiret, mentions de version) par du vide. Les remplacements s'enchaînent avec `|>`.
2. **`str_detect()`** : repérer les rééditions, les remix et les collaborations. Elle renvoie `TRUE` ou `FALSE` pour chaque titre. `regex(..., ignore_case = TRUE)` ignore la casse.
3. **`str_extract()`** : extraire l'artiste invité, l'année de la réédition, et estimer l'époque à partir des deux chiffres de l'année dans le code ISRC.
4. **`str_to_title()`** : uniformiser la casse des titres entièrement en majuscules. On ne l'applique qu'aux textes sans aucune minuscule, pour ne pas abîmer des noms comme « McDonald's » ou « iPhone ».

Fonctions auxiliaires utilisées : `str_squish()`, `str_remove()`, `str_to_lower()`, `str_c()`, `str_sub()`. Elles viennent aussi de `stringr`, mais l'exercice demande que les trois ou quatre fonctions principales soient les seules à présenter en détail.

## Contenu du projet

| Fichier | Rôle |
|---|---|
| `bande_son_stringr.qmd` | Rapport reproductible (Quarto) : contexte, démarche, résultats, conclusion. C'est le fichier à présenter. |
| `R/bande_son_stringr.R` | Même nettoyage sous forme de script R, sans texte autour. |
| `data/My Spotify Library.csv` | Export Spotify original (948 titres). |
| `data/My_Spotify_Library_messy.csv` | Version désordonnée générée à partir de l'export (973 lignes, avec 25 doublons en variantes). C'est elle que le rapport lit. |

## Comment l'utiliser

Pré-requis : R, le paquetage `tidyverse`, `knitr`, et Quarto pour le rendu HTML.

1. Cloner le dépôt et ouvrir le dossier `Jigsaw_Stringr` dans Positron ou RStudio. Les chemins sont relatifs à la racine du dossier, donc il faut bien ouvrir ce dossier comme projet de travail.
2. Pour générer le rapport HTML : `quarto render bande_son_stringr.qmd`. Ou ouvrir le fichier dans Positron et cliquer sur *Render*.
3. Pour exécuter seulement le code : ouvrir `R/bande_son_stringr.R` et l'exécuter.

Le chunk `generation-fichier` du rapport est désactivé (`eval: false`). Il sert uniquement à recréer le fichier désordonné à partir de l'export original, avec une graine fixe (`set.seed(7394)`). Il ne doit pas être réexécuté, sinon le fichier changera.

## Résultats de référence

- Les 78 titres contenant des caractères invisibles ont tous été nettoyés.
- Le fichier désordonné (973 lignes) donne 929 chansons distinctes, comme l'export original : les 25 doublons sont bien retrouvés.

## Limites à connaître

- L'époque vient de l'année d'attribution de l'ISRC, pas de la date de sortie. Un titre ancien réédité peut être classé dans une décennie récente.
- La détection de « feat » attrape toute parenthèse commençant par ce mot, ce qui pourrait toucher un vrai titre.
- La règle « tout ce qui suit un tiret est un suffixe » peut couper un titre légitime qui contient un tiret.
- Une règle de casse reste une approximation : un sigle comme « TQG » devient « Tqg ». Les résultats doivent être vérifiés.
