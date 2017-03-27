
<!-- README.md is generated from README.Rmd. Please edit that file -->
moodler
=======

[![Travis-CI Build Status](https://travis-ci.org/jchrom/moodler.svg?branch=master)](https://travis-ci.org/jchrom/moodler)

The purpose of moodler is to easily get data from Moodle database and format it for further analysis.

Installation
------------

You can install moodler from github with:

``` r
# install.packages("devtools")
devtools::install_github("jchrom/moodler")
```

Example
-------

``` r
# Create a database connection
con = DBI::dbConnect(RMySQL::MySQL())

# Get a course list
courses = get_courses(con)

# Get specific modules
modules = get_course_modules(con, course.id = 2, module.type = c("quiz", "forum"))
```
