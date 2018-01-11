" These functions require visual range

function! s:detectCase(value)
  if a:value =~ '^\u'
    if a:value =~ '\l'
      return 'PascalCase'
    else
      return 'AllCaps'
    end
  else
    if a:value =~ '\u'
      return 'CamelCase'
    elseif a:value =~ '_'
      return 'SnakeCase'
    elseif a:value =~ '-'
      return 'KebabCase'
    else
      return 'Unknown'
    end
  endif
endfunction

function! s:toPascalCase(target, from)
  if a:from == 'PascalCase' || a:from == 'CamelCase'
    let l:result = substitute(a:target, '\v^(.)', '\u\1', '')
  elseif a:from == 'AllCaps'
    let l:result = substitute(tolower(a:target), '\v^(.)', '\u\1', '')
    let l:result = substitute(l:result, '\v[_-]+(\l)', '\u\1', 'g')
  else
    let l:result = substitute(tolower(a:target), '\v%([-_])@<![-_](\l)', '\u\1', 'g')
    let l:result = substitute(l:result, '\v^(.)', '\u\1', '')
  endif
  return l:result
endfunction

function! s:toCamelCase(target, from)
  if a:from == 'PascalCase' || a:from == 'CamelCase'
    let l:result = substitute(a:target, '\v^(.)', '\l\1', '')
  elseif a:from == 'AllCaps'
    let l:result = substitute(tolower(a:target), '\v[_-]+(\l)', '\u\1', 'g')
  else
    let l:result = substitute(tolower(a:target), '\v%([-_])@<![-_](\l)', '\u\1', 'g')
  endif
  return l:result
endfunction

function! s:toAllCaps(target, from)
  if a:from == 'PascalCase' || a:from == 'CamelCase' || a:from == 'AllCaps'
    let l:result = toupper(substitute(a:target, '\v(\l)(\u)', '\1_\2', 'g'))
  else
    let l:result = toupper(substitute(a:target, '\v([^_-])([_-])([^_-])', '\u\1\2\u\3', 'g'))
  endif
  return l:result
endfunction

function! s:toSnakeCase(target, from)
  if a:from == 'PascalCase' || a:from == 'CamelCase'
    let l:result = substitute(a:target, '\v(\l)(\u)', '\1_\l\2', 'g')
    let l:result = substitute(l:result, '\v^(.)', '\l\1', '')
  elseif a:from == 'AllCaps'
    let l:result = substitute(tolower(a:target), '-+', '_', 'g')
  else
    let l:result = substitute(tolower(a:target), '\v(\l)(\u)', '\1_\l\2', 'g')
    let l:result = substitute(l:result, '-+', '_', 'g')
  endif
  return l:result
endfunction

function! s:toKebabCase(target, from)
  if a:from == 'PascalCase' || a:from == 'CamelCase'
    let l:result = substitute(a:target, '\v(\l)(\u)', '\1-\l\2', 'g')
    let l:result = substitute(l:result, '\v^(.)', '\l\1', '')
  elseif a:from == 'AllCaps'
    let l:result = substitute(tolower(a:target), '_+', '-', 'g')
  else
    let l:result = substitute(tolower(a:target), '\v(\l)(\u)', '\1-\l\2', 'g')
    let l:result = substitute(l:result, '_+', '-', 'g')
  endif
  return l:result
endfunction

function! case#ConvertCaseTo(format) range
  let l:tmp = @"
  normal! gvy
  let l:current = s:detectCase(@")
  if a:format == 'PascalCase'
    let @" = s:toPascalCase(@", l:current)
  elseif a:format == 'CamelCase'
    let @" = s:toCamelCase(@", l:current)
  elseif a:format == 'AllCaps'
    let @" = s:toAllCaps(@", l:current)
  elseif a:format == 'SnakeCase'
    let @" = s:toSnakeCase(@", l:current)
  elseif a:format == 'KebabCase'
    let @" = s:toKebabCase(@", l:current)
  endif

  normal! gvP
  let @" = l:tmp
endfunction
