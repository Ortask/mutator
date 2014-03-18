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


public class TestsuiteNotReferringToMutatedSource extends TestCase 
{

	List<RectangleNoComments> TestsuiteNotReferringToMutatedSources = null;

	protected void tearDown() throws Exception 
	{
		super.tearDown();
	}

	public void testBadRectangle()
	{
		try
		{
			RectangleNoComments r = new RectangleNoComments(0, 3);
			fail();
		}
		catch(Exception e)
		{
			e.getMessage();
		}

		try
		{
			RectangleNoComments r = new RectangleNoComments(0, -3);
			fail();
		}
		catch(Exception e)
		{
			e.getMessage();
		}
		
		
		try
		{
			RectangleNoComments r = new RectangleNoComments(2, 0);
			fail();
		}
		catch(Exception e)
		{
			e.getMessage();
		}
		
		try
		{
			RectangleNoComments r = new RectangleNoComments(-3, -3);
			fail();
		}
		catch(Exception e)
		{
			e.getMessage();
		}
		
	}
	
	
	
	
	
	
	public void test_1Rectangle()
	{
		TestsuiteNotReferringToMutatedSources = new ArrayList<RectangleNoComments>();
		TestsuiteNotReferringToMutatedSources.add(new RectangleNoComments(2, 10));

		List<RectangleNoComments> solutionList = RectangleNoComments.TwoD_CLPUC(TestsuiteNotReferringToMutatedSources);
		RectangleNoComments solution = solutionList.get(0);
		assertEquals( solution.longest_side, TestsuiteNotReferringToMutatedSources.get(0).longest_side );
		assertEquals( solution.shortest_side, TestsuiteNotReferringToMutatedSources.get(0).shortest_side );
		assertTrue( solution.pos_x == 0.0 );
		assertTrue( solution.pos_y == 0.0 );
		assertEquals( solution.arrangement, RectangleNoComments.Arrangement.NONE );
		assertEquals( RectangleNoComments.RectangleType.SINGLETON, solution.rectangleType ); 
	}

	
	
	
	
	

	public void test_2Rectangles()
	{
		TestsuiteNotReferringToMutatedSources = new ArrayList<RectangleNoComments>();
		TestsuiteNotReferringToMutatedSources.add(new RectangleNoComments(2, 10));
		TestsuiteNotReferringToMutatedSources.add(new RectangleNoComments(2, 12));

		List<RectangleNoComments> solutionList = RectangleNoComments.TwoD_CLPUC(TestsuiteNotReferringToMutatedSources);
		RectangleNoComments solution = solutionList.get(0);
		
		// there should be only one RectangleNoComments in the final solution
		assertEquals(1, solutionList.size());

		// there should be no side effects on the input list
		assertEquals(2, TestsuiteNotReferringToMutatedSources.size());

		// check the composite RectangleNoComments
		System.out.println(TestsuiteNotReferringToMutatedSources.get(0).longest_side + ", " + TestsuiteNotReferringToMutatedSources.get(0).shortest_side);
		System.out.println(TestsuiteNotReferringToMutatedSources.get(1).longest_side + ", " + TestsuiteNotReferringToMutatedSources.get(1).shortest_side);
		assertEquals( TestsuiteNotReferringToMutatedSources.get(0).longest_side + TestsuiteNotReferringToMutatedSources.get(1).longest_side, solution.longest_side );
		assertEquals( Math.max(TestsuiteNotReferringToMutatedSources.get(0).shortest_side, TestsuiteNotReferringToMutatedSources.get(1).shortest_side), solution.shortest_side );
		assertEquals( RectangleNoComments.Arrangement.NONE, solution.arrangement);
		assertTrue(solution.pos_x == 0.0);
		assertTrue(solution.pos_y == 0.0);
		
		// check the component rectangles
		List<RectangleNoComments> allComponentRectangles = solution.getRectangles();
		assertEquals(allComponentRectangles.size(), 2);

		RectangleNoComments r1 = allComponentRectangles.get(0);
		RectangleNoComments r2 = allComponentRectangles.get(1);
		System.out.println(r1.arrangement);
		System.out.println(r2.arrangement);
		assertTrue( RectangleNoComments.Arrangement.SHORT == r1.arrangement );
		assertTrue( RectangleNoComments.Arrangement.SHORT == r2.arrangement );
		
		// check positions too!
		assertTrue( r1.pos_x == 0 );
		assertTrue( r1.pos_y == 0 );
		assertTrue( r2.pos_x == 0.0 );
		assertEquals( r2.pos_y, r1.longest_side );
	}


	
	public void test_3Rectangles()
	{
		TestsuiteNotReferringToMutatedSources = new ArrayList<RectangleNoComments>();
		assertEquals(0, TestsuiteNotReferringToMutatedSources.size());
		TestsuiteNotReferringToMutatedSources.add(new RectangleNoComments(2, 10));
		TestsuiteNotReferringToMutatedSources.add(new RectangleNoComments(2, 12));
		TestsuiteNotReferringToMutatedSources.add(new RectangleNoComments(4, 3));
		assertEquals(3, TestsuiteNotReferringToMutatedSources.size());
		
		List<RectangleNoComments> solutionList = RectangleNoComments.TwoD_CLPUC(TestsuiteNotReferringToMutatedSources);
		RectangleNoComments solution = solutionList.get(0);

		// there should be only one RectangleNoComments in the final solution
		assertEquals(1, solutionList.size());

		// there should be no side effects on the input list
		assertEquals(3, TestsuiteNotReferringToMutatedSources.size());

		// check the composite (the solution) RectangleNoComments
		float longest_side = TestsuiteNotReferringToMutatedSources.get(0).longest_side + TestsuiteNotReferringToMutatedSources.get(1).longest_side + TestsuiteNotReferringToMutatedSources.get(2).longest_side;
		float shortest_side = Math.max( Math.max(TestsuiteNotReferringToMutatedSources.get(0).shortest_side, TestsuiteNotReferringToMutatedSources.get(1).shortest_side), TestsuiteNotReferringToMutatedSources.get(2).shortest_side ); 
		System.out.println(longest_side);
		System.out.println(shortest_side);
		assertEquals( longest_side, solution.longest_side );
		assertEquals( shortest_side, solution.shortest_side );
		assertEquals( RectangleNoComments.Arrangement.NONE, solution.arrangement);
		assertTrue(solution.pos_x == 0.0);
		assertTrue(solution.pos_y == 0.0);
		
		// check the component rectangles
		List<RectangleNoComments> allComponentRectangles = solution.getRectangles();
		assertEquals(allComponentRectangles.size(), 3);

		RectangleNoComments r1 = allComponentRectangles.get(0);
		RectangleNoComments r2 = allComponentRectangles.get(1);
		RectangleNoComments r3 = allComponentRectangles.get(2);

		System.out.println(r1.arrangement);
		System.out.println(r2.arrangement);
		System.out.println(r3.arrangement);
		assertTrue( RectangleNoComments.Arrangement.SHORT == r1.arrangement );
		assertTrue( RectangleNoComments.Arrangement.SHORT == r2.arrangement );
		assertTrue( RectangleNoComments.Arrangement.SHORT == r3.arrangement );
		
		// check positions too
		System.out.println(r1.pos_x + ", " + r1.pos_y);
		System.out.println(r2.pos_x + ", " + r2.pos_y);
		System.out.println(r3.pos_x + ", " + r3.pos_y);
		assertTrue( r1.pos_x == 0 );
		assertTrue( r1.pos_y == 0 );
		assertTrue( r2.pos_x == 0.0 );
		assertEquals( r1.longest_side, r2.pos_y );
		assertTrue( r3.pos_x == 0.0 );
		assertEquals( r3.pos_y, r1.longest_side + r2.longest_side );
	}

	
	
