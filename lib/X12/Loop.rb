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
    # Number of segments rendered in the enumerated loop
    attr_reader :segments_rendered
    # Control number of the loop to be accessed by respective +control_number+ engine variable inside this loop
    attr_accessor :control_number

    def initialize(*args)
      @segments_rendered = nil # Needs to start as nil and only initialize once ST is actually rendered
      @control_number = nil
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
      res = nodes.find{ |n| name == n.name || name == n.alias }
      return res if res
      # Depth now
      nodes.each{ |i| 
        res = i.find(name) if i.kind_of?(X12::Loop)
        return res unless res.nil? # otherwise keep looping
      }
      nil
    end

    # Parse a string and fill out internal structures with the pieces of it. Returns 
    # an unparsed portion of the string or the original string if nothing was parsed out.
    def parse(source_string)
      #puts "Parsing loop #{name}: " + str

      # Ask each node to attempt to grab its matching piece of string. +parse+ will return unconsumed
      # portion of the string or nil if unable to match. If nothing got consumed
      unconsumed_string = nodes.inject(source_string){ |remainder, node| node.parse(remainder) || remainder }

      return nil if source_string == unconsumed_string

      @parsed_str = source_string[0..-(unconsumed_string.length - 1)]

      str = do_repeats(unconsumed_string)

      #puts 'Parsed loop ' + self.inspect

      return str
    end # parse

    # Return the total count of segments that got successfilly parsed within this loop, 
    # (and its repeats if +include_repeats+ is +true+).
    def segments_parsed(include_repeats = false)
      res = 0  
      self.each_segment(include_repeats) { |s| res += 1 unless s.parsed_str.nil? }
      res
    end

    # Iterate through all the segments within this loop (and its repeats if +include_repeats+ is +true+),
    # enumerating them according to X12 requirements.
    def enumerate_segments
      n = 0
      self.each_segment(:include_repeats) { |s|
        next if s.parsed_str.nil?
        n = 0 if s.initial_segment 
        s.segment_position = (n += 1) 
      }
    end

    # Iterate through all the segments within this loop (and its repeats if +include_repeats+ is +true+),
    # invoking the given block on each one.
    def each_segment(include_repeats = false)
      nodes.each { |node| node.each_segment(true) { |x| yield(x) } }
      next_repeat.each_segment(:include_repeats) { |x| yield(x) } if include_repeats && next_repeat
    end

    # Convert all the segments within this loop and its successive repeats into X12-compliant string.
    def render
      @segments_rendered = 0
      res = ''
      self.each_segment(:include_repeats) { |s|
        @segments_rendered = 0 if s.initial_segment 
        if s.has_displayable_content? then
          # Current segment needs to be included in the count, so we increase in advance.
          @segments_rendered += 1
          res += s.render(self)
        end
      }
      res
    end

    # Returns recursive hash of nodes that have an alias defined, along with their respective values.
    def to_hsh
      hsh = {}

      nodes.each { |node|
        hsh[node.alias] = node.to_a.collect { |n| n.to_hsh } unless node.alias.nil?
      }

      hsh
    end

    # Validate the loop - whether incoming or outgoing. 
    # * +include_repeats+ - whether the repeats of this loop should be also validated
    # * +use_ext_charset+ - whether to validate alphanumeric values against X12's Basic or Advanced Character Set
    def valid?(include_repeats = false, use_ext_charset = true)
      @error_code = @error = nil

      if has_displayable_content? then
        return false if nodes.any? { |node|
          @error_code, @error = 5, '#{self.name}: one or more segments in error' unless node.valid?(true, use_ext_charset)
        }

        # Recursively check if all the repeats of this loop are correct.
        if include_repeats && next_repeat && !next_repeat.valid?(true, use_ext_charset) then
          @error_code, @error = next_repeat.error_code, next_repeat.error
          return false 
        end
      else
        if required then
          @error_code, @error = 3, "#{self.name}: mandatory loop missing"
          return false 
        end
      end

      return true
    end

  end # Loop
end # X12
