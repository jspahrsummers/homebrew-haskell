require 'formula'

class Ghcbinary < Formula
  if MacOS.version <= :leopard
    raise Homebrew::InstallationError.new(self, <<-EOS.undent
      Mac OS X versions 10.5 and earlier are not supported by the GHC formula.
      EOS
    )
  end
  if Hardware.is_64_bit? and not build.build_32_bit?
    if MacOS.version >= :lion
      url 'http://www.haskell.org/ghc/dist/7.6.3/ghc-7.6.3-x86_64-apple-darwin.tar.bz2'
      sha1 'fb9f18197852181a9472221e1944081985b75992'
    elsif MacOS.version == :snow_leopard
      url 'http://www.haskell.org/ghc/dist/7.2.2/ghc-7.2.2-x86_64-apple-darwin.tar.bz2'
      sha1 'a21bf999f07aa4e976dfff6c7f708287291d1b31'
    end
  else
    if MacOS.version >= :lion
      url 'http://www.haskell.org/ghc/dist/7.6.3/ghc-7.6.3-i386-apple-darwin.tar.bz2'
      sha1 '6a312263fef41e06003f0676b879f2d2d5a1f30c'
    elsif MacOS.version == :snow_leopard
      url 'http://www.haskell.org/ghc/dist/7.2.2/ghc-7.2.2-i386-apple-darwin.tar.bz2'
      sha1 'd04525570d3122e2a4b5dfed738b7b146813406b'
    end
  end
  if MacOS.version >= :lion
    version '7.6.3'
  elsif MacOS.version == :snow_leopard
    version '7.2.2'
  end
end

class Ghctestsuite < Formula
  url 'https://github.com/ghc/testsuite/archive/ghc-7.6.3-release.tar.gz'
  sha1 '6a1973ae3cccdb2f720606032ae84ffee8680ca1'
end

class Ghc < Formula
  homepage 'http://haskell.org/ghc/'
  url 'http://www.haskell.org/ghc/dist/7.6.3/ghc-7.6.3-src.tar.bz2'
  sha1 '8938e1ef08b37a4caa071fa169e79a3001d065ff'

  env :std

  # http://hackage.haskell.org/trac/ghc/ticket/6009
  depends_on :macos => :snow_leopard

  option '32-bit'
  option 'tests', 'Verify the build using the testsuite in Fast Mode, 5 min'

  fails_with :clang do
    cause <<-EOS.undent
      Building with Clang configures GHC to use Clang as its preprocessor,
      which causes subsequent GHC-based builds to fail.
      EOS
  end

  def patches
    # fixes ghc 7.6.3 compilation on Xcode 5
    DATA
  end

  def install
    # Move the main tarball contents into a subdirectory
    (buildpath+'Ghcsource').install Dir['*']

    # Define where the subformula will temporarily install itself
    subprefix = buildpath+'subfo'

    Ghcbinary.new.brew do
      # ensure configure script does not use Xcode 5 "gcc" aka clang
      bin_cfg_args =  %W[ --prefix=#{subprefix} ]
      bin_cfg_args << "--with-gcc=#{ENV.cc}"

      system "./configure", *bin_cfg_args
      system 'make install'
      ENV.prepend 'PATH', subprefix/'bin', ':'
    end

    cd 'Ghcsource' do
      # Fix an assertion when linking ghc with llvm-gcc
      # https://github.com/mxcl/homebrew/issues/13650
      ENV['LD'] = 'ld'

      if Hardware.is_64_bit? and not build.build_32_bit?
        arch = 'x86_64'
      else
        ENV.m32 # Need to force this to fix build error on internal libgmp.
        arch = 'i386'
      end

      # ensure configure script does not use Xcode 5 "gcc" aka clang
      src_cfg_args = %W[ --prefix=#{prefix} --build=#{arch}-apple-darwin ]
      src_cfg_args << "--with-gcc=#{ENV.cc}"

      system "./configure", *src_cfg_args
      system 'make'
      if build.include? 'tests'
        Ghctestsuite.new.brew do
          (buildpath+'Ghcsource/config').install Dir['config/*']
          (buildpath+'Ghcsource/driver').install Dir['driver/*']
          (buildpath+'Ghcsource/mk').install Dir['mk/*']
          (buildpath+'Ghcsource/tests').install Dir['tests/*']
          (buildpath+'Ghcsource/timeout').install Dir['timeout/*']
          cd (buildpath+'Ghcsource/tests') do
            system 'make', 'CLEANUP=1', "THREADS=#{ENV.make_jobs}", 'fast'
          end
        end
      end
      system 'make -j1 install' # -j1 fixes an intermittent race condition
    end
  end

  def caveats; <<-EOS.undent
    This brew is for GHC only; you might also be interested in haskell-platform.
    EOS
  end
end

__END__
diff --git a/includes/HsFFI.h b/includes/HsFFI.h
index 652fbea..a21811e 100644
--- a/includes/HsFFI.h
+++ b/includes/HsFFI.h
@@ -21,7 +21,7 @@ extern "C" {
 #include "stg/Types.h"
 
 /* get limits for integral types */
-#ifdef HAVE_STDINT_H
+#if defined HAVE_STDINT_H && !defined USE_INTTYPES_H_FOR_RTS_PROBES_D
 /* ISO C 99 says:
  * "C++ implementations should define these macros only when
  * __STDC_LIMIT_MACROS is defined before <stdint.h> is included."
diff --git a/rts/RtsProbes.d b/rts/RtsProbes.d
index 13f40f8..226f881 100644
--- a/rts/RtsProbes.d
+++ b/rts/RtsProbes.d
@@ -6,6 +6,12 @@
  *
  * ---------------------------------------------------------------------------*/
 
+#ifdef __APPLE__ && __MACH__
+# define USE_INTTYPES_H_FOR_RTS_PROBES_D
+#endif
+
 #include "HsFFI.h"
 #include "rts/EventLogFormat.h"
 
diff --git a/utils/mkdirhier/mkdirhier.sh b/utils/mkdirhier/mkdirhier.sh
index 4c5d5f7..80762f4 100644
--- a/utils/mkdirhier/mkdirhier.sh
+++ b/utils/mkdirhier/mkdirhier.sh
@@ -1,4 +1,4 @@
 #!/bin/sh
 
-mkdir -p ${1+"$@"}
+mkdir -p ${1+"./$@"}
 
