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

module X12

  # $Id: XMLDefinitions.rb 90 2009-05-13 19:51:27Z ikk $
  #
  # A class for parsing X12 message definition expressed in XML format.

  class XMLDefinitions < Hash

    # Parse definitions out of XML file
    def initialize(str)
      doc = Document.new(str)
      definitions = doc.root.name =~ /^Definition$/i ? doc.root.elements.to_a : [doc.root]
      definitions.each { |element|
        #puts element.name
        syntax_element = case element.name
                         when /table/i     then parse_table(element)
                         when /segment/i   then parse_segment(element)
                         when /composite/i then parse_composite(element)
                         when /loop/i      then parse_loop(element)
                         end

        self[syntax_element.class] ||= {}
        self[syntax_element.class][syntax_element.name]=syntax_element
      }
    end # initialize

    private

    def parse_boolean(s)
      return case s
             when nil then false
             when ""  then false
             when /(^y(es)?$)|(^t(rue)?$)|(^1$)/i  then  true
             when /(^no?$)|(^f(alse)?$)|(^0$)/i    then false
             else
               nil
             end # case
    end #parse_boolean

    def parse_type(s)
      return case s
             when nil                then 'string'
             when /^C.+$/            then s
             when /^i(nt(eger)?)?$/i then 'int'
             when /^l(ong)?$/i       then 'long'
             when /^d(ouble)?$/i     then 'double'
             when /^s(tr(ing)?)?$/i  then 'string'
             else
               nil
             end # case
    end #parse_type

    def parse_int(s)
      return case s
             when nil             then 0
             when /^\d+$/         then s.to_i
             when /^inf(inite)?$/ then 999999
             else
               nil
             end # case
    end #parse_int

    def parse_attributes(e)
      throw Exception.new("No name attribute found for : #{e.inspect}")          unless name = e.attributes["name"] 
      throw Exception.new("Cannot parse attribute 'min' for: #{e.inspect}")      unless min = parse_int(e.attributes["min"])
      throw Exception.new("Cannot parse attribute 'max' for: #{e.inspect}")      unless max = parse_int(e.attributes["max"])
      throw Exception.new("Cannot parse attribute 'type' for: #{e.inspect}")     unless type = parse_type(e.attributes["type"])
      throw Exception.new("Cannot parse attribute 'required' for: #{e.inspect}") if (required = parse_boolean(e.attributes["required"])).nil?
      
      validation = e.attributes["validation"]
      min = 1 if required and min < 1
      max = 999999 if max == 0

      return name, min, max, type, required, validation
    end # parse_attributes

    def parse_field(e)
      name, min, max, type, required, validation = parse_attributes(e)

      # FIXME - for compatibility with d12 - constants are stored in attribute 'type' and are enclosed in
      # double quotes
      const_field =  e.attributes["const"]
      if(const_field)
        type = "\"#{const_field}\""
      end

      Field.new(name, type, required, min, max, validation)
    end # parse_field

    def parse_table(e)
      name, min, max, type, required, validation = parse_attributes(e)

      content = e.get_elements("Entry").inject({}) {|t, entry|
        t[entry.attributes["name"]] = entry.attributes["value"]
        t
      }
      Table.new(name, content)
    end

    def parse_segment(e)
      name, min, max, type, required, validation = parse_attributes(e)

      fields = e.get_elements("Field").inject([]) {|f, field|
        f << parse_field(field)
      }
      Segment.new(name, fields, Range.new(min, max))
    end

    def parse_composite(e)
      name, min, max, type, required, validation = parse_attributes(e)

      fields = e.get_elements("Field").inject([]) {|f, field|
        f << parse_field(field)
      }
      Composite.new(name, fields)
    end

    def parse_loop(e)
      name, min, max, type, required, validation = parse_attributes(e)

      components = e.elements.to_a.inject([]){|r, element|
        r << case element.name
             when /loop/i    then parse_loop(element)
             when /segment/i then parse_segment(element)
             else
               throw Exception.new("Cannot recognize syntax for: #{element.inspect} in loop #{e.inspect}")
             end # case
      }
      Loop.new(name, components, Range.new(min, max))
    end

  end # Parser
end
