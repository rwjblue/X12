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
    attr_reader :error

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
      @x12_definition = {}
      @error = nil
      load_definition_file(file_name)
    end # initialize

    # Parse a loop of a given name out of a string. Throws an exception if the loop name is not defined.
    def parse(loop_name, str)
      loop = @x12_definition[X12::Loop][loop_name]
      #puts "Loops to parse #{@x12_definition[X12::Loop].keys}"
      throw Exception.new("Cannot find a definition for loop #{loop_name}") unless loop
      loop = loop.dup
      loop.parse(str)
      return loop
    end # parse

    # Make an empty loop to be filled out with information
    def factory(loop_name)
      loop = @x12_definition[X12::Loop][loop_name]
      throw Exception.new("Cannot find a definition for loop #{loop_name}") unless loop
      loop = loop.dup
      return loop
    end # factory

    # Validates the X12 document. Returns true if the document is valid, false otherwise;
    # use 'error' attribute to access the error message.
    def validate(node)
      @error = nil

      case node
      when X12::Field then
        table = node.validation && @x12_definition[X12::Table] && @x12_definition[X12::Table][node.validation]

        unless node.valid?(table)
          @error = "#{node.parent.name}/#{node.name}: #{node.error.last}"
          return false
        end

      else
        if node.has_displayable_content? then
          # See if all children of this node are correct
          return false unless node.nodes.all? { |node| validate(node) }
          # Recursively check if all the repeats of this node are correct.
          return false if node.next_repeat && !validate(node.next_repeat)
        else
          if node.required? then
            @error = "#{node.name}: required #{node.class.to_s.downcase} missing"
            return false 
          end
        end
      end
      return true
    end

    # Validates the X12 document and raises the Exception if invalid.
    def validate!(doc)
      raise Exception.new(@error) unless validate(doc)
      true
    end

    private

    def load_definition_file(file_name)
      file_name = cleanup_file_name(file_name)
      #puts "Reading definition from #{file_name}"

      # Read and parse the definition
      new_definition = X12::XMLDefinitions.new(File.open(file_name, 'r').read)

      # Populate fields in all segments found in all the loops
      new_definition[X12::Loop].each_pair{|k, v|
        #puts "Populating definitions for loop #{k}"
        process_loop(v)
      } if new_definition[X12::Loop]

      # Merge the newly parsed definition into a saved one, if any.
      new_definition.keys.each { |t|
        @x12_definition[t] ||= {}
        new_definition[t].keys.each { |u|
          @x12_definition[t][u] = new_definition[t][u] 
        }
      }
    end

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
      # Attempt to retrieve the definition from the cache
      definition = @x12_definition[klass] && @x12_definition[klass][name]

      if definition.nil? then # If not, load from the library and attempt to retrieve it again
        load_definition_file(name + '.xml')
        definition = @x12_definition[klass][name]
        throw Exception.new("Cannot find a definition for #{name}") if definition.nil?
      end

      definition
    end

    def load_from_library(obj)
      get_definition(obj.class, obj.name).nodes.each_with_index { |node, i| obj.nodes[i] = node }
      obj
    end

    # Recursively scan the loop and instantiate fields' definitions for all its segments
    def process_loop(loop)
      #puts "Trying to process loop #{loop.inspect}"
      load_from_library(loop) if loop.nodes.empty?

      loop.nodes.each { |node|
        case node
        when X12::Loop    then
          process_loop(node)
        when X12::Segment then
          if node.nodes.empty? then
            load_from_library(node) 
            node.apply_overrides
          end

          node.nodes.each { |n|
            # Make sure we have the validation table if any for this field. Try to read one in if missing.
            get_definition(X12::Table, n.validation) if n.validation
          }
        end
      }
    end

  end # Parser
end
