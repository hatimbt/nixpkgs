{
  lib,
  stdenv,
  fetchurl,
  updateAutotoolsGnuConfigScriptsHook,
  xz,
  coreutils ? null,
}:

# Note: this package is used for bootstrapping fetchurl, and thus
# cannot use fetchpatch! All mutable patches (generated by GitHub or
# cgit) that are needed here should be included directly in Nixpkgs as
# files.

stdenv.mkDerivation rec {
  pname = "diffutils";
  version = "3.11";

  src = fetchurl {
    url = "mirror://gnu/diffutils/diffutils-${version}.tar.xz";
    hash = "sha256-pz7wX+N91YX32HBo5KBjl2BBn4EBOL11xh3aofniEx4=";
  };

  outputs = [
    "out"
    "info"
  ];

  nativeBuildInputs = [
    updateAutotoolsGnuConfigScriptsHook
    (lib.getBin xz)
  ];
  # If no explicit coreutils is given, use the one from stdenv.
  buildInputs = [ coreutils ];

  # Disable stack-related gnulib tests on x86_64-darwin because they have problems running under
  # Rosetta 2: test-c-stack hangs, test-sigsegv-catch-stackoverflow fails.
  postPatch =
    if
      ((stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isx86_64) || (stdenv.hostPlatform.isAarch32))
    then
      ''
        sed -i -E 's:test-c-stack2?\.sh::g' gnulib-tests/Makefile.in
        sed -i -E 's:test-sigsegv-catch-stackoverflow[12]::g' gnulib-tests/Makefile.in
      ''
    else
      null;

  configureFlags =
    # "pr" need not be on the PATH as a run-time dep, so we need to tell
    # configure where it is. Covers the cross and native case alike.
    lib.optional (coreutils != null) "PR_PROGRAM=${coreutils}/bin/pr"
    ++ lib.optional (stdenv.buildPlatform != stdenv.hostPlatform) "gl_cv_func_getopt_gnu=yes";

  # Test failure on QEMU only (#300550)
  doCheck = !stdenv.buildPlatform.isRiscV64;

  meta = with lib; {
    homepage = "https://www.gnu.org/software/diffutils/diffutils.html";
    description = "Commands for showing the differences between files (diff, cmp, etc.)";
    license = licenses.gpl3;
    platforms = platforms.unix;
    maintainers = with maintainers; [ das_j ];
  };
}
