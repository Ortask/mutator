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

require File.join(File.dirname(__FILE__), 'LanguageAndTestStyleHandler')

class LanguageAndTestStyleHandler_RUBY < LanguageAndTestStyleHandler
    
    def getLanguage()
        return "ruby"
    end

    
    def getFileExtension()
        return ".rb"
    end

    
    def getPathAndFileNameOfMutant( fileToMutate, suffixForMutatedSourceFile )
        return File.dirname( fileToMutate ) + "/" + File.basename( fileToMutate ) + suffixForMutatedSourceFile + getFileExtension()
    end

    
    
    def testSuiteDoesNotExistMsg
        return "Please create a test suite called '#{@testSuiteToRun}' and "\
            "modify its \"require's\" from:\n\t require '#{@baseNameOfFileNoExtension}'\n"\
            " to \n\t require '#{@baseNameOfFileNoExtension + getFileExtension() + @suffixForMutatedSourceFile}'"
    end

    
    def removeCommentsFromFileToMutate
        #
        # Prep the file for analysis: remove all comments.
        #
        if not File.exists?( "commentRemover.rb" ) then
            raise "#{__FILE__}::#{__method__}():#{__LINE__}: commentRemover.rb was not found. This is needed to remove comments from source files."
        end
        stdoutAsString, stderrAsString = runCmd( "ruby -w -W commentRemover.rb \"#{@fileToMutate}\" \"#{getLanguage()}\" #{@sourceFileWithoutComments}" )
        if @debug then
            puts "\n\nstdoutAsString = (#{stdoutAsString})\n\n"
            puts "\n\nstderrAsString = (#{stderrAsString})\n\n"
        end
        if !stderrAsString.empty? or !stdoutAsString.empty? then
            raise "#{__FILE__}::#{__method__}():#{__LINE__}: There was an error when running 'commentRemover.rb'!\n\nstdoutAsString = (#{stdoutAsString})\n\nstderrAsString = (#{stderrAsString})"
        end
    end

    
    def allTestsPassed?( testResults )
        return !( wasMutantKilled?( testResults ) || 
                  testResults.include?( "syntax error" ) || 
                  testResults.include?( "(LoadError)" )    ||
                  testResults.include?( "(SyntaxError)" )    ||
                  testResults.include?( "(RuntimeError)" ) 
                )
    end

    
    def extraMsgForFailingTestSuite( testResults )
        msg = "Using 'require_relative' to load required modules might help here."
        return msg
    end
    

    def extraMsgForPreMutationAnalysisTestRun( testResults )
        msg = ""
        if ( testResults.include?( "warning: previous definition" ) || 
             testResults.include?( "warning: method redefined" ) 
           ) then
            msg << "\n\n" \
            "There might be source files out there that are not using the " \
            "mutated version of the given file. Please ensure that all the source" \
            " files are using the mutated version with the "\
            "#{@suffixForMutatedSourceFile} infix." 
        end
        return msg
    end


    def prepareTestSuiteForPreMutationAnalysisRun
        File.open(@fileToMutate + @fullExtensionForMutatedSourceFile, 'w') {|f| f.write( @fileToMutateContentsOriginal ) }
    end
    
    
    def post_runPriorChecks
        nil
    end
    
    
    def runTestSuite( redirectStderrToStdout=false )
        output = ""
        if @debug then
            output << "\n\n#{__FILE__}::#{__method__}():#{__LINE__}: Now running test suite '#{@testSuiteToRun}'\n\n"
            puts output
        end
        
        redirectionStr = ""
        if redirectStderrToStdout then
            redirectionStr = " 2>&1"
        end
        
        cmd = "#{@testRunner} #{@testSuiteToRun} #{redirectionStr}"
        if @debug then
            puts "\n\n#{__FILE__}::#{__method__}():#{__LINE__}: Running (#{cmd})\n\n"
        end
        output << `#{cmd}`
        return output
    end


    def wasMutantDOA?( testResults )
        return '' == testResults
    end

    
    def wasMutantKilled?( testResults )
        return ( testResults.include?( "Failure:" ) || testResults.include?( "Error:" ) )
    end

end
