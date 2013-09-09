require 'formula'

class CabalInstall < Formula
  homepage 'http://www.haskell.org/haskellwiki/Cabal-Install'
  url 'http://hackage.haskell.org/packages/archive/cabal-install/1.18.0.1/cabal-install-1.18.0.1.tar.gz'
  sha1 'ac403d580bd399d682e5d8f4fd8d6d07c03622d9'

  depends_on 'ghc'

  conflicts_with 'haskell-platform'

  def install
    # create a sandbox to encapsulate the bootstrap output
    sandbox = "#{Dir.getwd}/#{`mktemp -d .sandbox-XXXX`.chuzzle}"

    # create a temporary package database
    pkg_db = "#{sandbox}/package.conf.d"
    system 'ghc-pkg', 'init', pkg_db

    # use our temporary package database instead of ~/.ghc …
    ENV['EXTRA_CONFIGURE_OPTS'] = "--package-db=#{pkg_db}"
    # put the end result under #{sandbox} instead of ~/.cabal
    ENV['PREFIX'] = "#{sandbox}"

    # download, compile, and temporarily install cabal-install dependencies
    system 'sh', 'bootstrap.sh'

    # keep the cabal binary and bash completion; trash the rest
    bin.install "#{sandbox}/bin/cabal"
    bash_completion.install 'bash-completion/cabal'
  end
end
