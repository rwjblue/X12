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

  # $Id: Field.rb 90 2009-05-13 19:51:27Z ikk $
  #
  # Class to represent a segment field. Please note, it's not a descendant of Base.

  class Field
    attr_reader :name, :type, :required, :min_length, :max_length, :validation
    attr_writer :content

    # Create a new field with given parameters
    def initialize(name, type, required, min_length, max_length, validation, const_value = nil)
      @name       = name       
      @type       = type       
      @required   = required
      @min_length = min_length.to_i
      @max_length = max_length.to_i 
      @validation = validation
      @content    = const_value  # If not a constant, will be nil
      @special    = :const if const_value
    end

    # Returns printable string with field's content
    def inspect
      "<Field #{name}::#{type}#{ is_constant? ? " const(#{@content})" : '' } (#{required ? 'required' : 'optional'})|#{min_length}...#{max_length}|#{validation} \"#{@content}\">"
    end

    # Synonym for 'render'
    def to_s
      render
    end

    def render(parent = self)
      if self.is_constant? then # If it's a constant
        if @content == '@@counter' then
          return parent.segments_rendered.to_s
        end
      end
      @content || ''
    end # render

    # Check if it's been set yet and it's not a constant
    def has_content?
      !(@content.nil? || is_constant?)
    end

    # Constants are always pre-set, so if @content is nil, then it's definitely not a constant.
    def is_constant?
      @special == :const
    end

    # Erase the content
    def set_empty!
      @content = nil unless is_constant? # Constants always retain they value they were defined with.
    end

    # Returns simplified string regexp for this field, takes field separator and segment separator as arguments
    def simple_regexp(field_sep, segment_sep)
      return Regexp.escape(@content) if is_constant?
      "[^#{Regexp.escape(field_sep)}#{Regexp.escape(segment_sep)}]*"
    end # simple_regexp

    # Returns proper validating string regexp for this field, takes field separator and segment separator as arguments
    def proper_regexp(field_sep, segment_sep)
      return Regexp.escape(@content) if is_constant?

      case self.type
      when 'I'      then "\\d{#{@min_length},#{@max_length}}"
      when 'S'      then "[^#{Regexp.escape(field_sep)}#{Regexp.escape(segment_sep)}]{#{@min_length},#{@max_length}}"
      when /C.*/    then "[^#{Regexp.escape(field_sep)}#{Regexp.escape(segment_sep)}]{#{@min_length},#{@max_length}}"
      else "[^#{Regexp.escape(field_sep)}#{Regexp.escape(segment_sep)}]*"
      end # case
    end # str_regexp

  end
end
