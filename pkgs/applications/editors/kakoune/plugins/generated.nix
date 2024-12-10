# This file has been generated by ./pkgs/applications/editors/kakoune/plugins/update.py. Do not edit!
{
  lib,
  buildKakounePluginFrom2Nix,
  fetchFromGitHub,
  overrides ? (self: super: { }),
}:
let
  packages = (
    self: {
      active-window-kak = buildKakounePluginFrom2Nix {
        pname = "active-window-kak";
        version = "2022-11-14";
        src = fetchFromGitHub {
          owner = "greenfork";
          repo = "active-window.kak";
          rev = "36bf0364eed856a52cddf274072e9f255902c0ee";
          sha256 = "1fv1cp9q212gamf9z2papl5xcl2w31fpcmbgdzbxcxdl1pvfsqp8";
        };
        meta.homepage = "https://github.com/greenfork/active-window.kak/";
      };

      auto-pairs-kak = buildKakounePluginFrom2Nix {
        pname = "auto-pairs-kak";
        version = "2023-07-30";
        src = fetchFromGitHub {
          owner = "alexherbo2";
          repo = "auto-pairs.kak";
          rev = "d4b33b783ea42a536c848296b5b6d434b4d1470f";
          sha256 = "017x9g89q0w60y561xhigc0f14ryp4phh1hdna847ca5lvmbxksp";
        };
        meta.homepage = "https://github.com/alexherbo2/auto-pairs.kak/";
      };

      byline-kak = buildKakounePluginFrom2Nix {
        pname = "byline-kak";
        version = "2023-02-27";
        src = fetchFromGitHub {
          owner = "evanrelf";
          repo = "byline.kak";
          rev = "a27d109b776c60e11752eeb3207c989a5e157fc0";
          sha256 = "121dxd65ml65ablkvdxj0rib3kvfwss0pv943bgl3nq35ag19b81";
        };
        meta.homepage = "https://github.com/evanrelf/byline.kak/";
      };

      connect-kak = buildKakounePluginFrom2Nix {
        pname = "connect-kak";
        version = "2021-02-24";
        src = fetchFromGitHub {
          owner = "kakounedotcom";
          repo = "connect.kak";
          rev = "a536605a208149eed58986bda54f3dda215dfe61";
          sha256 = "1svw64zk28sn271vjyzvq21zaln13vnx59rxnxah6adq8n5nkr4a";
        };
        meta.homepage = "https://github.com/kakounedotcom/connect.kak/";
      };

      fzf-kak = buildKakounePluginFrom2Nix {
        pname = "fzf-kak";
        version = "2022-10-11";
        src = fetchFromGitHub {
          owner = "andreyorst";
          repo = "fzf.kak";
          rev = "6910bfb4c23cac59c17f5b7850f7bd49aba3e5cb";
          sha256 = "1hlals4d9x5i4mwigxjlx4f9xgc9rw15yzvbvc64cminxic2i3i8";
        };
        meta.homepage = "https://github.com/andreyorst/fzf.kak/";
      };

      kakboard = buildKakounePluginFrom2Nix {
        pname = "kakboard";
        version = "2022-04-02";
        src = fetchFromGitHub {
          owner = "lePerdu";
          repo = "kakboard";
          rev = "5759dcc5af593ff88a7faecc41a8f549ec440771";
          sha256 = "0g8q0rkdnzsfvlibjd1zfcapngfli5aa3qrgmkgdi24n9ad8wzvh";
        };
        meta.homepage = "https://github.com/lePerdu/kakboard/";
      };

      kakoune-buffer-switcher = buildKakounePluginFrom2Nix {
        pname = "kakoune-buffer-switcher";
        version = "2022-09-18";
        src = fetchFromGitHub {
          owner = "occivink";
          repo = "kakoune-buffer-switcher";
          rev = "21319aa08e7c9072dcf1a4f2f5583887d701fc37";
          sha256 = "0lnvcb4khw1ywxd369phd2xibsh5f6qc11x5vrla331wr1q7y8j8";
        };
        meta.homepage = "https://github.com/occivink/kakoune-buffer-switcher/";
      };

      kakoune-buffers = buildKakounePluginFrom2Nix {
        pname = "kakoune-buffers";
        version = "2021-11-10";
        src = fetchFromGitHub {
          owner = "Delapouite";
          repo = "kakoune-buffers";
          rev = "6b2081f5b7d58c72de319a5cba7bf628b6802881";
          sha256 = "0pbrgydifw2a8yf3ringyqq91fccfv4lm4v8sk5349hbcz6apr4c";
        };
        meta.homepage = "https://github.com/Delapouite/kakoune-buffers/";
      };

      kakoune-easymotion = buildKakounePluginFrom2Nix {
        pname = "kakoune-easymotion";
        version = "2020-03-09";
        src = fetchFromGitHub {
          owner = "danr";
          repo = "kakoune-easymotion";
          rev = "0ca75450023a149efc70e8e383e459b571355c70";
          sha256 = "15czvl0qj2k767pysr6xk2v31mkhvcbmv76xs2a8yrslchms70b5";
        };
        meta.homepage = "https://github.com/danr/kakoune-easymotion/";
      };

      kakoune-extra-filetypes = buildKakounePluginFrom2Nix {
        pname = "kakoune-extra-filetypes";
        version = "2021-05-16";
        src = fetchFromGitHub {
          owner = "kakoune-editor";
          repo = "kakoune-extra-filetypes";
          rev = "8ffeec08068edfee42e076c5f6d56a54a498bad2";
          sha256 = "1v87aqfk2jcysbdls3mh2v1yafk1albbinfxsxp11m4nxd2b9agl";
        };
        meta.homepage = "https://github.com/kakoune-editor/kakoune-extra-filetypes/";
      };

      kakoune-rainbow = buildKakounePluginFrom2Nix {
        pname = "kakoune-rainbow";
        version = "2020-09-01";
        src = fetchFromGitHub {
          owner = "listentolist";
          repo = "kakoune-rainbow";
          rev = "d09103e8d268cf4621215bf162a0244c9482be3c";
          sha256 = "1i3id7xw0j4z1a14mscr68ckpgvcwsjpl86lr864wy7w7qcmblx6";
        };
        meta.homepage = "https://github.com/listentolist/kakoune-rainbow/";
        meta.mainProgram = "kak-rainbow.scm";
      };

      kakoune-registers = buildKakounePluginFrom2Nix {
        pname = "kakoune-registers";
        version = "2022-03-01";
        src = fetchFromGitHub {
          owner = "Delapouite";
          repo = "kakoune-registers";
          rev = "b8ca8e04ebe50671a937bceccba69c62b68ae8b0";
          sha256 = "0vy5dc6jly5xqcck0vhnmbjxjdy3615b6d329v0b04amzy0hdlck";
        };
        meta.homepage = "https://github.com/Delapouite/kakoune-registers/";
      };

      kakoune-vertical-selection = buildKakounePluginFrom2Nix {
        pname = "kakoune-vertical-selection";
        version = "2023-04-20";
        src = fetchFromGitHub {
          owner = "occivink";
          repo = "kakoune-vertical-selection";
          rev = "dbb39712e3824ca6142b510f26f35a769934a1e1";
          sha256 = "1wncx16a8mi2b81cvkiji3ccv8is5g3sa4hwf1669va5a432vdwn";
        };
        meta.homepage = "https://github.com/occivink/kakoune-vertical-selection/";
      };

      openscad-kak = buildKakounePluginFrom2Nix {
        pname = "openscad-kak";
        version = "2020-12-10";
        src = fetchFromGitHub {
          owner = "mayjs";
          repo = "openscad.kak";
          rev = "ba51bbdcd96ccf94bb9239bef1481b6f37125849";
          sha256 = "15dybd6dnnwla6mj8sw83nwd62para1syxzifznl6rz6kp8vqjjj";
        };
        meta.homepage = "https://github.com/mayjs/openscad.kak/";
      };

      pandoc-kak = buildKakounePluginFrom2Nix {
        pname = "pandoc-kak";
        version = "2021-06-29";
        src = fetchFromGitHub {
          owner = "basbebe";
          repo = "pandoc.kak";
          rev = "e9597e8df58427884161ce27392a9558930832a7";
          sha256 = "1baslidszbybx2ngdkm7wns2m5l27gc0mb3blhhydiav8fcfvc6m";
        };
        meta.homepage = "https://github.com/basbebe/pandoc.kak/";
      };

      powerline-kak = buildKakounePluginFrom2Nix {
        pname = "powerline-kak";
        version = "2022-04-05";
        src = fetchFromGitHub {
          owner = "andreyorst";
          repo = "powerline.kak";
          rev = "c5ef9a845bbd886c73ef00c0efff986e02d5f5d8";
          sha256 = "1lshlnz5xrxzafxmb6w05g2i6nvi49aqyd8852k9l0lmzqryp7l2";
        };
        meta.homepage = "https://github.com/andreyorst/powerline.kak/";
      };

      prelude-kak = buildKakounePluginFrom2Nix {
        pname = "prelude-kak";
        version = "2021-02-24";
        src = fetchFromGitHub {
          owner = "kakounedotcom";
          repo = "prelude.kak";
          rev = "5dbdc020c546032885c1fdb463e366cc89fc15ad";
          sha256 = "1pncr8azqvl2z9yvzhc68p1s9fld8cvak8yz88zgrp5ypx2cxl8c";
        };
        meta.homepage = "https://github.com/kakounedotcom/prelude.kak/";
      };

      smarttab-kak = buildKakounePluginFrom2Nix {
        pname = "smarttab-kak";
        version = "2022-04-10";
        src = fetchFromGitHub {
          owner = "andreyorst";
          repo = "smarttab.kak";
          rev = "86ac6599b13617ff938905ba4cdd8225d7eb6a2e";
          sha256 = "1992xwf2aygzfd26lhg3yiy253g0hl1iagj0kq9yhcqg0i5xjcj9";
        };
        meta.homepage = "https://github.com/andreyorst/smarttab.kak/";
      };

      tabs-kak = buildKakounePluginFrom2Nix {
        pname = "tabs-kak";
        version = "2023-05-15";
        src = fetchFromGitHub {
          owner = "enricozb";
          repo = "tabs.kak";
          rev = "f0b3a399db1dfa12b89fbff3eed09aec74725bab";
          sha256 = "1sg26bv4vr08pqyxp68wsmzj8vhi2qg1bmkqb2jnngi5sjp4r7xy";
        };
        meta.homepage = "https://github.com/enricozb/tabs.kak/";
      };

      zig-kak = buildKakounePluginFrom2Nix {
        pname = "zig-kak";
        version = "2019-05-06";
        src = fetchFromGitHub {
          owner = "adrusi";
          repo = "zig.kak";
          rev = "5a7e84e138324e6b8d140fe384dfe5cc941e26b7";
          sha256 = "1w0nmhsgchjga4by9ch9md3pdc1bwn0p157g6zwnfpj7lnaahsmq";
        };
        meta.homepage = "https://github.com/adrusi/zig.kak/";
      };

    }
  );
in
lib.fix' (lib.extends overrides packages)
