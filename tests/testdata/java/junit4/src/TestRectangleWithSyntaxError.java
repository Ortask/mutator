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


import org.junit.Test;
import org.junit.Ignore;
import org.junit.runner.RunWith;


public class TestRectangleWithSyntaxError  
{

	List<RectangleNoCommentsWithSyntaxError> testRectangles = null;
	
  
  @Test
  public void ThisIsAJunit4Test()
  {
    org.junit.Assert.assertTrue( true );
  }
  
  @Test
	public void BadRectangle()
	{
		try
		{
			RectangleNoCommentsWithSyntaxError r = new RectangleNoCommentsWithSyntaxError(0, 3);
			org.junit.Assert.fail();
		}
		catch(Exception e)
		{
			e.getMessage();
		}

		try
		{
			RectangleNoCommentsWithSyntaxError r = new RectangleNoCommentsWithSyntaxError(0, -3);
			org.junit.Assert.fail();
		}
		catch(Exception e)
		{
			e.getMessage();
		}
		
		
		try
		{
			RectangleNoCommentsWithSyntaxError r = new RectangleNoCommentsWithSyntaxError(2, 0);
			org.junit.Assert.fail();
		}
		catch(Exception e)
		{
			e.getMessage();
		}
		
		try
		{
			RectangleNoCommentsWithSyntaxError r = new RectangleNoCommentsWithSyntaxError(-3, -3);
			org.junit.Assert.fail();
		}
		catch(Exception e)
		{
			e.getMessage();
		}
		
	}
	
	
	
	
	
	@Test
	public void OneRectangle()
	{
		testRectangles = new ArrayList<RectangleNoCommentsWithSyntaxError>();
		testRectangles.add(new RectangleNoCommentsWithSyntaxError(2, 10));

		List<RectangleNoCommentsWithSyntaxError> solutionList = RectangleNoCommentsWithSyntaxError.TwoD_CLPUC(testRectangles);
		RectangleNoCommentsWithSyntaxError solution = solutionList.get(0);
		org.junit.Assert.assertEquals( solution.longest_side, testRectangles.get(0).longest_side );
		org.junit.Assert.assertEquals( solution.shortest_side, testRectangles.get(0).shortest_side );
		org.junit.Assert.assertTrue( solution.pos_x == 0.0 );
		org.junit.Assert.assertTrue( solution.pos_y == 0.0 );
		org.junit.Assert.assertEquals( solution.arrangement, RectangleNoCommentsWithSyntaxError.Arrangement.NONE );
		org.junit.Assert.assertEquals( RectangleNoCommentsWithSyntaxError.RectangleType.SINGLETON, solution.rectangleType ); 
	}

	
	
	
	
	
  @Test
	public void TwoRectangles()
	{
		testRectangles = new ArrayList<RectangleNoCommentsWithSyntaxError>();
		testRectangles.add(new RectangleNoCommentsWithSyntaxError(2, 10));
		testRectangles.add(new RectangleNoCommentsWithSyntaxError(2, 12));

		List<RectangleNoCommentsWithSyntaxError> solutionList = RectangleNoCommentsWithSyntaxError.TwoD_CLPUC(testRectangles);
		RectangleNoCommentsWithSyntaxError solution = solutionList.get(0);
		
		// there should be only one RectangleNoCommentsWithSyntaxError in the final solution
		org.junit.Assert.assertEquals(1, solutionList.size());

		// there should be no side effects on the input list
		org.junit.Assert.assertEquals(2, testRectangles.size());

		// check the composite RectangleNoCommentsWithSyntaxError
		System.out.println(testRectangles.get(0).longest_side + ", " + testRectangles.get(0).shortest_side);
		System.out.println(testRectangles.get(1).longest_side + ", " + testRectangles.get(1).shortest_side);
		org.junit.Assert.assertEquals( testRectangles.get(0).longest_side + testRectangles.get(1).longest_side, solution.longest_side );
		org.junit.Assert.assertEquals( Math.max(testRectangles.get(0).shortest_side, testRectangles.get(1).shortest_side), solution.shortest_side );
		org.junit.Assert.assertEquals( RectangleNoCommentsWithSyntaxError.Arrangement.NONE, solution.arrangement);
		org.junit.Assert.assertTrue(solution.pos_x == 0.0);
		org.junit.Assert.assertTrue(solution.pos_y == 0.0);
		
		// check the component rectangles
		List<RectangleNoCommentsWithSyntaxError> allComponentRectangles = solution.getRectangles();
		org.junit.Assert.assertEquals(allComponentRectangles.size(), 2);

		RectangleNoCommentsWithSyntaxError r1 = allComponentRectangles.get(0);
		RectangleNoCommentsWithSyntaxError r2 = allComponentRectangles.get(1);
		System.out.println(r1.arrangement);
		System.out.println(r2.arrangement);
		org.junit.Assert.assertTrue( RectangleNoCommentsWithSyntaxError.Arrangement.SHORT == r1.arrangement );
		org.junit.Assert.assertTrue( RectangleNoCommentsWithSyntaxError.Arrangement.SHORT == r2.arrangement );
		
		// check positions too!
		org.junit.Assert.assertTrue( r1.pos_x == 0 );
		org.junit.Assert.assertTrue( r1.pos_y == 0 );
		org.junit.Assert.assertTrue( r2.pos_x == 0.0 );
		org.junit.Assert.assertEquals( r2.pos_y, r1.longest_side );
	}


