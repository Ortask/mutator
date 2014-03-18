#
# Copyright (c) 2014 "Ortask"
# Mutator [http://ortask.com/mutator]
#
# This file is part of Mutator.
#
# Mutator is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#

require 'test/unit'

require_relative './SourceFile_NoComments.rb_mutated'

class SleepingTest < Test::Unit::TestCase

    @secondsForSleep = 40 # secs

    def SleepingTest.getSecondsForSleep
        return @secondsForSleep
    end
    
    def SleepingTest.setSecondsForSleep( seconds )
        @secondsForSleep = seconds
    end    
        
    def testAppearsToHang_GoesToSleep
        sleep SleepingTest.getSecondsForSleep
    end
    
end # class 
