<div align="center">

<h1 align="center">MuXiu1997's dotfiles</h1>

<p>
  <a href="https://github.com/MuXiu1997/dotfiles/blob/main/LICENSE"><img alt="GitHub" src="https://img.shields.io/github/license/MuXiu1997/dotfiles?style=flat-square"></a>
  <a href="https://github.com/twpayne/chezmoi"><img alt="chezmoi" src="https://img.shields.io/badge/managed%20by-chezmoi@2.64.0-52e892?style=flat-square&logo=chezmoi"></a>
  <a href="https://github.com/jdx/mise"><img alt="mise" src="https://img.shields.io/badge/env-mise-00d9ff?style=flat-square&logo=mise"></a>
</p>

<p><b>MuXiu1997's personal dotfiles, managed by <a href="https://github.com/twpayne/chezmoi">chezmoi</a></b></p>

<br/>
</div>

> [!NOTE]
> This repository contains my personal environment settings. It is highly tailored to my own workflow and is primarily intended for my personal use. Feel free to use it as a reference or inspiration for your own configuration.

## Reference

- [twpayne/chezmoi: Manage your dotfiles across multiple machines, securely](https://github.com/twpayne/chezmoi)
- [XDG Base Directory](https://wiki.archlinux.org/title/XDG_Base_Directory)

## Install

```bash
bash -c "$(curl -fsSL https://github.com/MuXiu1997/dotfiles/raw/main/install.sh)"
```

## TODO

- [ ] Remove `dot_local/bin/executable_setup-dock` and migrate its functionality to `.chezmoiscripts/run_once_after_91-configure-darwin.sh.tmpl`

## License

This project is licensed under the [MIT License](LICENSE).
