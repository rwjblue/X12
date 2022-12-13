# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "x12"
  s.version = "1.2.0.doxo"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jim Kane"]
  s.date = "2011-10-10"
  s.description = "EDI X12 parsing for ruby"
  s.email = "jkane@acumenholdings.com"
  s.extra_rdoc_files = [
    "README",
    "TODO"
  ]
  s.files = [
    "CHANGELOG",
    "COPYING",
    "README",
    "Rakefile",
    "TODO",
    "VERSION",
    "lib/x12.rb",
    "lib/x12/base.rb",
    "lib/x12/composite.rb",
    "lib/x12/empty.rb",
    "lib/x12/field.rb",
    "lib/x12/loop.rb",
    "lib/x12/parser.rb",
    "lib/x12/segment.rb",
    "lib/x12/table.rb",
    "lib/x12/xml_definitions.rb",
    "test/tc_factory_270.rb",
    "test/tc_factory_270interchange.rb",
    "test/tc_factory_997.rb",
    "test/tc_parse_270.rb",
    "test/tc_parse_270interchange.rb",
    "test/tc_parse_997.rb"
  ]
  s.homepage = "http://github.com/acumenbrands/X12"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.11"
  s.summary = "EDI X12 parsing for ruby"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

