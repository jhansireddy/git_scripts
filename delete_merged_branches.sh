#!/usr/bin/env ruby

require 'open3'
require File.expand_path('./kernel_override', File.dirname(__FILE__)) if ARGV.include?("-v")

branches = `git branch -r`.split("\n")
do_not_delete_branches = ['master', '*release*']
current_branch = branches.detect{|l| l =~ /^\*/}.gsub("\* ", "")
raise "Should not run this when not in master" unless current_branch == 'master'
(branches - ["* master"]).each do |branch|
  system("git checkout #{branch}")
  system("git pull --rebase")
  Open3.popen3("git status") do |i,o,e|
    if o.readlines.include?("nothing to commit (working directory clean)\n")
      system("git checkout master")
      system("git branch -d #{branch}")
    else
      system("git checkout master")
      puts("****** #{branch} could not be deleted due to uncommitted changes")
    end
  end
end
