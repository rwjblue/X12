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

  # $Id: Table.rb 35 2008-11-13 18:33:44Z ikk $
  #
  # This just a named hash to store validation tables.

  class Table < Hash
    # Name of the table
    attr_reader :name

    # Create a new table with given name and hash content.
    def initialize(params, content)
      @name = params[:name]
      self.merge!(content)
    end

    # Return a printable string representing this table
    def inspect
      "Table #{name} -- #{super.inspect}"
    end
  end
end