	public void test_3Rectangles_versionB()
	{
		TestsuiteNotReferringToMutatedSources = new ArrayList<RectangleNoComments>();
		assertEquals(0, TestsuiteNotReferringToMutatedSources.size());
		TestsuiteNotReferringToMutatedSources.add(new RectangleNoComments(4, 3));
		TestsuiteNotReferringToMutatedSources.add(new RectangleNoComments(2, 10));
		TestsuiteNotReferringToMutatedSources.add(new RectangleNoComments(2, 12));
		assertEquals(3, TestsuiteNotReferringToMutatedSources.size());
		
		List<RectangleNoComments> solutionList = RectangleNoComments.TwoD_CLPUC(TestsuiteNotReferringToMutatedSources);
		RectangleNoComments solution = solutionList.get(0);

		// there should be only one RectangleNoComments in the final solution
		assertEquals(1, solutionList.size());

		// there should be no side effects on the input list
		assertEquals(3, TestsuiteNotReferringToMutatedSources.size());

		// check the composite (the solution) RectangleNoComments
		float longest_side = TestsuiteNotReferringToMutatedSources.get(0).longest_side + TestsuiteNotReferringToMutatedSources.get(1).longest_side + TestsuiteNotReferringToMutatedSources.get(2).longest_side;
		float shortest_side = Math.max( Math.max(TestsuiteNotReferringToMutatedSources.get(0).shortest_side, TestsuiteNotReferringToMutatedSources.get(1).shortest_side), TestsuiteNotReferringToMutatedSources.get(2).shortest_side ); 
		System.out.println(longest_side);
		System.out.println(shortest_side);
		assertEquals( longest_side, solution.longest_side );
		assertEquals( shortest_side, solution.shortest_side );
		assertEquals( RectangleNoComments.Arrangement.NONE, solution.arrangement);
		assertTrue(solution.pos_x == 0.0);
		assertTrue(solution.pos_y == 0.0);
		
		// check the component rectangles
		List<RectangleNoComments> allComponentRectangles = solution.getRectangles();
		assertEquals(allComponentRectangles.size(), 3);

		RectangleNoComments r1 = allComponentRectangles.get(0);
		RectangleNoComments r2 = allComponentRectangles.get(1);
		RectangleNoComments r3 = allComponentRectangles.get(2);

		System.out.println(r1.arrangement);
		System.out.println(r2.arrangement);
		System.out.println(r3.arrangement);
		assertTrue( RectangleNoComments.Arrangement.SHORT == r1.arrangement );
		assertTrue( RectangleNoComments.Arrangement.SHORT == r2.arrangement );
		assertTrue( RectangleNoComments.Arrangement.SHORT == r3.arrangement );
		
		// check positions too
		System.out.println(r1.pos_x + ", " + r1.pos_y);
		System.out.println(r2.pos_x + ", " + r2.pos_y);
		System.out.println(r3.pos_x + ", " + r3.pos_y);
		assertTrue( r1.pos_x == 0 );
		assertTrue( r1.pos_y == 0 );
		assertTrue( r2.pos_x == 0.0 );
		assertEquals( r1.longest_side, r2.pos_y );
		assertTrue( r3.pos_x == 0.0 );
		assertEquals( r3.pos_y, r1.longest_side + r2.longest_side );
	}


}