	@Test
	public void ThreeRectangles()
	{
		testRectangles = new ArrayList<RectangleNoCommentsWithSyntaxError>();
		org.junit.Assert.assertEquals(0, testRectangles.size());
		testRectangles.add(new RectangleNoCommentsWithSyntaxError(2, 10));
		testRectangles.add(new RectangleNoCommentsWithSyntaxError(2, 12));
		testRectangles.add(new RectangleNoCommentsWithSyntaxError(4, 3));
		org.junit.Assert.assertEquals(3, testRectangles.size());
		
		List<RectangleNoCommentsWithSyntaxError> solutionList = RectangleNoCommentsWithSyntaxError.TwoD_CLPUC(testRectangles);
		RectangleNoCommentsWithSyntaxError solution = solutionList.get(0);

		// there should be only one RectangleNoCommentsWithSyntaxError in the final solution
		org.junit.Assert.assertEquals(1, solutionList.size());

		// there should be no side effects on the input list
		org.junit.Assert.assertEquals(3, testRectangles.size());

		// check the composite (the solution) RectangleNoCommentsWithSyntaxError
		float longest_side = testRectangles.get(0).longest_side + testRectangles.get(1).longest_side + testRectangles.get(2).longest_side;
		float shortest_side = Math.max( Math.max(testRectangles.get(0).shortest_side, testRectangles.get(1).shortest_side), testRectangles.get(2).shortest_side ); 
		System.out.println(longest_side);
		System.out.println(shortest_side);
		org.junit.Assert.assertEquals( longest_side, solution.longest_side );
		org.junit.Assert.assertEquals( shortest_side, solution.shortest_side );
		org.junit.Assert.assertEquals( RectangleNoCommentsWithSyntaxError.Arrangement.NONE, solution.arrangement);
		org.junit.Assert.assertTrue(solution.pos_x == 0.0);
		org.junit.Assert.assertTrue(solution.pos_y == 0.0);
		
		// check the component rectangles
		List<RectangleNoCommentsWithSyntaxError> allComponentRectangles = solution.getRectangles();
		org.junit.Assert.assertEquals(allComponentRectangles.size(), 3);

		RectangleNoCommentsWithSyntaxError r1 = allComponentRectangles.get(0);
		RectangleNoCommentsWithSyntaxError r2 = allComponentRectangles.get(1);
		RectangleNoCommentsWithSyntaxError r3 = allComponentRectangles.get(2);

		System.out.println(r1.arrangement);
		System.out.println(r2.arrangement);
		System.out.println(r3.arrangement);
		org.junit.Assert.assertTrue( RectangleNoCommentsWithSyntaxError.Arrangement.SHORT == r1.arrangement );
		org.junit.Assert.assertTrue( RectangleNoCommentsWithSyntaxError.Arrangement.SHORT == r2.arrangement );
		org.junit.Assert.assertTrue( RectangleNoCommentsWithSyntaxError.Arrangement.SHORT == r3.arrangement );
		
		// check positions too
		System.out.println(r1.pos_x + ", " + r1.pos_y);
		System.out.println(r2.pos_x + ", " + r2.pos_y);
		System.out.println(r3.pos_x + ", " + r3.pos_y);
		org.junit.Assert.assertTrue( r1.pos_x == 0 );
		org.junit.Assert.assertTrue( r1.pos_y == 0 );
		org.junit.Assert.assertTrue( r2.pos_x == 0.0 );
		org.junit.Assert.assertEquals( r1.longest_side, r2.pos_y );
		org.junit.Assert.assertTrue( r3.pos_x == 0.0 );
		org.junit.Assert.assertEquals( r3.pos_y, r1.longest_side + r2.longest_side );
	}

	
	@Test
	public void ThreeRectangles_versionB()
	{
		testRectangles = new ArrayList<RectangleNoCommentsWithSyntaxError>();
		org.junit.Assert.assertEquals(0, testRectangles.size());
		testRectangles.add(new RectangleNoCommentsWithSyntaxError(4, 3));
		testRectangles.add(new RectangleNoCommentsWithSyntaxError(2, 10));
		testRectangles.add(new RectangleNoCommentsWithSyntaxError(2, 12));
		org.junit.Assert.assertEquals(3, testRectangles.size());
		
		List<RectangleNoCommentsWithSyntaxError> solutionList = RectangleNoCommentsWithSyntaxError.TwoD_CLPUC(testRectangles);
		RectangleNoCommentsWithSyntaxError solution = solutionList.get(0);

		// there should be only one RectangleNoCommentsWithSyntaxError in the final solution
		org.junit.Assert.assertEquals(1, solutionList.size());

		// there should be no side effects on the input list
		org.junit.Assert.assertEquals(3, testRectangles.size());

		// check the composite (the solution) RectangleNoCommentsWithSyntaxError
		float longest_side = testRectangles.get(0).longest_side + testRectangles.get(1).longest_side + testRectangles.get(2).longest_side;
		float shortest_side = Math.max( Math.max(testRectangles.get(0).shortest_side, testRectangles.get(1).shortest_side), testRectangles.get(2).shortest_side ); 
		System.out.println(longest_side);
		System.out.println(shortest_side);
		org.junit.Assert.assertEquals( longest_side, solution.longest_side );
		org.junit.Assert.assertEquals( shortest_side, solution.shortest_side );
		org.junit.Assert.assertEquals( RectangleNoCommentsWithSyntaxError.Arrangement.NONE, solution.arrangement);
		org.junit.Assert.assertTrue(solution.pos_x == 0.0);
		org.junit.Assert.assertTrue(solution.pos_y == 0.0);
		
		// check the component rectangles
		List<RectangleNoCommentsWithSyntaxError> allComponentRectangles = solution.getRectangles();
		org.junit.Assert.assertEquals(allComponentRectangles.size(), 3);

		RectangleNoCommentsWithSyntaxError r1 = allComponentRectangles.get(0);
		RectangleNoCommentsWithSyntaxError r2 = allComponentRectangles.get(1);
		RectangleNoCommentsWithSyntaxError r3 = allComponentRectangles.get(2);

		System.out.println(r1.arrangement);
		System.out.println(r2.arrangement);
		System.out.println(r3.arrangement);
		org.junit.Assert.assertTrue( RectangleNoCommentsWithSyntaxError.Arrangement.SHORT == r1.arrangement );
		org.junit.Assert.assertTrue( RectangleNoCommentsWithSyntaxError.Arrangement.SHORT == r2.arrangement );
		org.junit.Assert.assertTrue( RectangleNoCommentsWithSyntaxError.Arrangement.SHORT == r3.arrangement );
		
		// check positions too
		System.out.println(r1.pos_x + ", " + r1.pos_y);
		System.out.println(r2.pos_x + ", " + r2.pos_y);
		System.out.println(r3.pos_x + ", " + r3.pos_y);
		org.junit.Assert.assertTrue( r1.pos_x == 0 );
		org.junit.Assert.assertTrue( r1.pos_y == 0 );
		org.junit.Assert.assertTrue( r2.pos_x == 0.0 );
		org.junit.Assert.assertEquals( r1.longest_side, r2.pos_y );
		org.junit.Assert.assertTrue( r3.pos_x == 0.0 );
		org.junit.Assert.assertEquals( r3.pos_y, r1.longest_side + r2.longest_side );
	}


}
