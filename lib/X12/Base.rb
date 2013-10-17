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

  # $Id: Base.rb 70 2009-03-26 19:25:39Z ikk $
  #
  # Base class for Segment, Composite, and Loop. Contains setable
  # segment_separator, field_separator, and composite_separator fields.

  class Base

    # Name of the node
    attr_reader :name
    # +alias+ can be used to access the node instead of +name+; also, nodes with aliases
    # are collected in +to_hsh+ call
    attr_reader :alias
    # +Range+ determining max and min repeats of the node
    attr_reader :repeats
    # String from which the particular node was generated during parsing
    attr_reader :parsed_str
    # Error code as per X12 specifications as determined by +valid?+ method
    attr_reader :error_code
    # Human readable error message as determined by +valid?+ method
    attr_reader :error
    # Character that separates segments in the document (usually '~')
    attr_accessor :segment_separator
    # Character that separates fields in the segment (usually '*')
    attr_accessor :field_separator
    # Character that separates value parts fields in the composite field (usually ':')
    attr_accessor :composite_separator
    # Pointer to the next repeat of this node, or +nil+ if none
    attr_accessor :next_repeat
    # Collection of child nodes
    attr_accessor :nodes
    # Parent node of this one
    attr_accessor :parent

    # Creates a new base element with given parameters and array of sub-elements
    def initialize(params = {}, nodes = [])
      @error               = nil
      @error_code          = nil
      @name                = params[:name]
      @alias               = params[:alias]
      @nodes               = nodes.each { |n| n.parent = self }
      @repeats             = Range.new(params[:min], params[:max])
      @next_repeat         = nil
      @parsed_str          = nil
      @parent              = nil
      @segment_separator   = '~'
      @field_separator     = '*'
      @composite_separator = ':'

      #puts "Created #{name} #{object_id} #{self.class}  "
    end

    # Formats a printable string containing the element's content
    def inspect
      "#{self.class.to_s.sub(/^.*::/, '')} (#{name}) #{repeats} #{super.inspect[1..-2]} =<#{parsed_str}, #{next_repeat.inspect}> ".gsub(/\\*\"/, '"')
    end

    # Prints a tree-like representation of the element
    def show(ind = '')
      count = 0
      self.to_a.each{ |i|
        #puts "#{ind}#{i.name} #{i.object_id} #{i.super.object_id} [#{count}]: #{i.parsed_str} #{i.super.class}"
        puts "#{ind}#{i.name} [#{count}]: #{i.to_s.sub(/^(.{30})(.*?)(.{30})$/, '\1...\3')}"

        i.nodes.each{ |j|
          case 
          when j.kind_of?(X12::Base)  then j.show(ind + '  ')
          when j.kind_of?(X12::Field) then puts "#{ind + '  '}#{j.name} -> '#{j.to_s}'"
          end
        } 

        count += 1
      }
    end

    # Try to parse the current element one more time if allowed. Returns the unconsumed part of the string.
    def do_repeats(s)
      if self.repeats.end > 1 then
        possible_repeat = self.dup
        p_s = possible_repeat.parse(s)
        if p_s then
          s = p_s
          self.next_repeat = possible_repeat
        end # if parsed
      end # more repeats
      s
    end # do_repeats

    # Empty out the current element
    def set_empty!
      @next_repeat = nil
      @parsed_str = nil
      self
    end

    # Initialize the fresh copy of the object made by +dup+
    def initialize_copy(original_object)
      set_empty!

      self.nodes = original_object.nodes.collect { |child|
        child_copy = child.dup
        child_copy.parent = self
        child_copy
      }

      #puts "Duped #{original_object.class} #{original_object.name} #{original_object.object_id} #{original_object.super.object_id} -> #{self.name} #{self.super.object_id} #{self.object_id} "
    end

    # Method to be overloaded
    def find(e)
      return EMPTY
    end

    # Returns number of repeats
    def size
      s = 0
      repeat = self
      until repeat.nil? do
        s += 1
        repeat = repeat.next_repeat
      end
      s
    end

    # Present self and all repeats as an array with self being #0
    def to_a
      res = []
      repeat = self
      until repeat.nil? do
        res << repeat
        repeat = repeat.next_repeat
      end
      res
    end

    # Returns a parsed string representation of the element
    def to_s
      @parsed_str || render
    end

    # The main method implementing Ruby-like access methods for nested elements
    def method_missing(meth, *args, &block)
      str = meth.id2name
      str = str[1..-1] if str =~ /^_\d+$/ # to avoid pure number names like 270, 997, etc.
      #puts "Missing #{str}"
      if str =~ /=$/
        # Assignment
        str.chop!
        #puts str
        case self
        when X12::Segment
          res = find_field(str)
          throw Exception.new("No field '#{str}' in segment '#{self.name}'") if EMPTY == res
          res.content = args[0]
          #puts res.inspect
        else
          throw Exception.new("Illegal assignment to #{meth} of #{self.class}")
        end # case
      else
        # Retrieval
        res = find(str)
        yield res if block_given?
        res
      end # if assignment
    end
    
    # The main method implementing Ruby-like access methods for repeating elements
    def [](*args)
      #puts "squares #{args.inspect}"
      return self.to_a[args[0]] || EMPTY
    end

    # Yields to accompanying block passing self as a parameter.
    def with(&block)
      yield(self)
    end
    
    # True if any of the nodes below have user-provided content. That does not include
    # variables or constants.
    def has_content?
      self.nodes.any? { |i| i.has_content? }
    end

    # True if any of the nodes below have content that needs to be displayed - that includes
    # both user-provided content and variables.
    def has_displayable_content?
      self.nodes.any? { |i| i.has_displayable_content? }
    end

    # Adds a repeat to a segment or loop. Returns a new segment/loop or self if empty.
    def repeat
      new_repeat = if self.has_content? # Do not repeat an empty segment
                     last_repeat = self
                     last_repeat = last_repeat.next_repeat until last_repeat.next_repeat.nil?
                     last_repeat.next_repeat = last_repeat.dup
                   else
                     self
                   end
      yield new_repeat if block_given?
      new_repeat
    end

    def empty?
      false
    end

    def required?
      self.repeats.begin > 0
    end

  end # Base
end
