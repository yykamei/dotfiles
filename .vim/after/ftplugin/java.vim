setlocal shiftwidth=2
setlocal tabstop=2

" For Gradle
let g:syntastic_java_javac_classpath = join(split(glob(getcwd() . "/**/*.jar")), ':') . ':' . join(split(glob("~/.gradle/**/*.jar")), ':')
