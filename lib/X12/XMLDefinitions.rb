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
             when /(^y(es)?$)|(^t(rue)?$)|(^1$)/i  then true
             when /(^no?$)|(^f(alse)?$)|(^0$)/i    then false
             else
               nil
             end # case
    end #parse_boolean

    def parse_type(s)
      return case s
             when nil               then nil
             when 'date'            then 'DT' # Date in [CC]YYMMDD format
             when 'time'            then 'TM' # Time in HHMM[SS[D[D]]] format
             when /^C.+$/           then s    # Composite value
             when /^N\d+$/          then s    # Numeric data with implied decimal point
             when /^l(ong)?$/i      then 'N0' # Long integer, same as N0
             when /^d(ouble)?$/i    then 'R'  # Real. But sometimes in misc/*.xml, it's also N1, N2, N4 -- need to fix!
             when /^s(tr(ing)?)?$/i then 'AN' # Implied. Not actually used anywhere in misc/*.xml
             else :unknown
             end # case
    end #parse_type

    def parse_int(s)
      return case s
             when nil             then nil
             when /^\d+$/         then s.to_i
             when /^inf(inite)?$/ then 999999
             else :unknown
             end # case
    end #parse_int

    def parse_attributes(e, override = false)
      throw Exception.new("No name attribute found for : #{e.inspect}")          unless name = e.attributes["name"] 

      min      = parse_int(e.attributes["min"])
      max      = parse_int(e.attributes["max"])
      type     = parse_type(e.attributes["type"])
      required = parse_boolean(e.attributes["required"])

      # It is OK for override fields to have their components to be nil; it simply means that
      #   those components are not being overridden and must be carried over from the original field.
      unless override
        throw Exception.new("Cannot parse attribute 'min' for: #{e.inspect}")  if min == :unknown
        throw Exception.new("Cannot parse attribute 'max' for: #{e.inspect}")  if max == :unknown
        throw Exception.new("Cannot parse attribute 'type' for: #{e.inspect}") if type == :unknown

        # Populate defaults
        min  ||= 0
        max  ||= 999999
        type ||= 'AN'

        min = 1 if required and min < 1
      end
      
      return { :name        => name,
               :min         => min,
               :max         => max,
               :data_type   => type,
               :required    => required,
               :validation  => e.attributes["validation"],
               :const_value => e.attributes["const"],
               :var_name    => e.attributes["var"] }
    end # parse_attributes

    def parse_field(e, override = false)
      Field.new(parse_attributes(e, override))
    end # parse_field

    def parse_table(e)
      content = {}

      e.get_elements("Entry").each { |entry|
        content[entry.attributes["name"]] = entry.attributes["value"]
      }

      Table.new(parse_attributes(e), content)
    end

    def parse_segment(e)
      params = parse_attributes(e)
      params[:overrides] = e.get_elements("Override").collect { |override| parse_field(override, true) }
      params[:initial_segment] = parse_boolean(e.attributes["initial_segment"])
      s = Segment.new(params, e.get_elements("Field").collect { |field| parse_field(field) })
      s
    end

    def parse_composite(e)
      Composite.new(parse_attributes(e), e.get_elements("Field").collect { |field| parse_field(field) })
    end

    def parse_loop(e)
      params = parse_attributes(e)
      nodes = e.elements.collect { |element|
        case element.name
        when /loop/i    then parse_loop(element)
        when /segment/i then parse_segment(element)
        else throw Exception.new("Cannot recognize syntax for: #{element.inspect} in loop #{e.inspect}")
        end
      }
      Loop.new(params, nodes)
    end

  end # Parser
end
