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

  # $Id: Loop.rb 59 2009-03-19 22:32:13Z ikk $
  #
  # Implements nested loops of segments


  class Loop < Base
    attr_accessor :segments_rendered

    def initialize(*args)
      @segments_rendered = 0
      super(*args)
    end

#     def regexp
#       @regexp ||= 
#         Regexp.new(inject(''){|s, i|
#                      puts i.class
#                      s += case i
#                           when X12::Segment: "(#{i.regexp.source}){#{i.repeats.begin},#{i.repeats.end}}"
#                           when X12::Loop:    "(.*?)"
#                           else
#                             ''
#                           end
#                    })
#     end

    # Recursively find a sub-element
    def find(name)
      #puts "Finding [#{name}] in #{self.class} #{name}"
      # Breadth first
      res = nodes.find{ |n| name == n.name }
      return res if res
      # Depth now
      nodes.each{|i| 
        res = i.find(name) if i.kind_of?(X12::Loop)
        return res unless res.nil? or EMPTY == res # otherwise keep looping
      }
      return EMPTY
    end

    # Parse a string and fill out internal structures with the pieces of it. Returns 
    # an unparsed portion of the string or the original string if nothing was parsed out.
    def parse(str)
      #puts "Parsing loop #{name}: " + str
      s = str
      nodes.each{|i|
        m = i.parse(s)
        s = m if m
      } 

      if str == s
        return nil
      else
        self.parsed_str = str[0..-s.length-1]
        s = do_repeats(s)
      end

      #puts 'Parsed loop ' + self.inspect
      return s
    end # parse

    # Render all components of this loop as string suitable for EDI
    def render(root = self)
      res = ''
      if self.has_content? then
        nodes.each { |n| res << n.render(root) } # Render children of this Loop
        res << next_repeat.render(root) if next_repeat # Recursively render the repeats of this loop
      end
      res
    end # render

  end # Loop
end # X12
