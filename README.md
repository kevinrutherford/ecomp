ecomp
=====

This is a placeholder readme file aiming to provide a quick starting point to anyone getting their hands dirty with ecomp.

The readme tries to assume no knowledge of using a Ruby project (gems & bundler etc.) and is likely to be incorrect!

Requirements
------------
To run the ecomp tools, Ruby 2.1.2 must be available along with RubyGems and Bundler. 
Java analysis requires a JVM.
JavaScript analysis requires nodejs.
Ruby analysis requires no other tools. 

Quickstart
----------
Ensure you have Ruby 2.1.2 installed and RubyGems and Bundler, then in the directory you checked ecomp out to, run:

```
bundle
```

This will download and install the required gems that the tool requires to run.

In the directory you checked out ecomp to, run:

```
export PATH=$PATH:`pwd`/bin
```

You should now be able to execute the 'metrics' tool. 

Usage
=====
The metrics tool requires two arguments, a report output directory (where JSON files will be created) and a file glob string (e.g. **/*.java). 

Examples
========
The following examples try to highlight typical usage of ecomp.

Using run_ecomp.sh
------------------

Ensuring that `run_ecomp.sh` is available in your PATH, complexity of a project can be calculated by issueing the following command:

```
run_ecomp.sh SVN_REPOSITORY PROJECT_NAME '**/*.SOURCE_EXTENSION'
```
A concrete example could be:

```
run_ecomp.sh http://myrepo.org/myjavaproject/trunk myjavaproject '**/*.java'
```

The `run_ecomp.sh` script will then use git svn to clone the repository to the `myjavaproject`, correcting the author names as it does so and will then use the `metrics` tool to start analysing the source of the project.

Once the complexity calculation is complete, the JSON files will then be made available to the `public/data/myjavaproject` directory, allowing for visualisation of the data to be accessible at `http://a.sinatra.host:9292/#myjavaproject`.

NOTE: The process is time consuming and involves going through all the previous commits to calculate a play-by-play dataset of complexity changes to each of the source files.

TODO
====
Documenting how to render the datasets so that the data may be visualised. 
