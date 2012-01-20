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

  #
  # Global configuration for X12 separators
  #
  module Separators
    
    # Segment separator (default '~')
    #
    def self.segment_separator
      @@segment_separator ||= '~'
    end

    def self.segment_separator=(s)
      @@segment_separator = s
    end

    # Field separator (default '*')
    #
    def self.field_separator
      @@field_separator ||= '*'
    end

    def self.field_separator=(s)
      @@field_separator = s
    end

    # Composite separator (default ':')
    #
    def self.composite_separator
      @@component_separator ||= ':'
    end

    def self.composite_separator=(s)
      @@component_separator = s
    end

    def self.included(base)
      base.send(:include, InstanceMethods)
    end

    module InstanceMethods
      def segment_separator
        X12::Separators.segment_separator
      end

      def field_separator
        X12::Separators.field_separator
      end

      def composite_separator
        X12::Separators.composite_separator
      end
    end

  end
end
