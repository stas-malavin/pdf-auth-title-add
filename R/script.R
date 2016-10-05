require(magrittr)
path <- 'pdf'
ffs <- list.files(path, full.names = F)
auth <- list()
for (ff in ffs) {
  auth <- c(auth,
    list(
      # Extract names (all together)
      regmatches(ff, regexec('^\\D*', ff)) %>% 
      unlist %>% 
      # Split names
      strsplit('-|_') %>% 
      unlist %>% 
      # Remove "et alii" et cetera
      .[!grepl('^et$|^al.{,2}$|^и$|^др\\.?$', .)]
    )
  )
}
