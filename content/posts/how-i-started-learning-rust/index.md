---
title: "How I Started Learning Rust"
date: 2021-06-16T18:56:21+01:00
draft: true
toc: true
images:
tags:
  - software engineering
  - rust
---

I've been wanting to learn Rust for a while. This is partially to see to what extent it solves the memory-safety gripes of C and C++, and partially to see what all the hype is about.

I wanted to write a post talking about how I started learning Rust. This is partially to point anyone wanting to learn Rust to some useful resources, and partially for my own reflection and to document what worked well and what didn't.

Overall, I started learning Rust by first working through the official [**Rust book**](https://doc.rust-lang.org/book/), then working through the [**Rust Exercism exercises**](https://exercism.io/my/tracks/rust), and finally **working on a project**. I will describe each of the mentioned resources in further depth, how I used them, and any pointers which would have helped me when I was starting out. I hope you enjoy the post!

## The Rust Book

When researching a starting point for learning Rust, I found that the [near-unanimous answer](https://www.reddit.com/r/rust/comments/en3wjg/best_way_to_start_learning_rust/) is to read the [Rust Programming Language](https://doc.rust-lang.org/book/) book. Although this book is available in physical and e-book forms, the most common way to read it is to check the linked official website which has the book available as a web page.  

The book contains information which is up-to-date with stable Rust and gets actively updated. It covers the most important concepts of the language, and even includes some projects within it which helps with getting your feet wet.

Overall the book was a great introduction to Rust and is very approachable. It allowed me to get the core concepts of the language down. However, the book covers a lot of information and takes some time to go through if you work through the entirety. Personally I found that I spent too much time reading about the theory in the book, and not enough time using the knowledge or assimilating it in any meaningful manner.

## Exercism

After finishing the book, I started the [Exercism Rust track](https://exercism.io/my/tracks/rust). I've been told about Exercism by a co-worker and have been eager to try out since.

Effectively, Exercism is a site which provides lots of programming puzzles in increasing difficulty, structured into "tracks". Many languages are supported, one of which is Rust. The site provides a testing framework which you set up locally (it's quick and easy) and then use to download exercises and upload solutions to the website.

On Exercism, a track contains "core" and "extra" exercises which you work through in "mentored" or "practice" mode. In mentored mode (which is recommended) you complete the core exercises one by one. Then, a mentor gives  feedback on your answers which allows you to then progress to the next exercise. When you complete a core exercise you also unlock some of the extra exercises, which mentors can also give feedback on (but I found they rarely do). In practice mode everything is unlocked outright, but mentor feedback is disabled.

I found this to be a great transition from the Rust book, as it requires you to know the basics of the language that you are coding in. This was a great starting point for me to do my own research on the language and learn it in a more autonomous manner.
  


  - You can also get inspiration from other people's solutions which massively helped me with learning how to write idiomatic Rust.
  - solutions can be posted for other people to see and comment on. Personally i found that the "rating" feature was somewhat broken as the top-rated solutions are usually the oldest and hence outdated and dont work.
  - I found posting my solutions so be very beneficial as people asked some very good questions and suggested nice improvements to some questions. Easily the best part of the website for me.
  - I've read that mentored mode is supposedly not very good as it may take a while for a mentor to assess your answer. I found this to vary - sometimes i could receive feedback on the same day, and sometimes after a couple of days. The actual mentor feedback also varied depending on the mentor. Usually once I came up with my own solution and then reviewed other people's, the mentors didn't have much feedback to say. The most useful ones were when the mentor benchmarked my code, as that really made me delve deep into the performance of my code and what rust was doing under the hood.
  - some extra exercises are good, but some are pretty poor quality.
  - rust by erxample helped herE: https://doc.rust-lang.org/rust-by-example/

- project
  - i checked out the build-your-own-x repo for tutorials which use Rust. . It has become somewhat of a one-stop shop for when i want to learn something.
  - I wrote a DNS server in Rust using this guy's tutorial.
  - Used some of my experience from the book and exercism to make it more modern and tidy the code.
  - really helped with how to structure rust projects which is not what i could get from exercism

- still lots more to learn, rust is a very interesting and complex language. This was a great start and I'm hoping to learn more by doing other projects

- add screenshots of each method
