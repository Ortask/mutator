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

module MutatorAvailableLanguageAndTestStyleHandler

    require File.join(File.dirname(__FILE__), 'MutatorAvailableLanguageAndTestStyleHandlerPostProcessor')
    include MutatorAvailableLanguageAndTestStyleHandlerPostProcessor

    def MutatorAvailableLanguageAndTestStyleHandler.getAvailableLanguageAndTestStyleHandlers()
        require File.join(File.dirname(__FILE__), 'LanguageAndTestStyleHandler_RUBY_TESTUNIT')
        require File.join(File.dirname(__FILE__), 'LanguageAndTestStyleHandler_RUBY_RSPEC')
        require File.join(File.dirname(__FILE__), 'LanguageAndTestStyleHandler_JAVA_JUNIT3')
        require File.join(File.dirname(__FILE__), 'LanguageAndTestStyleHandler_JAVA_JUNIT4')
        
        availableLanguageHandlers = []
        availableLanguageHandlers << LanguageAndTestStyleHandler_RUBY_TESTUNIT
        availableLanguageHandlers << LanguageAndTestStyleHandler_RUBY_RSPEC
        availableLanguageHandlers << LanguageAndTestStyleHandler_JAVA_JUNIT3
        availableLanguageHandlers << LanguageAndTestStyleHandler_JAVA_JUNIT4
        
        availableLanguageHandlers = MutatorAvailableLanguageAndTestStyleHandlerPostProcessor.post_process_available_handlers( availableLanguageHandlers )
        
        return availableLanguageHandlers
    end
    
    
    def MutatorAvailableLanguageAndTestStyleHandler.getDefaultLanguageAndTestStyleHandler( availableLanguageHandlers )
        return availableLanguageHandlers[0]
    end

    
    def getAvailableLanguageAndTestStyleHandlersAsMessage( availableLanguageHandlers )
        availableLanguagesAndStyles = ""
        availableLanguageHandlers.each { |handler|
            languageHandler = handler.new( "bla" )
            availableLanguagesAndStyles << "    " + languageHandler.getTestStyle() + " (#{languageHandler.getLanguage()})" + "\n"
        }

        return """Available languages/styles are:
#{availableLanguagesAndStyles}
#{MutatorAvailableLanguageAndTestStyleHandlerPostProcessor.getExtraMessage()}
"""    
    end

    
    def MutatorAvailableLanguageAndTestStyleHandler.determineLanguageHandlerToUse( optionsHash, availableLanguageHandlers )
        language = optionsHash[:language]
        availableLanguageHandlers.each { |handler|
            if handler.new( "bla" ).getTestStyle() == language then
                return handler.new( optionsHash[:testsuite_file], optionsHash[:debug] )
            end
        }
        
        # 
        # If it got here, then no handler recognized the language/style.
        # 
        abort """Unknown given language '#{language}'

#{getAvailableLanguageAndTestStyleHandlersAsMessage( availableLanguageHandlers )}
"""    
    end

end
