<h1 align="center">Dark_Loon/dotfiles</h1>

# About

In-house baked configs for Home-Manager and NixOS. Borrowed bits sprinkled on
top. Using [flakes](https://wiki.nixos.org/wiki/Flakes) and
[flake-parts](https://github.com/hercules-ci/flake-parts).

See an overview of the flake outputs by running
`nix flake show git+https://gitlab.com/Dark_Loon/dotfiles`.


# Structure

- [home](./parts/home): Home Manager config
- [modules](./parts/modules): Custom options
- [hosts](./parts/hosts): Multiple machine configurations
- [secrets](./parts/secrets): SOPS-encrypted files
- [templates](./parts/templates): Isolated development environments


# Usage

<details>
  <summary>Install</summary>

To install NixOS use the [graphical NixOS installer](https://nixos.org/download/#nixos-iso).
Then run the following:
```nu
git clone gitlab.com/DarkLoon/dotfiles ~/
cd ~/dotfiles

# To build system configuration (alternatively ./bootstrap.sh desktop or ./bootstrap.sh server)
./bootstrap.sh
```
</details>


Use a template:
```nu
# Provide a development shell (alternatively nix flake init -t gitlab:Dark_loon/dotfiles#java)
dvt java
dvt java newProject
dvt typst my-project
dvt elm
```

# Features

Some features of my config:

- Structured to allow multiple **NixOS configurations**, including **desktop** and **laptop**
- **niri** environment
- **sops-nix** for secrets management
<!-- - **Opt-in persistance** through impermanence + blank snapshot with zfs -->
<!-- - Homelab all configured in nix. -->


# Showcase

### Desktop

![snapshot](/parts/home/images/snapshot.png)
![wallpaper](/parts/home/images/wallpaper.png)


# Appendix

- <a href="https://www.nerdfonts.com/" title="Icons">Icons created by FiraCode Nerd Font</a>


# Resources

Other people from whom I learned and copied:
- [AY's NixOS System Tour](https://www.youtube.com/watch?v=BNPlubtKeWo&pp=ygUSQXNrIFlvdXJzZWxmIE5peE9T)
- [hmajid2301/nixicle](https://github.com/hmajid2301/nixicle)
- [fufexan/dotfiles](https://github.com/fufexan/dotfiles)
- [Pipshag/dotfiles_nord](https://github.com/Pipshag/dotfiles_nord)
- [Igaboury](https://github.com/lgaboury/Sway-Waybar-Install-Script)
- [Claude Sonnet 4.6, Anthropic](https://claude.ai/)
