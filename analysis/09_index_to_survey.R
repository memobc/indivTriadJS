# requirements
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(corrplot))

# data
tidy.bias     <- read_rds(file = 'tidy_bias.rds')
tidy.sam      <- read_rds(file = 'tidy_sam.rds')
tidy.iri      <- read_rds(file = 'tidy_iri.rds')
tidy.vivq     <- read_rds(file = 'tidy_vviq.rds')

# minor tidying

tidy.sam %>%
  pivot_wider(names_from = 'category', values_from = 'response') -> tidy.sam

tidy.iri %>%
  pivot_wider(names_from = 'category', values_from = 'score') -> tidy.iri

tidy.vivq %>%
  rename(visual_imagery = response) -> tidy.vivq

left_join(tidy.bias, tidy.sam, by = 'subject_id') %>%
  left_join(tidy.iri, by = 'subject_id') %>%
  left_join(tidy.vivq, by = 'subject_id') -> df

## Analyses

df %>%
  ungroup() %>%
  dplyr::select(-subject_id) %>%
  corrr::correlate() -> corr_mat

df %>%
  ungroup() %>%
  dplyr::select(-subject_id) %>%
  corrplot::cor.mtest() %>%
  magrittr::extract2('p') %>%
  `diag<-`(1) %>%
  corrr::as_cordf() %>%
  corrr::shave(upper = F) %>%
  corrr::stretch(na.rm = T) %>%
  rename(p = r) -> p

corr_mat %>%
  corrr::shave(upper = F) %>%
  corrr::stretch(na.rm = T) %>%
  left_join(p) -> corr_df

corr_df %>%
  ggplot(aes(x = x, y = y, fill = r)) +
  geom_text(aes(label = round(r, 2)), color = 'black') +
  scale_fill_gradient2() +
  scale_x_discrete(limits = rev(corr_mat$term)) +
  scale_y_discrete(limits = rev(corr_mat$term)) +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1), axis.title = element_blank())

corr_df %>%
  ggplot(aes(x = x, y = y, fill = r)) +
  geom_raster() +
  geom_text(aes(label = round(r, 2)), color = 'black') +
  scale_fill_gradient2() +
  scale_x_discrete(limits = rev(corr_mat$term)) +
  scale_y_discrete(limits = rev(corr_mat$term)) +
  guides(fill = 'none', alpha = 'none') +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1), axis.title = element_blank())

corr_df %>%
  ggplot(aes(x = x, y = y, fill = r, alpha = p < 0.05)) +
  geom_raster() +
  geom_text(aes(label = round(r, 2)), color = 'black') +
  scale_fill_gradient2() +
  scale_x_discrete(limits = rev(corr_mat$term)) +
  scale_y_discrete(limits = rev(corr_mat$term)) +
  theme_classic() +
  guides(fill = 'none', alpha = 'none') +
  theme(axis.text.x = element_text(angle = 90, hjust = 1), axis.title = element_blank())

