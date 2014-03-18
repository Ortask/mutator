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

require 'set'

class SourceFile
    def initialize( sourceFileAsArray=[] )
        if Array != sourceFileAsArray.class then
            raise "The parameter must be of class Array, but it was of type '#{sourceFileAsArray.class}'"
        end
        
        sourceFileAsArray.each {|elem|
            if elem.class != String then
                raise "All members of an SourceFile must be of class String, but one was of type '#{elem.class}'"
            end
        }




        @SourceFile = Set.new( sourceFileAsArray )        
    end
    
    
    def SourceFile.getEmpty()
        return SourceFile.new()
    end
    
    
    def to_a()
        return @SourceFile.to_a
    end
    
    
    def empty?
        return @SourceFile.empty?
    end
    
    
    def ==( anotherSourceFile )
        if SourceFile != anotherSourceFile.class then
            raise "The parameter must be of class SourceFile, but it was of type '#{anotherSourceFile.class}'"
        end
        return to_a() == anotherSourceFile.to_a()
    end
    

   

   
    def to_s()
        return to_a().to_s()
    end
    
    
    def to_set()
        return @SourceFile
    end
    
    
   

   
    def eql?( anotherSourceFile )
        return self.to_set() == anotherSourceFile.to_set()
    end
    
   

   
    def hash()
        return @SourceFile.hash
    end

end
