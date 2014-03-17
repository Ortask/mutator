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

require 'Open3'

require_relative './TestUtilsHelper'
include TestUtilsHelper

module TestUtils

    def setup_environment( testName )
      
        puts "\n#{__FILE__}::#{__method__}():#{__LINE__}: Setting up test environment for '#{testName}'"

        @pathToMutator = "../src/"
        if ( defined?( TestUtilsHelper_PATH_TO_SOURCE ) ) then
            @pathToMutator = TestUtilsHelper_PATH_TO_SOURCE
        end
        
        @copyDestination = "."
        if ( defined?( TestUtilsHelper_COPY_DESTINATION ) ) then
            @copyDestination = TestUtilsHelper_COPY_DESTINATION
        end

        @requiredFilesPath = @pathToMutator
        
        @requiredVersionFileName = "MutatorVersion.rb"
        begin
            FileUtils.cp( @requiredFilesPath + @requiredVersionFileName, @copyDestination )
        rescue
        end

        @requiredFileName = "MutatorAvailableLanguageAndTestStyleHandler.rb"
        begin
            FileUtils.cp( @requiredFilesPath + @requiredFileName, @copyDestination )
        rescue
        end

        @requiredFileName = "MutatorAvailableLanguageAndTestStyleHandlerPostProcessor.rb"
        begin
            FileUtils.cp( @requiredFilesPath + @requiredFileName, @copyDestination )
        rescue
        end

        @requiredOptionsProcessorName = "MutatorOptions.rb"
        begin
            FileUtils.cp( @requiredFilesPath + @requiredOptionsProcessorName, @copyDestination )
        rescue
        end

        @mutatorName = "mutator.rb"
        @mutator = @pathToMutator + @mutatorName
        begin
            FileUtils.cp( @mutator, @copyDestination )
        rescue
        end
        if defined?( TestUtilsHelper_MUTATOR_NAME ) then
            @mutatorName = TestUtilsHelper_MUTATOR_NAME
        end
        if defined?( TestUtilsHelper_PATH_TO_MUTATOR ) then
            @pathToMutator = TestUtilsHelper_PATH_TO_MUTATOR
        end

        # 
        # And bring in the mutator to be able to use its definitions for 
        # timeout and others as well.
        # 
        require "./#{@mutator.slice( 0, @mutator.size - 3 )}"
        
        @requiredHelperScriptName = "commentRemover.rb"
        begin
            FileUtils.cp( @requiredFilesPath + @requiredHelperScriptName, @copyDestination )
        rescue
        end
        
        
        @pathToTestLanguageHandlers = "./"
        if ( defined?( TestUtilsHelper_PATH_TO_TEST_DIR ) ) then
            @pathToTestLanguageHandlers = TestUtilsHelper_PATH_TO_TEST_DIR
        end
        
        @pathToLanguageHandlers = @pathToMutator
        @languageAndTestStyleHandlers = []
        @languageAndTestStyleHandlers << @pathToLanguageHandlers + "LanguageAndTestStyleHandler"
        @languageAndTestStyleHandlers << @pathToLanguageHandlers + "LanguageAndTestStyleHandler_RUBY"
        @languageAndTestStyleHandlers << @pathToLanguageHandlers + "LanguageAndTestStyleHandler_RUBY_TESTUNIT"
        @languageAndTestStyleHandlers << @pathToLanguageHandlers + "LanguageAndTestStyleHandler_RUBY_RSPEC"
        @languageAndTestStyleHandlers << @pathToLanguageHandlers + "LanguageAndTestStyleHandler_JAVA_JUNIT3"
        @languageAndTestStyleHandlers << @pathToLanguageHandlers + "LanguageAndTestStyleHandler_JAVA_JUNIT4"
        @languageAndTestStyleHandlers << @pathToLanguageHandlers + "LanguageAndTestStyleHandler_JAVA"
        @languageAndTestStyleHandlers << @pathToTestLanguageHandlers + "LanguageAndTestStyleHandler_MockEmpty"
        @languageAndTestStyleHandlers << @pathToTestLanguageHandlers + "LanguageAndTestStyleHandler_WithUnrecognizedLanguage"

        @languageAndTestStyleHandlers.each { |handler|
            begin
                FileUtils.cp( handler + ".rb", @copyDestination )
            rescue
            end
            require_relative handler
        }
        
        rubyLanguageHandler = LanguageAndTestStyleHandler_RUBY_TESTUNIT.new("bla")
        @fullExtensionForMutatedSourceFile_Ruby = Mutator.getSuffixForMutatedSourceFile + rubyLanguageHandler.getFileExtension
        @rubyFileExtension = rubyLanguageHandler.getFileExtension
        @junit3LanguageHandler = LanguageAndTestStyleHandler_JAVA_JUNIT3.new( "bla" )
        @javaFileExtension = @junit3LanguageHandler.getFileExtension()

        TestUtilsHelper.override_setup_environment( testName )
    end

    
    def cleanUpTestData( dirToClean, patternOfFilesToMatch="ThisIsADummyPatternThatIsDefault" )
        # puts "\ncalling #{__method__} @ #{Time.now}\n"
        filesToDelete = []
        Dir.foreach( dirToClean ) { |entry|
            currentEntry = dirToClean + entry
            # puts currentEntry
            if ( currentEntry =~ /.*#{patternOfFilesToMatch}.*/ ) then
                filesToDelete << currentEntry
            end
            
            # 
            # Always clean up remaining mutants. 
            # 
            if ( currentEntry =~ /.*#{Mutator.getSuffixForMutatedSourceFile()}.*/ ) then
                filesToDelete << currentEntry
            end
        }
        
        # puts "\n\nfilesToDelete = '#{filesToDelete}'\n\n"
        filesToDelete.each { |e|
            begin 
                File.delete( e )
            rescue
            end
        }
    end
    
    
    def getOSEnvSeparator()
      if (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
        return ";"
      else
        return ":"
      end
    end

    
    def getDiffCount( sourcefileOriginal, sourcefileMutated, debug = false, language="ruby" )
        if debug then
          puts "\n#{__FILE__}::#{__method__}():#{__LINE__}: Diff'ing sourcefileMutated=(#{sourcefileMutated}) and sourcefileOriginal=(#{sourcefileOriginal})\n"
        end

        outputFile = "#{sourcefileOriginal}.NoComments.out"
        runCmd( "ruby " + @requiredHelperScriptName + " #{sourcefileOriginal} #{language} #{outputFile}" )
        file1 = File.read( outputFile )
        file2 = File.read( sourcefileMutated )
        
        diffFile1 = []
        diffFile1 << file1.split("\n")
        diffFile1.flatten!
        diffFileNew = diffFile1.map { |line|
            line.strip  # we will ignore whitespace differences
        }
        diffFile1 = diffFileNew

        diffFile2 = []
        diffFile2 << file2.split("\n")
        diffFile2.flatten!
        diffFileNew = diffFile2.map { |line|
            line.strip  # we will ignore whitespace differences
        }
        diffFile2 = diffFileNew

        differences = 0
        diff = []
        0.upto( diffFile2.size - 1 ) do |idx|
            if diffFile2[idx] != diffFile1[idx] then
                differences = differences + 1
                diff << diffFile2[idx]
                
                if debug then
                    puts "\n#{__FILE__}::#{__method__}():#{__LINE__}: Original line = (#{diffFile1[idx]})"
                    puts "\n#{__FILE__}::#{__method__}():#{__LINE__}: Mutated line = (#{diffFile2[idx]})"
                end
            end
        end
        
        if debug then
          puts "\n#{__FILE__}::#{__method__}():#{__LINE__}: final diff = "
          diff.each { |d|
            puts "\n#{__FILE__}::#{__method__}():#{__LINE__}: diff = (#{d})"
          }
        end

        return diff.size
    end
    
    

    def runCmd( cmd, debug=false )
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
        if debug then
            puts "\n#{__FILE__}::#{__method__}():#{__LINE__}: stdout: '#{stdoutAsString}'"
            puts "\n#{__FILE__}::#{__method__}():#{__LINE__}: stderr: '#{stderrAsString}'"
        end

        return stdoutAsString, stderrAsString
    end

    
    def assertSuccess( stderrAsString, stdoutAsString, debug=false )
    
        if debug then
          puts "\n#{__FILE__}::#{__method__}():#{__LINE__}: stderrAsString = (#{stderrAsString})"
          puts "\n#{__FILE__}::#{__method__}():#{__LINE__}: stdoutAsString = (#{stdoutAsString})"
        end
        
        actualText = stderrAsString
        expectedText = "no such file to load"
        expected = false
        actual = actualText.include?(expectedText)
        assert( expected == actual, "Not Expected '#{expectedText}' but got '#{actualText}'" )

        actualText = stderrAsString
        expectedText = "Progress: 100.00%"
        expected = true
        actual = actualText.include?(expectedText)
        assert( expected == actual, "Expected '#{expectedText}' but got '#{actualText}'" )

        actualText = stdoutAsString
        expectedText = "Good to go!"
        expected = true
        actual = actualText.include?(expectedText)
        assert( expected == actual, "Expected '#{expectedText}' but got '#{actualText}'" )
        expectedText = "@mutantsKilled = "
        expected = true
        actual = actualText.include?(expectedText)
        assert( expected == actual, "Expected '#{expectedText}' but got '#{actualText}'" )
        expectedText = "@deadOnArrival = "
        expected = true
        actual = actualText.include?(expectedText)
        assert( expected == actual, "Expected '#{expectedText}' but got '#{actualText}'" )
        expectedText = "@mutantsAlive = "
        expected = true
        actual = actualText.include?(expectedText)
        assert( expected == actual, "Expected '#{expectedText}' but got '#{actualText}'" )
        expectedText = "Mutation score thus far = "
        expected = true
        actual = actualText.include?(expectedText)
        assert( expected == actual, "Expected '#{expectedText}' but got '#{actualText}'" )
        expectedText = "Number of mutants created thus far = '1'"
        expected = true
        actual = actualText.include?(expectedText)
        assert( expected == actual, "Expected '#{expectedText}' but got '#{actualText}'" )
        
        actualText = stdoutAsString
        expectedText = "Mutation results for"
        expected = true
        actual = actualText.include?(expectedText)
        assert( expected == actual, "Expected '#{expectedText}' but got '#{actualText}'" )
        expectedText = "Mutants Killed ="
        expected = true
        actual = actualText.include?(expectedText)
        assert( expected == actual, "Expected '#{expectedText}' but got '#{actualText}'" )
        expectedText = "Mutants Alive ="
        expected = true
        actual = actualText.include?(expectedText)
        assert( expected == actual, "Expected '#{expectedText}' but got '#{actualText}'" )
        expectedText = "Mutants DOA ="
        expected = true
        actual = actualText.include?(expectedText)
        assert( expected == actual, "Expected '#{expectedText}' but got '#{actualText}'" )
        expectedText = "Total Mutants ="
        expected = true
        actual = actualText.include?(expectedText)
        assert( expected == actual, "Expected '#{expectedText}' but got '#{actualText}'" )
        expectedText = "Mutation Score = "
        expected = true
        actual = actualText.include?(expectedText)
        assert( expected == actual, "Expected '#{expectedText}' but got '#{actualText}'" )
    end
    
    
    def assertEmptyString( string )
        actualText = string
        expectedText = ""
        expected = true
        actual = ( actualText == expectedText )
        assert( expected == actual, "Expected '#{expectedText}' but got '#{actualText}'" )
    end

    
    
    #
    #
    # Due to the stochastic nature of the mutations, the only guarantee is 
    # that there will be *at most* k mutations per mutant (but there may
    # be less).
    #
    def assertMutations( actualMutations, k, minimumMutations, debug = false)
        if debug then
          puts "\n#{__FILE__}::#{__method__}():#{__LINE__}: actualMutations = #{actualMutations}"
          puts "\n#{__FILE__}::#{__method__}():#{__LINE__}: k = #{k}"
          puts "\n#{__FILE__}::#{__method__}():#{__LINE__}: minimumMutations = #{minimumMutations}"
        end
        
        assert( k % 2 != 0, "Expected k to be odd but was even: #{k}. Even values for k might lead to mutations reverting the source file to its original content, thus making it difficult to verify whether mutations were applied at all." )
        expectedMutations = "( (minimumMutations = #{minimumMutations}) <= (actualMutations = #{actualMutations}) ) and ( (actualMutations=#{actualMutations}) <= (k = #{k}))"
        expected = true
        actual = (minimumMutations <= actualMutations) && (actualMutations <= k)
        assert( expected == actual, "Expected '#{expectedMutations}' but got actualMutations = '#{actualMutations}'" )        
    end

      
      
    def assertHangingTestsSuitesAreSkipped(cmdToRun, pathAndNameOfTestSuite, secondsForPreMuationRun, toleranceForSkipSeconds, debug=false)
        msg = "\n\n#{__FILE__}::#{__method__}():#{__LINE__}: This might take a while..."
        puts msg
        $stderr.puts msg

        secondsBeforeTimeoutByMutator = Mutator.getSecondsBeforeTimeout
        
        expected = true
        actual = ( secondsForPreMuationRun > secondsBeforeTimeoutByMutator )
        assert_equal( expected, actual, "Was not expecting #{secondsForPreMuationRun} <= #{secondsBeforeTimeoutByMutator}" )
        
        stdoutAsString = ""
        stderrAsString = ""
        debugExtensionForCmd = ""
        if debug then
            debugExtensionForCmd = " -d"
        end
        while true
          stdoutAsString, stderrAsString = runCmd( cmdToRun + debugExtensionForCmd )
          if !stdoutAsString.include?( "Mutants DOA = '1'" ) then
            break
          end
        end

        assert_no_match( /Test suite not found/, stderrAsString )
        assert_no_match( /No such file or directory/, stderrAsString )
        
        expectedText = "The test suite '#{pathAndNameOfTestSuite}' appears to be hung"
        actualText = stderrAsString
        actual = actualText.include?(expectedText)
        assert( expected == actual, "Expected (#{expectedText}) but got (#{actualText})" )
        
        # 
        # We can't time the mutator from here because *this* test suite 
        # will wait for the "hanging" one to finish, thus screwing any
        # timing tests we do here. Instead, the mutator outputs a string
        # "Total seconds ran = '<seconds>'" when it finishes. Those
        # total seconds is what we will use to verify that it is honoring
        # the timeout value and killing the scripts when the time is up.
        #
        validationRegexp = "Total seconds ran = '([0-9]+\.[0-9]+)'"
        assert_match( /#{validationRegexp}/, stderrAsString )
        actualElapsedTimeSecs = -100.0
        if stderrAsString =~ /#{validationRegexp}/ then
            actualElapsedTimeSecs = $1.to_f
            assert( actualElapsedTimeSecs > 0.0, "The actual elapsed time is invalid = '#{actualElapsedTimeSecs}'. Perhaps there is a problem with the regex '#{validationRegexp}'?" )
        else
            flunk( "Required string not found with regex '#{validationRegexp}'. Was not able to verify the timeout functionality." )
        end
        
        expectedElapsedTimeSecs = secondsBeforeTimeoutByMutator
        assert_in_delta( expectedElapsedTimeSecs, actualElapsedTimeSecs, toleranceForSkipSeconds, "\nsecondsBeforeTimeoutByMutator = #{secondsBeforeTimeoutByMutator}\nsecondsForPreMuationRun = #{secondsForPreMuationRun}\nexpectedElapsedTimeSecs = #{expectedElapsedTimeSecs}\nactualElapsedTimeSecs=#{actualElapsedTimeSecs}\n\nstdout = (#{stdoutAsString})\n\nstderr = \n\n(#{stderrAsString})\n")        
    end

   
    def assertOnFailingTests( mutator, expectedMsg = nil )
        expectedText = expectedMsg || "The test suite is failing"
        begin
            mutator.run!
            flunk("An exception/error should have been raised but nothing was raised! Results of running the test suite = (#{mutator.getTestResults})")
        rescue
            exceptionRaised = $!
            actual = exceptionRaised.to_s.include?( expectedText )
            expected = true
            assert( expected == actual, "Expected (#{expectedText}) but got (#{exceptionRaised})" )
        end        
    end
   
   
    def assertMutationScoreWhenStandalone( cmdToRun, expectedMutationScore, toleranceForMutationScore )
        msg = "\n\n#{__FILE__}::#{__method__}():#{__LINE__}: This might take a while..."
        puts msg
        $stderr.puts msg

        validationRegexp = "Mutation Score = '([0-9]+\.[0-9]+)'"
        
        stdoutAsString, stderrAsString = runCmd( cmdToRun + " -r 50" )
        #
        assert_match( /#{validationRegexp}/, stdoutAsString )
        actualMutationScore = -100.0
        if stdoutAsString =~ /#{validationRegexp}/ then
            actualMutationScore = $1.to_f
            assert( actualMutationScore > 0.0, "The actual mutation score is invalid = '#{actualMutationScore}'. Perhaps there is a problem with the regex '#{validationRegexp}'?" )
        else
            flunk( "Required string not found with regex '#{validationRegexp}'. Was not able to verify the timeout functionality." )
        end
        #
        assert_in_delta( expectedMutationScore, actualMutationScore, toleranceForMutationScore, "\nstdout = (#{stdoutAsString})\n\nstderr = \n\n(#{stderrAsString})\n\nexpectedMutationScore = #{expectedMutationScore}\nactualMutationScore=#{actualMutationScore}\n")        
    end
end
