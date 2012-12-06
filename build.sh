cabal-dev add-source direct-sqlite
cabal-dev add-source sqlite-simple
#CONF="--extra-config-file=cabalconf"
cabal-dev $CONF --force-reinstalls --reinstall install direct-sqlite --ghc-option=-auto-all
cabal-dev $CONF --force-reinstalls --reinstall install sqlite-simple --ghc-option=-auto-all
cabal-dev $CONF --extra-config-file=cabalconf --force-reinstalls --reinstall install
