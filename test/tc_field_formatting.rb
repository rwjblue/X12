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
require 'X12'
require 'test/unit'

class FieldFormatting < Test::Unit::TestCase

  def setup
    # Nothing
  end # setup

  def teardown
    # Nothing
  end # teardown




  def test_parse
    # "Nn: Numeric data containing the numerals 0-9, and an implied decimal point. The 'N' indicates
    # that the element contains a numeric value and the 'n' indicates the number of decimal places to
    # the right of the implied decimal point. The actual decimal point is not transmitted. A leading + or -
    # sign may be used. The minus sign must be used for negative values. Leading zeroes should be
    # suppressed unless they are necessary to satisfy the minimum number of digits required by the
    # data element specification. For a data element defined as N4 with a minimum length of 4, the
    # value 0.0001 would be transmitted as '0001'. For an N4 data element with the minimum length of
    # 1, the value 0.0001 would be transmitted '1'."

    f = X12::Field.new(name = 'test', data_type = 'N4', required = false, min = 4, max = 8, validation = nil)
    f.content = 0.0001
    assert_equal('0001', f.render)
    assert_equal(f.content, f.parse(f.render))

    f = X12::Field.new(name = 'test', data_type = 'N4', required = false, min = 1, max = 8, validation = nil)
    f.content = 0.0001
    assert_equal('1', f.render)
    assert_equal(f.content, f.parse(f.render))

    f = X12::Field.new(name = 'test', data_type = 'N4', required = false, min = 1, max = 8, validation = nil)
    f.content = 1234.5678
    assert_equal('12345678', f.render)
    assert_equal(f.content, f.parse(f.render))

    f = X12::Field.new(name = 'test', data_type = 'N2', required = false, min = 1, max = 8, validation = nil)
    f.content = -12.34
    assert_equal('-1234', f.render)
    assert_equal(f.content, f.parse(f.render))

    f = X12::Field.new(name = 'test', data_type = 'N0', required = false, min = 8, max = 8, validation = nil)
    f.content = 123
    assert_equal('00000123', f.render)
    assert_equal(f.content, f.parse(f.render))

    # "R: (Real) numeric data containing the numerals 0-9 and a decimal point in the proper position.
    # The decimal point is optional for integer values but required for fractional values. A leading + or -
    # sign may be used. The minus sign must be used for negative values."

    f = X12::Field.new(name = 'test', data_type = 'R', required = false, min = 1, max = 8, validation = nil)
    f.content = 1234.56
    assert_equal('1234.56', f.render)
    assert_equal(f.content, f.parse(f.render))

  end # test_ST

end # TestList
