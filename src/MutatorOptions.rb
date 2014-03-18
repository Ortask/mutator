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

module MutatorOptions
    require 'optparse'
    require 'pathname'
    require File.join(File.dirname(__FILE__), 'MutatorVersion')
    include MutatorVersion
    require File.join(File.dirname(__FILE__), 'MutatorAvailableLanguageAndTestStyleHandler')
    include MutatorAvailableLanguageAndTestStyleHandler

    @languageHandlers = MutatorAvailableLanguageAndTestStyleHandler.getAvailableLanguageAndTestStyleHandlers()
    
    @@default_runs = 1
    @@default_mutation_order = 1 # k-order mutation means k mutations per run (i.e. per mutant)
    @@default_language_handler = MutatorAvailableLanguageAndTestStyleHandler.getDefaultLanguageAndTestStyleHandler( @languageHandlers )
    @@default_language = @@default_language_handler.new( "bla" ).getLanguage()
    @@default_test_style = @@default_language_handler.new( "bla" ).getTestStyle()
    
    @options = {}
    @options[:runs] = @@default_runs
    @options[:mutaton_order] = @@default_mutation_order
    @options[:language] = @@default_test_style
    @options[:debug] = false
    @options[:run_until_live] = false
    # 
    # Prepare the way the options are processed.
    # 
    @MutatorOptionsProcessor = OptionParser.new do |opts|
        opts.on("-s", "--source_file SOURCEFILE", "The source file to mutate.") do |fileToMutate|
            @options[:source_file] = fileToMutate
        end
        opts.on("-t", "--testsuite_file TESTSUITE", "The test suite file to run.") do |testSuiteToRun|
            @options[:testsuite_file] = testSuiteToRun
        end    
        opts.on("-r", "--runs [RUNS]", "The number of times to run this script. Default is #{@options[:runs]}.") do |numberOfRuns|
            @options[:runs] = numberOfRuns.to_i
        end
        opts.on("-m", "--mutaton_order [ORDER]", "The number of mutations to apply to a single mutation "\
                      "(a k-order mutant has k mutations per run). Default is #{@options[:mutaton_order]}.") do |mutationOrder|
            @options[:mutaton_order] = mutationOrder.to_i
        end
        opts.on("-l", "--language [LANGUAGE]", "The language/style the tests are written in. Default is '#{@@default_test_style}' (#{@@default_language}).") do |language|
            @options[:language] = language.downcase
        end
        opts.on("-d", "--debug", "Enables debugging.") do
            @options[:debug] = true
        end
        opts.on("-i", "--list", "Shows a list of available language/style handlers.") do
            puts "\n" + MutatorAvailableLanguageAndTestStyleHandler.getAvailableLanguageAndTestStyleHandlersAsMessage( @languageHandlers ) + "\n"
            exit 0
        end    
        opts.on("-a", "--alive", "Runs until a live mutant is found.") do
            @options[:run_until_live] = true
        end
    end
    @MutatorOptionsProcessor.banner = """
    Usage: mutator.rb -s SOURCEFILE -t TESTSUITE [options]

    Options:
    """

    
    # 
    # Process CLI options.
    # 
    def parse()
        # 
        # Process the options.
        # 
        begin
            @MutatorOptionsProcessor.version = VERSION
            @MutatorOptionsProcessor.parse!
            requiredParams = [:source_file, :testsuite_file]
            missingParams = requiredParams.select { |param| 
                @options[param].nil? 
            }
            if not missingParams.empty?
                puts "Required parameters are missing: #{missingParams.join(', ')}"
                puts @MutatorOptionsProcessor
                exit 1
            end
        rescue
            puts $!.to_s
            puts @MutatorOptionsProcessor
            exit 1
        end
    end
    
    # 
    # Return the options.
    # 
    def options()
        return @options
    end

    def setProgramName( theProgramName )
        @MutatorOptionsProcessor.program_name = theProgramName 
    end
    
    def setUsage( theUsage )
        @MutatorOptionsProcessor.banner = theUsage 
    end

    def getDefaultRuns()
        return @@default_runs
    end
    
    def getDefaultMutationOrder()
        return @@default_mutation_order
    end
    
    def getDefaultLanguageHandler( testSuiteToRun, debug=false )
        return @@default_language_handler.new( testSuiteToRun, debug )
    end

    def getDefaultLanguage()
        return @@default_language
    end
    
    def getDefaultTestStyle()
        return @@default_test_style
    end
    
    def determineLanguageHandler()
        MutatorAvailableLanguageAndTestStyleHandler.determineLanguageHandlerToUse( @options, @languageHandlers )
    end
end
