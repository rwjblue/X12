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

class Test270FactoryInterchange < Test::Unit::TestCase
  TEST_REPEAT = 100

  @@p = nil
@@result=<<-EOT
ISA*03*user      *01*password  *ZZ*0000000Eliginet*ZZ*CHICAGO BLUES*070724*1726*U*00401*230623206*0*T*:~
GS*HS*0000000Eliginet*CHICAGO BLUES*20070724*1726*0*X*004010X092A1~
ST*270*0000~
BHT*0022*13*LNKJNFGRWDLR*20070724*1726~
HL*1**20*1~
NM1*PR*2*RED CROSS*****PI*CHICAGO BLUES~
HL*2*1*21*1~
NM1*1P*1******SV*daw~
HL*3*2*22*0~
NM1*IL*1*LastName*FirstName~
DMG*D8*19700725~
DTP*307*D8*20070724~
EQ*60~
SE*12*0000~
ST*270*0001~
BHT*0022*13*LNKJNFGRWDLR*20070724*1726~
HL*1**20*1~
NM1*PR*2*RED CROSS*****PI*CHICAGO BLUES~
HL*2*1*21*1~
NM1*1P*1******SV*daw~
HL*3*2*22*0~
NM1*IL*1*LastName*FirstName~
DMG*D8*19700725~
DTP*307*D8*20070724~
EQ*60~
SE*12*0001~
ST*270*0002~
BHT*0022*13*LNKJNFGRWDLR*20070724*1726~
HL*1**20*1~
NM1*PR*2*RED CROSS*****PI*CHICAGO BLUES~
HL*2*1*21*1~
NM1*1P*1******SV*daw~
HL*3*2*22*0~
NM1*IL*1*LastName*FirstName~
DMG*D8*19700725~
DTP*307*D8*20070724~
EQ*60~
SE*12*0002~
GE*3*0~
GS*HS*0000000Eliginet*CHICAGO BLUES*20070724*1726*1*X*004010X092A1~
ST*270*1000~
BHT*0022*13*LNKJNFGRWDLR*20070724*1726~
HL*1**20*1~
NM1*PR*2*RED CROSS*****PI*CHICAGO BLUES~
HL*2*1*21*1~
NM1*1P*1******SV*daw~
HL*3*2*22*0~
NM1*IL*1*LastName*FirstName~
DMG*D8*19700725~
DTP*307*D8*20070724~
EQ*60~
SE*12*1000~
ST*270*1001~
BHT*0022*13*LNKJNFGRWDLR*20070724*1726~
HL*1**20*1~
NM1*PR*2*RED CROSS*****PI*CHICAGO BLUES~
HL*2*1*21*1~
NM1*1P*1******SV*daw~
HL*3*2*22*0~
NM1*IL*1*LastName*FirstName~
DMG*D8*19700725~
DTP*307*D8*20070724~
EQ*60~
SE*12*1001~
GE*2*1~
GS*HS*0000000Eliginet*CHICAGO BLUES*20070724*1726*2*X*004010X092A1~
ST*270*2000~
BHT*0022*13*LNKJNFGRWDLR*20070724*1726~
HL*1**20*1~
NM1*PR*2*RED CROSS*****PI*CHICAGO BLUES~
HL*2*1*21*1~
NM1*1P*1******SV*daw~
HL*3*2*22*0~
NM1*IL*1*LastName*FirstName~
DMG*D8*19700725~
DTP*307*D8*20070724~
EQ*60~
SE*12*2000~
GE*1*2~
IEA*3*230623206~
EOT

  @@result.gsub!(/\n/,'')

  def setup
    unless @@p
      @@p = X12::Parser.new('misc/270interchange.xml')
    end
  end # setup

  def teardown
    # Nothing
  end # teardown

  def create_270(message, fg_num, mess_num)
    message.control_number = "#{fg_num}00#{mess_num}"

    message.BHT {|bht|
      bht.HierarchicalStructureCode='0022'
      bht.TransactionSetPurposeCode='13'
      bht.ReferenceIdentification='LNKJNFGRWDLR'
      bht.Date = Date.new(2007, 07, 24)
      bht.Time = Time.new(0, nil, nil, 17, 26)
    }

    message.L2000A {|l2000A|
      l2000A.HL{|hl|
        hl.HierarchicalIdNumber='1'
        hl.HierarchicalParentIdNumber=''
        hl.HierarchicalChildCode='1'
      }

      l2000A.L2100A {|l2100A|
        l2100A.NM1 {|nm1|
          nm1.EntityIdentifierCode1='PR'
          nm1.EntityTypeQualifier='2'
          nm1.NameLastOrOrganizationName='RED CROSS'
          nm1.IdentificationCodeQualifier='PI'
          nm1.IdentificationCode='CHICAGO BLUES'
        }
      }
    }

    message.L2000B {|l2000B|
      l2000B.HL{|hl|
        hl.HierarchicalIdNumber='2'
        hl.HierarchicalParentIdNumber='1'
        hl.HierarchicalChildCode='1'
      }
      
      l2000B.L2100B {|l2100B|
        l2100B.NM1 {|nm1|
          nm1.EntityIdentifierCode1='1P'
          nm1.EntityTypeQualifier='1'
          nm1.NameLastOrOrganizationName=''
          nm1.IdentificationCodeQualifier='SV'
          nm1.IdentificationCode='daw'
        }
      }
    }

    message.L2000C {|l2000C|
      l2000C.HL{|hl|
        hl.HierarchicalIdNumber='3'
        hl.HierarchicalParentIdNumber='2'
        hl.HierarchicalChildCode='0'
      }

      l2000C.L2100C {|l2100C|
        l2100C.NM1 {|nm1|
          nm1.EntityIdentifierCode1='IL'
          nm1.EntityTypeQualifier='1'
          nm1.NameLastOrOrganizationName='LastName'
          nm1.NameFirst='FirstName'
        }

        l2100C.DMG {|dmg|
          dmg.DateTimePeriodFormatQualifier='D8'
          dmg.DateTimePeriod='19700725'
        }

        l2100C.DTP {|dtp|
          dtp.DateTimeQualifier='307'
          dtp.DateTimePeriodFormatQualifier='D8'
          dtp.DateTimePeriod='20070724'
        }

        l2100C.L2110C {|l2110C|
          l2110C.EQ {|eq|
            eq.ServiceTypeCode='60'
          }
        }
      }
    }

  end # create_270

  def create_fg(message, fg_num, num_of_270)
    message.control_number = fg_num

    message.GS { |gs|
      gs.FunctionalIdentifierCode = 'HS'
      gs.ApplicationSendersCode = '0000000Eliginet'
      gs.ApplicationReceiversCode = 'CHICAGO BLUES'
      gs.Date = Date.new(2007, 07, 24)
      gs.Time = Time.new(0, nil, nil, 17, 26)
      gs.ResponsibleAgencyCode = 'X'
      gs.VersionReleaseIndustryIdentifierCode = '004010X092A1'
    }

    num_of_270.times { |count|
      create_270(message._270.repeat, fg_num, count)
    }

    message.GE { |ge|
      ge.NumberOfTransactionSetsIncluded = num_of_270
    }
  end # create_fg
  
  def test_all
    Object.const_set :Date2, Date.dup # Save the original Date & Time classes
    Object.const_set :Time2, Time.dup
    def Date.today ; Date.new(2007, 07, 24)        ; end # Define dummy method for testing
    def Time.now   ; Time.new(0, nil, nil, 17, 26) ; end # Define dummy method for testing

    begin
      @r = @@p.factory('270interchange')
      @r.control_number = 230623206
      @r.ISA {|isa|
        isa.AuthorizationInformationQualifier = '03'
        isa.AuthorizationInformation = 'user      '
        isa.SecurityInformationQualifier = '01'
        isa.SecurityInformation = 'password  '
        isa.InterchangeIdQualifier1 = 'ZZ'
        isa.InterchangeSenderId = '0000000Eliginet'
        isa.InterchangeIdQualifier2 = 'ZZ'
        isa.InterchangeReceiverId = 'CHICAGO BLUES'
        isa.InterchangeControlStandardsIdentifier = 'U'
        isa.InterchangeControlVersionNumber = '00401'
        isa.AcknowledgmentRequested = '0'
        isa.UsageIndicator = 'T'
        isa.ComponentElementSeparator = ':'
      }

      fg_counter = 0
      @r.FG.repeat {|fg|
        create_fg(fg, fg_counter, 3)
        fg_counter += 1
      }

      @r.FG.repeat {|fg|
        create_fg(fg, fg_counter, 2)
        fg_counter += 1
      }

      @r.FG.repeat {|fg|
        create_fg(fg, fg_counter, 1)
        fg_counter += 1
      }

      @r.IEA {|iea|
        iea.NumberOfIncludedFunctionalGroups = fg_counter
      }

      assert_equal(@@result, @r.render)
    ensure 
      tmp = $-w  
      $-w = nil  # Temporarily suppress warnings
      Object.const_set :Date, Date2 # Restore the original Date & Time classes
      Object.send(:remove_const, :Date2)
      Object.const_set :Time, Time2
      Object.send(:remove_const, :Time2)
      $-w = tmp
    end
  end # test_all

  def test_timing
    start = Time::now
    TEST_REPEAT.times do
      test_all
    end
    finish = Time::now
    puts sprintf("Factories per second, 270interchange: %.2f, elapsed: %.1f", TEST_REPEAT.to_f/(finish-start), finish-start)
  end # test_timing

end # TestList
