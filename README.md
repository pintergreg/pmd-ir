[![LICENSE](https://img.shields.io/badge/license-MIT-blue.svg)](./LICENSE)


# PMD Interactive Report

PMD IR is a Sinatra based webservice, that clones a given git repo and runs a static code analyzing for *Java<sup>[1](#myfootnote1)</sup>* with PMD and present the report in an interactive way via a web browser.

This stuff might almost seem pretty awesome for the first glance, but actually the used libraries and tools, that made it possible to create PMD IR are awesome. In order of usage:

* [PMD](https://pmd.github.io/) 
	* for the Java static code analyzing
* [Ruby](https://www.ruby-lang.org/en/)
	* my favorite programming language 
* [Sinatra](http://www.sinatrarb.com/)
	* for making it possible to build up the webapp without pain
* [Haml](http://haml.info/)
	* for writing the HTML layout without writing HTML tags
	* and the [Haml gem](https://rubygems.org/gems/haml) for Ruby, of course
* [jQuery](https://jquery.com/)
	* for making the usage of JavaScript less painful
* [jQuery table sorter](https://mottie.github.io/tablesorter/docs/index.html)
	* for making possible the sorting of HTML tables with the less possible effort
	* official or unofficial fork, it is the best!
* [Prism](http://prismjs.com/index.html)
	* for the source viewer, syntax highlighting, line numbering and marking
	* simply awesome
* [vex](https://github.com/hubspot/vex)
	* for the bottom-right tooltips used in the source viewer
* [git gem for Ruby](https://github.com/schacon/ruby-git)
	* for using git from Ruby
* And last, but not least, the [Solarized color palette](http://ethanschoonover.com/solarized)
	* for sparing my eyes

## Requirements

* Ruby
* Gems for Ruby:
	* [Sinatra](https://rubygems.org/gems/sinatra)
	* [Haml](https://rubygems.org/gems/haml)
	* [git](https://rubygems.org/gems/git)
* PMD installed with `pmd` command in the `$PATH`
	* for ArchLinux it is in the [AUR](https://aur.archlinux.org/packages/pmd/) so just: `yaourt -S pmd`

PMD IR is developed on (Arch)Linux, but should be working on any unix-like OS that matched the requirements.

## Configuration

Some configuration is available via the `config.yml` file.

```
---
workingDir: WORKING DIRECTORY E.G. /tmp/pmdir
git:
  repository: A GIT REPOSITORY, E.G. FROM GITHUB
  branch: BRANCH NAME
  sourceDir: THE DIRECTORY WHERE THE SOURCE IS LOCATED INSIDE THE BRANCH E.G. src
pmd:
  rules:
    - Basic
    - Code Size
    - Design
    - Import Statements
    - Unnecessary
    - Unused Code
    - ... AND SO ON
```

Rule names has to be the exact names listed on https://pmd.github.io/pmd-5.3.3/pmd-java/rules/index.html

## TODO

* **ERROR HANDLING**
* write systemd scripts for daemonizing
* add some statistical info about the repository
	* summarize problems (weighted by priority) by classes

## Footnotes
<a name="myfootnote1">1</a>: PMD has rule sets for other languages as well, but it is absolutely not planned to make it configurable at the moment.