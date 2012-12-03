cabal-dev add-source direct-sqlite
cabal-dev add-source sqlite-simple
cabal-dev --extra-config-file=cabalconf --force-reinstalls --reinstall install direct-sqlite --ghc-option=-auto-all
cabal-dev --extra-config-file=cabalconf --force-reinstalls --reinstall install sqlite-simple --ghc-option=-auto-all
cabal-dev --extra-config-file=cabalconf --force-reinstalls --reinstall install
