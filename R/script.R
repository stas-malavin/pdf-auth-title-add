# Settings --------------------------------------------------------------------
require(magrittr)
path <- 'pdf'
out <- 'pdf_out'
ffs <- list.files(path, full.names = F)

# Get author from the filename ------------------------------------------------
get_auth <- function(ff, rem_etal = rem_etal) {
  aa <-
    # Extract names (all together)
    regmatches(ff, regexec('^\\D*', ff)) %>% 
    unlist %>% 
    # Split names
    strsplit('-|_| ') %>% 
    unlist
    if (rem_etal) {
      # Remove "et alii" et cetera
      aa %<>% .[!grepl('^et$|^al.{,2}$|^и$|^др\\.?$', .)]
    }
  return(aa)
}

sapply(ffs, get_auth, rem_etal)

# Get title from the filename -------------------------------------------------
get_title <- function(ff) {
  tt <-
    # Extract title
    regmatches(ff, regexec('\\D*$', ff)) %>% unlist %>% 
    # Split words
    strsplit('-|_| ') %>% unlist %>% 
    .[ . != '' ] %>% 
    sub('\\.pdf', '', .)
  return(tt)
}

# Read contents ---------------------------------------------------------------
# Compare times:
system.time(txt <- system2('head', '-n 15', input = system2('pdftotext', c('pdf/Renz*.pdf', '-'), stdout = T, stderr = F)))
system.time(txt <- system('pdftotext pdf/Renz*.pdf - | head -n 15', intern = T))
system.time({
  txt <- system2('pdftotext', c('pdf/Renz*.pdf', '-'), stdout = T, stderr = F)
  txt %<>% head(15)})
system.time(txt <- system2('pdftotext', c('pdf/Renz*.pdf', '-'), stdout = T, stderr = F))
# => no need to use 'head'
txt <- system2('pdftotext', c('pdf/Renz*.pdf', '-'), stdout = T, stderr = F)

# Get _true_ authors ----------------------------------------------------------
aa <- auth[[1]]
# if authors' list is longer than one line:
AA_beg <- sapply(aa, function(x) grep(x, txt)[1]) %>% min
AA_end <- sapply(aa, function(x) grep(x, txt)[1]) %>% max
AA <- txt[ AA_beg:AA_end ] %>% paste(collapse = ' ') %>%
  regmatches(gregexpr('[[:upper:]][[:lower:]]+', .)) %>%
  unlist %>% 
  paste(collapse = ',')

# Get _true_ title ------------------------------------------------------------
# if title is longer than one line:
TT_beg <- sapply(tt, function(x) grep(x, txt)[1]) %>% min
TT_end <- AA_line - 1
TT <- txt[ TT_beg:TT_end ] %>% paste(collapse = ' ')

# Get key words ---------------------------------------------------------------
KW_beg <- grep( '^(?i)Key\\>', txt )[1]
KW_end <- grep('^$', txt) %>% 
  .[ . > KW_beg ] %>% .[1] - 1
KW <- txt[ KW_beg:KW_end ] %>% .[-1] %>% paste(collapse = ',')

# Set properties --------------------------------------------------------------
args <- c(
  paste('-o', 'pdf_out'),
  paste0('-Author="', AA, '"'),
  paste0('-Title="', TT, '"'),
  paste0('-Keywords="', KW, '"'),
  ff
)
system2('exiftool', args, stdout = T)
