---
title: "Tips for Developing a Static Site Using Hugo"
date: 2022-01-08T14:28:18Z
ShowToc: true
cover:
    image: "img/cover.png"
    alt: "Cover"
tags:
  - hugo
---



- intro: been asked how this blog is written and maintained. I use hugo (explain what that is) thought I'd collate my findings over a couple of over a year of working with hugo. also useful for non-blog use cases, and I've used hugo personally in orgs that used hugo for internal and external doc sites and wikis. i'll mention practical advice on working with hugo
- 💻 set up your environment to work with hugo well
  - I use VSCode. Extensions I'd recommend are code spell checker, markdownlint, grammarly. Hemingway editor is also useful at the end. grammarlyt website is also decent at the end.
  - best to check what you're doing using e..g. `hugo serve -D`
- 🧠 choose your theme wisely
  - personally, I want this to be primarily a blog. The content is what matters most. I dont want to spend effort tweaking the theme. Hence, make sure to find a theme that has all you need right away. Hard to tell this at the start, so it's best to start on some theme, and stick to some vanilla markdown for the first couple of months to really tell what you need. E.g. one theme (hello friend ng) that i was using didnt have content on the front page. this is something that didnt bother me for a bit as i didnt blog much, but eventually became something i wanted. also, the maintainer stopped being particularlt active. had to find another theme
  - it's best to find a popular theme which is actively maintained. That way - it will receive updates that you personally don't have to maintain, you can suggest changes (and it's likely they will be reviewed or updated). If theme is not going to be maintained by the orignal maintainer, if it has lots of users, the odds are higher with popular themes that somene will fork it and start actively maintaining themes. This is a solid list of most popular themes: https://pfht.netlify.app/post/top-starred/
  - has the pro of having other people effectively maintain the theme for you - you can just focus on writing posts
  - why choose wisely? moving themes is a major pain. The more non-markdowny theme-specific stuff to use, the harder it is to migrate as a theme you're moving to may do something differently (or not support it at all). Which leads me to the next tip
- 🍦 use plain markdown when you can
  - easier to eventually migrate, hugo might fall our of favour (just like jekyll). luckily markdown is fairly prevalent now, so can easily future proof your blog this way
- 📋 use archetypes
    - i have one for a page bundle symlinked to a normal post. Creating posts is simple now, as i can just call hugo new and all the changes i need to make are in one file. Before, I called hugo new and had to rummage through old posts for the flags and commands I wanted
    - helps with website organisation, makes writing post faster, especially if e.g. this for an internal doc site. nice to have a template instead of getting an exiting post and making it work
- 🛠 write a simple build script
  - hugo generates a load of temp stuff. if deploying from CI not an issue, if locally, it's worht having a step that clears your entire output folder and resources/_gen before generating the site. hugo is fast so thius works, but maybe this is not feasible for larger projects (which would likely run on ci. This is also useful if you move or rename your files
  - update or notify if the theme you're using has updated - otherwise you just won't know (insert snippet)
- grammarly
