#!/usr/bin/env ruby
# =========================================================================
# This script will create a new rails app, a new git local repository, 
# substitute a new Gemfile and .gitignore file from 'master' copies, 
# run bundle install, run rspec:install and cucumber:install and 
# create and modify files for the gem 'simplecov'
#
# ** YOU WILL NEED TO MODIFY THE FILE PATHS for your own use! **
#
# usage: ruby rails_prep.rb app_name
#   for example, to create a new rails app named 'blog':
#   ruby rails_prep.rb blog
#
# This script assumes that you are using (and your Gemfile includes) rspec, 
# cucumber & simplecov.  It also assumes that it is being run from the 
# rails app parent directory and that 'create_gemset' is in same directory.
# =========================================================================
#todo restore ssh key from backup; then push to github
#
require 'fileutils'

# ***-------------------------   MODIFY THESE PATHS  -------------------------------***
@path_to_project_parent = "/Users/rab/rails_projects/"  # DON'T FORGET TRAILING SLASH!!
@master_file_dir_name = "master_files"  # DON'T ADD TRAILING SLASH!!
# ***===============================================================================***

@path_to_master = "#{@path_to_project_parent}#{@master_file_dir_name}/"

# -------------
# -- Methods --
# -------------
def modify_files(fn)
  # this method adds the 'require simplecov'
  # instruction to the file whose name is
  # passed as an argument
  puts "accessing #{fn} ..."
  f = File.open(fn, "r")
  f = f.readlines
  File.open(fn, "w") do |x|
    s = "require 'simplecov'\n\n"
    s = [s]
    contents = s.concat(f)
    x.puts contents
  end
end
# --------------------------
def check_assumptions
  # check to make sure master files exist 
  # and also that rails gem is installed
  err_msgs = []
  #path_to_master = "master_files/"
  File.exist?(@path_to_master+"Gemfile") ? "OK" : err_msgs << "Master Gemfile file does not exist."
  File.exist?(@path_to_master+"gitignore") ? "OK" : err_msgs << "Master gitignore file does not exist."
  File.exist?(@path_to_master+"simplecov") ? "OK" : err_msgs << "Master simplecov file does not exist."
  result = `gem list rails`
  result.include?("rails") ? "OK" : err_msgs << "Rails gem is not installed."
  return err_msgs
end
# **************************
# *** Begin Main Routine ***
# **************************
if ARGV[0].nil?  # -- was the name of the app passed on the command line?
  puts "*****************************************"
  puts "***       Forgetting something?       ***"
  puts "*** Please provide the rails app name ***"
  puts "*****************************************"
  print "> "
  app_name = gets
else
  app_name = ARGV[0]  
end

@path_to_app = @path_to_project_parent+app_name

err_msgs = check_assumptions
if err_msgs.length == 0
  puts "checks OK ..."
else
  puts "CHECKS FAILED".center(25, "*")
  puts err_msgs
  puts "Please correct the errors.  Nothing done.  Exiting ..."
  exit
end

# ----------------------------------------------------------------
# -- create gemset for use with new rails application           --
#  (I use a bash script here because I could not figure out     --
#  how to create and use rvm gemsets from within a ruby script) --
# ----------------------------------------------------------------
puts "creating gemset for use with new rails app ..."
`./create_gemset #{app_name}`

# -----------------------------
# create new rails application
# -----------------------------
puts "create new rails application '#{app_name}' (please be patient)..."
result = `rails new #{app_name} -T`

# change to the newly created rails app directory
FileUtils.cd(app_name)

# --------------------------------
# configure new rails application
# --------------------------------

# setup for git
puts "copy master .gitignore file ..."
file_name = "#{@path_to_master}gitignore"
`cp #{file_name} .gitignore`

puts "creating git repository ..."
`git init`
puts "configure git for color output ..."
`git config color.ui true`

# replace default Gemfile with my master & install gems
puts "copy master Gemfile ..."
file_name = "#{@path_to_master}Gemfile"
`cp #{file_name} Gemfile`

# install gems from master Gemfile
puts "install gems (please be patient)..."
`bundle install`

# setup app for testing with rspec, cucumber and simplecov
puts "setup rspec folders ..."
`rails generate rspec:install`

puts "setup cucumber folders ..."
`rails generate cucumber:install`

puts "set up development and test databases ..."
`rake db:migrate`
`rake db:test:prepare`

puts "install 'training wheels' files (web_steps.rb, etc.)"
`rails generate cucumber_rails_training_wheels:install`

puts "copy master .simplecov file ..."
`cp "#{@path_to_master}simplecov" .simplecov`

puts "modifying test framework files to use simplecov ..."
puts "modifying env.rb ..."
modify_files("#{@path_to_app}/features/support/env.rb")

puts "modifying spec_helper.rb"
modify_files("#{@path_to_app}/spec/spec_helper.rb")

puts "** Done! **"
