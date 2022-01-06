# home-manager portable users module args example

An example flake demonstrating the absence of the `pkgs` argument from
home-manager portable user configurations evaluated by
`home-manager.lib.homeManagerConfiguration` via the `home.user` attrset
argument to `digga.mkFlake`.

To demonstrate the issue, run the following from this repository's toplevel:

```
$ ./evaluate-hm-config-attrs
```

You should see output similar to:

```
# =============================================================================
$ nix eval .#hmConfig.config.home.username
# =============================================================================
"me"
# =============================================================================
[SUCCEEDED] hmConfig.config.home.username
# =============================================================================
# =============================================================================
$ nix eval .#fupHmConfig."x86_64-linux".config.home.username
# =============================================================================
"me"
# =============================================================================
[SUCCEEDED] fupHmConfig."x86_64-linux".config.home.username
# =============================================================================
# =============================================================================
$ nix eval .#homeConfigurationsPortable."x86_64-linux".me.config.home.username
# =============================================================================
error: 'hmProfile' at /nix/store/r26lg0q79qgi5l9ankswfzlp64grxd00-source/flake.nix:20:19 called without required argument 'pkgs'

       at /nix/store/8n591v5p3kj8ar5wm0j06xs824mdx7rh-source/lib/types.nix:484:114:

          483|       merge = loc: defs:
          484|         fnArgs: (mergeDefinitions (loc ++ [ "[function body]" ]) elemType (map (fn: { inherit (fn) file; value = fn.value fnArgs; }) defs)).mergedValue;
             |                                                                                                                  ^
          485|       getSubOptions = elemType.getSubOptions;
(use '--show-trace' to show detailed location information)
# =============================================================================
[FAILED] homeConfigurationsPortable."x86_64-linux".me.config.home.username
# =============================================================================
```
