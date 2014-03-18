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

class LanguageAndTestStyleHandler_JAVA < LanguageAndTestStyleHandler

    def post_initialize()
        @classPath = ENV["JAVA_HOME"]        
        @absolutePathToTestSuite = File.dirname( @testSuiteToRun )

        if @debug then
            puts "@classPath=(#{@classPath})\n\n"
            puts "@absolutePathToTestSuite=(#{@absolutePathToTestSuite})\n\n"
        end
    end


    def getLanguage()
        return "java"
    end

    
    def getFileExtension()
        return ".java"
    end

    
    def getPathAndFileNameOfMutant( fileToMutate, suffixForMutatedSourceFile )
        return File.dirname( fileToMutate ) + "/" + File.basename( fileToMutate, getFileExtension() ) + suffixForMutatedSourceFile + getFileExtension()
    end
    
    
    def testSuiteDoesNotExistMsg
        return "Please create a test suite called '#{@testSuiteToRun}' and "\
            "modify its references from:\n\t '#{@baseNameOfFileNoExtension}'\n"\
            " to \n\t '#{@baseNameOfFileNoExtension}#{@suffixForMutatedSourceFile}'"
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
                  testResults.include?( "Error:" ) || 
                  testResults.include?( "error:" ) || 
                  testResults.include?( "Failure:" ) || 
                  testResults.include?( "syntax error" ) || 
                  testResults.include?( "LoadError" ) || 
                  testResults.include?( "NoClassDefFoundError" ) || 
                  testResults.include?( "'javac' is not recognized" ) || 
                  testResults.include?( "Caused by:" ) || 
                  testResults.include?( "Class not found" ) 
                )
    end

    
    def extraMsgForFailingTestSuite( testResults )
        ""
    end

    
    def extraMsgForPreMutationAnalysisTestRun( testResults )
        ""
    end

    
    def prepareTestSuiteForPreMutationAnalysisRun
        # 
        # Modify all the references in the source file that will be mutated so 
        # that it uses its new (mutated) references.
        # 
        mutatedSourceFile = @pathToFile + @baseNameOfFileNoExtension + @fullExtensionForMutatedSourceFile
        if @debug then
          puts "\n\n@pathToFile = (#{@pathToFile})"
          puts "\n\n@baseNameOfFileNoExtension = (#{@baseNameOfFileNoExtension})"
          puts "\n\n@fullExtensionForMutatedSourceFile = (#{@fullExtensionForMutatedSourceFile})"
          puts "\n\nmutatedSourceFile = (#{mutatedSourceFile})"
        end
        @fileToMutateContentsOriginal.gsub!(/#{@baseNameOfFileNoExtension}/, @baseNameOfFileNoExtension + File.basename( @fullExtensionForMutatedSourceFile, getFileExtension() ))
        File.open( mutatedSourceFile , 'w') {|f| f.write( @fileToMutateContentsOriginal ) }
    end

    
    def post_runPriorChecks
        contentsOfTestSuiteForMutant = File.read( @testSuiteToRun )
        if nil == ( contentsOfTestSuiteForMutant =~ /#{@suffixForMutatedSourceFile}/ ) then 
            puts
            raise "#{__FILE__}::#{__method__}():#{__LINE__}: Error in '#{@testSuiteToRun}': the test suite is not using the mutated version! \n\n"\
            "Please modify its references from:\n\t '#{@baseNameOfFileNoExtension}'\n"\
            " to \n\t '#{@baseNameOfFileNoExtension + @suffixForMutatedSourceFile}'"
        end
    end

    
    def runTestSuite( redirectStderrToStdout=false )
        output = ""
        
        redirectionStr = ""
        if redirectStderrToStdout then
            redirectionStr = " 2>&1"
        end


        # 
        # Need to fist compile source file so that it creates a .class file that Java
        # can use.
        # 
        output = ""
        cmd = "javac -cp \"#{@classPath}\";\"#{@absolutePathToTestSuite}\" -d \"#{@absolutePathToTestSuite}\" -s \"#{@absolutePathToTestSuite}\" \"#{@testSuiteToRun}\" 2>&1"
        if @debug then
            puts "\n\n#{__FILE__}::#{__method__}():#{__LINE__}: Will compile the test suite to use the new mutant: (#{cmd})\n\n"
        end                
        output << `#{cmd}`
        if @debug then
          puts "\nCompilation results = (#{output})\n"
        end  
        if !allTestsPassed?( output ) then
            raise "#{__FILE__}::#{__method__}():#{__LINE__}: Compilation failed:"\
            " (#{output})\n\n"\
            "Current classpath = (#{@classPath})\n\n"\
            "Please make sure to add JUnit's /complete/path/to/junit.jar "\
            "(including the name \"junit.jar\") to the JAVA_HOME "\
            "environment variable. Also make sure that the appropriate "\
            "version of JUnit is used (v3 or v4)."
        end

        
        # 
        # Now run the test suite.
        # 
        nameOfTestSuiteToRunWithNoExtension = File.basename( @testSuiteToRun, getFileExtension() )    # takes away the given extension
        cmd = "java -cp \"#{@classPath}\";\"#{@absolutePathToTestSuite}\" #{@junitRunner} #{nameOfTestSuiteToRunWithNoExtension} #{redirectionStr}"
        
        if @debug then
            puts "\n\n#{__FILE__}::#{__method__}():#{__LINE__}: Will run the following command (#{cmd})\n\n"
        end                
        output << `#{cmd}`
        if @debug then
          puts "The output of the command was: (#{output})"
        end
        return output
    end

    
    def wasMutantDOA?( testResults )
        return '' == testResults
    end

    
    def wasMutantKilled?( testResults )
        return ( testResults.include?( "failures:" ) || testResults.include?( "FAILURES!!!" ) )
    end

end
