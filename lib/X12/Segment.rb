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
    # Flag denoting the segment from which should reset the rendered segment counter (usually that would be ST)
    attr_reader   :initial_segment
    # Position of the segment in the enumerated loop (once filled out by +X12::Loop#enumerate_segments+)
    attr_accessor :segment_position

    def initialize(params, nodes)
      @initial_segment  = params[:initial_segment] || false
      @overrides        = params[:overrides] || []
      @syntax_notes     = params[:syntax_notes] || []
      @segment_position = nil
      super
    end

    # Replaces fields loaded from definition skeleton for which overrides exist with their clones with overrides applied.
    def apply_overrides
      @overrides.each { |override| 
        nodes.each_with_index { |n, i| nodes[i] = n.apply_overrides(override) if n.name == override.name }
      }
    end

    # Parses this segment out of a string, puts the match into value, returns the rest of the string
    # or +nil+ if unable to parse
    def parse(str)
      s = str
      #puts "Parsing segment #{name} from #{s} with regexp [#{regexp.source}]"
      m = regexp.match(s)
      #puts "Matched #{m ? m[0] : 'nothing'}"
      
      return nil unless m

      s = m.post_match
      @parsed_str = m[0]
      parse_fields # Fill out the fields without waiting for them to be accessed

      s = do_repeats(s)

      #puts "Parsed segment "+self.inspect
      s
    end # parse

    # Iterate through +self+ plus all the repeats of this segments (if +include_repeats+ is +true+),
    # invoking the given block on each one.
    def each_segment(include_repeats = false, &block)
      segment = self
      while segment
        yield segment
        segment = include_repeats && segment.next_repeat
      end
    end

    # Render all components of this particular segment as string suitable for EDI
    # * +root+ - root loop of the hierarchy holding the separator information
    def render(root = self)
      return '' unless required || self.has_displayable_content?

      nodes_str = ''
      nodes.reverse.each { |fld| # Building string in reverse in order to toss empty optional fields off the end.
        field = fld.render(root)
        nodes_str = root.field_separator + field + nodes_str if fld.required || nodes_str != '' || field != ''
      }

      self.name + nodes_str + root.segment_separator
    end # render

    # Returns a regexp that matches this particular segment
    def regexp
      unless @regexp
        if self.nodes.any? { |i| i.is_constant? } then
          # It's a very special regexp if there are constant fields
          re_str = self.nodes.inject("^#{name}#{Regexp.escape(field_separator)}"){|s, i|
            field_re = i.simple_regexp(field_separator, segment_separator) + Regexp.escape(field_separator) + '?'
            field_re = "(#{field_re})?" unless (i.required || i.is_constant?)
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

    # Collect the fields that have an alias defined, with their corresponding +content+ values, into a hash.
    def to_hsh
      hsh = {}

      nodes.each { |node|
        hsh[node.alias] = node.content unless node.alias.nil?
      }

      hsh
    end

    # Finds a field in the segment and return its +content+.
    def find(name)
      #puts "Finding [#{name}] in #{self.class} #{name}"
      find_field(name).content
    end

    # Finds a field in the segment and returns the respective X12::Field object, or +nil+ if not found.
    # * +field_name+ can be either a field name as defined for the respective segment by X12 standard, a user-defined alias, or a string with the field numeric code (for example, "01" or "SN01", SN being the current segment name)
    def find_field(field_name)
      #puts "Finding field [#{field_name}] in #{self.class} #{name}"

      # If the segment hasn't been parsed yet, let's parse it
      parse_fields if @fields.nil? && @parsed_str

      if field_name =~ /^(?:#{self.name})?(\d\d)$/ then
        nodes[$1.to_i - 1]
      else
        nodes.find { |node| node.name == field_name || node.alias == field_name }
      end
    end

    # Provide access to individual fields in the segment using dot-notation.
    def method_missing(meth, *args, &block)
      str = meth.to_s
      #puts "Missing #{str}"
      if str =~ /=$/ # Assignment
        str.chop!
        #puts str
        field = find_field(str) # Note that fields can not have pure numeric names, so we are in the clear here.
        raise Exception.new("No field '#{str}' in segment '#{self.name}'") if field.nil?
        field.content = args[0]
      else # Retrieval
        super
      end # if assignment
    end

    # Validate the segment - whether incoming or outgoing.
    # * +include_repeats+ - whether the repeats of this segment should be also validated
    # * +use_ext_charset+ - whether to validate alphanumeric values against X12's Basic or Advanced Character Set
    def valid?(include_repeats = false, use_ext_charset = true)
      @error_code = @error = nil

      if has_displayable_content? then
        return false if nodes.any? { |node|
          @error_code, @error = 8, "#{self.name}: segment has data element errors" unless node.valid?(use_ext_charset)
          }

        if !@syntax_notes.empty? then
          @syntax_notes.each { |note|
            deps = note.unpack('a1a2a2a2a2a2a2a2a2').reject(&:empty?) # Never seen more than 5, but just in case...
            mode = deps.shift

            case mode
            when 'C' then # Conditional. If the first element is present, then the others must be present
              f = find_field(deps.shift)
              mode = 'P' if f && f.has_displayable_content?
            when 'L' then # List Conditional. If the first element is present, then at least one of the others must be present
              f = find_field(deps.shift)
              mode = 'R' if f && f.has_displayable_content?
            end

            case mode
            when 'P' then # Paired or multiple. If any are used, all must be used
              c = deps.count{ |i| find_field(i).has_displayable_content? }
              if c != 0 && c != deps.size then
                @error_code, @error = 10, "#{self.name}: exclusion condition violated"
                return false 
              end
            when 'R' then # Required. At least one of those noted must be used
              unless deps.any?{ |i| find_field(i).has_displayable_content? } then
                @error_code, @error = 2, "#{self.name}: conditional required data element missing"
                return false 
              end
            when 'E' then # Exclusion. No more than one may be used
              if deps.count{ |i| find_field(i).has_displayable_content? } > 1 then
                @error_code, @error = 10, "#{self.name}: exclusion condition violated"
                return false 
              end
            end
          }
        end

        # Recursively check if all the repeats of this segment are correct.
        if include_repeats && next_repeat && !next_repeat.valid?(true, use_ext_charset) then
          @error_code, @error = next_repeat.error_code, next_repeat.error
          return false 
        end
      else
        if required then
          @error_code, @error = 3, "#{self.name}: mandatory segment missing"
          return false 
        end
      end

      return true
    end

    # Take the X12 string that was determined as corresponding to this segment, and populate
    # this segment's individual fields with their respective content from that string.
    def parse_fields
      @fields = @parsed_str.chomp(segment_separator).split(field_separator)
      self.nodes.each_with_index{ |node, ind| node.parse(@fields[ind + 1]) }
    end
    private :parse_fields

  end # Segment
end # X12
