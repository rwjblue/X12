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

  # "Nn: Numeric data containing the numerals 0-9, and an implied decimal point. The 'N' indicates
  # that the element contains a numeric value and the 'n' indicates the number of decimal places to
  # the right of the implied decimal point. The actual decimal point is not transmitted. A leading + or -
  # sign may be used. The minus sign must be used for negative values. Leading zeroes should be
  # suppressed unless they are necessary to satisfy the minimum number of digits required by the
  # data element specification. For a data element defined as N4 with a minimum length of 4, the
  # value 0.0001 would be transmitted as '0001'. For an N4 data element with the minimum length of
  # 1, the value 0.0001 would be transmitted '1'."
  def test_field_numeric
    f = X12::Field.new({ :name => 'test', :data_type => 'N4', :min => 4, :max => 8 })
    f.content = 0.0001
    assert_equal('0001', f.render)
    assert_equal(f.content, f.parse(f.render))

    f = X12::Field.new({ :name => 'test', :data_type => 'N4', :min => 1, :max => 8 })
    f.content = 0.0001
    assert_equal('1', f.render)
    assert_equal(f.content, f.parse(f.render))

    f = X12::Field.new({ :name => 'test', :data_type => 'N4', :min => 1, :max => 8 })
    f.content = 1234.5678
    assert_equal('12345678', f.render)
    assert_equal(f.content, f.parse(f.render))

    f = X12::Field.new({ :name => 'test', :data_type => 'N2', :min => 1, :max => 8 })
    f.content = -12.34
    assert_equal('-1234', f.render)
    assert_equal(f.content, f.parse(f.render))

    f = X12::Field.new({ :name => 'test', :data_type => 'N0', :min => 8, :max => 8 })
    f.content = 123
    assert_equal('00000123', f.render)
    assert_equal(f.content, f.parse(f.render))
  end # test_field_numeric

  # "R: (Real) numeric data containing the numerals 0-9 and a decimal point in the proper position.
  # The decimal point is optional for integer values but required for fractional values. A leading + or -
  # sign may be used. The minus sign must be used for negative values."
  def test_field_real
    f = X12::Field.new({ :name => 'test', :data_type => 'R', :min => 1, :max => 8 })
    f.content = 1234.56
    assert_equal('1234.56', f.render)
    assert_equal(f.content, f.parse(f.render))
  end # test_field_real

  # "DT: Numeric date in the form CCYYMMDD."
  def test_field_date
    f = X12::Field.new({ :name => 'test', :data_type => 'DT', :min => 8, :max => 8 })
    f.content = Date.new(2013, 01, 23)
    assert_equal('20130123', f.render)
    assert_equal(f.content, f.parse(f.render))

    f = X12::Field.new({ :name => 'test', :data_type => 'DT', :min => 6, :max => 6 })
    f.content = Date.new(2013, 01, 23)
    assert_equal('130123', f.render)
    assert_equal(f.content, f.parse(f.render))
  end # test_field_date

  # "TM: Numeric time in the form HHMM. Time is represented in 24-hour clock format."
  def test_field_time
    f = X12::Field.new({ :name => 'test', :data_type => 'TM', :min => 4, :max => 4 })
    f.content = Time.new(0, nil, nil, 17, 26)
    assert_equal('1726', f.render)
    assert_equal(f.content, f.parse(f.render))

    f = X12::Field.new({ :name => 'test', :data_type => 'TM', :min => 4, :max => 8 })
    f.content = Time.new(0, nil, nil, 17, 26, 0)
    assert_equal('1726', f.render)
    assert_equal(f.content, f.parse(f.render))

    f = X12::Field.new({ :name => 'test', :data_type => 'TM', :min => 4, :max => 6 })
    f.content = Time.new(0, nil, nil, 17, 26, 30.25)
    assert_equal('172630', f.render)

    f = X12::Field.new({ :name => 'test', :data_type => 'TM', :min => 4, :max => 8 })
    f.content = Time.new(0, nil, nil, 17, 26, 30)
    assert_equal('172630', f.render)
    assert_equal(f.content, f.parse(f.render))

    f = X12::Field.new({ :name => 'test', :data_type => 'TM', :min => 6, :max => 7 })
    f.content = Time.new(0, nil, nil, 17, 26, 30.25)
    assert_equal('1726302', f.render)

    f = X12::Field.new({ :name => 'test', :data_type => 'TM', :min => 4, :max => 8 })
    f.content = Time.new(0, nil, nil, 17, 26, 30.25)
    assert_equal('17263025', f.render)
    assert_equal(f.content, f.parse(f.render))

    f = X12::Field.new({ :name => 'test', :data_type => 'TM', :min => 8, :max => 8 })
    f.content = Time.new(0, nil, nil, 17, 26)
    assert_equal('17260000', f.render)
    assert_equal(f.content, f.parse(f.render))
  end # test_field_time

  def test_field_variables
    Object.const_set :Date2, Date.dup # Save the original Date class
    def Date.today ; Date.new(2010, 12, 31) ; end # Define dummy method for testing

    f = X12::Field.new({ :name => 'test', :data_type => 'DT', :min => 8, :max => 8, :var_name => 'today' })
    dt = Date.today
    assert_equal('20101231', f.render)
    assert_equal(dt, f.parse(f.render))

    f = X12::Field.new({ :name => 'test', :data_type => 'DT', :min => 6, :max => 6, :var_name => 'today' })
    dt = Date.today
    assert_equal('101231', f.render)
    assert_equal(dt, f.parse(f.render))

    f.content = Date.new(2013, 01, 23)
    assert_equal('130123', f.render)
    assert_equal(f.content, f.parse(f.render))

    f1 = X12::Field.new({ :name => 'test1', :data_type => 'N', :min => 4, :max => 4, :var_name => 'segments_rendered' })
    f2 = X12::Field.new({ :name => 'test2', :data_type => 'N', :min => 4, :max => 4, :var_name => 'control_number' })
    l = X12::Loop.new({ :name => 'test', :min => 1, :max => 1 }, [ f1, f2 ] )

    l.segments_rendered = rand(1000)
    assert_equal("%04d" % l.segments_rendered, f1.render)
    assert_equal(l.segments_rendered, f1.parse(f1.render))

    l.control_number = rand(1000) + 2000
    assert_equal("%04d" % l.control_number,    f2.render)
    assert_equal(l.control_number,    f2.parse(f2.render))

    tmp = $-w  
    $-w = nil  # Temporarily suppress warnings
    Object.const_set :Date, Date2 # Restore the original Date class
    Object.send(:remove_const, :Date2)
    $-w = tmp
  end

  # "AN: Alphanumeric data elements containing the numerals 0-9, the characters A-Z and any
  # special characters except asterisk (*), the greater than sign (>) and the characters with a
  # hexadecimal value of '40' or less. These characters are control characters and should not be
  # used for data. The significant characters shall be left justified. Leading spaces, when they occur,
  # are presumed to be significant characters. Trailing spaces should be suppressed unless
  # necessary to satisfy the minimum length requirement."
  def test_field_string
    f = X12::Field.new({ :name => 'test', :data_type => 'AN', :min => 1, :max => 8 })
    f.content = nil
    assert_equal('', f.render)
    assert_equal('', f.parse(f.render))

    f = X12::Field.new({ :name => 'test', :data_type => 'AN', :min => 8, :max => 10 })
    f.content = 'test'
    assert_equal('test    ', f.render)
    assert_equal(f.content, f.parse(f.render))

    f = X12::Field.new({ :name => 'test', :data_type => 'AN', :min => 1, :max => 10 })
    f.content = '    test'
    assert_equal('    test', f.render)
    assert_equal(f.content, f.parse(f.render))
  end

  def test_field_validations
    f = X12::Field.new({ :name => 'test', :data_type => 'R', :min => 2, :max => 2 })
    f.content = 999
    assert_equal(false, f.valid?)
    assert_equal(5,     f.error_code)

    f = X12::Field.new({ :name => 'test', :data_type => 'R', :min => 4, :max => 4 })
    f.content = 0
    assert_equal(false, f.valid?)
    assert_equal(4,     f.error_code)

    t = X12::Table.new({:name => 'T123'}, { 'XY' => 'Valid Value' })
    f = X12::Field.new({ :name => 'test', :data_type => 'AN', :min => 2, :max => 2, :validation => 'T123'})
    f.validation_table = t

    f.content = 'XZ'
    assert_equal(false, f.valid?)
    assert_equal(7,     f.error_code)

    f.content = 'XY'
    assert_equal(true,  f.valid?)
    assert_equal(nil,   f.error_code)

    f = X12::Field.new({ :name => 'test', :data_type => 'AN', :min => 2, :max => 2, :required => true})
    f.content = nil
    assert_equal(false, f.valid?)
    assert_equal(1,     f.error_code)

    f.content = 'XY'
    assert_equal(true,  f.valid?)
    assert_equal(nil,   f.error_code)

    f.content = 'A#'
    assert_equal(false, f.valid?(false))
    assert_equal(6,     f.error_code)

  end

end # TestList
