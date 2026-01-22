<h1 align="center">Dark_Loon/dotfiles</h1>

# About

In-house baked configs for Home-Manager and NixOS. Borrowed bits sprinkled on
top. Using [flakes](https://nixos.wiki/wiki/Flakes) and
[flake-parts](https://github.com/hercules-ci/flake-parts).

See an overview of the flake outputs by running
`nix flake show git+https://gitlab.com/DarkLoon/dotfiles`.


# Structure

- [home](./home): Home Manager config
- [module](./modules): Custom options
- [system](./hosts): Multiple machine configurations


# Usage

<details>
  <summary>Install</summary>

To install NixOS use the nix installer ISO.
Then run the following:
```bash
git clone gitlab.com/DarkLoon/dotfiles ~/
cd ~/dotfiles

# To build system configuration (alternatively ./bootstrap.sh desktop or ./bootstrap.sh server)
./bootstrap.sh
```
</details>


# Features

Some features of my config:

- Structured to allow multiple **NixOS configurations**, including **desktop** and **laptop**
- **niri** environment
- Custom **Ghostty** setup
<!-- - **Opt-in persistance** through impermanence + blank snapshot with zfs -->
<!-- - Homelab all configured in nix. -->
<!-- - **sops-nix** for secrets management -->


# Showcase

### Desktop

![terminal](home/images/terminal.png)
![notifications](home/images/notifications.png)
![wallpaper](home/images/wallpaper.png)


# Appendix

- <a href="https://www.nerdfonts.com/" title="Icons">Icons created by FiraCode Nerd Font</a>


# Resources

Other people from whom I learned and copied:
- [AY's NixOS System Tour](https://www.youtube.com/watch?v=BNPlubtKeWo&pp=ygUSQXNrIFlvdXJzZWxmIE5peE9T)
- [hmajid2301/nixicle](https://github.com/hmajid2301/nixicle)
- [fufexan/dotfiles](https://github.com/fufexan/dotfiles)
- [Pipshag/dotfiles_nord](https://github.com/Pipshag/dotfiles_nord)
- [Igaboury](https://github.com/lgaboury/Sway-Waybar-Install-Script)
