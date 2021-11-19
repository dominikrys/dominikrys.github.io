---
title: "Installing Zsh (and oh-my-zsh) in Windows Git Bash"
date: 2021-11-11T19:10:26Z
ShowToc: true
cover:
    image: "img/cover.png"
    alt: "Cover"
tags:
  - windows
  - shell
---

I've recently started using Windows again. After a long time using a customised Zsh shell on macOS and Linux though, I've started to miss some of the small productivity boosts that Zsh plugins offered me. Of course, I could set up the shell as I want it under WSL, but WSL doesn't always play nicely with Windows-native applications and tools. To remedy this, I looked into how I could set up Zsh to run instead of Bash in Git Bash.

There are a couple of guides on GitHub from some years ago on how this can be achieved. However, I found they're either outdated, or they don't include information on whether plugins and custom themes can be used. I've addressed these issues in this post.

## Installing Zsh in Git Bash

1. Download the latest MSYS2 zsh package from [the MSYS2 package repository](https://packages.msys2.org/package/zsh?repo=msys&variant=x86_64). The file will be named something along the lines of `zsh-5.8-5-x86_64.pkg.tar.zst`.

2. Install an extractor that can open ZST archives such as [PeaZip](https://peazip.github.io/) or [7-Zip Beta](https://www.7-zip.org/).

3. Extract the contents of the archive (which should include `etc` and `usr` folders) into your Git Bash installation directory. This is likely to be under `C:\Program Files\Git`. Merge the contents of the folder if asked (no files should be getting overridden).

4. Open Git Bash and run:

    ```bash
    zsh
    ```

5. **IMPORTANT:** configure the tab completion and history in the Zsh first use wizard. If for some reason it doesn't appear, or you skip it, re-run it:

    ```bash
    autoload -U zsh-newuser-install
    zsh-newuser-install -f
    ```

    - To configure the history, press `1`, change the values if you like by pressing `1-3`, and then press `0`.
    - To configure the completion, press `2` to "Use the new completion system", and then press `0`.
    - Press `0` to save the settings.

6. Configure Zsh as the default shell by appending the following to your `~/.bashrc` file:

    ```bash
    if [ -t 1 ]; then
      exec zsh
    fi
    ```

## Installing oh-my-zsh

From this point, your Git Bash will behave essentially like a Unix Zsh shell. To install oh-my-zsh, run the usual command that you'd run in any Zsh shell:

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
```

## Installing plugins and themes

To install plugins and themes, use their oh-my-zsh installation methods. I've installed the [Powerlevel10k](https://github.com/romkatv/powerlevel10k) theme as well as the following plugins, and can verify that they work:

- [zsh-completions](https://github.com/zsh-users/zsh-completions)
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
  - NOTE: you may get strange artifacts and spacing in your terminal as of version `v0.7.0`. To fix this, use version `v.0.6.4`:

    ```bash
    cd ~/.oh-my-zsh/plugins/zsh-autosuggestions
    git checkout tags/v0.6.4 -b v0.6.4-branch
    ```

## Fixing mangled output

Windows can mangle some UTF-8 encoded text, causing unexpected characters to be displayed in your terminal (more info in [this Stack Overflow answer](https://stackoverflow.com/a/65688816/13749561)). To fix this, add the following to your `~/.bashrc` file, ideally before code that sets your shell as Zsh:

```bash
/c/Windows/System32/chcp.com 65001 > /dev/null 2>&1
```

## Troubleshooting

[fworks's guide](https://gist.github.com/fworks/af4c896c9de47d827d4caa6fd7154b6b) tends to be fairly active, so it's worth searching for or asking about any problems you may have there. Note that some of the information on there is outdated.
