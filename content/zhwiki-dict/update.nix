{ lib, python3, fetchFromGitHub, cmake, git, gnumake, wget, gzip, coreutils, bash
, findutils, gnused, writeShellScript }:
let
  opencc = with python3.pkgs;
    buildPythonPackage rec {
      pname = "OpenCC";
      version = "1.1.2";

      src = fetchFromGitHub {
        owner = "BYVoid";
        repo = "OpenCC";
        rev = "ver.${version}";
        sha256 = "1a15p9idznh23b44r7rw2zjnirbxjs5pyq3k6xkz0k64cdh2zq6h";
      };

      nativeBuildInputs = [ cmake ];
      dontUseCmakeConfigure = true;

      preBuild = ''
        ${python3.interpreter} setup.py build_ext
      '';
    };
  python = python3.withPackages (p: with p; [ opencc pypinyin ]);
in writeShellScript "zhwiki" ''
  export PATH='${
    lib.makeBinPath [ git python gnumake wget gzip coreutils gnused findutils bash ]
  }'
  # <<<sh>>>
  build_dir=$(mktemp -d)
  here=$(pwd)
  cd "$build_dir"
  git clone --depth 1 https://github.com/felixonmars/fcitx5-pinyin-zhwiki.git zhwiki
  cd zhwiki
  sed -i 's/echo -e/printf --/' Makefile
  make VERSION=latest WEB_SLANG_VERSION=latest zhwiki.dict.yaml
  cat zhwiki.dict.yaml|while read line;do echo "$line"|base32 -w 0;echo;done > zhwiki.dict.yaml.base32

  cp zhwiki.dict.yaml.base32 $here/zhwiki.dict.yaml.base32.new
  rm $here/zhwiki.dict.yaml.base32
  mv $here/zhwiki.dict.yaml.base32.new $here/zhwiki.dict.yaml.base32
  # >>>sh<<<
''
