{ runCommand }: runCommand "zhwiki.dict.yaml" {} ''
  cat ${./zhwiki.dict.yaml.base32}|while read line;do echo "$line"|base32 -d;done > $out
''
