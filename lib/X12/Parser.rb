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
#++
#

require "rexml/document"
include REXML 

require 'pp'

module X12

  # $Id: Parser.rb 89 2009-05-13 19:36:20Z ikk $
  #
  # Main class for creating X12 parsers and factories.

  class Parser
    # These constitute prohibited file names under Microsoft
    MS_DEVICES = [   
                  'CON',
                  'PRN',
                  'AUX',
                  'CLOCK$',
                  'NUL',
                  'COM1',
                  'LPT1',
                  'LPT2',
                  'LPT3',
                  'COM2',
                  'COM3',
                  'COM4',
                 ]

    # Creates a parser out of a definition
    def initialize(file_name)
      #puts "Reading definition from #{file_name}"
      file_name = cleanup_file_name(file_name)

      # Read and parse the definition
      @local_cache = X12::XMLDefinitions.new(File.open(file_name, 'r').read)

      # Populate fields in all segments found in all the loops
      @local_cache[X12::Loop].each_pair{ |k, v|
        #puts "Populating definitions for loop #{k}"
        resolve_dependencies(v)
      } if @local_cache[X12::Loop]
    end # initialize

    # Parse a loop of a given name out of a string. Throws an exception if the loop name is not defined.
    def parse(loop_name, str)
      loop = @local_cache[X12::Loop][loop_name]
      #puts "Loops to parse #{@local_cache[X12::Loop].keys}"
      throw Exception.new("Cannot find a definition for #{loop_name}") unless loop
      loop = loop.dup
      loop.parse(str)
      return loop
    end # parse

    # Make an empty loop to be filled out with information
    def factory(name, klass = X12::Loop)
      definition = @local_cache[klass][name]
      throw Exception.new("Cannot find a definition for #{name}") if definition.nil?
      return definition.dup
    end # factory

    def self.get_file(file_name)
      @@cache ||= {}
      @@cache[file_name] ||= new(file_name)
      @@cache[file_name]
    end

    private

    def cleanup_file_name(file_name)
      # Deal with Microsoft devices
      base_name = File.basename(file_name, '.xml')
      if MS_DEVICES.include?(base_name) then
        file_name = File.join(File.dirname, "#{base_name}_.xml")
      end

      # If just the file name is given and it is not actually present, fall back to the library files
      if File.dirname(file_name) == '.' && !File.readable?(file_name) then
        file_name = File.join(File.dirname(__FILE__), '..', '..', 'misc', File.basename(file_name))
      end

      file_name
    end

    def get_definition(klass, name)
      definition = @local_cache[klass] && @local_cache[klass][name]

      if definition.nil? then # If not found, attempt to load from the library file
        definition = X12::Parser.get_file(name + '.xml').factory(name, klass)
        throw Exception.new("Cannot find a definition for #{name}") if definition.nil?
      end

      definition
    end

    # Populate the nodes of the current object 
    def populate_nodes_from_library(obj)
      get_definition(obj.class, obj.name).nodes.each_with_index { |node, i| obj.nodes[i] = node }
      obj
    end

    # Recursively scan the loop and instantiate fields' definitions for all its segments
    def resolve_dependencies(loop)
      #puts "Trying to process loop #{loop.inspect}"
      populate_nodes_from_library(loop) if loop.nodes.empty?

      loop.nodes.each { |node|
        case node
        when X12::Loop    then
          resolve_dependencies(node)
        when X12::Segment then
          if node.nodes.empty? then
            populate_nodes_from_library(node) 
            node.apply_overrides
          end

          node.nodes.each { |n|
            # Make sure we have the validation table if any for this field. Try to read one in if missing.
            n.set_validation_table(get_definition(X12::Table, n.validation)) if n.validation
          }
        end
      }
    end

  end # Parser
end
