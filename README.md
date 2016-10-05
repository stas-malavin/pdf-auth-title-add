# pdf-auth-title-add
R function to add author and title metadata to `pdf` files

This assumes that all `pdf` files are named following a convention:
`Author1-Author2-...-YYYY-Title-of-the-paper.pdf`

Delimeters may be either `-`, `_`, or just ` `.

## The function does the following:
1. Extracts the names of the authors from the filename
2. Tries to find their initials in the text
3. Extracts the title of the paper from the filename
4. Adds the authors' names and the title to the correspondings fields in file metadata

## Requirements:
\*nix

[R](http://www.r-project.org)

[exiftool](http://owl.phy.queensu.ca/~phil/exiftool/)
