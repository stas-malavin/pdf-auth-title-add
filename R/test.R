source('R/function.R')
set_meta(file.path(getwd(), 'pdf1'), file.path(getwd(), 'pdf_out'))

interactive <- T
dir <- file.path(getwd(), 'pdf1')
dir_out <- file.path(getwd(), 'pdf_out')
ffs <- list.files(dir, full.names = F)
ffs <- list.files(dir_out, full.names = F)
paper <- 2
ff <- ffs[paper]

set_meta('/home/stas/Documents/SITE-LAB/papers', '/home/stas/Documents/SITE-LAB/papers_out')
