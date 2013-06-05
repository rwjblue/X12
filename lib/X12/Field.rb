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
    attr_reader :name, :data_type, :required, :min_length, :max_length, :validation
    attr_accessor :content

    # Create a new field with given parameters
    def initialize(name, data_type, required, min_length, max_length, validation, const_value = nil, var_name = nil)
      @name        = name       
      @data_type   = data_type       
      @required    = required
      @min_length  = min_length.to_i
      @max_length  = max_length.to_i 
      @validation  = validation
      @content     = nil
      @const_value = const_value
      @var_name    = var_name
     end

    # Returns printable string with field's content
    def inspect
      "<Field #{name}::#{data_type}#{ is_constant? ? " const(#{@const_value})" : '' } (#{required ? 'required' : 'optional'})|#{min_length}...#{max_length}|#{validation} \"#{@content}\">"
    end

    def render(root = self)
      return @const_value.to_s if is_constant?

      if @var_name then
        case @var_name
        when 'segments_rendered' then root.segments_rendered.to_s if root.respond_to?(:segments_rendered)
        end
      else
        case self.data_type
        when 'DT'    then @content.strftime('%Y%m%d')[-(max_length)..-1]
        when 'TM'    then 
          res = @content.strftime("%H%M%S%L")[0..(max_length - 1)].sub(/0{0,#{max_length - min_length}}$/, '')
          res += "0" if res.length == 5 # Special case to not allow minutes to lose the units digit if it's zero
          res
        # "Nn: Numeric data containing the numerals 0-9, and an implied decimal point. The 'N' indicates
        # that the element contains a numeric value and the 'n' indicates the number of decimal places to
        # the right of the implied decimal point. The actual decimal point is not transmitted. A leading + or -
        # sign may be used. The minus sign must be used for negative values. Leading zeroes should be
        # suppressed unless they are necessary to satisfy the minimum number of digits required by the
        # data element specification. For a data element defined as N4 with a minimum length of 4, the
        # value 0.0001 would be transmitted as '0001'. For an N4 data element with the minimum length of
        # 1, the value 0.0001 would be transmitted '1'."
        when /^N\d*/ then @content.nil? ? '' : (("%0#{min_length + 1}.#{$1}f" % @content).gsub('.', ''))
        # "R: (Real) numeric data containing the numerals 0-9 and a decimal point in the proper position.
        # The decimal point is optional for integer values but required for fractional values. A leading + or -
        # sign may be used. The minus sign must be used for negative values."
        when 'R'     then @content.to_s
        else              @content.to_s
        end
      end
    end # render

    # Check if it's been set yet and it's not a constant
    def has_content?
      !@content.nil?
    end

    # Constants are always pre-set, so if @content is nil, then it's definitely not a constant.
    def is_constant?
      !@const_value.nil?
    end

    # Erase the content
    def set_empty!
      @content = nil
    end

    # Returns simplified string regexp for this field, takes field separator and segment separator as arguments
    def simple_regexp(field_sep, segment_sep)
      return Regexp.escape(@const_value) if is_constant?
      "[^#{Regexp.escape(field_sep)}#{Regexp.escape(segment_sep)}]*"
    end # simple_regexp

    # Returns proper validating string regexp for this field, takes field separator and segment separator as arguments
    def proper_regexp(field_sep, segment_sep)
      return Regexp.escape(@const_value) if is_constant?

      # Need to bring data types to X12 standards
      case self.data_type
      when 'DT', 'TM'
                     then "\\d{#{@min_length},#{@max_length}}"
      when /^N\d*/   then "[0-9+-]{#{@min_length},#{@max_length}}"  # Numeric with implied decimal point; may contain sign
      when 'R'       then "[0-9+-.]{#{@min_length},#{@max_length}}" # Real; may contain leading sign and a decimal point
      when 'AN'      then "[^#{Regexp.escape(field_sep)}#{Regexp.escape(segment_sep)}]{#{@min_length},#{@max_length}}"
      when /C.*/     then "[^#{Regexp.escape(field_sep)}#{Regexp.escape(segment_sep)}]{#{@min_length},#{@max_length}}"
      else                "[^#{Regexp.escape(field_sep)}#{Regexp.escape(segment_sep)}]*"
      end # case
    end # str_regexp

    def parse(str)
      @parsed_str = str
      @content = 
        case self.data_type
        when /^N\d*/ then str.to_i / (10.0**($1.to_i)) # Numeric with implied decimal point
        when 'R'     then str.to_f                     # Real
        when 'DT'    then                              # [CC]YYMMDD
          y = (str[-8..-5] || Date.today.year - ( Date.today.year % 100) + str[-6..-5].to_i).to_i
          @content = Date.new(y, str[-4..-3].to_i, str[-2..-1].to_i)
        when 'TM'    then                              # HHMM[SS[D[D]]]
          str += '0000'
          Time.new(0, nil, nil, str[0..1].to_i, str[2..3].to_i, str[4..7].to_f / 100)
        else         str
        end
    end

  end
end
