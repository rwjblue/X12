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
$:.unshift(File.dirname(__FILE__))

require 'rubygems'

require 'X12/base'
require 'X12/empty'
require 'X12/field'
require 'X12/composite'
require 'X12/segment'
require 'X12/table'
require 'X12/loop'
require 'X12/xmldefinitions'
require 'X12/parser'

# $Id: X12.rb 91 2009-05-13 22:11:10Z ikk $
#
# Package implementing direct manipulation of X12 structures using Ruby syntax.

module X12

  VERSION = '1.1.0'
  EMPTY = Empty.new()
  TEST_REPEAT = 100
end
