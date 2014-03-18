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

require 'date'
require 'optparse'
require 'pathname'
require 'open3'
require File.join(File.dirname(__FILE__), 'MutatorOptions')
include MutatorOptions

# 
# Flush the output as soon as possible.
# 
STDOUT.sync = true
STDERR.sync = true

class Mutator
    
    @@secondsBeforeTimeout = 30 
    TIMEOUT_ERROR_STR = "Timeout!"


    def initialize( fileToMutate, testSuiteToRun, numberOfRuns = MutatorOptions.getDefaultRuns, mutationOrder = MutatorOptions.getDefaultMutationOrder, language = MutatorOptions.getDefaultLanguageHandler( testSuiteToRun ), debug = false, runUntilLiveMutantIsFound=false )
        if !language.is_a?( LanguageAndTestStyleHandler ) then
            raise "#{__FILE__}::#{__method__}():#{__LINE__}: The language/style handler must be of type 'LanguageAndTestStyleHandler' but was of type '#{language.class}': '#{language}'."
        end
        if numberOfRuns < 0 then
            raise "#{__FILE__}::#{__method__}():#{__LINE__}: The number of runs must be non-negative but was '#{numberOfRuns}'."
        end
        if mutationOrder < 0 then
            raise "#{__FILE__}::#{__method__}():#{__LINE__}: The mutation order must be non-negative but was '#{mutationOrder}'."
        end

        @debug = debug
        @fileToMutate = fileToMutate
        @testSuiteToRun = testSuiteToRun
        @numberOfRuns = numberOfRuns
        @runUntilLiveMutantIsFound = runUntilLiveMutantIsFound
        if @runUntilLiveMutantIsFound then
            @numberOfRuns = 10000
        end
        @mutationOrder = mutationOrder
        @languageAndTestStyleHandler = language
        @languageAndTestStyleHandler.setDebug( @debug || @languageAndTestStyleHandler.isDebugEnabled? )
        @fileToMutateContentsOriginal = ""
        @testSuiteForMutant = @testSuiteToRun
        @runsExecuted = 0
        @runtimeSeconds = -100
        @mutationWindow = 12 # characters in each mutation window
        @testResults = "No results yet."
        
        if @debug then
            puts "#{__FILE__}::#{__method__}():#{__LINE__}: testSuiteToRun = '#{testSuiteToRun}'"
            puts "#{__FILE__}::#{__method__}():#{__LINE__}: @testSuiteForMutant = '#{@testSuiteForMutant}'"
            puts "#{__FILE__}::#{__method__}():#{__LINE__}: @runUntilLiveMutantIsFound = '#{@runUntilLiveMutantIsFound}'"
        end
    end

    def getVersion
        return VERSION
    end

    def Mutator.getSecondsBeforeTimeout
        return @@secondsBeforeTimeout
    end
    
    def Mutator.setSecondsBeforeTimeout( seconds )
        @@secondsBeforeTimeout = seconds
    end


    def Mutator.getSuffixForMutatedSourceFile()
        return "_mutated"
    end
    

    def getRunsExecuted()
        return @runsExecuted
    end


    def getRuntimeSeconds()
        return @runtimeSeconds
    end

    
    def getMutationScore()
        return @mutationScore
    end

    
    def getMutantsKilled()
        return @mutantsKilledThusFar
    end

    
    def getMutantsAlive()
        return @mutantsAlive
    end

    
    def getMutantsDOA()
        return @deadOnArrivalThusFar
    end


    # 
    # This method determines if the current mutation is on the same place as we mutated before. 
    # If it is, then it returns true as we do not want to mutate the same place more than once.
    # Otherwise, returns false.
    # 
    def rejectMutation?( originalSectionOfFileToMutate, sectionOfFileToMutate, positionInFileOfCurrentMutationWindow )
        rejectMutation = false
        originalSectionOfFileToMutateCharArray = originalSectionOfFileToMutate.split(//)
        sectionOfFileToMutateCharArray = sectionOfFileToMutate.split(//)
        positionOfMutationInFile = nil

        if @debug then
            puts "#{__FILE__}::#{__method__}():#{__LINE__}: Size of original section: '#{originalSectionOfFileToMutate.size}'"
            puts "#{__FILE__}::#{__method__}():#{__LINE__}: Size of modified section: '#{sectionOfFileToMutate.size}'"
        end
        
        # 
        # Find the exact position of the mutation.
        # 
        0.upto( (originalSectionOfFileToMutateCharArray.size) - 1 ) do |idxOfMutation|
            if @debug then
                puts "#{__FILE__}::#{__method__}():#{__LINE__}: Now inspecting index '#{idxOfMutation}'"
                puts "#{__FILE__}::#{__method__}():#{__LINE__}: originalSectionOfFileToMutateCharArray[idxOfMutation] = '#{originalSectionOfFileToMutateCharArray[idxOfMutation]}'"
                puts "#{__FILE__}::#{__method__}():#{__LINE__}: sectionOfFileToMutateCharArray[idxOfMutation] = '#{sectionOfFileToMutateCharArray[idxOfMutation]}'"
                puts "#{__FILE__}::#{__method__}():#{__LINE__}: If NOT equal, then the absolute location of the mutation in the file will be idxOfMutation + positionInFileOfCurrentMutationWindow = '#{idxOfMutation + positionInFileOfCurrentMutationWindow}'"
            end
            
            if originalSectionOfFileToMutateCharArray[idxOfMutation] != sectionOfFileToMutateCharArray[idxOfMutation] then
                positionOfMutationInFile = idxOfMutation + positionInFileOfCurrentMutationWindow
                
                if @debug then
                    puts "#{__FILE__}::#{__method__}():#{__LINE__}: Detected a difference at index '#{idxOfMutation}'."
                    puts "#{__FILE__}::#{__method__}():#{__LINE__}: positionOfMutationInFile = '#{positionOfMutationInFile}'."
                end

                break;
            end
        end
        
        if @debug then
            puts "#{__FILE__}::#{__method__}():#{__LINE__}: About to determine if position '#{positionOfMutationInFile}' has been mutated before..."
        end
        
        # 
        # Now determine if that position has been mutated before.
        # 
        if true == @positionsOfPreviousMutationsHash[positionOfMutationInFile] then 
            # 
            # Reject the mutation.
            # 
            rejectMutation = true
            
            if @debug then
                puts "#{__FILE__}::#{__method__}():#{__LINE__}: Rejecting mutation at position '#{positionOfMutationInFile}'"
                puts "#{__FILE__}::#{__method__}():#{__LINE__}: Found position '#{positionOfMutationInFile}' already mutated."
                puts "#{__FILE__}::#{__method__}():#{__LINE__}: Rejected mutation = (#{sectionOfFileToMutate})"
            end
        else
            # 
            # Record the position of the mutation so that other mutations are not
            # in the same place.
            # 
            
            if @debug then
                puts "#{__FILE__}::#{__method__}():#{__LINE__}: positionOfMutationInFile = '#{positionOfMutationInFile}'."
            end
            
            if nil == positionOfMutationInFile then
                abort "#{__FILE__}::#{__method__}():#{__LINE__}: positionOfMutationInFile was '#{positionOfMutationInFile}' but it should have been a non-negative integer!"
            end
            
            @positionsOfPreviousMutationsHash[positionOfMutationInFile] = true
        end
        
        return rejectMutation
    end

    
    def mutate( contentsToMutate, mutationWindow, mutationsToGo )
    
        if @debug then
          puts "#{__FILE__}::#{__method__}():#{__LINE__}: contentsToMutate=(#{contentsToMutate})\n\nmutationWindow=(#{mutationWindow})\n\nmutationsToGo=(#{mutationsToGo})\n"
        end
    
        begin
            fileToMutateContents = contentsToMutate.dup
        rescue
            exceptionRaised = $!
            raise "#{__FILE__}::#{__method__}():#{__LINE__}: #{exceptionRaised}"
        end

        # 
        # This hash contains the locations of the mutations applied thus far. 
        # This is used to prevent other mutations being applied in the same
        # spot and, thus, reverting previous mutations.
        # 
        @positionsOfPreviousMutationsHash = {}
        
        while mutationsToGo > 0
            countTries = 0    
            notYetMutated = true    # true simply to get it into the loop. 
            while notYetMutated
                # 
                # Make sure we distribute the mutations across the entire file
                # 
                randomNumber = Random.new
                begin
                    positionInFile = randomNumber.rand(0.0..(@languageAndTestStyleHandler.getMaxPositionInFile)).to_i
                rescue
                    exceptionRaised = $!
                    raise "#{__FILE__}::#{__method__}():#{__LINE__}: #{exceptionRaised}"
                end
                

                sectionOfFileToMutate = fileToMutateContents.slice(positionInFile, mutationWindow).dup
                originalSectionOfFileToMutate = sectionOfFileToMutate.dup
                if @debug then
                  puts "#{__FILE__}::#{__method__}():#{__LINE__}: Current section to modify: position '#{positionInFile}': '#{sectionOfFileToMutate}'"
                end
                
                notYetMutated = false   # now that it's in the loop, it's correctly set. 
                                        # Assume we will get a mutation. If we do not get
                                        # a mutation, then it will be reset below anyway.
                case sectionOfFileToMutate
                when /\s*nil\s*/
                    # puts "matched '#{$&}'"
                    sectionOfFileToMutate.sub!(/nil/, '"1"')
                when /\s*<=\s*/
                    # puts "matched '#{$&}'"
                    sectionOfFileToMutate.sub!(/<=/, '> ')
                when /\s*>=\s*/
                    # puts "matched '#{$&}'"
                    sectionOfFileToMutate.sub!(/>=/, '< ')
                when /\s*"(.+)"\s*/
                    # puts "matched '#{$1}'"
                    maxLength = $1.size
                    idx = 0
                    mutatedString = ""
                    randomNumber = Random.new
                    while idx < maxLength 
                        mutatedString = mutatedString + randomNumber.rand(0.0..9).to_i.to_s
                        idx = idx + 1
                    end
                    sectionOfFileToMutate.sub!(/".+"/, "\"#{mutatedString}\"")
                    # puts "sectionOfFileToMutate = '#{sectionOfFileToMutate}'"
                    # puts "mutatedString = '#{mutatedString}'"
                when /\s+or\s+/
                    # puts "matched '#{$&}'"
                    sectionOfFileToMutate.sub!(/\s+or\s+/, ' and ')
                when /\s+and\s+/
                    # puts "matched '#{$&}'"
                    sectionOfFileToMutate.sub!(/\s+and\s+/, ' or ')
                when /\s+\|\|\s+/
                    # puts "matched '#{$&}'"
                    sectionOfFileToMutate.sub!(/\|\|/, '&&')
                when /\s+\&\&\s+/
                    # puts "matched '#{$&}'"
                    sectionOfFileToMutate.sub!(/\&\&/, "||")
                when /\s+==\s+/
                    # puts "matched '#{$&}'"
                    sectionOfFileToMutate.sub!(/==/, '!=')
                when /\s+!=\s+/
                    # puts "matched '#{$&}'"
                    sectionOfFileToMutate.sub!(/!=/, '==')
                when /[0-9]+/
                    # puts "matched '#{$&}'"
                    matchedNumber = $&
                    maxLength = $&.size
                    mutatedNumber = ""
                    loop do
                        idx = 0
                        mutatedNumber = ""  # start over (if we got the same string)
                        randomNumber = Random.new
                        while idx < maxLength 
                            mutatedNumber = mutatedNumber + randomNumber.rand(0.0..9).to_i.to_s
                            idx = idx + 1
                        end
                        # 
                        # Prevent mutations from applying the same string.
                        # 
                        break if mutatedNumber != matchedNumber
                    end
                    sectionOfFileToMutate.sub!(/[0-9]+/, mutatedNumber )
                    # puts "sectionOfFileToMutate = '#{sectionOfFileToMutate}'"
                    # puts "mutatedNumber = '#{mutatedNumber}'"
                when /\s*true\s*/
                    # puts "matched '#{$&}'"
                    sectionOfFileToMutate.sub!(/true/, 'false')
                when /\s*false\s*/
                    # puts "matched '#{$&}'"
                    sectionOfFileToMutate.sub!(/false/, 'true ')
                when /\s*\/\s*/
                    # puts "matched '#{$&}'"
                    sectionOfFileToMutate.sub!(/\//, '*')
                when /\s*\*\s*/
                    # puts "matched '#{$&}'"
                    sectionOfFileToMutate.sub!(/\*/, '/')
                when /\s+\+\s+/
                    # puts "matched '#{$&}'"
                    sectionOfFileToMutate.sub!(/\+/, '-')
                when /\s+\-\s+/
                    # puts "matched '#{$&}'"
                    sectionOfFileToMutate.sub!(/\-/, '+')
                when /\s+>\s+/
                    # puts "matched '#{$&}'"
                    sectionOfFileToMutate.sub!(/>/, '<')
                when /\s+<\s+/
                    # puts "matched '#{$&}'"
                    sectionOfFileToMutate.sub!(/</, '>')
                when /\s*raise\s*/
                    # puts "matched '#{$&}'"
                    sectionOfFileToMutate.sub!(/raise\s*/, '#')
                else
                    notYetMutated = true
                end

                if not notYetMutated then 
                    # 
                    # We don't want mutations on the same place as we mutated before. 
                    # 
                    if rejectMutation?( originalSectionOfFileToMutate, sectionOfFileToMutate, positionInFile ) then 
                        notYetMutated = true
                    end
                end
                
                if notYetMutated then 
                    countTries = countTries + 1
                end
                if countTries > @mutationOrder
                    mutationWindow = mutationWindow + 2
                end

                # 
                # Got a mutation. Now incorporate the mutation into the original
                # contents.
                # 
                if not notYetMutated then 
                    positionAfterMutationWindow = positionInFile + sectionOfFileToMutate.size - 1
                    
                    # 
                    # Sometimes, the mutation makes the final mutated window 
                    # different in size than the original (un-mutated) copy.
                    # This creates a discrepancy in the positions.
                    # 
                    # Also, for some reason, newlines are not counted at all
                    # by the size() method of strings.
                    # 
                    # The combination of these two issues causes the last 
                    # character within the mutation window to be included 
                    # twice.
                    #
                    # In such cases, we increment the position when these
                    # two situations are in effect so that the counter 
                    # goes to the correct location.
                    # 
                    # This happens when the mutation window keeps increasing
                    # to find more opportunity to apply a mutation. The bigger
                    # the window, the more likely it is to include more than
                    # one newline. This issue is not very frequent.
                    # 
                    numberOfNewlines = sectionOfFileToMutate.count("\n")
                    if ( numberOfNewlines > 0 ) && ( originalSectionOfFileToMutate.size == sectionOfFileToMutate.size ) then
                        positionAfterMutationWindow = positionAfterMutationWindow + 1
                    end
                    
                    if @debug then
                        puts "#{__FILE__}::#{__method__}():#{__LINE__}: Original section: '#{originalSectionOfFileToMutate}'"
                        puts "#{__FILE__}::#{__method__}():#{__LINE__}: Modified section: '#{sectionOfFileToMutate}'"
                        puts "#{__FILE__}::#{__method__}():#{__LINE__}: Size of modified section: '#{sectionOfFileToMutate.size}'"
                        puts "#{__FILE__}::#{__method__}():#{__LINE__}: Size of original section: '#{originalSectionOfFileToMutate.size}'"
                        puts "#{__FILE__}::#{__method__}():#{__LINE__}: Current position in file: '#{positionInFile}'"
                        puts "#{__FILE__}::#{__method__}():#{__LINE__}: First character pointed to by the position in file: '#{fileToMutateContents[positionInFile]}'"
                        puts "#{__FILE__}::#{__method__}():#{__LINE__}: Character right before the mutation window: '#{fileToMutateContents[positionInFile-1]}'"
                        puts "#{__FILE__}::#{__method__}():#{__LINE__}: Character right after the mutation window: '#{fileToMutateContents[positionAfterMutationWindow]}'"
                        puts "#{__FILE__}::#{__method__}():#{__LINE__}: number Of Newlines in mutation window: '#{numberOfNewlines}'"
                    end
                    
                    # 
                    # Determine the pre and post strings (strings around the mutation window).
                    # 
                    fileToMutateContentsAnte = fileToMutateContents.slice(0, positionInFile)
                    fileToMutateContentsPost = fileToMutateContents.slice(positionAfterMutationWindow, fileToMutateContents.size + 1)
                    # 
                    # Now concatenate the parts to form the final mutant.
                    # 
                    fileToMutateContents = fileToMutateContentsAnte + sectionOfFileToMutate + fileToMutateContentsPost

                    if @debug then
                        puts "#{__FILE__}::#{__method__}():#{__LINE__}: fileToMutateContentsAnte = (#{fileToMutateContentsAnte})"
                        puts "#{__FILE__}::#{__method__}():#{__LINE__}: Modified section: (#{sectionOfFileToMutate})"
                        puts "#{__FILE__}::#{__method__}():#{__LINE__}: fileToMutateContentsPost = (#{fileToMutateContentsPost})"
                    end
                end
            end # while notYetMutated
            mutationsToGo = mutationsToGo - 1
        end # while mutationsToGo > 0

        if @debug then
            puts "#{__FILE__}::#{__method__}():#{__LINE__}: Finished creating a new mutant."
        end

        return fileToMutateContents
    end

    
    def getTestResults()
      return @testResults
    end

    
    def run!
        @languageAndTestStyleHandler.runPriorChecks( @fileToMutate, Mutator.getSuffixForMutatedSourceFile() )
        
        startTime = Time.now
        @mutationScore = 0
        numberOfRunsToGo = @numberOfRuns
        @mutantsKilledThusFar = 0
        @deadOnArrivalThusFar = 0
        @mutantsAlive = 0
        while numberOfRunsToGo > 0
            if @debug then
              puts "#{__FILE__}::#{__method__}():#{__LINE__}: Mutating: numberOfRunsToGo = #{numberOfRunsToGo}"
            end
            
            mutant = mutate( @languageAndTestStyleHandler.getOriginalContentsOfFileToMutate(), @mutationWindow, @mutationOrder )
            pathAndFileNameOfMutant = @languageAndTestStyleHandler.getPathAndFileNameOfMutant( @fileToMutate, Mutator.getSuffixForMutatedSourceFile )
            if @debug then
              puts "#{__FILE__}::#{__method__}():#{__LINE__}: @fileToMutate = (#{@fileToMutate})"
              puts "#{__FILE__}::#{__method__}():#{__LINE__}: Mutator.getSuffixForMutatedSourceFile = (#{Mutator.getSuffixForMutatedSourceFile})"
              puts "#{__FILE__}::#{__method__}():#{__LINE__}: pathAndFileNameOfMutant = (#{pathAndFileNameOfMutant})"
            end
            File.open(pathAndFileNameOfMutant, 'w') {|f| f.write( mutant ) }
            
            elapsedSeconds = 0.0
            timeoutStart = Time.now
            testResults = ""
            test_thread = Thread.new do
              # 
              # WARNING: setting this to 'true' might affect the mutation score!
              # 
              redirectStderrToStdout = false
              testResults = @languageAndTestStyleHandler.runTestSuite( redirectStderrToStdout )
              @testResults = testResults
              if @debug then
                puts "#{__FILE__}::#{__method__}():#{__LINE__}: testResults = (#{testResults})"
              end
            end
            while test_thread.alive?
              elapsedSeconds = Time.now - timeoutStart
              if elapsedSeconds >= Mutator.getSecondsBeforeTimeout
                $stderr.puts "\n\nWARNING: The test suite '#{@testSuiteForMutant}' appears to be hung (it has been running for #{elapsedSeconds} seconds, with a maximum allowed of #{Mutator.getSecondsBeforeTimeout} seconds). Will now try to kill it...\n\n"
                testResults = TIMEOUT_ERROR_STR
                # 
                # Now kill the subshell so it's not left dangling using CPU
                # and memory.
                # 
                output = ""
                begin
                    cmdToFindRunningTestSuiteSubshell = "tasklist /FI \"IMAGENAME eq #{@languageAndTestStyleHandler.getLanguage()}.exe\" /FI \"SESSIONNAME eq Console\""
                    puts "Running '#{cmdToFindRunningTestSuiteSubshell}'"
                    output = `#{cmdToFindRunningTestSuiteSubshell}`
                rescue
                end
                $stderr.puts "\n\nOutput of '#{cmdToFindRunningTestSuiteSubshell}' = (#{output})\n\n"
                outputSplit = output.split(/\n/)
                $stderr.puts "'#{outputSplit}'"
                if nil == ( outputSplit[-1] =~ /#{@languageAndTestStyleHandler.getLanguage()}.exe\s+([0-9]+)\s+Console/ ) then
                  $stderr.puts "WARNING: Was not able to find PID of child process!"
                else
                  $stderr.puts "Killing child process #{$1}"
                  output = `taskkill /F /PID #{$1}`
                  if not output.include?( "SUCCESS" ) then
                    $stderr.puts "WARNING: Was not able to kill child process with PID #{$1}"
                  end
                end
                #
                # kill the Ruby thread too.
                #
                test_thread.kill if test_thread.alive?
                break
              end
              sleep 0.001   # ms
            end
            test_thread.join if test_thread.alive?
            
            mutantsKilled, deadOnArrival = @languageAndTestStyleHandler.analyzeTestRunResults( testResults )
            
            if testResults.include?( TIMEOUT_ERROR_STR ) then
              mutantsKilled = 1
              deadOnArrival = 0
            end
            
            @mutantsKilledThusFar = @mutantsKilledThusFar + mutantsKilled
            @deadOnArrivalThusFar = @deadOnArrivalThusFar + deadOnArrival
            
            numberOfRunsToGo = numberOfRunsToGo - 1
            @runsExecuted = @runsExecuted + 1

            # 
            # DOA's are caused by, say, syntax errors which do not allow the
            # test suite to run. Thus, they are NOT counted toward the mutation
            # score of the suite.
            # 
            @mutationScore = @mutantsKilledThusFar.to_f / (@numberOfRuns - numberOfRunsToGo - @deadOnArrivalThusFar).to_f 
            if @mutationScore.nan? then
              # 
              # Division by zero occurs when @numberOfRuns == @deadOnArrivalThusFar.
              # 
              @mutationScore = 0.0
            end
            
            @mutantsAlive = @numberOfRuns - numberOfRunsToGo - @mutantsKilledThusFar - @deadOnArrivalThusFar
            
            if @runUntilLiveMutantIsFound && ( getMutantsAlive() > 0 ) then
                puts "\n\nFound a live mutant!\n\n"                
                @numberOfRuns = @runsExecuted
                numberOfRunsToGo = 0
                
                if @debug then
                    puts "#{__FILE__}::#{__method__}():#{__LINE__}: @numberOfRuns = '#{@numberOfRuns}'"
                    puts "#{__FILE__}::#{__method__}():#{__LINE__}: numberOfRunsToGo = '#{numberOfRunsToGo}'"
                end
                    
                # 
                # We will break out of the loop after the calculations below.
                # So no need to break from here.
                #
            end
            

            if @debug then
                puts "#{__FILE__}::#{__method__}():#{__LINE__}: @runUntilLiveMutantIsFound = '#{@runUntilLiveMutantIsFound}'"
                puts "#{__FILE__}::#{__method__}():#{__LINE__}: mutants Alive = '#{ getMutantsAlive() }'"
                puts "#{__FILE__}::#{__method__}():#{__LINE__}: mutants Killed Thus Far = '#{ getMutantsKilled() }'"
                puts "#{__FILE__}::#{__method__}():#{__LINE__}: DOA Thus Far = '#{ getMutantsDOA() }'"
                puts "#{__FILE__}::#{__method__}():#{__LINE__}: mutation Score thus far = '#{ getMutationScore() }'"
                puts "#{__FILE__}::#{__method__}():#{__LINE__}: number Of Runs To Go = '#{numberOfRunsToGo}'"
                puts "#{__FILE__}::#{__method__}():#{__LINE__}: total runs to execute = '#{@numberOfRuns}'"
                puts "#{__FILE__}::#{__method__}():#{__LINE__}: runs executed thus far = '#{ getRunsExecuted() }'"
            end
            
            puts "@mutantsKilled = '#{@mutantsKilledThusFar}'"
            puts "@deadOnArrival = '#{@deadOnArrivalThusFar}'"
            puts "@mutantsAlive = '#{@mutantsAlive}'"
            puts "Mutation score thus far = '#{@mutationScore}'"
            puts "Number of mutants created thus far = '#{@numberOfRuns - numberOfRunsToGo}'"
            $stderr.printf("Progress: %5.2f%\n", ( (@numberOfRuns - numberOfRunsToGo) / @numberOfRuns.to_f) * 100 )

        end
        endTime = Time.now
        elapsedTimeSecs = endTime - startTime
        @runtimeSeconds = elapsedTimeSecs
        $stderr.puts "Total seconds ran = '#{elapsedTimeSecs}'; mins = '#{elapsedTimeMins = (elapsedTimeSecs/60.0)}'; hrs = '#{elapsedTimeMins/60.0}'"
        puts
        puts "Mutation results for '#{@testSuiteForMutant}':"
        puts "\tMutants Killed = '#{@mutantsKilledThusFar}'"
        puts "\tMutants Alive = '#{@mutantsAlive}'"
        puts "\tMutants DOA = '#{@deadOnArrivalThusFar}'"
        puts "\tTotal Mutants = '#{@numberOfRuns}'"
        puts "\tMutation Score = '#{@mutationScore}'"
    end

end


# 
# This allows others to decorate (wrap) it and call later, while still 
# allowing this file to be used in the command line.
# 
module MutatorModule

    if $0 == __FILE__ then  # do not remove: 90d9a4574519b3 for build
        MutatorOptions.parse
        
        fileToMutate = MutatorOptions.options[:source_file]
        testSuiteToRun = MutatorOptions.options[:testsuite_file]
        numberOfRuns = MutatorOptions.options[:runs]
        mutationOrder = MutatorOptions.options[:mutaton_order]
        debug = MutatorOptions.options[:debug]
        language = MutatorOptions.determineLanguageHandler()
        runUntilLiveMutantIsFound = MutatorOptions.options[:run_until_live]
        
        mutator = Mutator.new( fileToMutate, testSuiteToRun, numberOfRuns, mutationOrder, language, debug, runUntilLiveMutantIsFound )
        mutator.run!
    end # do not remove: 90d9a4574519b3 for build

end    
