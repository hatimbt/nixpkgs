{ stdenv, symlinkJoin, lib, makeWrapper
, bundlerEnv
, ruby
, nodejs
, writeText
, neovim-node-client
, python3
, callPackage
, neovimUtils
, perl
, lndir
, vimUtils
}:

neovim-unwrapped:

let
  # inherit interpreter from neovim
  lua = neovim-unwrapped.lua;

  wrapper = {
      extraName ? ""
    # certain plugins need a custom configuration (available in passthru.initLua)
    # to work with nix.
    # if true, the wrapper automatically appends those snippets when necessary
    , autoconfigure ? true

    # append to PATH runtime deps of plugins
    , autowrapRuntimeDeps ? true

    # should contain all args but the binary. Can be either a string or list
    , wrapperArgs ? []
    , withPython2 ? false
    , withPython3 ? true
    /* the function you would have passed to python3.withPackages */
    , extraPython3Packages ? (_: [ ])

    , withNodeJs ? false
    , withPerl ? false
    , withRuby ? true

    # wether to create symlinks in $out/bin/vi(m) -> $out/bin/nvim
    , vimAlias ? false
    , viAlias ? false

    # additional argument not generated by makeNeovimConfig
    # it will append "-u <customRc>" to the wrapped arguments
    # set to false if you want to control where to save the generated config
    # (e.g., in ~/.config/init.vim or project/.nvimrc)
    , wrapRc ? true
    # vimL code that should be sourced as part of the generated init.lua file
    , neovimRcContent ? null
    # lua code to put into the generated init.lua file
    , luaRcContent ? ""
    # DEPRECATED: entry to load in packpath
    # use 'plugins' instead
    , packpathDirs ? null # not used anymore

    # a list of neovim plugin derivations, for instance
    #  plugins = [
    # { plugin=far-vim; config = "let g:far#source='rg'"; optional = false; }
    # ]
    , plugins ? []
    , ...
  }@attrs:
  assert withPython2 -> throw "Python2 support has been removed from the neovim wrapper, please remove withPython2 and python2Env.";

  assert packpathDirs != null -> throw "packpathdirs is not used anymore: pass a list of neovim plugin derivations in 'plugins' instead.";

  stdenv.mkDerivation (finalAttrs:
  let
    pluginsNormalized = neovimUtils.normalizePlugins finalAttrs.plugins;

    myVimPackage = neovimUtils.normalizedPluginsToVimPackage pluginsNormalized;

    rubyEnv = bundlerEnv {
      name = "neovim-ruby-env";
      gemdir = ./ruby_provider;
      postBuild = ''
        ln -sf ${ruby}/bin/* $out/bin
      '';
    };

    pluginRC = lib.foldl (acc: p: if p.config != null then acc ++ [p.config] else acc) []  pluginsNormalized;

    # a limited RC script used only to generate the manifest for remote plugins
    manifestRc = "";
    # we call vimrcContent without 'packages' to avoid the init.vim generation
    neovimRcContent' = lib.concatStringsSep "\n" (pluginRC ++ lib.optional (neovimRcContent != null) neovimRcContent);

    packpathDirs.myNeovimPackages = myVimPackage;
    finalPackdir = neovimUtils.packDir packpathDirs;

    luaPluginRC = let
      op = acc: normalizedPlugin:
           acc ++ lib.optional (finalAttrs.autoconfigure && normalizedPlugin.plugin.passthru ? initLua) normalizedPlugin.plugin.passthru.initLua;
      in
        lib.foldl' op [] pluginsNormalized;

    rcContent = ''
      ${luaRcContent}
    '' + lib.optionalString (neovimRcContent' != null) ''
      vim.cmd.source "${writeText "init.vim" neovimRcContent'}"
    '' +
      lib.concatStringsSep "\n" luaPluginRC
    ;

    getDeps = attrname: map (plugin: plugin.${attrname} or (_: [ ]));

    requiredPlugins = vimUtils.requiredPluginsForPackage myVimPackage;
    pluginPython3Packages = getDeps "python3Dependencies" requiredPlugins;

    python3Env = lib.warnIf (attrs ? python3Env) "Pass your python packages via the `extraPython3Packages`, e.g., `extraPython3Packages = ps: [ ps.pandas ]`"
      python3.pkgs.python.withPackages (ps:
      [ ps.pynvim ]
      ++ (extraPython3Packages ps)
      ++ (lib.concatMap (f: f ps) pluginPython3Packages));


    wrapperArgsStr = if lib.isString wrapperArgs then wrapperArgs else lib.escapeShellArgs wrapperArgs;

    generatedWrapperArgs =
            [
              # vim accepts a limited number of commands so we join all the provider ones
              "--add-flags" ''--cmd "lua ${providerLuaRc}"''
            ]
            ++ lib.optionals (finalAttrs.packpathDirs.myNeovimPackages.start != [] || finalAttrs.packpathDirs.myNeovimPackages.opt != []) [
              "--add-flags" ''--cmd "set packpath^=${finalPackdir}"''
              "--add-flags" ''--cmd "set rtp^=${finalPackdir}"''
            ]
            ++ lib.optionals finalAttrs.withRuby [
              "--set" "GEM_HOME" "${rubyEnv}/${rubyEnv.ruby.gemPath}"
            ] ++ lib.optionals (finalAttrs.runtimeDeps != []) [
              "--suffix" "PATH" ":" (lib.makeBinPath finalAttrs.runtimeDeps)
            ]
            ;

    providerLuaRc = neovimUtils.generateProviderRc {
      inherit (finalAttrs) withPython3 withNodeJs withPerl withRuby;
    };

    # If configure != {}, we can't generate the rplugin.vim file with e.g
    # NVIM_SYSTEM_RPLUGIN_MANIFEST *and* NVIM_RPLUGIN_MANIFEST env vars set in
    # the wrapper. That's why only when configure != {} (tested both here and
    # when postBuild is evaluated), we call makeWrapper once to generate a
    # wrapper with most arguments we need, excluding those that cause problems to
    # generate rplugin.vim, but still required for the final wrapper.
    finalMakeWrapperArgs =
      [ "${neovim-unwrapped}/bin/nvim" "${placeholder "out"}/bin/nvim" ]
      ++ [ "--set" "NVIM_SYSTEM_RPLUGIN_MANIFEST" "${placeholder "out"}/rplugin.vim" ]
      ++ lib.optionals finalAttrs.wrapRc [ "--add-flags" "-u ${writeText "init.lua" rcContent}" ]
      ++ finalAttrs.generatedWrapperArgs
      ;

    perlEnv = perl.withPackages (p: [ p.NeovimExt p.Appcpanminus ]);

    pname = "neovim";
    version = lib.getVersion neovim-unwrapped;
  in {
      name = "${pname}-${version}${extraName}";
      inherit pname version;
      inherit plugins;

      __structuredAttrs = true;
      dontUnpack = true;
      inherit viAlias vimAlias withNodeJs withPython3 withPerl withRuby;
      inherit autoconfigure autowrapRuntimeDeps wrapRc providerLuaRc packpathDirs;
      inherit python3Env rubyEnv;
      inherit wrapperArgs generatedWrapperArgs;


      runtimeDeps = let
        op = acc: normalizedPlugin: acc ++ normalizedPlugin.plugin.runtimeDeps or [];
        runtimeDeps = lib.foldl' op [] pluginsNormalized;
      in
             lib.optional finalAttrs.withRuby rubyEnv
          ++ lib.optional finalAttrs.withNodeJs nodejs
          ++ lib.optionals finalAttrs.autowrapRuntimeDeps runtimeDeps
          ;


      luaRcContent = rcContent;
      # Remove the symlinks created by symlinkJoin which we need to perform
      # extra actions upon
      postBuild = lib.optionalString stdenv.hostPlatform.isLinux ''
        rm $out/share/applications/nvim.desktop
        substitute ${neovim-unwrapped}/share/applications/nvim.desktop $out/share/applications/nvim.desktop \
          --replace-warn 'Name=Neovim' 'Name=Neovim wrapper'
      ''
      + lib.optionalString finalAttrs.withPython3 ''
        makeWrapper ${python3Env.interpreter} $out/bin/nvim-python3 --unset PYTHONPATH --unset PYTHONSAFEPATH
      ''
      + lib.optionalString (finalAttrs.withRuby) ''
        ln -s ${finalAttrs.rubyEnv}/bin/neovim-ruby-host $out/bin/nvim-ruby
      ''
      + lib.optionalString finalAttrs.withNodeJs ''
        ln -s ${neovim-node-client}/bin/neovim-node-host $out/bin/nvim-node
      ''
      + lib.optionalString finalAttrs.withPerl ''
        ln -s ${perlEnv}/bin/perl $out/bin/nvim-perl
      ''
      + lib.optionalString finalAttrs.vimAlias ''
        ln -s $out/bin/nvim $out/bin/vim
      ''
      + lib.optionalString finalAttrs.viAlias ''
        ln -s $out/bin/nvim $out/bin/vi
      ''
      + lib.optionalString (manifestRc != null) (let
        manifestWrapperArgs =
          [ "${neovim-unwrapped}/bin/nvim" "${placeholder "out"}/bin/nvim-wrapper" ] ++ finalAttrs.generatedWrapperArgs;
      in ''
        echo "Generating remote plugin manifest"
        export NVIM_RPLUGIN_MANIFEST=$out/rplugin.vim
        makeWrapper ${lib.escapeShellArgs manifestWrapperArgs} ${wrapperArgsStr}

        # Some plugins assume that the home directory is accessible for
        # initializing caches, temporary files, etc. Even if the plugin isn't
        # actively used, it may throw an error as soon as Neovim is launched
        # (e.g., inside an autoload script), causing manifest generation to
        # fail. Therefore, let's create a fake home directory before generating
        # the manifest, just to satisfy the needs of these plugins.
        #
        # See https://github.com/Yggdroot/LeaderF/blob/v1.21/autoload/lfMru.vim#L10
        # for an example of this behavior.
        export HOME="$(mktemp -d)"
        # Launch neovim with a vimrc file containing only the generated plugin
        # code. Pass various flags to disable temp file generation
        # (swap/viminfo) and redirect errors to stderr.
        # Only display the log on error since it will contain a few normally
        # irrelevant messages.
        if ! $out/bin/nvim-wrapper \
          -u ${writeText "manifest.vim" manifestRc} \
          -i NONE -n \
          -V1rplugins.log \
          +UpdateRemotePlugins +quit! > outfile 2>&1; then
          cat outfile
          echo -e "\nGenerating rplugin.vim failed!"
          exit 1
        fi
        rm "${placeholder "out"}/bin/nvim-wrapper"
      '')
      + ''
        rm $out/bin/nvim
        touch $out/rplugin.vim

        echo "Looking for lua dependencies..."
        source ${lua}/nix-support/utils.sh

        _addToLuaPath "${finalPackdir}"

        echo "LUA_PATH towards the end of packdir: $LUA_PATH"

        makeWrapper ${lib.escapeShellArgs finalMakeWrapperArgs} ${wrapperArgsStr} \
            --prefix LUA_PATH ';' "$LUA_PATH" \
            --prefix LUA_CPATH ';' "$LUA_CPATH"
      '';

    buildPhase = ''
      runHook preBuild
      mkdir -p $out
      for i in ${neovim-unwrapped}; do
        lndir -silent $i $out
      done
      runHook postBuild
    '';

    preferLocalBuild = true;

    nativeBuildInputs = [ makeWrapper lndir ];

    # A Vim "package", see ':h packages'
    vimPackage = myVimPackage;

    checkPhase = ''
      runHook preCheck

      $out/bin/nvim -i NONE -e +quitall!
      runHook postCheck
      '';

    passthru = {
      inherit providerLuaRc packpathDirs;
      unwrapped = neovim-unwrapped;
      initRc = neovimRcContent';

      tests = callPackage ./tests {
      };
    };

    meta = {
      inherit (neovim-unwrapped.meta)
        description
        longDescription
        homepage
        mainProgram
        license
        maintainers
        platforms;

      # To prevent builds on hydra
      hydraPlatforms = [];
      # prefer wrapper over the package
      priority = (neovim-unwrapped.meta.priority or lib.meta.defaultPriority) - 1;
    };
  });
in
  lib.makeOverridable wrapper
