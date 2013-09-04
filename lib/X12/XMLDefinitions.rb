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
        self[syntax_element.class][syntax_element.name] = syntax_element
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
             when nil               then 'AN'
             when 'date'            then 'DT' # Date in [CC]YYMMDD format
             when 'time'            then 'TM' # Time in HHMM[SS[D[D]]] format
             when /^C.+$/           then s    # Composite value
             when /^N\d+$/          then s    # Numeric data with implied decimal point
             when /^l(ong)?$/i      then 'N0' # Long integer, same as N0
             when /^d(ouble)?$/i    then 'R'  # Real. But sometimes in misc/*.xml, it's also N1, N2, N4 -- need to fix!
             when /^s(tr(ing)?)?$/i then 'AN' # Implied. Not actually used anywhere in misc/*.xml
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
      const_value = e.attributes["const"]
      var_name = e.attributes["var"]
      min = 1 if required and min < 1
      max = 999999 if max == 0

      return name, min, max, type, required, validation, const_value, var_name
    end # parse_attributes

    def parse_field(e)
      name, min, max, type, required, validation, const_value, var_name = parse_attributes(e)

      Field.new(name, type, required, min, max, validation, const_value, var_name)
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

      fields = e.get_elements("Field").collect { |field| parse_field(field) }

      initial_segment = parse_boolean(e.attributes["initial_segment"])
      overrides = e.get_elements("Override").collect { |override| parse_field(override) }
      s = Segment.new(name, fields, Range.new(min, max), initial_segment, overrides)
      s
    end

    def parse_composite(e)
      name, min, max, type, required, validation = parse_attributes(e)

      fields = e.get_elements("Field").collect { |field| parse_field(field) }
      Composite.new(name, fields)
    end

    def parse_loop(e)
      name, min, max, type, required, validation = parse_attributes(e)

      nodes = []

      e.elements.to_a.each { |element|
        case element.name
        when /loop/i    then nodes << parse_loop(element)
        when /segment/i then nodes << parse_segment(element)
        else throw Exception.new("Cannot recognize syntax for: #{element.inspect} in loop #{e.inspect}")
        end
      }

      Loop.new(name, nodes, Range.new(min, max))
    end

  end # Parser
end
