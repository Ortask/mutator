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

require_relative './LanguageAndTestStyleHandler'

class LanguageAndTestStyleHandler_MockEmpty < LanguageAndTestStyleHandler

    def initialize( testSuiteToRun, debug=false )
        @debug = debug
        if @debug then
            puts "#{__FILE__}.#{__method__}:#{__LINE__}: initialized mock language handler with @debug = '#{@debug}'"
        end
    end

    
    def getFileExtension()
        return ".mock"
    end

    
    def getPathAndFileNameOfMutant( fileToMutate, suffixForMutatedSourceFile )
        return "lalala"
    end

    
    def setDebug( debug=false )
        if @debug then
            puts "#{__FILE__}.#{__method__}:#{__LINE__}: will set @debug to '#{debug}' "
        end
        @debug = debug
    end
    
    def isDebugEnabled?()
        return @debug
    end
    
    def getMaxPositionInFile
        if @debug then
            puts "#{__FILE__}.#{__method__}:#{__LINE__}"
        end
        return 1
    end

    def getOriginalContentsOfFileToMutate
        if @debug then
            puts "#{__FILE__}.#{__method__}:#{__LINE__}"
        end
        return "nil"
    end
    
    def runPriorChecks( fileToMutate, suffixForMutatedSourceFile )
        if @debug then
            puts "#{__FILE__}.#{__method__}:#{__LINE__}"
        end
    end

    def analyzeTestRunResults( testResults )
        if @debug then
            puts "#{__FILE__}.#{__method__}:#{__LINE__}"
        end
        return 0, 0
    end

end

