source('R/function.R')

# dir <- file.path(getwd(), 'pdf')
# dir <- file.path(getwd(), 'pdf1')
dir <- file.path(getwd(), 'pdf2')
dir_out <- file.path(getwd(), 'pdf_out')
set_meta(dir, dir_out)

interactive <- T
ffs <- list.files(dir, full.names = F)
ffs <- list.files(dir_out, full.names = F)
paper <- 2
ff <- ffs[paper]

set_meta('/home/stas/Documents/SITE-LAB/papers', '/home/stas/Documents/SITE-LAB/papers_out')
