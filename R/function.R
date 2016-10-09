set_meta <- function(dir, dir_out, interactive = T) {
  
  require(magrittr)
  if(interactive) message('running in interactive mode')
  if (!file.exists(dir_out)) dir.create(dir_out)
  ffs <- list.files(dir, full.names = F)
  for (ff in ffs) {
    # Get author and title from the filename ----------------------------------
    aa <-
      # Extract names (all together)
      regmatches(ff, regexec('^\\D*', ff, perl = T)) %>% 
      unlist %>% 
      # Split names
      strsplit('-|_| ') %>% 
      unlist
    tt <-
      # Extract title
      regmatches(ff, regexec('(?<=\\d{4}).*$', ff, perl = T)) %>% unlist %>% 
      # Split words
      strsplit('-|_| ') %>% unlist %>% 
      .[ . != '' ] %>% 
      sub('\\.pdf', '', .)

    # Read file content -------------------------------------------------------
    tryCatch(
      txt <- system2('pdftotext',
        c(paste0('"', file.path(dir, ff), '"'), '-'),
        stdout = T, stderr = F),
      error = function(e) message('file', ff, "can't be read")
    )
    
    # Read existing metadata --------------------------------------------------
    tryCatch(
      am <- system2('exiftool',
        c('-Author', paste0('"', file.path(dir, ff), '"')),
        stdout = T, stderr = F) %>% 
        sub('Author\\s*:\\s*', '', .),
      error = function(e) {
        message('author metadata of file  ', ff, "  can't be read")
        am <- character(0)
      }
    )
    tryCatch(
      tm <- system2('exiftool',
        c('-Title', paste0('"', file.path(dir, ff), '"')),
        stdout = T, stderr = F) %>% 
        sub('Title\\s*:\\s*', '', .),
      error = function(e) {
        message('title metadata of file  ', ff, "  can't be read")
        tm <- character(0)
      }
    )
    tryCatch(
      km <- system2('exiftool',
        c('-Keywords', paste0('"', file.path(dir, ff), '"')),
        stdout = T, stderr = F) %>% 
        sub('Keywords\\s*:\\s*', '', .),
      error = function(e) {
        message('keywords metadata of file  ', ff, "  can't be read")
        kw <- character(0)
      }
    )
    
    # Get data from the text --------------------------------------------------
    # Authors
    tryCatch({
      if (length(am) > 0) AA <- am 
        else {
          AA_beg <- grep(paste0('^.{,10}','(?i)', aa[1]), txt)[1]
          AA <- txt[AA_beg] %>%
            gsub("[*'@#$%†‡※•¿¡]|\\d", '', .) %>% 
            gsub(',+', ',', .) %>% 
            gsub(', , ', ', ', .) %>% 
            gsub(' , ', ', ', .)
        }
      },
      error = function(e) AA <<- '',
      finally = if(is.na(AA)) AA <<- ''
    )
    # Title
    tryCatch({
      if (length(tm) > 0) TT <- tm
        else {
        TT_beg <- sapply( tt[nchar(tt) > 5 ],
          function(x) grep(paste0('(?i)', x), txt)[1]) %>%
          table %>% which.max %>% names %>% as.numeric
        TT_end <- AA_beg - 1
        TT <- txt[ TT_beg:TT_end ] %>% paste(collapse = ' ')
        }
      },
      error = function(e) TT <<- '',
      finally = if(is.na(TT)) TT <<- ''
    )
    # Keywords
    tryCatch({
      if (length(km) > 0) KW <- km
        else {
          KW_beg <- grep( '^(?i)key\\s?words\\>|^(?i)ключевые слова\\>',
            txt )[1]
          KW_end <- grep('^$', txt) %>% .[ . > KW_beg ] %>% .[1] - 1
          KW <- txt[ KW_beg:KW_end ] %>%
            gsub('(?i)key\\s?words\\s?:?\\s?|(?i)ключевые слова:?\\s?',
              '', .) %>%
            .[.!=''] %>% 
            gsub(';', ',', .) %>% 
            gsub('\\.', '', .) %>% 
            paste(collapse = ', ')
        }
      },
      error = function(e) KW <<- ''
    )
    
    # Interactively choose metadata to fill in --------------------------------
    if (interactive) {
      # Open file by external program
      system2('zathura',
        paste0('"', file.path(dir, ff), '"'), wait = F)
      
      # Choose authors
      msg <- paste('file: ', ff,
        '\n(1) authors found: ', AA,
        '\n(2) authors from file name: ',
        paste(aa, collapse = ', ') %>% sub(', et, al', ' et al.', .),
        '\nchoose:   use 1 / use 2 / input manually  (1/2/authors): ')
      What <- readline(cat(msg))
      if (What == '2') AA <- paste(aa, collapse = ', ')
        else if (What != '1') AA <- What
      
      # Choose title
      msg <- paste(
        # 'file:', ff,
        '\n(1) title found: ', TT,
        '\n(2) title from file name: ',
        paste(tt, collapse = ' '),
        '\nchoose:  use 1 / use 2 / input manually  (1/2/title): ')
      What <- readline(cat(msg))
      if (What == '2') TT <- paste(tt, collapse = ' ')
      else if (What != '1') TT <- What
      
      # Choose keywords
      msg <- paste(
        # 'file:', ff,
        '\n(1) keywords found: ', KW,
        '\nchoose:  use found / input manually  (1/keywords): ')
      What <- readline(cat(msg))
      if (What != '1') KW <- What
    }

    # Set metadata ------------------------------------------------------------
    args <- c(
      paste0('-o "', dir_out, '"'),
      paste0('-Author="', get('AA'), '"'),
      paste0('-Title="', get('TT'), '"'),
      paste0('-Keywords="', get('KW'), '"'),
      paste0('"', file.path(dir, ff), '"')
    )
    tryCatch({
      system2('exiftool', args, stdout = T, stderr = T)
      cat('file processed\n')},
      error = function(e) message('failed to set metadata of file ', ff),
      warning = function(e) message('failed to set metadata of file ', ff)
    )
    if (interactive) {
      zathura_last_proc <- system2('pgrep', 'zathura', stdout = T) %>% max
      system2('kill', zathura_last_proc)
      What <- readline('continue? (Y/n) ')
      if (What == 'n') stop('interrupted by user')
      cat('\n----- NEXT -----\n')
    }
  }
}