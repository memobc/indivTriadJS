library(tidyverse)
library(patchwork)

pltA <- read_rds(file = 'figures/winsor-595_plt.Rds') + theme(aspect.ratio = 1)
pltB <- read_rds(file = 'figures/winsor-1090_plt.Rds') + theme(aspect.ratio = 1)
pltC <- read_rds(file = 'figures/winsor-2575_plt.Rds') + theme(aspect.ratio = 1)

pltA + pltB + pltC + 
  plot_annotation(title = 'Overall Accuracy Retrieval Dependency Confound in Winsorized Subsamples')

ggsave(filename = 'figures/Figure16.png', 
       plot = last_plot(), device = 'png', 
       width = 9, height = 6.42, 
       units = 'in', dpi = 600)
