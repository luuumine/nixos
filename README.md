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
├── luminode    [my backup server]
├── luminout    [my laptop]
└── luminova    [config for vms and such]
```

## thanks

- [Vimjoyer](https://www.youtube.com/@vimjoyer), for introducing me to nix
- [raf / NotAShelf](https://notashelf.dev), for being very good at nix, building cool projects, and having such a well structured [flake](https://github.com/notashelf/nyx)
- [poz](https://poz.pet/), for being cool and having a nice [config](https://nix.poz.pet/)
- [orangc](https://orangc.net), for helping me with tailscale
- [Turpix](https://twitter.com/Turpix_00), for drawing the awesome art used for my profile picture and wallpapers
- [fazzi](https://gitlab.com/fazzi/nixohess), for having clean hyprland animations
- [matilde](https://matilde.pet), for the inspiration behind some of the design

## usage

everything's under the `config.lumine.<thing>` userspace, to avoid clashing with stuff that already exists somewhere

just put the ~~fries~~ modules in the bag bro..
