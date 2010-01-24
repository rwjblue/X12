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
require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/packagetask'
require 'rake/gempackagetask'
require 'rake/contrib/rubyforgepublisher'
require 'fileutils'
require 'pp'

require File.join(File.dirname(__FILE__), 'lib', 'X12')

PKG_NAME        = 'X12'
PKG_VERSION     = X12::VERSION
PKG_FILE_NAME   = "#{PKG_NAME}-#{PKG_VERSION}"
PKG_DESTINATION = "../#{PKG_NAME}"

RAKE            = $0
RUBY_DIR        = File.expand_path(File.dirname(RAKE)+'../..')
RUBY            = "#{RUBY_DIR}/bin/ruby.exe"

CLEAN.include(
              '**/*.log',
              'doc/**/*',
              '**/*.tmp',
              'lib/X12/X12syntax.rb'
              )
CLEAN.exclude(
              )


#puts "Files to clobber: #{CLOBBER}"
#puts "Files to clean: #{CLEAN}"

desc "Default Task"
task :default => [ :example, :test ]

# Run examples
task :example do |x|
  Dir['example/*.rb'].each {|f|
    puts "Running #{f}"
    sh(RUBY, '-I', 'lib', f) do |ok, res|
      fail "Command failed (status = #{res.exitstatus})" unless ok
    end
  }
end

# Run examples in scratch dir
task :scratch do |x|
  Dir['scratch/p270.rb'].each {|f|
    puts "Running #{f}"
    sh(RUBY, '-I', 'lib', f) do |ok, res|
      fail "Command failed (status = #{res.exitstatus})" unless ok
    end
  }
end

task :test do |x|
  Rake::TestTask.new { |t|
#    t.libs << "test"
    t.test_files = Dir['test/tc_*.rb']
#    t.test_files = Dir['test/tc_factory_270interchange.rb']
#    t.test_files = Dir['test/tc_parse_270interchange.rb']
    t.verbose = true
  }
end # :test

file 'doc/index.html' => ['misc/rdoc_template.rb' ]
task :rdoc => ['doc/index.html']

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


# Create compressed packages by running 'rake gem'

desc "gem task"
task :gem => [ :clobber, :rdoc ]

# Here's how to look inside the gem package:
# ~..>tar xvf package.gem; gunzip data.tar.gz metadata.gz; tar xvf data.tar; cat metadata
spec = Gem::Specification.new do |s|
  s.platform          = Gem::Platform::RUBY
  s.name              = PKG_NAME
  s.version           = PKG_VERSION
  s.summary           = 'X12 parsing and generation library'
  s.description       = 'Library to parse X12 messages and manipulate their loops, segments, fields, composites, and validation tables.'
  s.author            = 'APP Design, Inc.'
  s.email             = 'info@appdesign.com'
  s.rubyforge_project = PKG_NAME
  s.homepage          = "http://www.appdesign.com"

  s.has_rdoc = true
  s.requirements << 'none'
  s.require_path = 'lib'
  s.autorequire = 'x12'

  [ 
   "Rakefile", 
   "README", 
   "TODO",
   "CHANGELOG",
   "COPYING",
   "doc/**/*",
   "lib/**/*",
   "test/**/*",
   "example/**/*",
   "misc/**/*"
  ].each do |i|
    s.files += Dir.glob(i).delete_if do
      |x| x =~ /.*~/
    end
  end
  puts "Files included into the GEM:" if $VERBOSE
  pp s.files if $VERBOSE

  s.test_files = Dir.glob( "test/tc_*rb" )
end

Rake::GemPackageTask.new(spec) do |p|
  p.gem_spec = spec
  p.need_tar = true
  p.need_zip = true
end
