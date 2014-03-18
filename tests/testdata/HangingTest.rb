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

class HangingTest < Test::Unit::TestCase

    @secondsForHang = 40 # secs

    def HangingTest.getSecondsForHang
        return @secondsForHang
    end
    
    def HangingTest.setSecondsForHang( seconds )
        @secondsForHang = seconds
    end
    
    def testAppearsToHang_NoSleep
        elapsedSeconds = 0.0
        timeoutStart = Time.now
        while elapsedSeconds < HangingTest.getSecondsForHang
            elapsedSeconds = Time.now - timeoutStart
        end
        assert true
    end

end # class 
