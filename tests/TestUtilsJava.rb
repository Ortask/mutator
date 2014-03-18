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

module TestUtilsJava

    def getDiffCountJava( sourcefileOriginal, sourcefileMutated, debug = false )
        # 
        # First copy the mutant to another java file and revert the 
        # references to the mutant back to the original. We need to
        # do this since Java requires classes to be saved in files
        # with the exact same name, so doing a diff without this
        # preparation will throw many false positives. Remember:
        # we only want to know how many actual mutations Mutator
        # created.
        # 
        tempSourcefileMutated = sourcefileMutated + ".temp"
        baseNameOfMutatedSourceFileNoExtension = File.basename( sourcefileMutated, @javaFileExtension )    # takes away the given extension
        baseNameOfOriginalSourceFileNoExtension = File.basename( sourcefileOriginal, @javaFileExtension )    # takes away the given extension
        mutatedFileContentsOriginal = File.read( sourcefileMutated )
        mutatedFileContentsOriginal.gsub!(/#{baseNameOfMutatedSourceFileNoExtension}/, baseNameOfOriginalSourceFileNoExtension)
        File.open( tempSourcefileMutated , 'w') {|f| f.write( mutatedFileContentsOriginal ) }        

        if debug then
          puts "\n#{__FILE__}::#{__method__}():#{__LINE__}: Diff'ing tempSourcefileMutated=(#{tempSourcefileMutated}) and sourcefileOriginal=(#{sourcefileOriginal})\n"
        end

        return getDiffCount( sourcefileOriginal, tempSourcefileMutated, debug, "java" )
    end
    
    
    def assertSuccessJava( stderrAsString, stdoutAsString )
        actualText = stderrAsString
        unexpectedText = "Caused by"
        expected = false
        actual = actualText.include?(unexpectedText)
        assert( expected == actual, "Not Expected '#{unexpectedText}' but got '#{actualText}'" )

        assertSuccess( stderrAsString, stdoutAsString )        
    end
    
end
