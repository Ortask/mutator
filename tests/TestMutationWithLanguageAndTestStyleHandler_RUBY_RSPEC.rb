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
require_relative './TestStandaloneUtils'
include TestStandaloneUtils

class TestMutationWithLanguageAndTestStyleHandler_RUBY_RSPEC < Test::Unit::TestCase

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

        @pathToSourceFileRspecForTestData = @locationOfTestFiles + "/rspec/lib/naught/null_class_builder/commands/"
        @sourcefileForRspec = "mimic.rb_NoComments.rb"
        @sourcefileForRspecWithError = "mimic.rb_NoComments_WithError.rb"
        @sourcefileForRspecWithSyntaxError = "mimic.rb_NoComments_WithSyntaxError.rb"
        #
        @pathToRspecTestData = @locationOfTestFiles + "/rspec/spec/"
        @testsuiteRubyRspecStyle = "mimic_spec.rb.TestForMutant.rb"
        @testsuiteRubyRspecStyleWithError = "mimic_spec.rb.WithError.rb"
        @testsuiteRubyRspecStyleWithSyntaxError = "mimic_spec.rb.WithSyntaxError.rb"
        @testsuiteRubyRspecStyleWithLoadError = "mimic_spec.rb.WithLoadError.rb"
        
        @mutationCmdRspec = "ruby #{@mutatorName} -s \"#{@pathToSourceFileRspecForTestData + @sourcefileForRspec}\" -t \"#{@pathToRspecTestData + @testsuiteRubyRspecStyle}\" -l rspec"
        
        override_setup_environment_standalone(__FILE__)
    end

    
    
    def teardown
        if @debug then
            puts "Leaving test."
        end
        
        cleanUpTestData( @pathToSourceFileRspecForTestData )
    end

    
    
    
    def test_mutator_can_be_given_rspec_language_handler_as_object
        return unless !defined?( @skipTest )
        localDebug = @debug || false
        if localDebug then
            puts "Running '#{__method__}'"
        end

        mutator = Mutator.new( @pathToSourceFileRspecForTestData + @sourcefileForRspec, @pathToRspecTestData + @testsuiteRubyRspecStyle, 1, 1, LanguageAndTestStyleHandler_RUBY_RSPEC.new( @pathToRspecTestData + @testsuiteRubyRspecStyle, localDebug ), localDebug )
        begin
            mutator.run!
        rescue
            exceptionRaised = $!
            fail("No exception/error should have been raised but got '#{exceptionRaised}'")
        end
        
        k = 1
        minimumMutations = 1
        assertMutations( getDiffCount( @pathToSourceFileRspecForTestData + @sourcefileForRspec, @pathToSourceFileRspecForTestData + @sourcefileForRspec + @fullExtensionForMutatedSourceFile_Ruby, localDebug ), k, minimumMutations, localDebug)
    end


    def test_language_handler_alerts_user_of_failing_test_before_mutation_analysis_begins
        return unless !defined?( @skipTest )
        localDebug = @debug || false
        if localDebug then
            puts "Running '#{__method__}'"
        end

        mutator = Mutator.new( @pathToSourceFileRspecForTestData + @sourcefileForRspecWithError, @pathToRspecTestData + @testsuiteRubyRspecStyleWithError, 1, 1, LanguageAndTestStyleHandler_RUBY_RSPEC.new( @pathToRspecTestData + @testsuiteRubyRspecStyleWithError, localDebug ), localDebug )
        assertOnFailingTests( mutator )

        mutator = Mutator.new( @pathToSourceFileRspecForTestData + @sourcefileForRspec, @pathToRspecTestData + @testsuiteRubyRspecStyleWithLoadError, 1, 1, LanguageAndTestStyleHandler_RUBY_RSPEC.new( @pathToRspecTestData + @testsuiteRubyRspecStyleWithLoadError, localDebug ), localDebug )
        assertOnFailingTests( mutator )
        
        mutator = Mutator.new( @pathToSourceFileRspecForTestData + @sourcefileForRspec, @pathToRspecTestData + @testsuiteRubyRspecStyleWithSyntaxError, 1, 1, LanguageAndTestStyleHandler_RUBY_RSPEC.new( @pathToRspecTestData + @testsuiteRubyRspecStyleWithSyntaxError, localDebug ), localDebug )
        assertOnFailingTests( mutator )
    end


    def test_mutator_can_handle_rspec_when_run_as_standalone
        if @debug then
            puts "Running '#{__method__}'"
        end
        
        stdoutAsString, stderrAsString = runCmd( @mutationCmdRspec )
        assertSuccess( stderrAsString, stdoutAsString )
    end


    def test_mutation_score_is_stable
        if @debug then
            puts "Running '#{__method__}'"
        end
        
        expectedMutationScore = 1.0
        toleranceForMutationScore = 0.2
        assertMutationScoreWhenStandalone( @mutationCmdRspec, expectedMutationScore, toleranceForMutationScore )
    end

end # class 
