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

import java.util.Iterator;


public class RectangleIterator implements Iterator 
{
	Rectangle root, current;

	
	public RectangleIterator (Rectangle r)
	{
		this.root = r;
		current = root;
	}

	
	public boolean hasNext() 
	{
		// base case: current rectangle is a singleton
		if( current.rectangleType == Rectangle.RectangleType.SINGLETON )
		{
			return false;
		}
		return true;
	}

	
	
	public Rectangle next() 
	{
		return null;
	}

	
	
	public void remove() 
	{
		throw new UnsupportedOperationException("This is not implemented.");
	}

}
