---
title: "Live Reload Browserify + TypeScript in Node.js"
date: 2022-01-17T20:39:17Z
ShowToc: true
cover:
  image: "img/cover.png"
  alt: "Cover"
tags:
  - Node.js
  - TypeScript
  - Software Development
---

I've recently been working on a Node.js project in TypeScript and bundling its dependencies using [Browserify](https://browserify.org/). To increase the speed of iteration, I wanted to automatically reload the tab with my web app whenever I made code changes, which would entail recompiling the TypeScript code into JavaScript. However, I couldn't find a good guide on how to achieve this online. In the end, I managed to figure it out by bolting some tools together - with no JavaScript task runner such as [Gulp](https://gulpjs.com/) or [Grunt](https://gruntjs.com/) needed!

## Alternative Solutions (That Don't Quite Work)

There is [an existing StackOverflow question](https://stackoverflow.com/questions/29388004/livereload-with-npm-and-browserify) on this topic with no working answer. [livereactload](https://github.com/milankinen/livereactload) has been suggested if you're using React, but I couldn't get this to work (probably because I'm not using React). [An article from DigitalOcean about using Browserify](https://www.digitalocean.com/community/tutorials/getting-started-with-browserify#toc-live-rebuild) is also linked in the SO thread, which includes a section on live rebuild. It mentions two tools: [watchify](https://github.com/browserify/watchify) and [beefy](http://didact.us/beefy/). Watchify works well, it just doesn't automatically reload the page with the web app when changes are made. Beefy doesn't work with TypeScript, so it wasn't appropriate for my use case.

Other solutions I found included [browserify-livereload](https://github.com/jacobtipp/browserify-livereload), which doesn't work and whose GitHub repo has been archived, and [nodemon](https://github.com/remy/nodemon), which only monitors for file changes and would rely on other tools to rebuild my TypeScript code.

## The Solution

In the end, the solution I found is fairly simple - run watchify recompile your browserify bundle when changes are made, and use [browser-sync](https://browsersync.io/) to serve and live-reload your website after detecting the changes. These can be parallelised, which I explain at the end.

### Set Up watchify

Install watchify as a dev dependency:

- npm: `npm install --save-dev watchify`

- yarn: `yarn add -D watchify`

Then, add a new script to your `package.json`:

```json
{
  "scripts": {
    "watch": "watchify <.ts or .js file to monitor> -p tsify -o <.js file to output> --verbose --debug"
  }
}
```

- Make sure to fill in the paths to your `.ts` file to monitor and where the output `.js` file should be placed relative to the root of your Node package.

- Note that the `-p tsify` part is only needed if your code is in TypeScript. I'm assuming that if you're using TypeScript, you've already set up browserify with tsify.

- The `--verbose` flag logs to the console when file changes are detected. It can be omitted if you like.

- The `--debug` flag enables source maps so that the code can be debugged. This shouldn't be used in production, so make sure to have another script that bundles your code for production using `browserify` (which is also ideally minified using something like [UglifyJS](https://github.com/mishoo/UglifyJS)).

### Set Up browser-sync

Install browser-sync as a dev dependency:

- npm: `npm install --save-dev browser-sync`

- yarn: `yarn add -D browser-sync`

Then, add a new script to your `package.json`:

```json
{
  "scripts": {
    "serve": "yarn browser-sync <directory to host> --watch"
  }
}
```

### Parallelise watchify and browser-sync

Both watchify and browser-sync need to run concurrently for this solution to work. They could be run in the background in one terminal instance using the `&` bash command, but that may be cumbersome if you leave it running and don't realise. They could also be run in separate terminal instances/processes, but there is a neater way - run both in parallel with a single command using [npm-run-all](https://github.com/mysticatea/npm-run-all).

> **NOTE**: despite the package having `npm` in the name, it works the same when using `yarn`.

To get started, install npm-run-all as a dev dependency:

- npm: `npm install --save-dev npm-run-all`

- yarn: `yarn add -D npm-run-all`

Then, add a new script to your `package.json` that runs the previously added `watch` and `serve` scripts in parallel:

```json
{
  "scripts": {
    "start": "npm-run-all --parallel watch serve"
  }
}
```

Finally, run `npm run start` or `yarn start` and you're done! Any changes you make to your source code will be automatically recompiled, and the page with your web app with automatically reload.
