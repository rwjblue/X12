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
module X12

  # $Id: Segment.rb 82 2009-05-13 18:07:22Z ikk $
  #
  # Implements a segment containing fields or composites
    
  class Segment < Base
    attr_accessor :initial_segment

    def initialize(*args)
      @initial_segment = false
      super(*args)
    end

    # Parses this segment out of a string, puts the match into value, returns the rest of the string - nil
    # if cannot parse
    def parse(str)
      s = str
      #puts "Parsing segment #{name} from #{s} with regexp [#{regexp.source}]"
      m = regexp.match(s)
      #puts "Matched #{m ? m[0] : 'nothing'}"
      
      return nil unless m

      s = m.post_match
      self.parsed_str = m[0]
      s = do_repeats(s)

      #puts "Parsed segment "+self.inspect
      return s
    end # parse

    # Render all components of this segment as string suitable for EDI
    def render(root = self)
      self.to_a.inject(''){ |repeat_str, i|
        if i.repeats.begin < 1 and !i.has_content?
          # Skip optional empty segments
          repeat_str
        else
          if root.respond_to?(:segments_rendered) then
            root.segments_rendered = 0 if initial_segment
            root.segments_rendered += 1
          end

          # Have to render no matter how empty
          repeat_str += i.name + i.nodes.reverse.inject(''){ |nodes_str, j|
            field = j.render(root)
            (j.required or nodes_str != '' or field != '') ? root.field_separator + field + nodes_str : nodes_str
          } + root.segment_separator
        end
      }
    end # render

    # Returns a regexp that matches this particular segment
    def regexp
      unless @regexp
        if self.nodes.any? { |i| i.is_constant? } then
          # It's a very special regexp if there are constant fields
          re_str = self.nodes.inject("^#{name}#{Regexp.escape(field_separator)}"){|s, i|
            field_re = i.simple_regexp(field_separator, segment_separator) + Regexp.escape(field_separator) + '?'
            field_re = "(#{field_re})?" unless i.required
            s + field_re
          } + Regexp.escape(segment_separator)
          @regexp = Regexp.new(re_str)
        else
          # Simple match
          @regexp = Regexp.new("^#{name}#{Regexp.escape(field_separator)}[^#{Regexp.escape(segment_separator)}]*#{Regexp.escape(segment_separator)}")
        end
        #puts sprintf("%s %p", name, @regexp)
      end
      @regexp
    end

    # Recursively find a sub-element
    def find(name)
      #puts "Finding [#{name}] in #{self.class} #{name}"
      find_field(name).render
    end

    # Finds a field in the segment. Returns EMPTY if not found.
    def find_field(field_name)
      #puts "Finding field [#{field_name}] in #{self.class} #{name}"

      # If the segment hasn't been parsed yet, let's parse it
      if @parsed_str && @fields.nil? then
        segment_data = @parsed_str.gsub(Regexp.new("#{Regexp.escape(segment_separator)}$"), '')
        @fields = segment_data.split(Regexp.new(Regexp.escape(field_separator)))
        self.nodes.each_with_index{ |node, ind| node.parse(@fields[ind + 1]) }
      end

      self.nodes.find { |node| node.name == field_name } || EMPTY
    end

  end # Segment
end # X12
