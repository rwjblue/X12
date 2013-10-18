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

class Test997Parse < Test::Unit::TestCase
  TEST_REPEAT = 100

  @@p = nil
#  @@parser = X12::Parser.new('misc/997single.xml')
  @@parser = X12::Parser.new('misc/997.xml')

  def setup
    unless @@p
      @@m997=<<-EOT
ST*997*2878~
AK1*HS*293328532~
AK2*270*307272179~
AK3*NM1*8*L10100*8~
AK4*0:0*66*1~
AK4*0:1*66*1~
AK4*0:2*66*1~
AK3*NM1*8*L10101*8~
AK4*1:0*66*1~
AK4*1:1*66*1~
AK3*NM1*8*L10102*8~
AK4*2:0*66*1~
AK5*R*5~
AK9*R*1*1*0~
SE*15*2878~
EOT

# This should parse into 
# 997 [0]: ST*997*2878~AK1*HS*293328532~A...AK5*R*5~AK9*R*1*1*0~SE*8*2878~
#   ST [0]: ST*997*2878~
#   AK1 [0]: AK1*HS*293328532~
#   L1000 [0]: AK2*270*307272179~AK3*NM1*8*L1...1010_2*8~AK4*2:0*66*1~AK5*R*5~
#     AK2 [0]: AK2*270*307272179~
#     L1010 [0]: AK3*NM1*8*L1010_0*8~AK4*0:0*66*1~AK4*0:1*66*1~AK4*0:2*66*1~
#       AK3 [0]: AK3*NM1*8*L1010_0*8~
#       AK4 [0]: AK4*0:0*66*1~
#       AK4 [1]: AK4*0:1*66*1~
#       AK4 [2]: AK4*0:2*66*1~
#     L1010 [1]: AK3*NM1*8*L1010_1*8~AK4*1:0*66*1~AK4*1:1*66*1~
#       AK3 [0]: AK3*NM1*8*L1010_1*8~
#       AK4 [0]: AK4*1:0*66*1~
#       AK4 [1]: AK4*1:1*66*1~
#     L1010 [2]: AK3*NM1*8*L1010_2*8~AK4*2:0*66*1~
#       AK3 [0]: AK3*NM1*8*L1010_2*8~
#       AK4 [0]: AK4*2:0*66*1~
#     AK5 [0]: AK5*R*5~
#   AK9 [0]: AK9*R*1*1*0~
#   SE [0]: SE*8*2878~

      @@m997.gsub!(/\n/,'')

      @@p = @@parser.parse('997', @@m997)
    end
    @r = @@p
  end # setup

  def teardown
    # Nothing
  end # teardown

  def test_ST
    assert_equal('ST*997*2878~', @r.ST.to_s)
    assert_equal('997', @r.ST.TransactionSetIdentifierCode)
  end # test_ST

  def test_AK1
    assert_equal(293328532, @r.AK1.GroupControlNumber)
  end # test_AK1

  def test_AK2
    assert_equal('270', @r.L1000.AK2.TransactionSetIdentifierCode)
  end # test_AK2

  def test_L1010
    assert_match(/L10100/, @r.L1000.L1010.to_s)
    assert_equal(3, @r.L1000.L1010.to_a.size)
    assert_equal(3, @r.L1000.L1010.size)
    assert_match(/L10102/, @r.L1000.L1010.to_a[2].to_s)
    assert_match(/L10102/, @r.L1000.L1010[2].to_s)
  end # test_L1010

  def test_AK4
    assert_equal('AK4*1:0*66*1~', @r.L1000.L1010.to_a[1].AK4.to_s)
    assert_equal('AK4*1:0*66*1~', @r.L1000.L1010[1].AK4.to_s)
    assert_equal(3, @r.L1000.L1010.AK4.to_a.size)
    assert_equal(3, @r.L1000.L1010.AK4.size)
    assert_equal(2, @r.L1000.L1010.to_a[1].AK4.to_a.size)
    assert_equal(2, @r.L1000.L1010[1].AK4.size)
    assert_equal('AK4*1:1*66*1~', @r.L1000.L1010.to_a[1].AK4.to_a[1].to_s)
    assert_equal('AK4*1:1*66*1~', @r.L1000.L1010[1].AK4[1].to_s)
    assert_equal(66, @r.L1000.L1010.AK4.DataElementReferenceNumber)
  end # test_AK4

  def test_absent
    assert_nil(@r.L1000.AK8)
    assert_nil(@r.L1000.L1111)
    assert_nil(@r.L1000.L1010[-99])
    assert_nil(@r.L1000.L1010[99])
  end # test_absent

  def test_validity
    assert_equal(true, @r.valid?)
  end

  def test_segment_counter
    assert_equal(15, @r.segments_parsed)
    assert_equal(11, @r.L1000.segments_parsed)
    assert_equal(4, @r.L1000.L1010.segments_parsed)
    assert_equal(9, @r.L1000.L1010.segments_parsed(:include_repeats))
  end

  def test_field_accessor
    assert_equal('997', @r.ST.find_field('TransactionSetIdentifierCode').content)
    assert_equal('997', @r.ST.find_field('01').content)
    assert_equal('997', @r.ST.find_field('ST01').content)
    assert_nil(@r.ST.find_field('should not find'))
  end

  def test_segment_enumerator
    @r.enumerate_segments
    assert_equal(1, @r.ST.segment_position)
    assert_equal(2, @r.AK1.segment_position)
    assert_equal(3, @r.L1000.AK2.segment_position)
    assert_equal(4, @r.L1000.L1010.AK3.segment_position)
    assert_equal(5, @r.L1000.L1010.AK4[0].segment_position)
    assert_equal(6, @r.L1000.L1010.AK4[1].segment_position)
    assert_equal(7, @r.L1000.L1010.AK4[2].segment_position)
    assert_equal(8, @r.L1000.L1010[1].AK3.segment_position)
    assert_equal(9, @r.L1000.L1010[1].AK4[0].segment_position)
    assert_equal(10, @r.L1000.L1010[1].AK4[1].segment_position)
    assert_equal(11, @r.L1000.L1010[2].AK3.segment_position)
    assert_equal(12, @r.L1000.L1010[2].AK4.segment_position)
    assert_equal(13, @r.L1000.AK5.segment_position)
    assert_equal(14, @r.AK9.segment_position)
    assert_equal(15, @r.SE.segment_position)
  end

  def test_timing
    start = Time::now
    TEST_REPEAT.times do
      @r = @@parser.parse('997', @@m997)
      test_ST
      test_AK1
      test_AK2
      test_AK4
      test_L1010
      test_absent
    end
    finish = Time::now
    puts sprintf("Parses per second, 997: %.2f, elapsed: %.1f", TEST_REPEAT.to_f/(finish - start), finish - start)
  end # test_timing

end # TestList
