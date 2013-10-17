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
    attr_reader :name, :alias, :parsed_str, :data_type, :required, :min_length, :max_length, :validation,
                :const_value, :error, :error_code
    attr_accessor :content, :parent, :validation_table

    # Create a new field with given parameters
    def initialize(params = {})
      @content     = nil
      @parent      = nil
      @error       = nil
      @error_code  = nil
      @name        = params[:name]
      @data_type   = params[:data_type]
      @required    = params[:required] || false
      @min_length  = params[:min]
      @max_length  = params[:max]
      @validation  = params[:validation]
      @const_value = params[:const_value]
      @var_name    = params[:var_name]
      @alias       = params[:alias]
    end

    def apply_overrides(override_field)
      self.class.new({ :name        => @name,
                       :data_type   => @data_type,
                       :required    => @required,
                       :min         => override_field.min_length  || @min_length,
                       :max         => override_field.max_length  || @max_length,
                       :validation  => @validation,
                       :const_value => override_field.const_value || @const_value,
                       :var_name    => @var_name,
                       :alias       => override_field.alias       || @alias })
    end

    def initialize_copy(original_object)
      set_empty!
    end

    # Returns printable string with field's content
    def inspect
      "<Field #{name}::#{data_type}#{ is_constant? ? " const(#{@const_value})" : '' } (#{required ? 'required' : 'optional'})|#{min_length}...#{max_length}|#{validation} \"#{@content}\">"
    end

    # Returns string representation of the field's content formatted to X12 specs
    def render(root = self)
      val = raw_value

      return '' if val.nil?

      case self.data_type
      when 'DT'      then val.strftime('%Y%m%d')[-(max_length)..-1]
      when 'TM'      then 
        res = val.strftime("%H%M%S%L")[0..(max_length - 1)].sub(/0{0,#{max_length - min_length}}$/, '')
        res += "0" if res.length == 5 # Special case to not allow minutes to lose the units digit if it's zero
        res
      # "AN: Alphanumeric data elements containing the numerals 0-9, the characters A-Z and any
      # special characters except asterisk (*), the greater than sign (>) and the characters with a
      # hexadecimal value of '40' or less. These characters are control characters and should not be
      # used for data. The significant characters shall be left justified. Leading spaces, when they occur,
      # are presumed to be significant characters. Trailing spaces should be suppressed unless
      # necessary to satisfy the minimum length requirement."
      when 'AN'      then val.to_s.rstrip.ljust(min_length)
      # "Nn: Numeric data containing the numerals 0-9, and an implied decimal point. The 'N' indicates
      # that the element contains a numeric value and the 'n' indicates the number of decimal places to
      # the right of the implied decimal point. The actual decimal point is not transmitted. A leading + or -
      # sign may be used. The minus sign must be used for negative values. Leading zeroes should be
      # suppressed unless they are necessary to satisfy the minimum number of digits required by the
      # data element specification. For a data element defined as N4 with a minimum length of 4, the
      # value 0.0001 would be transmitted as '0001'. For an N4 data element with the minimum length of
      # 1, the value 0.0001 would be transmitted '1'."
      when /^N(\d)*/ then "%0#{min_length}d" % (val * (10**($1.to_i)))
      # "R: (Real) numeric data containing the numerals 0-9 and a decimal point in the proper position.
      # The decimal point is optional for integer values but required for fractional values. A leading + or -
      # sign may be used. The minus sign must be used for negative values."
      when 'R'       then val.to_s
      else                val.to_s
      end
    end # render

    # Specifies if the field has user-provided data (as opposed to static data)
    def has_content?
      !@content.nil?
    end

    # Specifies if the field has anything to render at all
    def has_displayable_content?
      has_content? || (is_variable? && !var_value.nil?)
    end

    def is_constant?
      !@const_value.nil?
    end

    def is_variable?
      !@var_name.nil?
    end

    def raw_value
      @content || @const_value || var_value
    end

    # Obtain the value from the closest ancestor of this object that supports the specified method
    def get_from_ancestor(meth)
      ancestor = self.parent
      begin
        if ancestor.respond_to?(meth) then
          val = ancestor.send(meth)
          return val unless val.nil?
        end
        ancestor = ancestor.parent
      end until ancestor.nil?
      return nil
    end
    private :get_from_ancestor

    # Obtain the value corresponding to the internal variable 
    def var_value
      case @var_name
      when 'segments_rendered' then get_from_ancestor(:segments_rendered)
      when 'control_number'    then get_from_ancestor(:control_number)
      when 'today'             then Date.today
      when 'now'               then Time.now
      when 'fg_count'          then     # Find the parent loop of this field's 
        loop = parent && parent.parent  #   parent segment (which would be IEA)
        fg_loop = loop && loop.nodes[1] # Second node of that loop should be the functional group loop
        fg_loop && fg_loop.size         #   so return its count
      else nil
      end
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

      case self.data_type
      when 'DT', 'TM' then "\\d{#{@min_length},#{@max_length}}"
      when /^N\d*/    then "[0-9+-]{#{@min_length},#{@max_length}}"  # Numeric with implied decimal point; may contain sign
      when 'R'        then "[0-9+-.]{#{@min_length},#{@max_length}}" # Real; may contain leading sign and a decimal point
      when 'AN'       then "[^#{Regexp.escape(field_sep)}#{Regexp.escape(segment_sep)}]{#{@min_length},#{@max_length}}"
      when /C.*/      then "[^#{Regexp.escape(field_sep)}#{Regexp.escape(segment_sep)}]{#{@min_length},#{@max_length}}"
      else                 "[^#{Regexp.escape(field_sep)}#{Regexp.escape(segment_sep)}]*"
      end # case
    end # str_regexp

    def parse(str)
      @parsed_str = str
      @content =
        case self.data_type
        when /^N(\d)*/ then str.to_i / (10.0**($1.to_i)) # Numeric with implied decimal point
        when 'R'       then str.to_f                     # Real
        when 'DT'      then                              # [CC]YYMMDD
          y = (str[-8..-5] || Date.today.year - ( Date.today.year % 100) + str[-6..-5].to_i).to_i
          @content = Date.new(y, str[-4..-3].to_i, str[-2..-1].to_i)
        when 'TM'      then                              # HHMM[SS[D[D]]]
          if str then
            str += '0000'
            Time.new(0, nil, nil, str[0..1].to_i, str[2..3].to_i, str[4..7].to_f / 100)
          end
        when 'AN'      then str && str.rstrip
        else str
        end
    end

    def empty?
      false
    end

    # Validate the field data - whether incoming or outgoing. use_ext_charset controls whether 
    #   the X12's Basic or Advanced Character Set is expected for alphanumeric values.
    def valid?(use_ext_charset = true)
      @error_code = @error = nil
      val = @parsed_str || self.raw_value

      if val.nil? || val == '' then
        if required && !is_variable? then
          @error_code, @error = 1, 'Mandatory data element missing'
          return false
        end
      else
        val2 = @parsed_str || self.render

        if validation then
          if validation_table.nil?
            @error = "Validation table #{validation} not provided"
            return false
          end

          unless validation_table.has_key?(val2)
            @error_code, @error = 7, "Invalid code value ([#{val}] not in validation table #{validation})"
            return false
          end
        end

        if val2.length > max_length then
            @error_code, @error = 5, "Data element too long (data=[#{val2}], max_length=#{max_length})"
          return false
        end

        if val2.length < min_length then
            @error_code, @error = 4, "Data element too short (data=[#{val2}], (min_length=#{min_length})"
          return false
        end

        # Note that regexps MUST be written as to ALWAYS succeed, even if zero characters are captured (see below).
        re = case self.data_type
             when 'DT', 'TM'  then /^\d*/
             when /^N\d*/     then /^[+-]?\d*/       # Numeric with implied decimal point; may contain sign
             when 'R'         then /^[+-]?\d*\.?\d*/ # Real; may contain leading sign and a decimal point
             # http://www.x12.org/rfis/Basic%20Character%20Set%20X222A1.pdf
             when 'AN', /C.*/ then 
               if use_ext_charset then 
                 /^[A-Za-z0-9!"&'()*+,-.\/:;?= %@\[\]_{}\\|<>~#\$]*/
               else
                 /^[A-Z0-9!"&'()*+,-.\/:;?= ]*/      #'
               end
             else             nil
             end

        # If regexp left something behind ($' stands for match_data.post_match), the first uncosumed character
        #   will be the one that failed the match.
        if re && re.match(val2) && $' != '' then
          @error_code, @error = 6, "Invalid character in data element (data=[#{val2}], char='#{$'[0]}')"
          return false
        end

      end

      true
    end

  end
end
