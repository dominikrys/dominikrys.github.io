# Personal Website and Blog

Available at **[dominikrys.com](https://dominikrys.com/)**

## Cloning

```zsh
git clone --recurse-submodules git@github.com:dominikrys/dominikrys.github.io.git
```

## Building and Usage

Local testing:

```bash
hugo serve [-D]
```

Add a new post:

```bash
hugo new --kind post-bundle posts/<POST NAME SEPARATED BY DASHES>
```

The website is deployed automatically using CI from the `main` branch.

For automated local theme updates, a [Lefthook](https://github.com/evilmartians/lefthook) script is included. Run `lefthook install` to initialize it.

## Notes

### Technical Details

- Built with [Hugo](https://gohugo.io/)

- Hosted on [GitHub Pages](https://pages.github.com/)

### Images

- For blank cover images, use dimensions of 2000x800 (1:4 ratio).

- Export [diagrams.net](https://app.diagrams.net/) diagrams with 500% zoom and 5 border radius.
