---
title: "'HashiCorp Certified: Terraform Associate' Course Review"
date: 2021-12-23T10:38:04Z
ShowToc: true
cover:
    image: "img/cover.png"
    alt: "Cover"
tags:
  - terraform
  - course
  - infrastructure
  - devops
---

I've recently been working with Terraform a lot at work. However, I was never taught properly how it works. I jumped straight into the code and figured things out, which wasn't particularly difficult. Nevertheless, I was curious as to what I was missing and how I could set Terraform up myself in a new project. Therefore, I looked at how I could learn Terraform on my own.

After some initial looking around, I found [Zeal Vora's 'HashiCorp Certified: Terraform Associate' course](https://www.reddit.com/r/Terraform/comments/jfzerz/comment/g9nio4h/?utm_source=share&utm_medium=web2x&context=3) on Udemy to be well-regarded. Now, I'm not a fan of courses. I'd much rather get stuck into a project of my own and avoid the hand-holding that most courses offer. In the case of Terraform though, since I didn't have deploying any complicated infrastructure in mind, completing a course seemed like the right approach. The instructor of the course also seemed credible, seeing as he's released many courses on Cloud Engineering topics and works as a Cloud Security Consultant.

In this post, I describe what the course does well and not so well, and aim to answer whether it was worth the time and monetary investment. Note that my intention was not to do the course to get ready for the [Terraform Associate certification](https://www.hashicorp.com/certification/terraform-associate). I wanted a hands-on overview of Terraform, but I'll give an insight into how well I reckon the course could prepare someone for the certification also.

## What the Course Does Well

### Good Course Structure

The course is structured into distinct sections, starting from Terraform basics and building upon them. Towards the end, the instructor delves into more in-depth topics as well. These include Terraform Cloud and various enterprise capabilities, which are needed for the certification. In the end, there is also a handy exam preparation section. I found the structure of the course to be just right.

{{< figure src="img/course-structure.png" alt="Course Structure" align="center" >}}

I also found that you could skip some parts towards the end if you're not preparing for the certification, and not miss any vital information on using Terraform in a professional scenario.

### Provides Supporting Materials

The instructor provides a [GitHub repo](https://github.com/zealvora/terraform-beginner-to-advanced-resource) with code snippets and notes. There are also notes at the end of every section on Udemy. While the repo helps support the content in the course, it's not particularly well structured as each directory in the repo has all resources for that section. The instructor could have taken some care to separate the resources into directories referring to individual lessons.

### Mentions Multiple Cloud Providers

The instructor focuses on working with AWS, but he also touches upon how to use Terraform with other cloud service providers. I found that this makes the course content highly transferable while allowing me to find out about some aspects of AWS that I haven't known about before.

### Multiple Explanations for Concepts Provided

When introducing new topics, the instructor first starts with a textual explanation of the topic, then he sometimes follows with a diagram, and finally shows how it works in practice with a demo. This greatly helps with making sure you understand the topics, especially if one of the methods of explanation wasn't clear. I found that it also could make the course accessible to beginners, as the instructor doesn't assume much existing knowledge.

This is a double-edged sword though. I found many of the concepts very easy to grasp, yet the instructor took a couple of minutes to describe them. In some cases, he may have been a bit too pedantic, for example dedicating entire sections to conditional statements or on how to reference items in lists by index. To save some time, I'd recommend speeding up the playback speed of lessons which include concepts you already know about.

### Mentions Terraform Integrations

The instructor mentions how Terraform can be integrated with other tools, such as [Ansible](https://www.ansible.com/) for configuration management. This kind of pragmatic advice was very welcome, allowing me to place exactly where Terraform would fit in existing DevOps configurations

### Practice Tests Provided

The instructor provides a whole section dedicated to the certification exam. Two practice tests are also provided, which I found valuable to complete to consolidate my knowledge. However, the practice tests lack proper explanations as to what the correct answer is. While this may not work for some people, I found it to be a useful prompt to do my own research.

## What the Course Could Do Better

### Provide Independent Exercises

The course had too much hand-holding for my liking. It would have been beneficial for the instructor to give small tasks to complete independently, and then to provide a model answer along with an explanation. This would have been a much more pragmatic approach to learning Terraform, and it would make more of the content stick for the certification exam.

### Describe Methods of Storing Secrets

In one of the first lessons, the instructor stores secrets in plain text alongside Terraform code and doesn't mention anything about how detrimental such a practice is. Later on, he does describe that in the case of AWS you can instead use the [AWS credentials file](https://docs.aws.amazon.com/sdk-for-php/v3/developer-guide/guide_credentials_profiles.html) and mentions using environment variables in a later lesson. I thought that this was a wasted opportunity to describe alternative approaches, such as using [encrypted files or secret stores](https://blog.gruntwork.io/a-comprehensive-guide-to-managing-secrets-in-your-terraform-code-1d586955ace1#c49b).

### Provide More General Terraform Advice

This could just be me being pedantic, but I found that the course lacked practical advice around many of the described concepts. For example, the instructor dedicates a couple of lessons to Terraform Provisioners. When checking [the documentation](https://www.terraform.io/language/resources/provisioners/syntax) for them though, the first thing that's stated is that they should only be used as a last resort. This is not mentioned anywhere in the lessons. A saving grace is that the instructor throws in some anecdotes from his professional life when backing up how infrastructure-as-code tools should be used in organisations.

As someone who also enjoys looking at clean code that follows consistent conventions, I'd have liked if the instructor mentioned some Terraform [general style guidelines](https://www.terraform.io/language/syntax/style) or [naming best practises](https://www.terraform-best-practices.com/naming) (and ideally to follow a consistent naming regime himself) as well.

## Is the Course Worth It?

Coming in at around 10 hours of video and covering all the main Terraform concepts, I found this course to be very insightful. Sure, it has some slight issues, but for the price, those can be forgiven. Overall, I confidently feel that completing this course has improved my DevOps/software reliability skills.

If you're considering this course to get help to prepare for the Terraform Associate exam, I'd highly recommend it.

If you're considering it as a way to learn Terraform so that you can then use it in your own project, I'd probably recommend working through the [official Terraform tutorials](https://learn.hashicorp.com/terraform). While this course would provide supplementary explanations, a bit too much of it is certification-related to make it a good resource.
