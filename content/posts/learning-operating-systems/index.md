---
title: "Short Guide on Self-Teaching About Operating Systems"
date: 2021-08-03T16:07:52+01:00
cover:
    image: "img/cover.jpg"
tags:
  - software engineering
  - operating systems
---

I've recently graduated with a Computer Science degree from the University of Birmingham. Overall, the course covered most of the fundamentals of computer science. However, the course structure changed starting from the year below me, moving the operating systems module from the third to the second year. Since I took a year out for a year in industry, this meant that **I completely missed out on the operating systems module**!

I've always been quite interested in operating systems and felt that knowledge about them is key in computer science. Therefore, I decided to self-teach myself about them.

In this short post, I will cover what online resources I found to be particularly useful in  teaching myself about OSes. I’ll mention resources ranging from ones that can be gone through in a couple of hours to acquire some surface-level knowledge, to those that will take a bit longer but prepare you to write the next Unix successor.

## Where to Start?

As a pre-requisite to learning about operating systems, **I'd recommend having some familiarity with C and assembly language**. Both are prevalent in many operating systems and will greatly help you in exercises and following different texts.

There are three resources that I found to be the most useful from online recommendations. They're also all free. I've ordered them from the most comprehensive, to the least:

1. [Operating Systems: Three Easy Pieces (OSTEP) book](http://ostep.org)

2. [Xv6 book and course](https://pdos.csail.mit.edu/6.828/2020/xv6.html)

3. [Operating Systems Notes from the University of Wisconsin-Madison](http://pages.cs.wisc.edu/~bart/537/lecturenotes/titlepage.html)

Each one has its pros and cons, so I’ll describe what they cover and what I thought about them below.

### OSTEP Book

This is considered to be the most comprehensive resource on learning operating systems by many. The book is split into three main concepts: **virtualization**, **concurrency**, and **persistence**. Each concept is then further split into relevant chapters. The book also contains small projects and assignments so you can put each concept you learn about into practice.

The book is rather long and can be quite daunting, however. If you're looking for a more concise way of learning about operating systems, I'd recommend the xv6 book. I found OSTEP to be useful to refer to when some concepts weren't clear in other resources.

### Xv6 Book

This is the resource I mostly used. It's much more concise than OSTEP and still manages to cover most of the topics around operating systems well. I also found that it kept a better balance between theory and practical exercises compared to OSTEP, letting me put what I learned into practice earlier.

The book explains a rudimentary Unix-like operating system made just for the course, called **xv6**. Each concept starts with a general explanation, then a walk-through of the xv6 code, and finally some information on how other real-world operating systems handle this concept. There are also exercises at the end of some chapters so you can consolidate your knowledge. For anyone wanting even more practice, self-grading labs are provided.

Xv6 was initially written for the x86 architecture. The current version has been re-written for RISC-V. Still, the old course can be useful to look into - for example, I found it insightful to compare how the bootloader differs between RISC-V and x86. You can access the old course [here](https://pdos.csail.mit.edu/6.828/2012/xv6.html).

### OS Notes from the University of Wisconsin-Madison

This is a set of notes on an OS course split into topics. The notes are concise and are accompanied by lots of useful diagrams. I found these notes to be a great compliment to the xv6 book where the diagrams are rather scarce. The notes also include some information on Windows, which the xv6 book lacked. For further reading, the notes reference other books as well as OSTEP.

In the end, these notes are still just notes though. Compared to the other resources they are much easier to refer back to, but they don't flow particularly well when it comes to learning about different concepts. Since these notes also don't include practical exercises, I'd recommend referring to other resources if you're just starting to learn about OSes.

## Additional Resources

The mixture of the resources above should give you a solid understanding of operating systems. There are two other valuable resources that I also found though.

To put your understanding to the test, writing an operating system could be a good idea. Good resources for this are the [**OSDev Wiki**](http://osdev.org/) and the accompanying [OSDev subreddit](https://www.reddit.com/r/osdev/).

A book that is often used in undergraduate OS courses is **Operating System Concepts** by Silberschatz, Galvin, and Gagne. Some notes for it can be found [here](https://www.os-book.com/OS9/slide-dir/index.html). I've not personally looked into this book as I found OSTEP to be more accessible, but it's regarded as a useful resource.
