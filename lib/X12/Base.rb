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
    def show(indent = '')
      count = 0
      self.to_a.each{ |i|
        #puts "#{indent}#{i.name} #{i.object_id} #{i.super.object_id} [#{count}]: #{i.parsed_str} #{i.super.class}"
        puts "#{indent}#{i.name} [#{count}]: #{i.to_s.sub(/^(.{30})(.*?)(.{30})$/, '\1...\3')}"

        i.nodes.each{ |j|
          case 
          when j.kind_of?(X12::Base)  then j.show(indent + '  ')
          when j.kind_of?(X12::Field) then puts "#{indent}  #{j.name} -> '#{j.to_s}'"
          end
        } 

        count += 1
      }
    end

    # Check if the source string contains one more repeat of the current element, and parse it if it is so.
    # Returns the unconsumed part of the string.
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

    # Initialize the fresh copy of the object made by +dup+ by cleaning up user data
    # and cloneing all of the original's nodes.
    def initialize_copy(original_object)
      set_empty!

      self.nodes = original_object.nodes.collect { |child|
        child_copy = child.dup
        child_copy.parent = self
        child_copy
      }

      #puts "Duped #{original_object.class} #{original_object.name} #{original_object.object_id} #{original_object.super.object_id} -> #{self.name} #{self.super.object_id} #{self.object_id} "
    end

    # Prototype method to be overloaded
    def find(e)
      raise 'Subclass responsebility'
    end

    # Number of repeats of this element, starting with self.
    def size
      s = 0
      repeat = self        # Yes, this loop is used in a few places, but extracting it into a
      until repeat.nil? do # separate method causes about 20% performance drop due to yield overhead.
        s += 1
        repeat = repeat.next_repeat
      end
      s
    end

    # Returns the array of repeats of this element, starting with self.
    def to_a
      res = []
      repeat = self        # Yes, this loop is used in a few places, but extracting it into a
      until repeat.nil? do # separate method causes about 20% performance drop due to yield overhead.
        res << repeat
        repeat = repeat.next_repeat
      end
      res
    end

    # Returns a parsed string representation of the element
    def to_s
      @parsed_str || render
    end

    # The main method implementing Ruby-like access methods for nested elements. 
    # To address nodes with purely numeric names (i.e. 270, 997, etc.), prefix them with an underscore.
    def method_missing(meth, *args, &block)
      str = meth.to_s
      str = str[1..-1] if str =~ /^_\d+$/
      #puts "Missing #{str}"
      res = find(str)
      yield res if block_given?
      res
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
    # There's no need to check repeats, because the only way for an element to be empty
    # is to be the first and only in the repeats list.
    def has_content?
      self.nodes.any? { |i| i.has_content? }
    end

    # True if any of the nodes below have content that needs to be displayed - that includes
    # both user-provided content and variables.
    # There's no need to check repeats, because the only way for an element to be empty
    # is to be the first and only in the repeats list.
    def has_displayable_content?
      self.nodes.any? { |i| i.has_displayable_content? }
    end

    # Returns a fresh repeat of this segment/loop ready to be filled with user content - 
    # either self, or a fresh copy.
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

    def required?
      self.repeats.begin > 0
    end

  end # Base
end
