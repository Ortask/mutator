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
require_relative './TestUtils'
include TestUtils
require_relative './MutatorVersion'
include MutatorVersion
require_relative './TestStandaloneUtils'
include TestStandaloneUtils

class TestMutator < Test::Unit::TestCase

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
                            
        @sourcefile = "SourceFile_NoComments.rb"
        @testsuite = "TestSuite.rb"
        @testsuiteRubyTestUnitStyle = @testsuite

        @mutationCmd = "ruby #{@mutatorName} -s \"#{@locationOfTestFiles + @sourcefile}\" -t \"#{@locationOfTestFiles + @testsuite}\" "        
        @mutationCmdNoParams = "ruby #{@mutatorName}"        
        @mutationCmdNoAllRequiredParamsOnlyTestFile = "ruby #{@mutatorName} -t #{@locationOfTestFiles + @testsuite}"
        @mutationCmdNoAllRequiredParamsOnlySourceFile = "ruby #{@mutatorName} -s #{@locationOfTestFiles + @sourcefile}"
        
        
        override_setup_environment_standalone(__FILE__)
    end
    
    
    def teardown()
        if @debug then
            puts "Leaving test."
        end
        
        cleanUpTestData( @locationOfTestFiles )
    end
    
    
    def test_alert_when_no_parameters_are_given
        if @debug then
            puts "Running '#{__method__}'"
        end
        
        stdoutAsString, stderrAsString = runCmd( @mutationCmdNoParams )

        actualText = stdoutAsString
        expectedText = "Required parameters are missing: source_file, testsuite_file"
        expected = true
        actual = actualText.include?(expectedText)
        assert( expected == actual, "Expected '#{expectedText}' but got '#{actualText}'" )
    end

    
    def test_alert_when_not_all_required_parameters_are_given
        if @debug then
            puts "Running '#{__method__}'"
        end
        
        stdoutAsString, stderrAsString = runCmd( @mutationCmdNoAllRequiredParamsOnlyTestFile  )
        
        actualText = stdoutAsString
        expectedText = "Required parameters are missing: source_file"
        expected = true
        actual = actualText.include?(expectedText)
        assert( expected == actual, "Expected '#{expectedText}' but got '#{actualText}'" )
        

        stdoutAsString, stderrAsString = runCmd( @mutationCmdNoAllRequiredParamsOnlySourceFile  )
        
        actualText = stdoutAsString
        expectedText = "Required parameters are missing: testsuite_file"
        expected = true
        actual = actualText.include?(expectedText)
        assert( expected == actual, "Expected '#{expectedText}' but got '#{actualText}'" )
    end

    
    

    
    def test_mutator_can_be_instantiated_with_defaults
        return unless !defined?( @skipTest )
        if @debug then
            puts "Running '#{__method__}'"
        end
        localDebug = @debug || false
        
        mutator = Mutator.new( @locationOfTestFiles + @sourcefile, @locationOfTestFiles + @testsuite )
        begin
            mutator.run!
        rescue
            exceptionRaised = $!
            fail("No exception/error should have been raised but got '#{exceptionRaised}'")
        end

        k = 1
        minimumMutations = 1
        assertMutations( getDiffCount( @locationOfTestFiles + @sourcefile, @locationOfTestFiles + @sourcefile + @fullExtensionForMutatedSourceFile_Ruby, localDebug ), k, minimumMutations, localDebug )
    end
    

    
    # 
    # Due to the stochastic nature of the mutations, this test might fail
    # sometimes. 
    # 
    def test_mutator_can_be_instantiated_with_parameters
        return unless !defined?( @skipTest )
        localDebug = @debug || false
        if localDebug then
            puts "Running '#{__method__}'"
        end
        
        runs = 10
        k = 3
        minimumMutations = 2
        mutator = Mutator.new( @locationOfTestFiles + @sourcefile, @locationOfTestFiles + @testsuite, runs, k, Mutator.getDefaultLanguageHandler( @locationOfTestFiles + @testsuite ), localDebug )
        begin
            mutator.run!
        rescue
            exceptionRaised = $!
            fail("No exception/error should have been raised but got '#{exceptionRaised}'")
        end
        actual = mutator.getRunsExecuted()
        expected = runs
        assert( expected == actual, "Expecting #{expected} but got #{actual}" )
        assertMutations( getDiffCount( @locationOfTestFiles + @sourcefile, @locationOfTestFiles + @sourcefile + @fullExtensionForMutatedSourceFile_Ruby ), k, minimumMutations )
    end
    
    
    
    

    
    # 
    # Since the Random module uses the very (statistically) robust 
    # pseudo-random number generator called Mersenne Twister, the 
    # generated numbers will be well distributed.
    # Therefore, the mutations will also be well distributed.
    # 
    def test_mutations_are_independent_and_identically_distributed
        if @debug then
            puts "Running '#{__method__}'"
        end
        assert( true )
    end

    
    

    def test_alert_when_bad_language_handler_is_given
        return unless !defined?( @skipTest )
        if @debug then
            puts "Running '#{__method__}'"
        end
        
        language = "random!"
        begin
            Mutator.new( @locationOfTestFiles + @sourcefile, @locationOfTestFiles + @testsuite, 1, 1, language )
            flunk("An exception/error should have been raised but nothing was raised!")
        rescue
            exceptionRaised = $!
            expected = true
            actual = exceptionRaised.to_s.include?( "The language/style handler must be of type 'LanguageAndTestStyleHandler' but was of type" ) 
            assert( expected == actual, "Was not expecting: ('#{exceptionRaised.to_s}')"  )
        end
    end


    # 
    # This is an interesting test that needs more thought. The reason for 
    # this is because each LanguageAndTestStyleHandler takes responsibility
    # of its own language and test suite, so as long as Mutator gets a 
    # LanguageAndTestStyleHandler, it does not care what that handler does.
    #
    # For now, this test serves as documentation that mutator will "trust"
    # and delegate to the handler, even if the handler does crazy things.
    # 
    def test_mutator_delegates_to_language_handler
        return unless !defined?( @skipTest )
        localDebug = @debug || false
        if localDebug then
            puts "Running '#{__method__}'"
        end
        
        language = LanguageAndTestStyleHandler_MockEmpty.new( @locationOfTestFiles + @testsuiteRubyTestUnitStyle, localDebug )
        mutator = Mutator.new( @locationOfTestFiles + @sourcefile, @locationOfTestFiles + @testsuite, 1, 1, language )
        mutator.run!
    end

    
    
    def test_alert_when_unrecognized_language_handler_is_given
        return unless !defined?( @skipTest )
        localDebug = @debug || false
        if localDebug then
            puts "Running '#{__method__}'"
        end
        
        language = LanguageAndTestStyleHandler_WithUnrecognizedLanguage.new( @locationOfTestFiles + @testsuiteRubyTestUnitStyle, localDebug )
        mutator = Mutator.new( @locationOfTestFiles + @sourcefile, @locationOfTestFiles + @testsuite, 1, 1, language )
        begin
            mutator.run!
            flunk("An exception/error should have been raised but nothing was raised!")
        rescue
            exceptionRaised = $!
            expected = true
            expectedText = "Unknown given language '#{language.getLanguage}'"
            actual = exceptionRaised.to_s.include?( expectedText )
            assert( expected == actual, "Expecting: (#{expectedText}). Was not expecting: ('#{exceptionRaised.to_s}')"  )
        end
    end

    
    def test_alert_when_unrecognized_language_handler_is_given_when_invoked_as_standalone
        localDebug = @debug || false
        if localDebug then
            puts "Running '#{__method__}'"
        end
        
        language = "doesnotexist"
        stdoutAsString, stderrAsString = runCmd( @mutationCmd + " -l " + language)
        expected = true
        expectedText = "Unknown given language '#{language}'"
        actualText = stderrAsString
        actual = ( actualText.include?( expectedText ) )
        expected = true
        assert( expected == actual, "Expected (#{expectedText}) but got (#{actualText})" )

        expectedText = """Available languages/styles are:
    test/unit (ruby)
    rspec (ruby)
    junit3 (java)
    junit4 (java)

"""
        actualText = stderrAsString
        actual = ( actualText.include?( expectedText ) )
        expected = true
        assert( expected == actual, "Expected (#{expectedText}) but got (#{actualText})" )
    end


    def test_mutator_shows_list_of_available_language_and_test_style_handlers_when_invoked_as_standalone
        localDebug = @debug || false
        if localDebug then
            puts "Running '#{__method__}'"
        end
        
        stdoutAsString, stderrAsString = runCmd( @mutationCmd + " -i ")
        expected = true
        expectedText = """Available languages/styles are:
    test/unit (ruby)
    rspec (ruby)
    junit3 (java)
    junit4 (java)

"""
        actualText = stdoutAsString
        actual = ( actualText.include?( expectedText ) )
        expected = true
        assert( expected == actual, "Expected (#{expectedText}) but got (#{actualText})" )
    end
    
    
    def test_usage_when_invoked_as_standalone
        if @debug then
            puts "Running '#{__method__}'"
        end
        
        stdoutAsString, stderrAsString = runCmd( @mutationCmd + " -h")
        expectedText = """Usage: #{@mutatorName} -s SOURCEFILE -t TESTSUITE [options]

    Options:
    
    -s, --source_file SOURCEFILE     The source file to mutate.
    -t, --testsuite_file TESTSUITE   The test suite file to run.
    -r, --runs [RUNS]                The number of times to run this script. Default is 1.
    -m, --mutaton_order [ORDER]      The number of mutations to apply to a single mutation (a k-order mutant has k mutations per run). Default is 1.
    -l, --language [LANGUAGE]        The language/style the tests are written in. Default is 'test/unit' (ruby).
    -d, --debug                      Enables debugging.
    -i, --list                       Shows a list of available language/style handlers.
    -a, --alive                      Runs until a live mutant is found.
""" 
        actualText = stdoutAsString
        actual = ( actualText.include?( expectedText ) )
        expected = true
        assert( expected == actual, "Expected '#{expectedText}' but got '#{actualText}'" )
        assertEmptyString( stderrAsString )
    end
    

    def test_mutator_prints_version
        if @debug then
            puts "Running '#{__method__}'"
        end
        
        # 
        # Mutator prints version when called on CLI.
        # 
        stdoutAsString, stderrAsString = runCmd( @mutationCmd + " -v")
        expectedText = VERSION
        actualText = stdoutAsString
        actual = ( actualText.include?( expectedText ) )
        expected = true
        assert( expected == actual, "Expected '#{expectedText}' but got '#{actualText}'" )
        assertEmptyString( stderrAsString )

        # 
        # Mutator gives version when instantiated as object.
        # 
        return unless !defined?( @skipTest )
        mutator = Mutator.new( "dummy", "dummy" )
        expectedText = VERSION
        actualText = mutator.getVersion
        actual = ( actualText.include?( expectedText ) )
        expected = true
        assert( expected == actual, "Expected '#{expectedText}' but got '#{actualText}'" )
        assertEmptyString( stderrAsString )
    end

    
    def test_default_language_handler_is_ruby
        if @debug then
            puts "Running '#{__method__}'"
        end
        
        # puts @mutationCmd
        stdoutAsString, stderrAsString = runCmd( @mutationCmd )
        assertSuccess( stderrAsString, stdoutAsString )
        
        stdoutAsString, stderrAsString = runCmd( @mutationCmd + " -l test/unit" )
        assertSuccess( stderrAsString, stdoutAsString )
    end




    
    #
    # Ensure that there are k mutations in the mutated file
    #
    def test_mutation_quantity_is_honored
        if @debug then
            puts "Running '#{__method__}'"
        end
        localDebug = @debug || false
        
        extensionForCmd = ""
        if localDebug then
          extensionForCmd = " -d "
        end
          
        
        #
        # Choosing odd number of mutations will assure we can see the 
        # mutations applied to the file. Choosing an even number of 
        # mutations might cause the mutation to be applied at the
        # same place in the file (due to the stochastic nature of 
        # the mutator script), which might revert the mutation back
        # to the original version.
        # 
        k = 3
        minimumMutations = 1
        # 
        stdoutAsString, stderrAsString = runCmd( @mutationCmd + " -m #{k}" + extensionForCmd, localDebug )
        assertSuccess( stderrAsString, stdoutAsString, localDebug )
        assertMutations( getDiffCount( @locationOfTestFiles + @sourcefile, @locationOfTestFiles + @sourcefile + @fullExtensionForMutatedSourceFile_Ruby, localDebug ), k, minimumMutations, localDebug )
        

        k = 5
        minimumMutations = 2
        stdoutAsString, stderrAsString = runCmd( @mutationCmd + " -m #{k}" + extensionForCmd)
        assertSuccess( stderrAsString, stdoutAsString, localDebug )
        assertMutations( getDiffCount( @locationOfTestFiles + @sourcefile, @locationOfTestFiles + @sourcefile + @fullExtensionForMutatedSourceFile_Ruby, localDebug ), k, minimumMutations, localDebug )
    end

    
    def test_mutation_analysis_results_are_accessible_when_mutator_is_an_object
        return unless !defined?( @skipTest )
        localDebug = @debug || false
        if localDebug then
            puts "Running '#{__method__}'"
        end

        runs = 50
        k = 1
        minimumMutations = 2
        mutator = Mutator.new( @locationOfTestFiles + @sourcefile, @locationOfTestFiles + @testsuite, runs, k, Mutator.getDefaultLanguageHandler( @locationOfTestFiles + @testsuite ), localDebug )
        begin
            mutator.run!
        rescue
            exceptionRaised = $!
            fail("No exception/error should have been raised but got '#{exceptionRaised}'")
        end
        #
        expectedMutationScore = 0.6
        toleranceForMutationScore = 0.2
        actualMutationScore = mutator.getMutationScore()
        assert_in_delta( expectedMutationScore, actualMutationScore, toleranceForMutationScore, "\n\nexpectedMutationScore = #{expectedMutationScore}\nactualMutationScore=#{actualMutationScore}\n")        
        #
        expected = true
        actual = ( mutator.getMutantsKilled() > 0 )
        assert( expected == actual, "Expecting #{expected} but got #{actual}" )
        #
        expected = true
        actual = ( mutator.getMutantsAlive() > 0 )
        assert( expected == actual, "Expecting #{expected} but got #{actual}" )
        #
        expected = true
        actual = ( mutator.getMutantsDOA() >= 0 )
        assert( expected == actual, "Expecting #{expected} but got #{actual}" )
        #
        expected = runs
        actual = mutator.getMutantsDOA() + mutator.getMutantsKilled() + mutator.getMutantsAlive() 
        assert( expected == actual, "Expecting #{expected} but got #{actual}" )

    end


    def test_mutator_stops_until_it_finds_a_live_mutant
        localDebug = @debug || false
        if localDebug then
            puts "Running '#{__method__}'"
        end
        
        stdoutAsString, stderrAsString = runCmd( @mutationCmd + " -a" )
        assertSuccess( stderrAsString, stdoutAsString )
        expectedText = "Mutants Alive = '1'"
        expected = true
        actual = stdoutAsString.include?( expectedText ) 
        assert( expected == actual, "Expecting (#{expectedText}) but got (#{stdoutAsString})" )
        expectedText = "Found a live mutant!"
        expected = true
        actual = stdoutAsString.include?( expectedText ) 
        assert( expected == actual, "Expecting (#{expectedText}) but got (#{stdoutAsString})" )
        
        
        return unless !defined?( @skipTest )
        #
        # runs should not matter when telling Mutator to 
        # run until a live mutant is found.
        #
        runs = 0
        k = 1
        runUntilLiveMutantIsFound = true
        mutator = Mutator.new( @locationOfTestFiles + @sourcefile, @locationOfTestFiles + @testsuite, runs, k, Mutator.getDefaultLanguageHandler( @locationOfTestFiles + @testsuite ), localDebug, runUntilLiveMutantIsFound )
        begin
            mutator.run!
        rescue
            exceptionRaised = $!
            fail("No exception/error should have been raised but got '#{exceptionRaised}'")
        end
        actual = ( mutator.getRunsExecuted() > 0 )
        expected = true
        assert( expected == actual, "Expecting #{expected} but got #{actual}" )
        actual = mutator.getMutantsAlive()
        expected = 1
        assert( expected == actual, "Expecting #{expected} but got #{actual}" )

    end
    
    
end # class 
