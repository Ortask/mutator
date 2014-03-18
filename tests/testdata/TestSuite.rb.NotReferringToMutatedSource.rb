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

require_relative './SourceFile'

class TestSourceFile < Test::Unit::TestCase

    def setup()
        @debug = false
        if @debug then
            puts "Starting test."
        end
    end

    def teardown()
        if @debug then
            puts "Leaving test."
        end
    end
    
    
    def test1
        if @debug then
            puts "Running '#{__method__}'"
        end
        as1 = SourceFile.new()
        as2 = SourceFile.new( [] )
        expected = true
        actual = as1 == as2
        assert( expected == actual, "Expecting '#{expected}' but got '#{actual}'" )
    end


    def test2
        if @debug then
            puts "Running '#{__method__}'"
        end
        as1 = SourceFile.new()
        as2 = SourceFile.new( ["1"] )
        expected = false
        actual = as1 == as2
        assert( expected == actual, "Expecting '#{expected}' but got '#{actual}'" )
    end
    
    
    def test3
        if @debug then
            puts "Running '#{__method__}'"
        end
        as1 = SourceFile.new(["2"])
        as2 = SourceFile.new( ["1"] )
        expected = false
        actual = as1 == as2
        assert( expected == actual, "Expecting '#{expected}' but got '#{actual}'" )
    end
    
    def test4
        as1 = SourceFile.new(["2"])
        as2 = SourceFile.new( ["1"] )
        expected = false
        actual = as1 == as2
        assert( expected == actual, "Expecting '#{expected}' but got '#{actual}'" )
    end
    
    def test5
        as1 = SourceFile.new(["1"])
        as2 = SourceFile.new( ["1"] )
        expected = true
        actual = as1 == as2
        assert( expected == actual, "Expecting '#{expected}' but got '#{actual}'" )
    end
    
    def test6
        as1 = SourceFile.new(["a"])
        as2 = SourceFile.new( ["b"] )
        expected = false
        actual = as1 == as2
        assert( expected == actual, "Expecting '#{expected}' but got '#{actual}'" )
    end
    
    def test7
        as1 = SourceFile.new(["a"])
        as2 = SourceFile.new( ["b"] )
        expected = false
        actual = as1 == as2 
        assert( expected == actual, "Expecting '#{expected}' but got '#{actual}'" )
    end
    
    def test8
        as1 = SourceFile.new(["b"])
        as2 = SourceFile.new( ["b"] )
        expected = true
        actual = as1 == as2
        assert( expected == actual, "Expecting '#{expected}' but got '#{actual}'" )
    end
    
    def test9
        as1 = SourceFile.new(["        assert( actual == expected, \"Expecting '\#{expected}' but got '\#{actual}'\" )"])
        as2 = SourceFile.new( ["1"] )
        expected = false
        actual = as1 == as2
        assert( expected == actual, "Expecting '#{expected}' but got '#{actual}'" )
    end
    
    def test10
        as1 = SourceFile.new(["        assert( actual == expected, \"Expecting '\#{expected}' but got '\#{actual}'\" )"])
        as2 = SourceFile.new( ["        assert( actual == expected, \"Expecting '\#{expected}' but got '\#{actual}'\" )"] )
        expected = true
        actual = as1 == as2
        assert( expected == actual, "Expecting '#{expected}' but got '#{actual}'" )
    end

    
    
    
    def test11
        if @debug then
            puts "Running '#{__method__}'"
        end
        
        as1 = SourceFile.new(["hola yo me llamo amok!", "como", "estas", "?"])
        as2 = SourceFile.new(["hola yo me llamo amok!", "como", "estas", "?"])
        expected = true
        actual = as1 == as2
        assert( expected == actual, "Expecting '#{expected}' but got '#{actual}'" )
    end
    
    def test12
        as1 = SourceFile.new(["hola yo me llamo amok!", "como", "estas", "?"])
        as2 = SourceFile.new(["amok me llamo yo hola", "cómo", "estás", "!"])
        expected = false
        actual = as1 == as2
        assert( expected == actual, "Expecting '#{expected}' but got '#{actual}'" )
    end
    
    def test13
        as1 = SourceFile.new(["2", "3", "4", "5"])
        as2 = SourceFile.new( ["1", "3", "4", "5"] )
        expected = false
        actual = as1 == as2
        assert( expected == actual, "Expecting '#{expected}' but got '#{actual}'" )
    end
    
    def test14
        as1 = SourceFile.new(["2", "3", "4", "5"])
        as2 = SourceFile.new( ["1", "3", "4", "5"] )
        expected = false
        actual = as1 == as2
        assert( expected == actual, "Expecting '#{expected}' but got '#{actual}'" )
    end
    
    def test15
        as1 = SourceFile.new(["2", "3", "4", "5"])
        as2 = SourceFile.new( ["2", "3", "4", "5"] )
        expected = true
        actual = as1 == as2
        assert( expected == actual, "Expecting '#{expected}' but got '#{actual}'" )
    end
    
    def test16
        as1 = SourceFile.new(["2", "3", "4", "5"])
        as2 = SourceFile.new( ["5", "2", "3", "4"] )
        expected = false
        actual = as1 == as2
        assert( expected == actual, "Expecting '#{expected}' but got '#{actual}'" )
    end
    
    def test17
        as1 = SourceFile.new(["2", "3", "4", "5"])
        as2 = SourceFile.new( ["5", "2", "3", "4"] )
        expected = false
        actual = as1.== as2
        assert( expected == actual, "Expecting '#{expected}' but got '#{actual}'" )
    end    
    
    def test18
        as1 = SourceFile.new(["hola", "como", "estas", "?"])
        as2 = SourceFile.new(["hola", "como", "estas"])
        expected = false
        actual = as1 == as2
        assert( expected == actual, "Expecting '#{expected}' but got '#{actual}'" )
    end
    
    def test19
        as1 = SourceFile.new(["hola", "como", "estas", "?"])
        as2 = SourceFile.new(["?", "hola", "como", "estas"])
        expected = false
        actual = as1 == as2
        assert( expected == actual, "Expecting '#{expected}' but got '#{actual}'" )
    end
    
    
    def test20
        as1 = SourceFile.new(["hola", "como", "estas", "?"])
        as2 = SourceFile.new(["hola", "como", "estas"])
        expected = false
        actual = (as1.hash == as2.hash)
        assert( expected == actual, "Expecting '#{expected}' but got '#{actual}'" )
    end
    
    def test21
        as1 = SourceFile.new(["hola", "como", "estas", "?"])
        as2 = SourceFile.new(["?", "hola", "como", "estas"])
        expected = true
        actual = (as1.hash == as2.hash)
        assert( expected == actual, "Expecting '#{expected}' but got '#{actual}'" )        
    end

    
    def test22
        as1 = SourceFile.new(["hola", "como", "estas", "?"])
        as2 = SourceFile.new(["hola", "como", "estas"])
        expected = false
        actual = as1.eql?( as2 )
        assert( expected == actual, "Expecting '#{expected}' but got '#{actual}'" )
    end
    
    
    def test23
        as1 = SourceFile.new(["hola", "como", "estas", "?"])
        as2 = SourceFile.new(["?", "hola", "como", "estas"])
        expected = true
        actual = as1.eql?( as2 )
        assert( expected == actual, "Expecting '#{expected}' but got '#{actual}'" )        
    end

    
    def test24
        set1 = Set.new
        set2 = Set.new
        set1 << SourceFile.new(["hola"])
        set2 << SourceFile.new(["?"])
        actual = (set2 & set1).to_a
        expected = []
        assert( expected == actual, "Expecting '#{expected}' but got '#{actual}'" )        
        actual = (set1 & set2).to_a
        expected = []
        assert( expected == actual, "Expecting '#{expected}' but got '#{actual}'" )
    end
    
    
    def test25
        set1 = Set.new
        set2 = Set.new
        set1 << SourceFile.new(["hola", "como", "estas", "?"])
        set2 << SourceFile.new(["hola", "como", "estas"])
        actual = (set2 & set1).to_a
        expected = []
        assert( expected == actual, "Expecting '#{expected}' but got '#{actual}'" )
        actual = (set1 & set2).to_a
        expected = []
        assert( expected == actual, "Expecting '#{expected}' but got '#{actual}'" )
    end

    def test26
        set1 = Set.new
        set2 = Set.new
        set1 << SourceFile.new(["1", "2", "3", "4"])
        set2 << SourceFile.new(["1", "2", "3"])
        actual = (set2 & set1).to_a
        expected = []
        assert( expected == actual, "Expecting '#{expected}' but got '#{actual}'" )
        actual = (set1 & set2).to_a
        expected = []
        assert( expected == actual, "Expecting '#{expected}' but got '#{actual}'" )
    end
    
    
    def test27
        set1 = Set.new
        set2 = Set.new
        set1 << SourceFile.new(["hola", "como", "estas", "?"])
        set2 << SourceFile.new(["?", "hola", "como", "estas"])
        actual = (set2 & set1).to_a
        expected = set1.to_a
        assert( expected == actual, "Expecting '#{expected}' but got '#{actual}'" )        
        actual = (set1 & set2).to_a
        expected = set2.to_a
        assert( expected == actual, "Expecting '#{expected}' but got '#{actual}'" )

    end
    
    
end # class 
