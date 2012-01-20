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
require 'x12'
require 'test/unit'

class TestField < Test::Unit::TestCase

  def setup
    @field = X12::Field.new('test', 'string', false, 0, 10, nil)
  end # setup

  def teardown
    # Nothing
  end # teardown

  def test_content_with_separators
    @field.content = "Foo#{X12::Separators.field_separator}#{X12::Separators.segment_separator}#{X12::Separators.composite_separator}bar"
    assert_equal 'Foo:bar', @field.render, 'Fields should strip out field and segment separators'
  end

  def test_content_with_newlines
    @field.content = "Foo\nbar"
    assert_equal 'Foo bar', @field.render, 'Fields should replace new lines with spaces'
  end
  
  def test_content_with_tabs
    @field.content = "Foo\tbar"
    assert_equal 'Foo bar', @field.render, 'Fields should replace tabs with spaces'
  end

end # TestList
