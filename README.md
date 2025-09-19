# MuXiu1997/dotfiles

MuXiu1997's personal dotfiles, managed with [`chezmoi`](https://github.com/twpayne/chezmoi).

## Reference

- [twpayne/chezmoi: Manage your dotfiles across multiple machines, securely](https://github.com/twpayne/chezmoi)

- [XDG Base Directory](https://wiki.archlinux.org/title/XDG_Base_Directory)

## Install

```bash
bash -c "$(curl -fsSL https://github.com/MuXiu1997/dotfiles/raw/main/install.sh)"
```

## TODO

- [x] Remove `deviceId` related configurations and replace the condition with `personal` tag
- [x] Enhance scripts in `.chezmoiscripts` directory with better logging output
- [ ] Remove `dot_local/bin/executable_setup-dock` and migrate its functionality to `.chezmoiscripts/run_once_after_91-configure-darwin.sh.tmpl`
- [x] Optimize `Homebrew` installation process and configuration management

## License

[MIT](https://github.com/MuXiu1997/dotfiles/blob/main/LICENSE)
