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
require './TestUtilsJava'
include TestUtilsJava

class TestMutationWithLanguageAndTestStyleHandler_JAVA_JUNIT4 < Test::Unit::TestCase

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

        
        originalJAVA_HOME = ENV.values_at("JAVA_HOME")
        newJAVA_HOMEWithJunit = originalJAVA_HOME
        newJAVA_HOMEWithJunit << "C:\\junit4.jar"
        envVarHash = {}
        envVarHash["JAVA_HOME"] = newJAVA_HOMEWithJunit.join( getOSEnvSeparator() )
        ENV.update( envVarHash )
        
        @pathToSourceFileJavaForTestData = @locationOfTestFiles + "/java/junit4/src/"
        @sourcefileForJava = "RectangleNoComments.java"
        @mutatedSourcefileForJava = File.basename( @sourcefileForJava, @javaFileExtension ) + Mutator.getSuffixForMutatedSourceFile() + @javaFileExtension
        @sourcefileForJavaWithError = "RectangleNoCommentsWithError.java"
        @sourcefileForJavaWithSyntaxError = "RectangleNoCommentsWithSyntaxError.java"
        #
        @pathToJavaTestData = @pathToSourceFileJavaForTestData
        @testsuiteJavaJunit4Style = "TestRectangle.java"
        @testsuiteJavaJunit4StyleWithError = "TestRectangleWithError.java"
        @testsuiteJavaJunit4StyleWithSyntaxError = "TestRectangleWithSyntaxError.java"
        @nonExistentTestSuite = "ThisTestSuiteDoesNotExist.java"
        @testsuiteNotReferringToMutatedSource = "TestsuiteNotReferringToMutatedSource.java"
        @testsuiteThatHangs = "TestSuiteThatHangs.java"
        @testsuiteThatSleeps = "TestSuiteThatSleeps.java"
        
        @mutationCmdNonExistentTestSuite = "ruby #{@mutatorName} -s \"#{@pathToSourceFileJavaForTestData + @sourcefileForJava}\" -t \"#{@pathToJavaTestData + @nonExistentTestSuite}\" -l junit4"
        @mutationCmdTestSuiteNotReferringToMutatedSource = "ruby #{@mutatorName} -s \"#{@pathToSourceFileJavaForTestData + @sourcefileForJava}\" -t \"#{@pathToJavaTestData + @testsuiteNotReferringToMutatedSource}\" -l junit4"
        @mutationCmdHangingTestSuite = "ruby #{@mutatorName} -s \"#{@pathToSourceFileJavaForTestData + @sourcefileForJava}\" -t \"#{@pathToJavaTestData + @testsuiteThatHangs}\" -l junit4"
        @mutationCmdSleepingTestSuite = "ruby #{@mutatorName} -s \"#{@pathToSourceFileJavaForTestData + @sourcefileForJava}\" -t \"#{@pathToJavaTestData + @testsuiteThatSleeps}\" -l junit4"
        @mutationCmdJunit4 = "ruby #{@mutatorName} -s \"#{@pathToSourceFileJavaForTestData + @sourcefileForJava}\" -t \"#{@pathToJavaTestData + @testsuiteJavaJunit4Style}\" -l junit4"
    end

        
    def teardown()
        if @debug then
            puts "Leaving test."
        end
        
        cleanUpTestData( @pathToSourceFileJavaForTestData, ".*class" )
    end



    
    def test_user_is_alerted_when_given_test_suite_does_not_exist_and_mutator_is_invoked_as_standalone
        if @debug then
            puts "Running '#{__method__}'"
        end

        stdoutAsString, stderrAsString = runCmd( @mutationCmdNonExistentTestSuite )

        assertEmptyString( stdoutAsString )
        
        actualText = stderrAsString
        expectedText = """Test suite not found: '#{@pathToJavaTestData + @nonExistentTestSuite}'!  (RuntimeError)

Please create a test suite called '#{@pathToJavaTestData + @nonExistentTestSuite}' and modify its references from:
	 '#{File.basename( @sourcefileForJava, @javaFileExtension )}'
 to 
	 '#{File.basename( @sourcefileForJava, @javaFileExtension ) + Mutator.getSuffixForMutatedSourceFile()}'"""
        expected = true
        actual = actualText.include?(expectedText)
        assert( expected == actual, "Expected (#{expectedText}) but got (#{actualText})" )
    end


    def test_user_is_alerted_when_given_test_suite_does_not_exist_and_mutator_is_invoked_as_instance
        localDebug = @debug || false
        if localDebug then
            puts "Running '#{__method__}'"
        end
        
        nonExistentTestSuite = @pathToJavaTestData + "NonExistentJavaTestSuite.java"
        begin
            mutator = Mutator.new( @pathToSourceFileJavaForTestData + @sourcefileForJava, nonExistentTestSuite, 1, 1, LanguageAndTestStyleHandler_JAVA_JUNIT4.new( nonExistentTestSuite, localDebug ), localDebug )
            mutator.run!
            flunk("An exception/error should have been raised but nothing was raised!")
        rescue
            exceptionRaised = $!
            expected = true
            expectedText = """Test suite not found: '#{nonExistentTestSuite}'! 

Please create a test suite called '#{nonExistentTestSuite}' and modify its references from:
	 '#{File.basename( @sourcefileForJava, @javaFileExtension )}'
 to 
	 '#{File.basename( @sourcefileForJava, @javaFileExtension ) + Mutator.getSuffixForMutatedSourceFile()}'"""
            actual = exceptionRaised.to_s.include?( expectedText )
            assert( expected == actual, "Expecting: (#{expectedText}). \nWas not expecting: ('#{exceptionRaised.to_s}')"  )            
        end
    end

    
    
    def test_user_is_alerted_when_testsuite_does_not_reference_source_to_mutate
        if @debug then
            puts "Running '#{__method__}'"
        end
        
        stdoutAsString, stderrAsString = runCmd( @mutationCmdTestSuiteNotReferringToMutatedSource )

        actualText = stderrAsString
        expectedText = """Error in '#{@pathToJavaTestData + @testsuiteNotReferringToMutatedSource}': the test suite is not using the mutated version!  (RuntimeError)

Please modify its references from:
	 '#{File.basename( @sourcefileForJava, @javaFileExtension )}'
 to 
	 '#{File.basename( @sourcefileForJava, @javaFileExtension ) + Mutator.getSuffixForMutatedSourceFile()}'"""
        expected = true
        actual = actualText.include?(expectedText)
        assert( expected == actual, "Expected '#{expectedText}' but got '#{actualText}'" )
    end



    def test_testsuite_that_hangs_too_long_get_skipped
        if @bypassHangingOrSleepingTests then
            return
        end
        localDebug = @debug || false
    
        secondsForPreMuationRun = 40.0

        assertHangingTestsSuitesAreSkipped( @mutationCmdHangingTestSuite, @pathToSourceFileJavaForTestData + @testsuiteThatHangs, secondsForPreMuationRun, @toleranceForSkipSeconds, localDebug )
    end

        
    
    def test_testsuite_that_sleeps_too_long_get_skipped
        if @bypassHangingOrSleepingTests then
            return
        end
        localDebug = @debug || false
    
        secondsForPreMuationRun = 40.0
        
        assertHangingTestsSuitesAreSkipped( @mutationCmdSleepingTestSuite, @pathToSourceFileJavaForTestData + @testsuiteThatSleeps, secondsForPreMuationRun, @toleranceForSkipSeconds, localDebug )
    end


    
    def test_mutator_can_be_given_junit4_language_handler_as_object
        localDebug = @debug || false
        if localDebug then
            puts "Running '#{__method__}'"
        end
        
        mutator = Mutator.new( @pathToSourceFileJavaForTestData + @sourcefileForJava, @pathToJavaTestData + @testsuiteJavaJunit4Style, 1, 1, LanguageAndTestStyleHandler_JAVA_JUNIT4.new( @pathToJavaTestData + @testsuiteJavaJunit4Style, localDebug ), localDebug )
        begin
            mutator.run!
        rescue
            exceptionRaised = $!
            fail("No exception/error should have been raised but got '#{exceptionRaised}'")
        end

        
        k = 1
        minimumMutations = 1
        assertMutations( getDiffCountJava( @pathToJavaTestData + @sourcefileForJava, @pathToJavaTestData + @mutatedSourcefileForJava, localDebug ), k, minimumMutations, localDebug )
    end
    


    def test_show_useful_error_when_JAVA_HOME_env_variable_does_not_have_junit_path
        localDebug = @debug || false
        if @debug then
            puts "Running '#{__method__}'"
        end
        
        oldJAVA_HOME = ENV["JAVA_HOME"]
        ENV["JAVA_HOME"] = ""
        
        mutator = Mutator.new( @pathToSourceFileJavaForTestData + @sourcefileForJava, @pathToJavaTestData + @testsuiteJavaJunit4Style, 1, 1, LanguageAndTestStyleHandler_JAVA_JUNIT4.new( @pathToJavaTestData + @testsuiteJavaJunit4Style, localDebug ), localDebug )
        begin
            mutator.run!
            flunk("An exception/error should have been raised but nothing was raised!")
        rescue
            exceptionRaised = $!
            expectedText = "Please make sure to add JUnit's /complete/path/to/junit.jar (including the name \"junit.jar\") to the JAVA_HOME environment variable. Also make sure that the appropriate version of JUnit is used (v3 or v4)."
            actual = exceptionRaised.to_s.include?( expectedText )
            expected = true
            assert( expected == actual, "Expected (#{expectedText}) but got (#{exceptionRaised})" )
        end        
        
        ENV["JAVA_HOME"] = oldJAVA_HOME
    end
    

    def test_mutator_can_handle_junit4_when_run_as_standalone
        if @debug then
            puts "Running '#{__method__}'"
        end
        
        stdoutAsString, stderrAsString = runCmd( @mutationCmdJunit4 )
        assertSuccessJava( stderrAsString, stdoutAsString )
    end


    def test_mutation_score_is_stable
        if @debug then
            puts "Running '#{__method__}'"
        end
        
        expectedMutationScore = 0.5
        toleranceForMutationScore = 0.23
        assertMutationScoreWhenStandalone( @mutationCmdJunit4, expectedMutationScore, toleranceForMutationScore )
    end

    
    def test_language_handler_alerts_user_of_failing_test_before_mutation_analysis_begins
        localDebug = @debug || false
        if localDebug then
            puts "Running '#{__method__}'"
        end

        mutator = Mutator.new( @pathToSourceFileJavaForTestData + @sourcefileForJavaWithError, @pathToJavaTestData + @testsuiteJavaJunit4StyleWithError, 1, 1, LanguageAndTestStyleHandler_JAVA_JUNIT4.new( @pathToJavaTestData + @testsuiteJavaJunit4StyleWithError, localDebug ), localDebug )
        assertOnFailingTests( mutator )

        mutator = Mutator.new( @pathToSourceFileJavaForTestData + @sourcefileForJavaWithSyntaxError, @pathToJavaTestData + @testsuiteJavaJunit4StyleWithSyntaxError, 1, 1, LanguageAndTestStyleHandler_JAVA_JUNIT4.new( @pathToJavaTestData + @testsuiteJavaJunit4StyleWithSyntaxError, localDebug ), localDebug )
        assertOnFailingTests( mutator, "Compilation failed:" )
    end
    
end # class 
