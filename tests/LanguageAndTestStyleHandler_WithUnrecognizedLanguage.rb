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

class LanguageAndTestStyleHandler_WithUnrecognizedLanguage < LanguageAndTestStyleHandler

    def initialize( testSuiteToRun, debug=false )
        @debug = debug
        if @debug then
            puts "#{__FILE__}.#{__method__}:#{__LINE__}: initialized mock language handler with @debug = '#{@debug}'"
        end
    end


    def getLanguage
        if @debug then
            puts "#{__FILE__}.#{__method__}:#{__LINE__}"
        end
        return "mock!"
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
    
        if not File.exists?( fileToMutate ) then
            raise "#{__FILE__}.#{__method__}:#{__LINE__}: File not found: '#{fileToMutate}'!"
        end


        #
        # Prep the file for analysis:
        #
        if not File.exists?( "commentRemover.rb" ) then
            raise "#{__FILE__}.#{__method__}:#{__LINE__}: commentRemover.rb was not found. This is needed to remove comments from source files."
        end
        stdoutAsString, stderrAsString = runCmd( "ruby -w -W commentRemover.rb \"#{fileToMutate}\" \"#{getLanguage()}\" mutation.out" )
        # puts "\n\nstdoutAsString = '#{stdoutAsString}'\n\n"
        # puts "\n\nstderrAsString = '#{stderrAsString}'\n\n"
        if !stderrAsString.empty? or !stdoutAsString.empty? then
            raise "#{__FILE__}.#{__method__}:#{__LINE__}: There was an error when running 'commentRemover.rb'!\n\nstdoutAsString = '#{stdoutAsString}'\n\nstderrAsString = '#{stderrAsString}'"
        end

    end

end

