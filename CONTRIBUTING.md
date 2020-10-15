# Contributing to docker_development

Please inform the maintainer as early as possible about your planned
feature developments, extensions, or bugfixes that you are working on.
An easy way is to open an issue or a pull request in which you explain
what you are trying to do and tag it Work in Progress.

## Pull Requests

The preferred way to contribute is to fork the
[main repository](http://github.com/dfki-ric/docker_development) on GitHub, then submit a "pull request"
(PR):

1. [Create an account](https://github.com/signup/free) on
   GitHub if you do not already have one.

2. Fork the [project repository](<github url>):
   click on the 'Fork' button near the top of the page. This creates a copy of
   the code under your account on the GitHub server.

3. Clone this copy to your local disk:

        $ git clone git@github.com:dfki-ric/docker_development.git

4. Create a branch to hold your changes:

        $ git checkout -b my-feature

    and start making changes. Never work in the ``master`` branch!

5. Work on this copy, on your computer, using Git to do the version
   control. When you're done editing, do::

        $ git add modified_files
        $ git commit

    to record your changes in Git, then push them to GitHub with::

       $ git push -u origin my-feature

Finally, go to the web page of your fork of the repo,
and click 'Pull request' to send your changes to the maintainers for review.

## Merge Policy

Usually it is not possible to push directly to the master branch for anyone.
Only tiny changes, urgent bugfixes, and maintenance commits can
be pushed directly to the master branch by the maintainer without a review.
"Tiny" means backwards compatibility is mandatory and all tests must succeed.
No new feature must be added.

Developers have to submit pull requests. Those will be reviewed by at least
one other developer and merged by the maintainer. New features must be
documented and tested. Breaking changes must be discussed and announced
in advance with deprecation warnings.
