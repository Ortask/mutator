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

require File.join(File.dirname(__FILE__), 'LanguageAndTestStyleHandler_JAVA')

class LanguageAndTestStyleHandler_JAVA_JUNIT3 < LanguageAndTestStyleHandler_JAVA

    def getTestStyle
        return "junit3"
    end

    
    def post_initialize()
        @junitRunner = "junit.textui.TestRunner"
        super
    end
end
