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

//
// This file has an error (not a syntax error) that will make its test suite
// fail.
//

public class RectangleNoCommentsWithError 
{
	public float longest_side;
	public float shortest_side;
	public float pos_x;
	public float pos_y;
	public RectangleNoCommentsWithError rectangle1;
	public RectangleNoCommentsWithError rectangle2;
	
	public List<RectangleNoCommentsWithError> solution;
	
	
	
	
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
	
	
	
	protected void setSidesCorrectly(float side1, float side2)
	{
		if( (side1 <= 0) || (side2 <= 0))
		{
			throw new UnsupportedOperationException("Can't create RectangleNoCommentsWithError with dimentions (" + side1 + ", " + side2 + ")");
		}
		
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
	
	

	
	
	public RectangleNoCommentsWithError(float side1, float side2)
	{
		setSidesCorrectly(side1, side2);
		this.arrangement = Arrangement.NONE;
		pos_x = 0;
		pos_y = 0;
		rectangleType = RectangleType.SINGLETON; 
	}

	


	
	
	public RectangleNoCommentsWithError(
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
	
	
	
	
	
	public RectangleNoCommentsWithError(RectangleNoCommentsWithError r)
	{
		this.longest_side = r.longest_side;
		this.shortest_side = r.shortest_side;
		this.pos_x = r.pos_x;
		this.pos_y = r.pos_y;
		this.arrangement = r.arrangement;
		this.rectangleType = r.rectangleType;
	}

	


	public List<RectangleNoCommentsWithError> getRectangles() 
	{
		solution = new ArrayList<RectangleNoCommentsWithError>();
		getRectangles(this);
		return solution;
	}
	

	
	
	public void getRectangles(RectangleNoCommentsWithError root) 
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

	

	
	
	static public List<RectangleNoCommentsWithError> TwoD_CLPUC(final List<RectangleNoCommentsWithError> rectangles)
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
			RectangleNoCommentsWithError composite = ARMUS(rectangles.get(0), rectangles.get(1));
			List<RectangleNoCommentsWithError> newResult = new ArrayList<RectangleNoCommentsWithError>();
			newResult.add(composite);
			return newResult;
		}
		else
		{
			List<RectangleNoCommentsWithError> half1 = new ArrayList<RectangleNoCommentsWithError>();
			List<RectangleNoCommentsWithError> half2 = new ArrayList<RectangleNoCommentsWithError>();
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
	
	
	
	
	
	private static void updatePosition(RectangleNoCommentsWithError root)
	{
		updatePositionWorkhorse(root.rectangle1, 0,0);		
		updatePositionWorkhorse(root.rectangle2, 0,0);		
	}
	

	
	
	private static void updatePositionWorkhorse(RectangleNoCommentsWithError rect, float x, float y)
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

	
	
	
	private static RectangleNoCommentsWithError ARMUS(RectangleNoCommentsWithError r1, RectangleNoCommentsWithError r2)
	{
		float currentUnusedArea = 0;
		float previousUnusedArea = 0;
		float longest = 0;
		float shortest = 0;
		float rectangleAreas = r1.area() + r2.area();
		
		float longestSideForSolution = 0;
		float shortestSideForSolution = 0;
		
		longest = Math.max(r1.longest_side, r2.longest_side);
		previousUnusedArea = longest * (r1.shortest_side + r2.shortest_side) - rectangleAreas;
		r1.arrangement = Arrangement.LONG;
		r2.arrangement = Arrangement.LONG;
		r2.pos_x = r1.shortest_side;
		longestSideForSolution = longest;
		shortestSideForSolution = r1.shortest_side + r2.shortest_side;
		
		shortest = Math.max(r1.shortest_side, r2.shortest_side);
		currentUnusedArea = shortest * (r1.longest_side + r2.longest_side) - rectangleAreas;
		if( currentUnusedArea < previousUnusedArea)
		{
			r1.arrangement = Arrangement.SHORT;
			r2.arrangement = Arrangement.SHORT;
			r2.pos_x = 0;
			r2.pos_y = r1.longest_side;
			previousUnusedArea = currentUnusedArea;
			longestSideForSolution = r1.longest_side - r2.longest_side;
			shortestSideForSolution = shortest;
		}
		
		
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

		
		RectangleNoCommentsWithError solution = new RectangleNoCommentsWithError(longestSideForSolution, shortestSideForSolution);
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
