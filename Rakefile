# encoding: utf-8
#--
#     This file is part of the X12Parser library that provides tools to
#     manipulate X12 messages using Ruby native syntax.
#
#     http://x12parser.rubyforge.org 
#     
#     Copyright (C) 2008 APP Design, Inc.
#
#     This library is free software; you can redistribute it and/or
#     modify it under the terms of the GNU Lesser General Public
#     License as published by the Free Software Foundation; either
#     version 2.1 of the License, or (at your option) any later version.
#
#     This library is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#     Lesser General Public License for more details.
#
#     You should have received a copy of the GNU Lesser General Public
#     License along with this library; if not, write to the Free Software
#     Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
#
# $Id: Rakefile 92 2009-05-13 22:12:10Z ikk $
#++

require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'rubygems'
require 'jeweler'
require 'rake/testtask'
require 'rdoc/task'

Jeweler::Tasks.new do |s|
  s.name        = 'X12'
  s.summary     = 'X12 parsing and generation library'
  s.description = 'Library to parse X12 messages and manipulate their loops, segments, fields, composites, and validation tables.'
  s.email       = 'info@appdesign.com'
  s.homepage    = 'https://github.com/eligoenergy/X12'
  s.authors     = ['APP Design, Inc.', 'Eligo Energy']
end
Jeweler::RubygemsDotOrgTasks.new

require File.join(File.dirname(__FILE__), 'lib', 'X12')

desc "Default Task"
task :default => [ :example, :test ]

# Run examples
task :example do |x|
  Dir['example/*.rb'].each {|f|
    puts "Running #{f}"
    sh('ruby', '-I', 'lib', f) do |ok, res|
      fail "Command failed (status = #{res.exitstatus})" unless ok
    end
  }
end

Rake::TestTask.new { |t|
  t.test_files = Dir['test/tc_*.rb']
  t.verbose = true
}

# Generate the RDoc documentation
Rake::RDocTask.new { |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title    = "X12 -- an X12 parsing library"
  rdoc.options << '--line-numbers' << '--inline-source' << '--main' << 'README' 
  rdoc.template = 'misc/rdoc_template.rb'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('CHANGELOG')
  rdoc.rdoc_files.include('TODO')
  rdoc.rdoc_files.include('lib/**/*.rb')
}
