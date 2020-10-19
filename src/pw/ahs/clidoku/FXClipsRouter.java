/*
	Copyright 2013 Anas H. Sulaiman (ahs.pw)
	
	This file is part of Clidoku.

    Clidoku is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Clidoku is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Clidoku.  If not, see <http://www.gnu.org/licenses/>.
 */

package pw.ahs.clidoku;

/**
 * This is class is intended for routing output to TextInputControl.
 */
public abstract class FXClipsRouter extends CLIPSJNI.Router
{

	/**
	 * CLIPSJNI routers.
	 */
	public static final String[]	ROUTERS_NAMES	= new String[]
													{
			"stdout",
			"stdin",
			"wwarning",
			"werror",
			"wtrace",
			"wdialog",
			"wclips",
			"wdisplay"								};

	/**
	 * Constructs a new router whose name is 'FXClipsRouter' and a priority of 100.
	 */
	public FXClipsRouter()
	{
		super("FXClipsRouter", 100);
	}

	@Override
	public void print(String routerName, String printMessage)
	{
		print(printMessage);
	}

	/**
	 * Prints a message on the associated TextInputControl.
	 * 
	 * @param msg
	 *            The message to print.
	 */
	public abstract void print(String msg);

	/**
	 * Queries this router for its accepted output type. Return true only for a router name supplied by {@link #ROUTERS_NAMES}.
	 * If you always return true, the environment may hang.
	 * 
	 * @param routerName
	 * @return true if this router accepts the queried output.
	 */
	@Override
	public abstract boolean query(String routerName);

	/**
	 * Prints a message with new line on the associated TextInputControl.
	 * 
	 * @param msg
	 *            The message to print
	 */
	public abstract void println(String msg);

}
