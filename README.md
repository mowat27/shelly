# shelly

Extensible framework for cli utilities using the `command subcommand [args...]` pattern.  

Inspired by git.

:construction: Just an idea the moment.  The docs below describe what I want.

## Rationale

Often teams need a shared scripting interface that allows them to easily share utilities and commands for other team and/or users.  For example the AWS cli includes subcommands for each of its services; `aws ec2 [args...]` for working with ec2 service and `aws s3 [args...]` for working with s3 buckets and objects.

This pattern allows the teams than run the services to provide their own cli behind a common interface.

The Git command line works in a similar way, `git commit [args...]`, `git rebase [args...]` and so on.  Git allows you to write your own subcommands by creating a new script prefixed by `git-` on your PATH.  This allows [contributors](https://gitirc.eu/howto/new-command.html) and users ([example](https://blog.sebastian-daschner.com/entries/custom-git-subcommands)) to easily extend the `git` cli like this.

```sh
$ echo 'echo Hello, World' > git-hello
$ chmod +x git-hello
$ PATH=$PWD:$PATH
$ git hello
Hello, World
```

Shelly provides a toolbox for creating new top level commands that use this pattern and subcommands that use it.  

:warning: TBC: It is designed to leverage common tools such as `git`, `homebrew` and POSIX shell scripts for maximum portability.

### Worked Example 

ACME corp have a web development department using Ruby on Rails and a data science team working in Python.  The developers in both departments have noticed that it would be useful to share command line utilities.

One way to do this would be to create a git repository called `acme-cli` that everyone commits to but this introduces a number of problems.

* **Conflicts:** Everyone needs to agree on which programming language to use
* **Bloat:** All sorts of code and dependencies will get mixed up in the same ever-growing repo
* **Churn:** Everyone needs to pull everyone else's changes
* **Inflexibility:** It's hard to experiment 
* **Bureaucracy:** Eventually, change control will be needed to bring some sort of order to the chaos 

On the other hand, each team can create separate cli repos that they manage themselves - eg `web-deployment-cli`, `data-science-reporting-cli` - but this has a different set of problems.

* **Inconsitency:** each cli will have its own conventions so it's hard for people to use other people's tools 
* **Fragmentation:** the number of clis in the company can become unmanageable
* **Duplication:** the code needed to handle argments and launch commands will be duplicated but changed in subtle and unusual ways

Shelly provides a half-way house that provides consistency without being restrictive.

#### Creating the CLI

A developer creates a new cli called `acme` using the `create-cli` command.

`shelly create-cli acme`

This creates `acme-cli` which consists of a lightweight command launcher and a self-installer script that will not change.  It is standalone code and it does not depend on `shelly`.

She creates a new repository in Github and pushes the code.

```
$ git add remote origin https://github.com/acme/acme-cli
$ git push -u origin master
```

Users can then run the `acme` installer directly from the internet

`bash <(curl -s https://raw.githubusercontent.com/acme/acme-cli/blob/master/bin/install.sh)`

This command which installs `acme` in `/usr/local/shelly/acme` and symlinks it into `/usr/local/bin` so it is available across the system.  

On its own `acme` doesn't do much except look for sub commands.

```sh 
$ acme web deploy 
Not recognised: `web`

$ acme ds stats 
Not recognised: `ds`
```
#### Adding Subcommands 

A web developer then comes along and starts building the `web` subcommand in ruby.  He creates a new project by running `shelly create-subcommand acme web` which creates `acme-web-cli/` and he commits it to Github as usual.

The subcommand project contains a script `bin/acme-web` which the `acme` command will recognise.  Shelly is not opinionated about how this script should be written, just that it follows the naming convention `<command>-<subcommand>`.  

The developer would put it on his PATH manually for development purposes.

```sh 
$ cd acme-web-cli  
$ export PATH=$PWD/bin:$PATH 
# start developing
```

A sensible pattern for a ruby project would be to create a `main.rb` file in `bin/` and then call it from `acme-web`

```sh 
#!/bin/sh 
ruby "$(dirname $0)"/main.rb
```

A library like [Thor](http://whatisthor.com/) might be a good choice for implementing the `web` subcommand in ruby.  

Once he has finished making his cli and pushed it to github other developers can install it directly from Github by running `acme install-subcommand https://github.com/acme/acme-web-cli`.

Now the `web` subcommand is available to 

#### Shelly Within Shelly

Over on the data science team, they don't want all their cli commands in one big repo.  Instead they can use `shelly` to create a new `shelly` command that is available as a subcommand to `acme`.

```sh 
shelly create-subcommand acme ds --using-shelly
```

:warning: subcommands cannot include hyphens (`-`)

A normal shelly project will be created and it will be called `acme-ds-cli`.  It can be distributed using git and installed in exactly the same way as a normal subcommand.

```sh 
acme install-subcommand https://github.com/acme/acme-ds-cli
```

The data science team could continue in this vein as long as they like but things like this could get a bit silly after a while.

```
shelly create subcommand acme ds reporting utils --using-shelly
# creates acme-ds-reporting-utils-cli 
acme subcommand install https://github.com/acme/acme-ds-reporting-utils-cli
```

:thinking: It might be more intuitive to install an L2 subcommand inside the L1 subcommand like this...

```sh
acme ds reporting subcommand install https://github.com/acme/acme-ds-reporting-utils-cli
```

... but it could be confusing if some subcommands are shelly launchers and others are not.


## Installation

### Manually 

Directly from the internet

```sh
bash <$(curl -s https://raw.githubusercontent.com/mowat27/shelly/master/bin/bootstrap.sh)
```

### Homebrew 

`brew install shelly`

### Using Git 

`git clone https://github.com/mowat27/shelly.git`

And then add `shelly/bin/` to your PATH.

## Usage 

### Help 

To get help with Shelly run `man shelly` or `shelly help`.

Subcommands should have help pages available.  Help pages are accessed from the main command.

`acme help ds`

:thinking: help should be distributed using the UNIX manpage spec and available as `man acme` and `man acme-ds` etc

If the subcommand does not have a help page then the main command will display a default message.

:thinking: `shelly install-subcommand` could compile `.asciidoc` files but markdown is more prevalent these days so maybe it would be better to use that instead

:thinking: according to [this blog](https://eddieantonio.ca/blog/2015/12/18/authoring-manpages-in-markdown-with-pandoc/) from the internets, [pandoc](https://pandoc.org/installing.html) seems like a good option for compiling man pages because it supports a lot of input and output formats
