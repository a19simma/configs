# This is the repo for my vaious configurations

Nvim setup is based on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim)
### Dev commands

Backup local copies
```
cp ~/.zshrc ~/.zshrc.bak &&
cp -R ~/.config ~/.config.bak
```

Copy local files to repo
```
cp ~/.zshrc ./zsh/.zshrc &&
cp -R ~/.config/nvim ./
```

Link repo files to local config
```
rm -rf ~/.config/nvim
ln -s ./nvim ~/.config/nvim
```
