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

require File.join(File.dirname(__FILE__), 'LanguageAndTestStyleHandler_RUBY')

class LanguageAndTestStyleHandler_RUBY_TESTUNIT < LanguageAndTestStyleHandler_RUBY

    def getTestStyle
        return "test/unit"
    end

    
    def post_initialize
      @testRunner = "ruby"
    end


    def post_runPriorChecks
        contentsOfTestSuiteForMutant = File.read( @testSuiteToRun )
        if nil == ( contentsOfTestSuiteForMutant =~ /#{@suffixForMutatedSourceFile}/ ) then 
            puts
            raise "#{__FILE__}::#{__method__}():#{__LINE__}: Error in '#{@testSuiteToRun}': the file is not using the mutated version! \n\n"\
            "Please change its \"require's\" from:\n\t require '#{@baseNameOfFileNoExtension}'\n"\
            " to \n\t require '#{@baseNameOfFileNoExtension + getFileExtension() + @suffixForMutatedSourceFile}'"
        end
        super
    end

end
