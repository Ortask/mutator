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
require 'set'
require 'open3'
require 'fileutils'
require './TestUtils'
include TestUtils

class TestMutationWithLanguageAndTestStyleHandler_RUBY_TESTUNIT < Test::Unit::TestCase

    def self.test_order
        :random # randomize test runs
    end


    def setup
        @debug = false
        if @debug then
            puts "Starting test."
        end

        setup_environment(__FILE__)
        
        @locationOfTestFiles = "testdata/"
                    
        # 
        # Setting to "true" will skip the tests that verify the 
        # behavior of mutator with hanging/sleeping test suites,
        # which tend to run slow.
        # 
        @bypassHangingOrSleepingTests = false
        
        @toleranceForSkipSeconds = 1.0

        
        @sourcefile = "SourceFile_NoComments.rb"
        @sourcefileWithError = "SourceFile_NoComments_WithError.rb"
        #
        @testsuite = "TestSuite.rb"
        @testsuiteRubyTestUnitStyle = @testsuite
        @nonExistentTestSuite = "ThisTestSuiteDoesNotExist.rb"
        @testsuiteWithError = "TestSuite.rb.WithError.rb"
        @testsuiteWithSyntaxError = "TestSuite.rb.WithSyntaxError.rb"
        @testsuiteNotReferringToMutatedSource = "TestSuite.rb.NotReferringToMutatedSource.rb"
        @testsuiteThatHangs = "HangingTest.rb"
        @testsuiteThatSleeps = "SleepingTest.rb"
        
        
        @mutationCmd = "ruby #{@mutatorName} -s \"#{@locationOfTestFiles + @sourcefile}\" -t \"#{@locationOfTestFiles + @testsuite}\" "
        @mutationCmdNonExistentTestSuite = "ruby #{@mutatorName} -s \"#{@locationOfTestFiles + @sourcefile}\" -t \"#{@nonExistentTestSuite}\" "
        @mutationCmdTestSuiteNotReferringToMutatedSource = "ruby #{@mutatorName} -s \"#{@locationOfTestFiles + @sourcefile}\" -t \"#{@locationOfTestFiles + @testsuiteNotReferringToMutatedSource}\" "
        @mutationCmdHangingTestSuite = "ruby #{@mutatorName} -s \"#{@locationOfTestFiles + @sourcefile}\" -t \"#{@locationOfTestFiles + @testsuiteThatHangs}\" "
        @mutationCmdSleepingTestSuite = "ruby #{@mutatorName} -s \"#{@locationOfTestFiles + @sourcefile}\" -t \"#{@locationOfTestFiles + @testsuiteThatSleeps}\" "
    end


    def teardown()
        if @debug then
            puts "Leaving test."
        end
        
        cleanUpTestData( @locationOfTestFiles )
    end

    
    def test_user_is_alerted_when_required_helper_script_does_not_exist
        if @debug then
            puts "Running '#{__method__}'"
        end
        
        renamedRequiredHelperScriptName = "-#{@requiredHelperScriptName}"
        FileUtils.cp( @requiredHelperScriptName, renamedRequiredHelperScriptName )
        FileUtils.rm( @requiredHelperScriptName, :force => true )
        
        stdoutAsString, stderrAsString = runCmd( @mutationCmd  )
        
        actualText = stderrAsString
        expectedText = "#{@requiredHelperScriptName} was not found. This is needed to remove comments from source files. (RuntimeError)"
        expected = true
        actual = actualText.include?(expectedText)
        assert( expected == actual, "Expected '#{expectedText}' but got '#{actualText}'" )
        
        assertEmptyString( stdoutAsString )
        
        FileUtils.cp( renamedRequiredHelperScriptName, @requiredHelperScriptName )

    end

    
    def test_user_is_alerted_when_given_test_suite_does_not_exist
        if @debug then
            puts "Running '#{__method__}'"
        end
        
        stdoutAsString, stderrAsString = runCmd( @mutationCmdNonExistentTestSuite )

        assertEmptyString( stdoutAsString )
        
        actualText = stderrAsString
        expectedText = """Test suite not found: '#{@nonExistentTestSuite}'!  (RuntimeError)

Please create a test suite called '#{@nonExistentTestSuite}' and modify its \"require's\" from:
	 require '#{File.basename( @sourcefile, @rubyFileExtension )}'
 to 
	 require '#{@sourcefile + Mutator.getSuffixForMutatedSourceFile()}'"""
        expected = true
        actual = actualText.include?(expectedText)
        assert( expected == actual, "Expected '#{expectedText}' but got '#{actualText}'" )
    end

    
    
    def test_user_is_alerted_when_testsuite_does_not_reference_source_to_mutate
        if @debug then
            puts "Running '#{__method__}'"
        end
        
        stdoutAsString, stderrAsString = runCmd( @mutationCmdTestSuiteNotReferringToMutatedSource )

        actualText = stderrAsString
        expectedText = """Error in '#{@locationOfTestFiles + @testsuiteNotReferringToMutatedSource}': the file is not using the mutated version!  (RuntimeError)

Please change its \"require's\" from:
	 require '#{File.basename( @sourcefile, @rubyFileExtension )}'
 to 
	 require '#{@sourcefile + Mutator.getSuffixForMutatedSourceFile()}'
"""
        expected = true
        actual = actualText.include?(expectedText)
        assert( expected == actual, "Expected '#{expectedText}' but got '#{actualText}'" )
    end

    
    
    def test_testsuite_that_hangs_too_long_get_skipped
        if @bypassHangingOrSleepingTests then
            return
        end
        localDebug = @debug || false
    
        # 
        # Create the necessary mutated source file which is required by the 
        # test suite below.
        # 
        FileUtils.cp( @locationOfTestFiles + @sourcefile, @locationOfTestFiles + @sourcefile + Mutator.getSuffixForMutatedSourceFile() + @rubyFileExtension )
        
        # 
        # Bring in the right suite for this test.
        # 
        require "./#{@locationOfTestFiles + File.basename( @testsuiteThatHangs, @rubyFileExtension )}"            

        secondsForPreMuationRun = HangingTest.getSecondsForHang.to_f

        assertHangingTestsSuitesAreSkipped( @mutationCmdHangingTestSuite, @locationOfTestFiles + @testsuiteThatHangs, secondsForPreMuationRun, @toleranceForSkipSeconds, localDebug )
    end
    

    def test_testsuite_that_sleeps_too_long_get_skipped
        if @bypassHangingOrSleepingTests then
            return
        end
        localDebug = @debug || false

        # 
        # Create the necessary mutated source file which is required by the 
        # test suite below.
        # 
        FileUtils.cp( @locationOfTestFiles + @sourcefile, @locationOfTestFiles + @sourcefile + Mutator.getSuffixForMutatedSourceFile() + @rubyFileExtension )
        
        # 
        # Bring in the right suite for this test.
        # 
        require "./#{@locationOfTestFiles + File.basename( @testsuiteThatSleeps, @rubyFileExtension )}"            
        
        secondsForPreMuationRun = SleepingTest.getSecondsForSleep.to_f

        assertHangingTestsSuitesAreSkipped( @mutationCmdSleepingTestSuite, @locationOfTestFiles + @testsuiteThatSleeps, secondsForPreMuationRun, @toleranceForSkipSeconds, localDebug )
    end
    

    

    
    def test_mutator_can_be_given_ruby_language_handler_as_object
        localDebug = @debug || false
        if localDebug then
            puts "Running '#{__method__}'"
        end

        mutator = Mutator.new( @locationOfTestFiles + @sourcefile, @locationOfTestFiles + @testsuiteRubyTestUnitStyle, 1, 1, LanguageAndTestStyleHandler_RUBY_TESTUNIT.new( @locationOfTestFiles + @testsuiteRubyTestUnitStyle, localDebug ), localDebug )
        begin
            mutator.run!
        rescue
            exceptionRaised = $!
            fail("No exception/error should have been raised but got '#{exceptionRaised}'")
        end
        
        k = 1
        minimumMutations = 1
        assertMutations( getDiffCount( @locationOfTestFiles + @sourcefile, @locationOfTestFiles + @sourcefile + @fullExtensionForMutatedSourceFile_Ruby ), k, minimumMutations )
    end
    
    

    def test_mutation_score_is_stable
        if @debug then
            puts "Running '#{__method__}'"
        end

        expectedMutationScore = 0.6
        toleranceForMutationScore = 0.2
        assertMutationScoreWhenStandalone( @mutationCmd, expectedMutationScore, toleranceForMutationScore )
    end

    
    def test_language_handler_alerts_user_of_failing_test_before_mutation_analysis_begins
        localDebug = @debug || false
        if localDebug then
            puts "Running '#{__method__}'"
        end

        mutator = Mutator.new( @locationOfTestFiles + @sourcefileWithError, @locationOfTestFiles + @testsuiteWithError, 1, 1, LanguageAndTestStyleHandler_RUBY_TESTUNIT.new( @locationOfTestFiles + @testsuiteWithError, localDebug ), localDebug )
        assertOnFailingTests( mutator )
        
        mutator = Mutator.new( @locationOfTestFiles + @sourcefile, @locationOfTestFiles + @testsuiteWithSyntaxError, 1, 1, LanguageAndTestStyleHandler_RUBY_TESTUNIT.new( @locationOfTestFiles + @testsuiteWithSyntaxError, localDebug ), localDebug )
        assertOnFailingTests( mutator )
    end
    
    
    # 
    # This test needs to be improved just like similar tests here so that 
    # it is not affected by DOA's because DOAs will immediately fail 
    # (within 1 sec) thus making this test fail!
    # 
    def test_can_modify_timeout_to_skip_hanging_tests_when_mutator_is_an_object
        if @bypassHangingOrSleepingTests then
            return
        end

        # 
        # Create the necessary mutated source file which is required by the 
        # test suite below.
        # 
        FileUtils.cp( @locationOfTestFiles + @sourcefile, @locationOfTestFiles + @sourcefile + Mutator.getSuffixForMutatedSourceFile() + @rubyFileExtension )

        
        # 
        # Bring in the right suite for this test.
        # 
        require "./#{@locationOfTestFiles + File.basename( @testsuiteThatHangs, @rubyFileExtension )}"            
        
        mutator = Mutator.new( @locationOfTestFiles + @sourcefile, @locationOfTestFiles + @testsuiteThatHangs )
        timeWaitForMutator = 3
        Mutator.setSecondsBeforeTimeout( timeWaitForMutator )    # seconds before mutator kills the thread
        assert_equal( timeWaitForMutator, Mutator.getSecondsBeforeTimeout )
        
        secondsForPreMuationRun = HangingTest.getSecondsForHang.to_f
        secondsBeforeTimeoutByMutator = Mutator.getSecondsBeforeTimeout    # seconds before mutator kills the thread
        assert_equal( timeWaitForMutator, secondsBeforeTimeoutByMutator )

        expected = true
        actual = ( secondsForPreMuationRun > secondsBeforeTimeoutByMutator )
        assert_equal( expected, actual, "Was not expecting #{secondsForPreMuationRun} <= #{secondsBeforeTimeoutByMutator}" )
        
        begin
            mutator.run!
        rescue
            exceptionRaised = $!
            fail("No exception/error should have been raised but got '#{exceptionRaised}'")
        end
                
        
        # 
        # We can't time the mutator from here because *this* test suite 
        # will wait for the "hanging" one to finish, thus screwing any
        # timing tests we do here. Instead, the mutator keeps its own time
        # which will we query when it finishes. Those
        # total seconds is what we will use to verify that it is honoring
        # the timeout value and killing the scripts when the time is up.
        #
        actualElapsedTimeSecs = mutator.getRuntimeSeconds()
        expectedElapsedTimeSecs = secondsBeforeTimeoutByMutator
        assert_in_delta( expectedElapsedTimeSecs, actualElapsedTimeSecs, @toleranceForSkipSeconds, "\nsecondsBeforeTimeoutByMutator = #{secondsBeforeTimeoutByMutator}\nsecondsForPreMuationRun = #{secondsForPreMuationRun}\nexpectedElapsedTimeSecs = #{expectedElapsedTimeSecs}\nactualElapsedTimeSecs=#{actualElapsedTimeSecs}\n")        
    end
    
    


end # class 
