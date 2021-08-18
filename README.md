# Personal Website and Blog

Available at **[dominikrys.com](https://dominikrys.com/)**

## Cloning

```zsh
git clone --recurse-submodules git@github.com:dominikrys/dominikrys.github.io.git
```

## Building and Usage

Deployment:

```zsh
./build.sh [--clear-gen]
```

Local testing:

```zsh
hugo serve [-D]
```

Add a new post:

```zsh
hugo new --kind post-bundle posts/<POST NAME>
```

## Notes

### Technical Details

- Built with [Hugo](https://gohugo.io/)

- Hosted on [GitHub Pages](https://pages.github.com/)

  > Website deployed from the `docs` folder, so that the generated website and raw markdown is kept in one repo. `docs` is used as it's [the only deployment directory supported by GitHub Pages apart from root](https://docs.github.com/en/github/working-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site).

### Images

- For blank cover images, use dimensions of 2000x800 (1:4 ratio).

- Export [diagrams.net](https://app.diagrams.net/) diagrams with 500% zoom and 5 border radius.
