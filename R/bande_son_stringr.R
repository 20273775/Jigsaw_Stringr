library(tidyverse)

fichier <- "data/My Spotify Library.csv"
stopifnot("Placez le fichier CSV dans data/." = file.exists(fichier))

bande_son <- read_csv(fichier, show_col_types = FALSE) |>
  select(titre = `Track name`, artiste = `Artist name`, album = Album, isrc = ISRC)

# Étape 1 : nettoyage et titre de base
invisibles <- "[\\u200b\\u200c\\u200d\\ufeff]"

etape1 <- bande_son |>
  mutate(
    titre_net = str_replace_all(titre, invisibles, ""),
    titre_base = titre_net |>
      # Collaborations entre parenthèses ou crochets
      str_replace_all("(?i)\\s*[\\(\\[]\\s*(feat|ft|featuring|with)\\b[^\\)\\]]*[\\)\\]]", "") |>
      # Autres crochets
      str_replace_all("\\s*\\[[^\\]]*\\]", "") |>
      # Suffixe après un tiret
      str_replace_all("\\s+-\\s+.*$", "") |>
      # Parenthèses de version
      str_replace_all("(?i)\\s*\\([^\\)]*(remaster|remix|edit|version)[^\\)]*\\)", "") |>
      str_squish()
  )

# Étape 2 : détection des versions et collaborations
motif_collab <- "(?i)(\\(|\\[|- )\\s*(feat|ft|featuring|with)\\b\\.?\\s+"

etape2 <- etape1 |>
  mutate(
    est_remaster = str_detect(titre_net, regex("remaster", ignore_case = TRUE)),
    est_remix = str_detect(titre_net, regex("remix", ignore_case = TRUE)),
    est_collab = str_detect(titre_net, motif_collab)
  )

resume_etape2 <- etape2 |>
  summarise(
    titres = n(),
    remasters = sum(est_remaster),
    remix = sum(est_remix),
    collaborations = sum(est_collab)
  )

# Étape 3 : extraction de l'invité, de l'année de réédition et de l'époque
etape3 <- etape2 |>
  mutate(
    invite = titre_net |>
      str_extract(str_c(motif_collab, "[^\\)\\]]+")) |>
      str_remove(motif_collab),
    annee_remaster = str_extract(titre_net, "\\d{4}(?= Remaster)") |> as.integer(),
    annee_isrc = isrc |>
      str_to_upper() |>
      str_extract("^[A-Z]{2}[A-Z0-9]{3}\\d{2}") |>
      str_sub(-2) |>
      as.integer(),
    annee_isrc = if_else(annee_isrc <= 26, 2000 + annee_isrc, 1900 + annee_isrc),
    decennie = str_c(annee_isrc %/% 10 * 10, "s")
  )

# Étape 4 : casse des titres entièrement en majuscules
etape4 <- etape3 |>
  mutate(
    titre_propre = if_else(
      str_detect(titre_base, "^[^a-z]+$"),
      str_to_title(titre_base),
      titre_base
    ),
    cle = str_c(str_to_lower(artiste), " | ", str_to_lower(titre_propre))
  )

# Résultats
chansons <- etape4 |>
  distinct(cle, .keep_all = TRUE)

tibble(
  lignes = nrow(etape4),
  chansons_distinctes = nrow(chansons)
)

etape4 |>
  group_by(cle) |>
  filter(n() > 1) |>
  ungroup() |>
  arrange(artiste, titre_propre) |>
  select(artiste, titre) |>
  slice_head(n = 10)

chansons |>
  filter(!is.na(decennie)) |>
  count(decennie) |>
  ggplot(aes(x = decennie, y = n)) +
  geom_col(fill = "#2a6f97") +
  labs(
    x = "Décennie (estimée avec l'ISRC)",
    y = "Chansons distinctes",
    title = "Répartition de la bande sonore par décennie"
  ) +
  theme_minimal()

chansons |>
  count(artiste, name = "chansons", sort = TRUE) |>
  slice_head(n = 5)
