## Script to prepare new rails application

I always want to use git for version control, rspec and cucumber for testing
and simplecov for coverage reports.  Therefore, every time I create a new rails
application, I always need to immediately modify my Gemfile, modify my .gitignore
file, run bundle install and edit files to use simplecov.  I also use rvm
(ruby version manager) and I often create a new gemset for use with the
new rails application.

Therefore, I have written this script which does all of those things.

This script will

* create a new rvm gemset for use with this application
* create a new rails app,
* create a new git local repository,
* substitute a new Gemfile and .gitignore file from 'master' copies,
* run bundle install,
* run rspec:install,
* run cucumber:install and
* create .simplecov from master copy,
* create and modify files for the gem 'simplecov'

### YOU WILL NEED TO MODIFY THE FILE PATHS for your own use! Specifically, find these lines:

### ***-------------------------   MODIFY THESE PATHS  -------------------------------***
@path_to_project_parent = "/Users/rab/rails_projects/"  # DON'T FORGET TRAILING SLASH!!

@master_file_dir_name = "master_files"  # DON'T ADD TRAILING SLASH!!

and to reflect your paths.

###Important Note:
The .gitignore and .simplecov are hidden files (because of the leading ".").
But my master copies in the 'master_files' subdirectory are not hidden.  The script assumes
this to be the case.  Therefore the script copies the file 'master_files/gitignore' to
'app_name/.gitignore'.  The same is true for the file .simplecov.

###Also,
this script calls a bash script ('create_gemset') for the purpose of creating the
rvm gemset.  If you do not wish to create a gemset then comment out the following lines:

    puts "creating gemset for use with new rails app ..."
    `./create_gemset #{app_name}`

## Usage:
ruby rails_prep.rb app_name

For example, to create a new rails app named 'blog':

    ruby rails_prep.rb blog

This script assumes that you are using (and your Gemfile includes) rspec,
cucumber, cucumber_rails_training_wheels & simplecov.  It also assumes that
it is being run from the rails app parent directory and that the
'create_gemset' bash script file is in the same directory.