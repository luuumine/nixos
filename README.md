# lumine's nixos

> [!CAUTION]
> this flake was made by, and to be used by, myself. it's still very incomplete and will definitely change a lot with time. i have many things planned and lots will happen here.
> thanks for reading this :)

i try to keep this structured "enough" so that i understand what's going on.


## hosts

```text
hosts
├── luminix     [my main desktop]
├── luminadel   [my server]
└── luminova    [config for vms and such]
```

## thanks

- [Vimjoyer](https://www.youtube.com/@vimjoyer), for introducing me to nix
- [NotAShelf/nyx](https://github.com/NotAShelf/nyx), for being such a well structured flake
- [poz](https://poz.pet/), for being cool and having a nice [config](https://git.poz.pet/poz/niksos)
- [orangc](https://orangc.net), for helping me with tailscale

## usage

everything's under the `config.lumine.<thing>` userspace, to avoid clashing with stuff that already exists somewhere

just put the ~~fries~~ modules in the bag bro..
