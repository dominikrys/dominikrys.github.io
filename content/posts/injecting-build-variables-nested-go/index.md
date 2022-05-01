---
title: "Injecting Build-Time Variables to Nested Golang Packages"
date: 2021-11-07T18:32:38Z
ShowToc: true
cover:
    image: "img/cover.png"
    alt: "Cover"
tags:
  - Go
  - Software Development
---

I've recently tried to figure out how to inject variables to a Go executable at build-time. The available guidance online was straightforward, but it all referred to simple Go programs with rudimentary package structures that aren't hosted remotely. None also mentioned working with the [Cobra](https://github.com/spf13/cobra) CLI library, which usually results in multiple levels of nesting in the Go application's package structure.

To address what the other posts don't cover, I thought I'd write this short blog post.

## Simple Example

Let's get the simple example out of the way. Injecting build-time variables to Go programs can be done by specifying the `-X` [linker flag](https://pkg.go.dev/cmd/link):

```bash
go build -ldflags="-X 'package_path.variable_name=value'"
```

Given a simple Go program called `main.go` inside of a repo called `go-app`:

```go
package main

import (
    "fmt"
)

var buildDate string

func main() {
    fmt.Printf("Build date: %s\n", buildDate)
}
```

To inject the buildDate variable, run:

```bash
go build -ldflags="-X 'main.buildDate=$(time)'"
```

The variable value will now be set at build-time.

Note that variables that have their values set at build-time **don't need to be exported**. Also, if you want to set the values of additional variables, simply append additional `-X` flags.

Another thing to keep in mind is that **the name of the Go file has no impact on the path** that needs to be specified in the linker flags, and only the package name matters.

## Nested Packages

Small issues arise if your package structure is more involved, for example, if using [Cobra](https://github.com/spf13/cobra).

Let's take the previous example Go program, but now rename it to `root.go` and place it in a nested directory. The file's path relative to the root of our repo is `foo/bar/cmd/root.go`. The relevant parts of the file now look as follows (note the changed package name):

```go
package cmd

-- snip --

var buildDate string

-- snip --
```

To inject the value of the variable now, we have to fully qualify the package name with its subdirectories. Note that, still, the name of the file that the variable is defined in doesn't matter:

```bash
go build -ldflags="-X 'foo/bar/cmd.buildDate=$(time)'"
```

## Remotely Hosted Repositories

Finally, if you're hosting your repository directly, you will have to fully qualify the path to the variable with the remote repo URL.

Taking our example from the previous part, let's host it under `github.com/dominikrys/go-app` and *not change the directory structure in any way*. To inject the values of our variables, the `go build` command becomes:

```bash
go build -ldflags="-X 'github.com/dominikrys/go-app/foo/bar/cmd.buildDate=$(time)'"
```
