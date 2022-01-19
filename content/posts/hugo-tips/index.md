---
title: "Tips for Developing a Static Site Using Hugo"
date: 2022-01-05T21:08:18Z
ShowToc: true
cover:
    image: "img/cover.png"
    alt: "Cover"
tags:
  - hugo
  - documentation
---

I've been asked a handful of times how this blog is written and maintained. The answer changed every time, as the blog's gone through a couple of iterations in the time I've had it. I reckon that it's in a good state now, so I thought that I'd collate and document what I found works well with developing a Hugo static site, and what I wished that I knew earlier.

These tips may be useful for personal blogs, but also more generally for static sites. I've worked for a couple of companies that use Hugo for various knowledge bases and wikis, for example, so some of this advice also has the potential to streamline those workflows.

## How This Blog Is Written Developed

The setup for this blog is quite simple. The posts are written in ordinary Markdown and generated into a static site using [Hugo](https://gohugo.io/). To automate the building process, I push my changes to GitHub where a CI pipeline builds the website and deploys it to [GitHub Pages](https://pages.github.com/).

### Why Not Use a Dedicated Blog Website?

Admittedly, using a static site generator may seem like a lot of hassle compared to using a service that lets you have a blog out-of-the-box such as [Hashnode](https://hashnode.com/), [DEV.to](https://dev.to/), or [Medium](https://medium.com/). However, I highly value that I own this blog's content. I don't have to worry about if the service that hosts my blog suddenly changes the way certain elements are displayed, or locks my posts behind a paywall or a daily post limit. I can also more easily migrate the data to another service since all the content is in Markdown, which is very flexible.

## Tips

### 💻 Set up Your Environment to Work with Hugo

You write posts in Markdown that Hugo can then generate into static sites. For this, all you really need is a text editor. Out of the box in most text editors though, this is a much less pleasant writing experience compared to writing a post in a rich text editor. I personally use [Visual Studio Code](https://code.visualstudio.com/) along with a couple of extensions to find issues as I type:

- [markdownlint](https://marketplace.visualstudio.com/items?itemName=DavidAnson.vscode-markdownlint) - helps with keeping the styling of Markdown files consistent and can find errors in my formatting.
- [Grammarly (unofficial)](https://marketplace.visualstudio.com/items?itemName=znck.grammarly) - helps find grammatical mistakes and strangely worded phrases. Sometimes the extension breaks, in which case the [Grammarly website](https://app.grammarly.com/) works well. Note that you can freely paste your entire raw Markdown into the Grammarly website, and it will ignore all the Markdown formatting directives.
- [Code Spell Checker](https://marketplace.visualstudio.com/items?itemName=streetsidesoftware.code-spell-checker) - spell checker.
- [Capitalize](https://marketplace.visualstudio.com/items?itemName=viablelab.capitalize) - used to normalise the capitalization in the titles (super pedantic, I know).

Alongside VSCode I run the Hugo server using `hugo serve -D`, allowing me to check how my changes look in real-time.

### 🎨 Choose Your Theme Wisely

One of my main motivations for using a static site generator compared to making the blog from scratch is that I don't have to worry about maintaining the theme or the styling, allowing me to focus on writing blog posts. Given this, Hugo themes vary. You may start using a theme, only to find that it doesn't include a feature you'd like. In such a case, you'll either have to extend the theme to support the feature (which admittedly is fairly easy to do in Hugo) or use another theme with that feature. The problem with making this yourself is that it may break in the future and it would be harder to guarantee that it works properly on many devices and device form factors.

Another problem you may run into is if the theme stops being actively maintained. To help mitigate this, I'd recommend using popular themes so that the likelihood of it being maintained is much higher. I found [this website](https://pfht.netlify.app/post/top-starred/) to be a great resource for finding the most commonly used themes.

To alleviate the above issues, make sure to choose your theme wisely from the start. Ideally, something popular, paying special attention to the features you may need when checking theme demos.

### 🍦 Write Posts in Vanilla Markdown (Where Possible)

If you've ever tried to or spoken to someone that has migrated their blog from one platform to another, you'll know how painful of a process that could be. It's likely that Hugo will eventually fall out of favour for whatever reason ([Jekyll](https://jekyllrb.com/) comes to mind), or you'll find that the theme you're using is not sufficient for your use-case anymore. If you stick to writing posts in plain markdown where possible, fewer Hugo or theme-specific styling directives would need to be migrated if you switch theme or static site generator, making your blog much more future-proof.

### 📋 Use Archetypes

[Hugo Archetypes](https://gohugo.io/content-management/archetypes/) can give you a small productivity boost, reducing the friction it takes to write a new post. They're effectively templates that can be invoked by calling `hugo new --kind <your archetype name> <path to your content>`. I use one for new posts that fills in the front matter for me and sets up a dummy cover photo.

I found archetypes to be particularly effective for use in sites that host a variety of content, allowing its maintainers to quickly write up posts for the site.

### 🛠 Automate What You Can

I use [Github Actions](https://github.com/features/actions) with [these Hugo actions](https://github.com/peaceiris/actions-hugo) to deploy my blog from CI. I recommend this as it doesn't take long to set up, and for most personal use-cases the [free GitHub Actions minutes](https://github.com/pricing) would give you enough freedom to not have to worry about any costs.

Before deploying from CI though, I used to build this blog locally and push the built site. A build script came in handy for this. The build script first cleared out temporary Hugo data from `resources/_gen`, cleared the output folder (in case any posts were renamed or removed), and finally built a minified version of the site using `hugo --minify`.

It's also worth updating your themes periodically. There are better ways to do this, but I run a simple pre-push script maintained using [Lefthook](https://github.com/evilmartians/lefthook) that updates the themes in my project:

```bash
git submodule update --recursive --remote
```
