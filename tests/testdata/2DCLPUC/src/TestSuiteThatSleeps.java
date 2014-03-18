/**
 * Copyright (c) 2014 "Ortask"
 * Mutator [http://ortask.com/mutator]
 *
 * This file is part of Mutator.
 *
 * Mutator is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

import java.util.ArrayList;
import java.util.List;


import junit.framework.TestCase;


public class TestSuiteThatSleeps extends TestCase 
{
	List<RectangleNoComments_mutated> testRectangles = null;

  int secondsForSleep = 40;
  
  public void testAppearsToHang_GoesToSleep() {
    try{
        Thread.sleep( secondsForSleep * 1000);
    }catch(InterruptedException e){
    }
		assertTrue( 1 == 1 );
  }

}
