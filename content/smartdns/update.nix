{ lib, git, gnumake, coreutils, gnugrep, gnused, writeShellScript }:
writeShellScript "dns" ''
  export PATH=${lib.makeBinPath [ coreutils gnugrep gnused gnumake git ]}
  # <<<sh>>>
  build_dir=$(mktemp -d)
  here=$(pwd)
  cd "$build_dir"
  git clone --depth 1 https://github.com/felixonmars/dnsmasq-china-list.git list
  cd list
  make smartdns SERVER=cn 

  cat ./*.smartdns.conf > $here/accelerate.conf.new
  rm $here/accelerate.conf
  mv $here/accelerate.conf.new $here/accelerate.conf
  # >>>sh<<<
''
