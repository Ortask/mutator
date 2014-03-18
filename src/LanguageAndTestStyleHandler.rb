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

class LanguageAndTestStyleHandler

    def initialize( testSuiteToRun, debug=false, skipSourceFileCheck=true )
        @debug = debug
        @maxPositionInFile = "not yet available"
        @testSuiteToRun = testSuiteToRun
        @skipSourceFileCheck = skipSourceFileCheck
        @fileToMutateContentsOriginal = ""
        @sourceFileWithoutComments = "mutation.out"
        
        if @debug then
            puts "initialized with \n\n"
            puts "@maxPositionInFile=(#{@maxPositionInFile})\n\n"
            puts "@testSuiteToRun=(#{@testSuiteToRun})\n\n"
            puts "@skipSourceFileCheck=(#{@skipSourceFileCheck})\n\n"
        end
        
        post_initialize
    end

    
    def post_initialize
        raise "To be implemented by subclasses"
    end


    def setDebug( debug=false )
        @debug = debug
    end
    
    
    def isDebugEnabled?()
        return @debug
    end

    
    def getMaxPositionInFile
        return @maxPositionInFile
    end
    
    
    def getOriginalContentsOfFileToMutate
      return @fileToMutateContentsOriginal
    end


    def getLanguage
        raise "To be implemented by subclasses"
    end

    
    def getFileExtension
        raise "To be implemented by subclasses"
    end

    
    def getPathAndFileNameOfMutant( fileToMutate, suffixForMutatedSourceFile )
        raise "To be implemented by subclasses"
    end

    
    def getTestStyle
        raise "To be implemented by subclasses"
    end


    # 
    # Returns: a String with the stdout (+ stderr, if enabled) of running 
    # the test suite.
    # 
    def runTestSuite( redirectStderrToStdout=false )
        raise "To be implemented by subclasses"
    end
    
    
    def runCmd( cmd )
        stdin, stdout, stderr = Open3.popen3( cmd )
        begin
            stderrAsString = stderr.readlines.join
        rescue
            stderrAsString = ""
        end
        stdoutAsString = stdout.readlines.join
        stdin.close
        stderr.close
        stdout.close
        if @debug then
            p "stdout: '#{stdoutAsString}'"
            p "stderr: '#{stderrAsString}'"
        end

        return stdoutAsString, stderrAsString
    end


    def removeCommentsFromFileToMutate
        raise "To be implemented by subclasses"
    end

    
    def allTestsPassed?( testResults )
        raise "To be implemented by subclasses"
    end

    
    def extraMsgForFailingTestSuite( testResults )
        raise "To be implemented by subclasses"
    end

    
    def extraMsgForPreMutationAnalysisTestRun( testResults )
        raise "To be implemented by subclasses"
    end

    
    def ensureTestSuiteRunsWithoutFailures()
        redirectStderrToStdout = true
        output = runTestSuite( redirectStderrToStdout )

        if !allTestsPassed?( output ) then
            raise "\n\n#{__FILE__}::#{__method__}():#{__LINE__}: The test suite is failing. If the source to mutate '#{@baseNameOfFile}' is the original (non-mutant), "\
                  "then mutation testing will not be accurate.\n"\
                  "If the source to mutate is a mutant, then simply remove it and "\
                  "re-run this program.\n\n"\
                  "Here's the output of the test suite: (#{output})\n\n" + extraMsgForFailingTestSuite( output )
        else
            extraMsgForPreMutationAnalysisTestRun( output )
        end
        puts
    end
    
    
    def runPriorChecks( fileToMutate, suffixForMutatedSourceFile )
        @fileToMutate = fileToMutate
        @suffixForMutatedSourceFile = suffixForMutatedSourceFile
        @fullExtensionForMutatedSourceFile = @suffixForMutatedSourceFile + getFileExtension

        if not File.exists?( @fileToMutate ) then
            raise "#{__FILE__}::#{__method__}():#{__LINE__}: File not found: '#{@fileToMutate}'!"
        end
        @baseNameOfFile = File.basename( @fileToMutate )    # filename with extension
        @baseNameOfFileNoExtension = File.basename( @fileToMutate, getFileExtension() )    # takes away the given extension
        @pathToFile = File.dirname( @fileToMutate ) + "/"
        
        
        removeCommentsFromFileToMutate()
        
        if not File.exists?( @testSuiteToRun ) then
            raise "#{__FILE__}::#{__method__}():#{__LINE__}: Test suite not found: '#{@testSuiteToRun}'! \n\n" + testSuiteDoesNotExistMsg() 
        end

        #
        # It is important to revert all source files to their original 
        # version so that there's no cross-contamination from other sources 
        # using mutated versions by mistake.
        # That is, let's help the user remember to revert the references of
        # the to-be-mutated file to the non-mutated source files. Basically
        # we do not want a k-mutation spread over who knows how many files. 
        #
        offendingFiles = []
        Dir.foreach( @pathToFile ) { |entry|
            currentEntry = @pathToFile + entry
            if File.directory?( currentEntry ) then
                next
            end
            # 
            # Also skip any mutated version of source files
            # 
            if ( currentEntry =~ /.*#{@suffixForMutatedSourceFile}.*/ ) then
                next
            end
            
            if @debug then
              puts "Current entry to ensure that it is not using the mutated version of the source file = '#{currentEntry}'"
              puts "\t\tFile.directory?( #{currentEntry} ) = #{File.directory?( currentEntry )}"
            end

            contentsOfFile = File.read( currentEntry )
            if nil != ( contentsOfFile =~ /#{@suffixForMutatedSourceFile}/ ) then 
              offendingFiles << currentEntry
            end
        }
        if !offendingFiles.empty? && !@skipSourceFileCheck then
            raise "#{__FILE__}::#{__method__}():#{__LINE__}: These are the files " \
            "that still need to be reverted to their original versions:" \
            "" + offendingFiles.to_s + "" \
            "\n" \
            "Please revert these files to avoid cross-contamination and try again."
        end

        
        offendingFiles = []
        Dir.foreach( @pathToFile ) { |entry|
            currentEntry = @pathToFile + entry
            if File.directory?( currentEntry ) then
                next
            end

            if ( currentEntry =~ /.*#{@fullExtensionForMutatedSourceFile}.*/ ) then
                offendingFiles << currentEntry
            end

            if @debug then
                puts "Checking if current entry needs to be removed prior to starting mutation = '#{currentEntry}'"
            end
        }
        if !offendingFiles.empty? then
            puts "WARNING: These are the remaining mutated source files that " \
            "need to be removed prior to starting mutation analysis:"
            puts offendingFiles 
            puts
        end

        #
        # - Now run the test suite that is modified to use the mutant source 
        #   to verify that it is indeed using the right file:
        #
        @fileToMutateContentsOriginal = File.read( @sourceFileWithoutComments )
        @maxPositionInFile = @fileToMutateContentsOriginal.length
        #
        if @debug then
            puts "@maxPositionInFile = #{@maxPositionInFile}"
        end
        #
        puts "Running '#{@testSuiteToRun}' to verify that the test suite" \
             " is passing..."
        prepareTestSuiteForPreMutationAnalysisRun()
        ensureTestSuiteRunsWithoutFailures()     
        
        
        # 
        # TO DO: Figure out how to verify that the test suite is ultimately using
        # the mutated source file!
        # 


        post_runPriorChecks()
        
        puts "\n\nGood to go!\n\n"
    end

    
    def prepareTestSuiteForPreMutationAnalysisRun
        raise "To be implemented by subclasses"
    end

    
    def testSuiteDoesNotExistMsg
        raise "To be implemented by subclasses"
    end

    
    # 
    # Anything specific to run after pre-mutation analysis.
    # 
    def post_runPriorChecks
        raise "To be implemented by subclasses"
    end


    def wasMutantDOA?( testResults )
        raise "To be implemented by subclasses"
    end

    
    # 
    # Killing a mutant means that a test failed. 
    # So another way to see this method is by asking the 
    # question: Did a test fail?
    # 
    def wasMutantKilled?( testResults )
        raise "To be implemented by subclasses"
    end

    
    # 
    # Analyzes the results of running the test suite on a mutant.
    # Params:
    #   - A string containing the results of executing the test suite. 
    # 
    # Returns:
    #   - An *ordered* pair of values: mutantsKilled, deadOnArrival
    # 
    def analyzeTestRunResults( testResults )
        mutantsKilled = 0
        deadOnArrival = 0
        
        if wasMutantDOA?( testResults ) then
          # 
          # DOA's are caused by, say, syntax errors which do not allow the
          # test suite to run. Thus, they are NOT counted toward the mutation
          # score of the suite.
          # 
          deadOnArrival = 1
        else
          if wasMutantKilled?( testResults ) then
              mutantsKilled = 1
          end
        end
        
        return mutantsKilled, deadOnArrival
    end
end
