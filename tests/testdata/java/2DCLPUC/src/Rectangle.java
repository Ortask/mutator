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

/**
 * 
 * @author Mario G.
 *
 * Note that this class is not abstract because it needs
 * a constructor but Java doesn't allow abstract constructors.
 * Thus, all methods except the constructor in this base class 
 * throw UnsupportedOperationException.
 *
 */
public class Rectangle 
{
	public float longest_side;
	public float shortest_side;
	public float pos_x;
	public float pos_y;
	public Rectangle rectangle1;
	public Rectangle rectangle2;
	
	// this list will be populated when 
	// getRectangles() is called.
	public List<Rectangle> solution;
	
	
	
	
	public enum RectangleType
	{
		SINGLETON,
		COMPOSITE
	}
	RectangleType rectangleType;
	
	
	
	public enum Arrangement 
	{
		SHORT,
		LONG,
		NONE
	}
	public Arrangement arrangement;
	
	
	
	/**
	 * Utility method for correctly setting the 
	 * longest and shortest sides.
	 * 
	 * This is meant to be used only by the constructors
	 * of this class.
	 * 
	 * @param side1 - a side of this rectangle
	 * @param side2 - a side of this rectangle
	 */
	protected void setSidesCorrectly(float side1, float side2)
	{
		if( (side1 <= 0) || (side2 <= 0))
		{
			throw new UnsupportedOperationException("Can't create Rectangle with dimentions (" + side1 + ", " + side2 + ")");
		}
		
		// if the sides were given wrong then correct them
		if(side1 < side2)
		{
			this.longest_side = side2;
			this.shortest_side = side1;						
		}
		else
		{
			this.longest_side = side1;
			this.shortest_side = side2;			
		}
	}
	
	

	
	
	/**
	 * Will construct a Rectangle with the given
	 * sides and will use default values for arrangement,
	 * position and type as "NONE", (0,0) and
	 * SINGLETON, respectively.
	 * 
	 * @param side1 - one side of the rectangle
	 * @param side2 - the other side of the rectangle
	 */
	public Rectangle(float side1, float side2)
	{
		setSidesCorrectly(side1, side2);
		this.arrangement = Arrangement.NONE;
		pos_x = 0;
		pos_y = 0;
		rectangleType = RectangleType.SINGLETON; 
	}

	


	
	
	public Rectangle(
			float side1, 
			float side2, 
			Arrangement arrangement, 
			float pos_x, 
			float pos_y,
			RectangleType type)
	{
		setSidesCorrectly(side1, side2);
		this.arrangement = arrangement;
		this.pos_x = pos_x;
		this.pos_y = pos_y;
		rectangleType = type;
	}
	
	
	
	
	
	public Rectangle(Rectangle r)
	{
		this.longest_side = r.longest_side;
		this.shortest_side = r.shortest_side;
		this.pos_x = r.pos_x;
		this.pos_y = r.pos_y;
		this.arrangement = r.arrangement;
		this.rectangleType = r.rectangleType;
	}

	


	/**
	 * This method is meant to be called from a composite
	 * rectangle. It may be better design to make it static, 
	 * but this works for now.
	 * 
	 * Traverse the Rectangle tree and create a list of all
	 * component (singleton) rectangles.
	 * 
	 * @return A list of all singleton rectangles that are in the
	 * 		tree starting from this rectangle.
	 */
	public List<Rectangle> getRectangles() 
	{
		// cleanup any old list
		solution = new ArrayList<Rectangle>();
		getRectangles(this);
		return solution;
	}
	

	
	
	public void getRectangles(Rectangle root) 
	{
		if(root.rectangleType == RectangleType.SINGLETON)
		{
			solution.add(root);
		}
		else
		{
			getRectangles(root.rectangle1);
			getRectangles(root.rectangle2);
		}
	}

	

	
	
	/**
	 * Solution algorithm for the 2D version of the Container
	 * Loading Problem (w/ unbounded container)
	 * 
	 *  
	 * @param rectangles - the list of rectangles in the problem space
	 * 		for which their minimal arrangement will be found.
	 * 
	 * @return A list containing a single composite rectangle whose 
	 * components are arranged such that they minimize the unused area.
	 * 
	 */
	static public List<Rectangle> TwoD_CLPUC(final List<Rectangle> rectangles)
	{
		if(rectangles.size() == 0)
		{
			throw new UnsupportedOperationException("No rectangles given.");
		}
		
		
		if(rectangles.size() == 1)
		{
			return rectangles;
		}
		
		
		if(rectangles.size() == 2)
		{
			Rectangle composite = ARMUS(rectangles.get(0), rectangles.get(1));
			List<Rectangle> newResult = new ArrayList<Rectangle>();
			newResult.add(composite);
			return newResult;
		}
		else
		{
			// main idea:
			// TwoD_CLPUC( TwoD_CLPUC(rectangles / 2) set_union TwoD_CLPUC(rectangles / 2) ):
			//
			
			// Can't use method subList() here because it returns
			// a list of references to the original list and, 
			// by the way this algorithm works, it would (wrongly) modify
			// that list. Thus, use iteration to get each rectangle in the list.
			// 
			List<Rectangle> half1 = new ArrayList<Rectangle>();
			List<Rectangle> half2 = new ArrayList<Rectangle>();
			for(int idx = 0; idx < (int)Math.floor( rectangles.size() / 2); idx++)
			{
				half1.add(rectangles.get(idx));
			}
			for(int idx = (int)Math.ceil( rectangles.size() / 2); idx < rectangles.size() ; idx++)
			{
				half2.add(rectangles.get(idx));
			}
			half1 = TwoD_CLPUC(half1);
			half2 = TwoD_CLPUC(half2);
			
			half1.addAll(half2);
			half1 = TwoD_CLPUC(half1);
			updatePosition(half1.get(0));

			return half1;
		}
		
	}
	
	
	
	
	
	/**
	 * Because all r1 rectangles (r.rectangle1) assume
	 * they are at (0,0), all r2 rectangles (r.rectangle2)
	 * assume they are based on r1 plus some x or y. 
	 * 
	 * This method is meant to update all positions so that
	 * they are in absolute coordinates (not relative to 
	 * component rectangles anymore).
	 * 
	 * @param root - the root of the tree whose position will
	 * be updated.
	 */
	private static void updatePosition(Rectangle root)
	{
		updatePositionWorkhorse(root.rectangle1, 0,0);		// do left subtree
		updatePositionWorkhorse(root.rectangle2, 0,0);		// do right subtree
	}
	

	
	
	/**
	 * This method traverses the tree of rectangles starting 
	 * from the given rectangle and updates
	 * all positions with respect to the starting rectangle.
	 * 
	 * Do not call this method directly. Call updatePosition(Rectangle root)
	 * instead.
	 * 
	 * @param rect - the rectangle whose components will get their
	 * 		positions updated.
	 * @param x - the x coord of the parent rectangle
	 * @param y - the y coord of the parent rectangle
	 */
	private static void updatePositionWorkhorse(Rectangle rect, float x, float y)
	{
		if(rect == null)
		{
			return;
		}
		else
		{
			rect.pos_x = rect.pos_x + x;
			rect.pos_y = rect.pos_y + y;
			
			updatePositionWorkhorse(rect.rectangle1, rect.pos_x, rect.pos_y);
			updatePositionWorkhorse(rect.rectangle2, rect.pos_x, rect.pos_y);
		}
	}

	
	
	
	/**
	 * ARMUS: Add Rectangle and Minimize Unused Space.
	 * 
	 * @param r1 - a singleton or composite rectangle
	 * @param r2 - a singleton or composite rectangle
	 * 
	 * @return A composite rectangle composed of the given rectangles such that
	 * 		their arrangement has the minimum unused area.
	 * 		The given rectangles will have their positions and arrangements
	 * 		changed.
	 */
	private static Rectangle ARMUS(Rectangle r1, Rectangle r2)
	{
		float currentUnusedArea = 0;
		float previousUnusedArea = 0;
		float longest = 0;
		float shortest = 0;
		float rectangleAreas = r1.area() + r2.area();
		
		float longestSideForSolution = 0;
		float shortestSideForSolution = 0;
		
		// go thru each case:
		//
		// longest side on longest side:
		//
		longest = Math.max(r1.longest_side, r2.longest_side);
		previousUnusedArea = longest * (r1.shortest_side + r2.shortest_side) - rectangleAreas;
		r1.arrangement = Arrangement.LONG;
		r2.arrangement = Arrangement.LONG;
		r2.pos_x = r1.shortest_side;
		longestSideForSolution = longest;
		shortestSideForSolution = r1.shortest_side + r2.shortest_side;
		
		//
		// shortest side on shortest side:
		//
		shortest = Math.max(r1.shortest_side, r2.shortest_side);
		currentUnusedArea = shortest * (r1.longest_side + r2.longest_side) - rectangleAreas;
		if( currentUnusedArea < previousUnusedArea)
		{
			r1.arrangement = Arrangement.SHORT;
			r2.arrangement = Arrangement.SHORT;
			r2.pos_x = 0;
			r2.pos_y = r1.longest_side;
			previousUnusedArea = currentUnusedArea;
			longestSideForSolution = r1.longest_side + r2.longest_side;
			shortestSideForSolution = shortest;
		}
		
		
		//
		// r1.longest side on r2.shortest side:
		//
		longest = Math.max(r1.longest_side, r2.shortest_side);
		currentUnusedArea = longest * (r1.shortest_side + r2.longest_side) - rectangleAreas;
		if( currentUnusedArea < previousUnusedArea)
		{
			r1.arrangement = Arrangement.LONG;
			r2.arrangement = Arrangement.SHORT;
			r2.pos_x = r1.shortest_side;
			r2.pos_y = 0;
			previousUnusedArea = currentUnusedArea;
			longestSideForSolution = longest;
			shortestSideForSolution = r1.shortest_side + r2.longest_side;
		}

		
		//
		// r1.shortest side on r2.longest side:
		//
		longest = Math.max(r1.shortest_side, r2.longest_side);
		currentUnusedArea = longest * (r1.longest_side + r2.shortest_side) - rectangleAreas;
		if( currentUnusedArea < previousUnusedArea)
		{
			r1.arrangement = Arrangement.SHORT;
			r2.arrangement = Arrangement.LONG;
			r2.pos_x = 0;
			r2.pos_y = r1.shortest_side;
			previousUnusedArea = currentUnusedArea;
			longestSideForSolution = longest;
			shortestSideForSolution = r1.longest_side + r2.shortest_side;
		}

		
		Rectangle solution = new Rectangle(longestSideForSolution, shortestSideForSolution);
		solution.rectangle1 = r1;
		solution.rectangle2 = r2;
		solution.rectangleType = RectangleType.COMPOSITE;

		return solution;
	}
	
	
	
	
	
	
	
	
	private float area()
	{
		return this.longest_side * this.shortest_side;
	}
	
		
}
