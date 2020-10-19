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

import java.io.BufferedOutputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.StringWriter;
import java.nio.file.DirectoryStream;
import java.nio.file.Files;
import java.nio.file.LinkOption;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Scanner;

import javafx.application.Application;
import javafx.application.Platform;
import javafx.beans.value.ChangeListener;
import javafx.beans.value.ObservableValue;
import javafx.concurrent.Task;
import javafx.concurrent.Worker;
import javafx.embed.swing.SwingFXUtils;
import javafx.event.ActionEvent;
import javafx.event.EventHandler;
import javafx.geometry.Insets;
import javafx.geometry.Orientation;
import javafx.geometry.Pos;
import javafx.scene.Cursor;
import javafx.scene.Scene;
import javafx.scene.SceneBuilder;
import javafx.scene.control.Button;
import javafx.scene.control.CheckBox;
import javafx.scene.control.CheckBoxBuilder;
import javafx.scene.control.ContextMenu;
import javafx.scene.control.ContextMenuBuilder;
import javafx.scene.control.Hyperlink;
import javafx.scene.control.HyperlinkBuilder;
import javafx.scene.control.Label;
import javafx.scene.control.LabelBuilder;
import javafx.scene.control.ListView;
import javafx.scene.control.Menu;
import javafx.scene.control.MenuBar;
import javafx.scene.control.MenuBarBuilder;
import javafx.scene.control.MenuBuilder;
import javafx.scene.control.MenuItem;
import javafx.scene.control.MenuItemBuilder;
import javafx.scene.control.ProgressIndicator;
import javafx.scene.control.SplitPane;
import javafx.scene.control.SplitPaneBuilder;
import javafx.scene.control.TextArea;
import javafx.scene.control.TextAreaBuilder;
import javafx.scene.control.TextField;
import javafx.scene.control.TextFieldBuilder;
import javafx.scene.control.TooltipBuilder;
import javafx.scene.image.Image;
import javafx.scene.input.Clipboard;
import javafx.scene.input.ClipboardContent;
import javafx.scene.input.ContextMenuEvent;
import javafx.scene.input.DragEvent;
import javafx.scene.input.KeyCode;
import javafx.scene.input.KeyCodeCombination;
import javafx.scene.input.KeyCombination;
import javafx.scene.input.KeyEvent;
import javafx.scene.input.MouseEvent;
import javafx.scene.input.TransferMode;
import javafx.scene.layout.BorderPaneBuilder;
import javafx.scene.layout.GridPane;
import javafx.scene.layout.GridPaneBuilder;
import javafx.scene.layout.HBox;
import javafx.scene.layout.HBoxBuilder;
import javafx.scene.layout.Priority;
import javafx.scene.layout.TilePane;
import javafx.scene.layout.TilePaneBuilder;
import javafx.scene.layout.VBox;
import javafx.scene.layout.VBoxBuilder;
import javafx.scene.paint.Paint;
import javafx.scene.text.Font;
import javafx.scene.text.FontWeight;
import javafx.scene.text.Text;
import javafx.scene.text.TextBuilder;
import javafx.stage.FileChooser.ExtensionFilter;
import javafx.stage.FileChooserBuilder;
import javafx.stage.Modality;
import javafx.stage.Popup;
import javafx.stage.PopupBuilder;
import javafx.stage.Stage;
import javafx.stage.WindowEvent;

import javax.imageio.ImageIO;

import CLIPSJNI.Environment;
import CLIPSJNI.PrimitiveValue;

public class Clidoku extends Application
{

	// 1) create an instance of Environment
	private Environment	clips	= new Environment();

	private Cell		cells[][];						// every cell has 9 candidates and one number as solution
	private int			checkPoint[][];				// a snapshot of grid values

	private Stage		stage;
	private String		css;
	boolean				facts;							// used for the workaround of the debugger
	Map<String, File>	puzzles;						// holds the puzzles: file name -> file
	CheckBox[]			techniques;					// enable/disable techniques

	@Override
	public void start(final Stage primaryStage) throws Exception
	{
		this.stage = primaryStage;
		this.css = getClass().getResource("style.css").toExternalForm();

		Stage stgOptions = createOptionsStage();
		MenuBar menuBar = createMenuBar(stgOptions);

		// prepare grid
		GridPane gpGroup[] = new GridPane[9];
		for (int i = 0; i < gpGroup.length; i++)
		{
			gpGroup[i] = GridPaneBuilder
				.create()
				.alignment(Pos.CENTER)
				.styleClass("thick-border")
				.build();
		}

		cells = new Cell[9][9];
		checkPoint = new int[9][9];
		int x = 0;
		for (int i = 0; i < 9; i++)
		{
			for (int j = 0; j < 9; j++)
			{
				Cell c = new Cell();
				c.row = i;
				c.col = j;
				cells[i][j] = c;
				x = getBox(i, j);
				gpGroup[x].add(c, j % 3, i % 3);
				checkPoint[i][j] = 0;
			}
		}

		GridPane gpGroups = GridPaneBuilder
			.create()
			.padding(new Insets(1.0, 1.0, 1.0, 1.0))
			.build();

		gpGroups.addRow(0, gpGroup[0], gpGroup[1], gpGroup[2]);
		gpGroups.addRow(1, gpGroup[3], gpGroup[4], gpGroup[5]);
		gpGroups.addRow(2, gpGroup[6], gpGroup[7], gpGroup[8]);

		initClips(clips);

		primaryStage.setTitle("Clidoku");
		primaryStage.setResizable(false);
		primaryStage.setScene(SceneBuilder.create().onDragOver(new EventHandler<DragEvent>()
		{

			@Override
			public void handle(DragEvent event)
			{
				if (event.getGestureSource() != stage.getScene() && event.getDragboard().hasFiles())
				{
					event.acceptTransferModes(TransferMode.COPY_OR_MOVE);
				}
				event.consume();
			}
		})
			.onDragDropped(new EventHandler<DragEvent>()
			{

				@Override
				public void handle(DragEvent event)
				{
					if (event.getDragboard().hasFiles())
					{
						File f = event.getDragboard().getFiles().get(0);
						if (f.isFile())
						{
							readFromFile(f);
							event.setDropCompleted(true);
						}
					}
					event.consume();
				}
			})
			.stylesheets(css)
			.root(BorderPaneBuilder.create().top(menuBar).center(gpGroups).build())
			.build());
		primaryStage.getScene().getAccelerators().put(
														KeyCombination.valueOf("ctrl+l"),
														new Runnable()
														{

															@Override
															public void run()
															{
																final IntegerField tfFileNumber = new IntegerField(
																		1, puzzles.size(), 1);
																tfFileNumber
																	.setTooltip(TooltipBuilder
																		.create()
																		.text(
																				"Type a puzzle number to load")
																		.autoFix(true)
																		.autoHide(true)
																		.focused(false)
																		.build());
																final Popup ppup = PopupBuilder
																	.create()
																	.autoFix(true)
																	.autoHide(true)
																	.hideOnEscape(true)
																	.content(tfFileNumber)
																	.build();

																tfFileNumber
																	.setOnAction(new EventHandler<ActionEvent>()
																	{
																		@Override
																		public void handle(
																				ActionEvent event)
																		{
																			int val = Integer
																				.parseInt(tfFileNumber
																					.getText());
																			if (val > puzzles
																				.size()) return;
																			String num = val < 10 ? ("0" + val)
																					: ("" + val);

																			readFromFile(puzzles
																				.get("5 puzzle"
																						+ num
																						+ ".clp"));
																			ppup.hide();
																		}
																	});

																tfFileNumber
																	.setOnKeyReleased(new EventHandler<KeyEvent>()
																	{

																		@Override
																		public void handle(
																				KeyEvent event)
																		{
																			if (event.getCode() == KeyCode.ESCAPE)
																				ppup.hide();
																		}
																	});

																ppup.show(stage);
															}
														});
		primaryStage.sizeToScene();
		primaryStage.show();
	}

	/**
	 * Remove candidates for the solved value.
	 * 
	 * @param row
	 *            The row of solved cell.
	 * @param col
	 *            The column of solved cell.
	 * @param v
	 *            The value of solved cell.
	 */
	private void updateGrid(int row, int col, int v)
	{
		for (int i = 0; i < 9; i++)
		{
			cells[row][i].disableCandidate(v);
			cells[i][col].disableCandidate(v);
		}
		int g = getBox(row, col);
		int gr = g / 3 * 3;
		int gc = g % 3 * 3;
		int rmax = gr + 3;
		int cmax = gc + 3;
		for (int r = gr; r < rmax; r++)
		{
			for (int c = gc; c < cmax; c++)
			{
				cells[r][c].disableCandidate(v);
			}
		}
	}

	/**
	 * Check the entire grid and remove invalid candidates.
	 */
	private void updateGrid()
	{
		for (int i = 0; i < cells.length; i++)
		{
			for (int j = 0; j < cells[i].length; j++)
			{
				Cell c = cells[i][j];
				if (c.isSolved()) continue;
				c.enableAllCandidates();
				List<Integer> not = getNotAllowedCandidates(i, j);
				for (Integer v : not)
				{
					c.disableCandidate(v);
				}
			}
		}
	}

	/**
	 * For the cell in the specified position, get a list of prohibited values.
	 * 
	 * @param row
	 * @param col
	 * @return a list of integers representing prohibired values.
	 */
	private List<Integer> getNotAllowedCandidates(int row, int col)
	{
		List<Integer> not = new ArrayList<>(9);
		for (int i = 0; i < 9; i++)
		{
			if (i != col) if (cells[row][i].isSolved()) not.add(cells[row][i].getValue());
			if (i != row) if (cells[i][col].isSolved()) not.add(cells[i][col].getValue());
		}
		return not;
	}

	/**
	 * Clears all cells.
	 */
	private void clear()
	{
		for (int i = 0; i < cells.length; i++)
		{
			for (int j = 0; j < cells[i].length; j++)
			{
				cells[i][j].enableAllCandidates();
				cells[i][j].setSolved(false);
			}
		}
	}

	/**
	 * Saves a snapshot of the current gird values in {@link #checkPoint}.
	 */
	private void saveState()
	{
		for (int i = 0; i < 9; i++)
		{
			for (int j = 0; j < 9; j++)
			{
				checkPoint[i][j] = cells[i][j].getValue();
			}
		}
	}

	/**
	 * Restores the last saved checkpoint from {@link #checkPoint}.
	 */
	private void reset()
	{
		clear();
		int v;
		Cell c;
		for (int i = 0; i < 9; i++)
		{
			for (int j = 0; j < 9; j++)
			{
				v = checkPoint[i][j];
				c = cells[i][j];
				if (v > 0)
				{
					c.setSolved(v);
					updateGrid(i, j, v);
				}
			}
		}
	}

	/**
	 * Saves the current gird values into a file as Clidoku's CLD format.
	 * 
	 * @param f
	 */
	private void saveToFile(File f)
	{
		try
		{
			DataOutputStream dos = new DataOutputStream(new BufferedOutputStream(
					new FileOutputStream(f)));
			for (int i = 0; i < cells.length; i++)
			{
				for (int j = 0; j < cells[i].length; j++)
				{
					dos.writeInt(cells[i][j].getValue());
				}
			}
			dos.close();
		} catch (IOException e)
		{
			Utils.showError("ERROR", e.getMessage(), e, stage);
		}

	}

	/**
	 * Reads grid values from a file. It can be a CLD or CLP file.
	 * 
	 * @param f
	 */
	private void readFromFile(File f)
	{
		clear();
		int[][] vals = new int[9][9];
		boolean clpFile = f.getName().toLowerCase().lastIndexOf(".clp") == f.getName().length() - 4;
		boolean cldFile = f.getName().toLowerCase().lastIndexOf(".cld") == f.getName().length() - 4;

		try
		{
			if (cldFile)
				vals = Utils.readCld(new FileInputStream(f), vals);
			else if (clpFile)
				vals = Utils.readClp(new FileReader(f), vals);
			else
				return;

			for (int i = 0; i < vals.length; i++)
			{
				for (int j = 0; j < vals[i].length; j++)
				{
					if (vals[i][j] > 0)
					{
						checkPoint[i][j] = vals[i][j];
						cells[i][j].setSolved(vals[i][j]);
						updateGrid(i, j, vals[i][j]);
					} else
						checkPoint[i][j] = 0;
				}
			}
		} catch (IOException e)
		{
			Utils.showError("ERROR", e.getMessage(), e, stage);
		}

	}

	/**
	 * Checks if the current grid values form a valid solved Sudoku.
	 */
	private void check()
	{
		// 3) use Environment#eval method to send commands to the CLIPS environment.
		loadGridToClips(clips);
		clips.eval("(assert (phase check))");
		clips.run();
		// 4) use the following workaround to retrieve facts from CLIPS environment.
		PrimitiveValue pv = clips.eval("(find-fact ((?f invalid)) TRUE)");
		try
		{
			if (pv.size() == 0)
				Utils.showMessage("Check", "valid", stage);
			else
			{
				pv = pv.get(0);
				Utils.showMessage("Check", pv.getFactSlot("why").toString(), stage);
			}
		} catch (Exception e)
		{
			Utils.showError("ERROR", e.getMessage(), e, stage);
		}
	}

	private void initClips(Environment clips)
	{
		// 2) load rules files
		clips.clear();
		clips.load("./clp/1 init.clp");
		clips.load("./clp/2 solve.clp");
		clips.load("./clp/3 check.clp");
	}

	private void loadGridToClips(Environment clips)
	{
		clips.reset();

		for (int i = 0; i < 9; i++)
		{
			for (int j = 0; j < 9; j++)
			{
				int v = cells[i][j].getValue();
				StringBuilder toAssert = new StringBuilder("(assert (cell ");
				toAssert.append("(val ").append(v).append(") ");
				toAssert.append("(row ").append(i + 1).append(") ");
				toAssert.append("(col ").append(j + 1).append(") ");
				toAssert.append("(id ").append((i * 9) + j + 1).append(") ");
				toAssert.append("(box ").append(getBox(i, j) + 1).append(") ");
				toAssert.append("))");
				clips.eval(toAssert.toString());
			}
		}
	}

	private void loadGridFromClips()
	{
		for (int i = 0; i < 9; i++)
		{
			for (int j = 0; j < 9; j++)
			{
				String s = "(find-fact ((?f cell)) (and (= ?f:row " + (i + 1) + ") (= ?f:col "
						+ (j + 1) + ")))";
				PrimitiveValue pv = clips.eval(s);
				try
				{
					if (pv.size() == 0) continue;
					pv = pv.get(0);
					int v = pv.getFactSlot("val").intValue();
					cells[i][j].setValue(v);
					if (v > 0)
					{
						cells[i][j].setSolved(true);
						updateGrid(i, j, v);
					}

				} catch (Exception e)
				{
					Utils.showError("ERROR", e.getMessage(), e, stage);
				}
			}
		}

	}

	private static int getBox(int r, int c)
	{
		return (r / 3) * 3 + c / 3;
	}

	private void showDebug()
	{
		final Environment clips = new Environment();

		final Button btnStart = new Button("_Start");
		btnStart.setMnemonicParsing(true);
		final Button btnStep = new Button("S_tep");
		btnStep.setMnemonicParsing(true);
		final Button btnRun = new Button("_Run");
		btnRun.setMnemonicParsing(true);
		final Button btnClearConsole = new Button("_Clear Console");
		btnClearConsole.setMnemonicParsing(true);
		final IntegerField tfRun = new IntegerField(-1, Integer.MAX_VALUE, -1);
		tfRun.setPromptText("Steps");
		final CheckBox cbWatchFacts = CheckBoxBuilder
			.create()
			.text("Watch _Facts")
			.selected(true)
			.mnemonicParsing(true)
			.build();
		final CheckBox cbWatchActivations = CheckBoxBuilder
			.create()
			.text("Watch _Activations")
			.selected(false)
			.mnemonicParsing(true)
			.build();
		final TextField tfCommand = TextFieldBuilder
			.create()
			.styleClass("code")
			.promptText("Command")
			.build();
		final Button btnExecute = new Button("E_xecute");
		final TextArea taOutput = TextAreaBuilder
			.create()
			.editable(false)
			.prefColumnCount(80)
			.prefRowCount(30)
			.styleClass("code")
			.build();
		final TextArea taFacts = TextAreaBuilder
			.create()
			.editable(false)
			.prefColumnCount(80 / 4)
			.prefRowCount(30)
			.styleClass("code")
			.build();
		final TextArea taAgenda = TextAreaBuilder
			.create()
			.editable(false)
			.prefRowCount(30 / 4)
			.styleClass("code")
			.build();

		final CheckBox cbShowFacts = CheckBoxBuilder
			.create()
			.text("Show Facts")
			.selected(false)
			.build();
		final CheckBox cbShowActivations = CheckBoxBuilder
			.create()
			.text("Show Activations")
			.selected(true)
			.build();

		// the first router should route to the console text area
		final FXClipsRouter router;
		clips.addRouter(router = new FXClipsRouter()
		{

			// this router should accept all kinds of output
			@Override
			public boolean query(String routerName)
			{
				for (String rname : ROUTERS_NAMES)
				{
					if (routerName.equals(rname)) return true;
				}
				return false;
			}

			@Override
			public void println(String msg)
			{
				taOutput.appendText(msg);
				taOutput.appendText("\n");
			}

			@Override
			public void print(String msg)
			{
				taOutput.appendText(msg);
			}
		});

		// the second router should route (facts) and (agenda)
		// to the facts and activations text areas
		// the problem is CLIPSJNI cannot do that

		facts = true; // used to tell the following router to write to facts text area or activations text area
		clips.addRouter(new FXClipsRouter()
		{

			// this router should only accepts (facts) and (agenda)
			@Override
			public boolean query(String routerName)
			{
				return routerName.equals("wdisplay");
			}

			@Override
			public void println(String msg)
			{
				print(msg);
			}

			@Override
			public void print(String msg)
			{
				if (facts)
				{
					// route output to facts text area
					taFacts.appendText(msg);
				} else
				{
					// route output to agenda text area
					taAgenda.appendText(msg);
				}
			}
		});

		clips.printBanner();

		btnStep.setDisable(true);
		btnRun.setDisable(true);
		tfRun.setDisable(true);
		cbWatchFacts.setDisable(true);
		cbWatchActivations.setDisable(true);
		tfCommand.setDisable(true);
		btnExecute.setDisable(true);

		btnStart.setOnAction(new EventHandler<ActionEvent>()
		{

			@Override
			public void handle(ActionEvent event)
			{
				btnStep.setDisable(false);
				btnRun.setDisable(false);
				tfRun.setDisable(false);
				cbWatchFacts.setDisable(false);
				cbWatchActivations.setDisable(false);
				tfCommand.setDisable(false);
				btnExecute.setDisable(false);

				clips.eval("(unwatch all)");
				initClips(clips);
				loadGridToClips(clips);
				clips.assertString("(debug)");
				clips.assertString("(manual-technique-assertion)");
				clips.assertString("(phase solve)");
				clips.assertString("(start-techniques)");
				for (CheckBox cb : techniques)
				{
					if (cb.isSelected())
						clips.assertString("(technique (name " + cb.getText() + ") (priority "
								+ ((Integer) cb.getUserData()) + ") (active no) (used no) )");
				}
				clips.run();
				clips.assertString("(rc)");
				clips.watch(Environment.FACTS);

				updateDebugWindows(
									clips,
									cbShowFacts.isSelected() ? taFacts : null,
									cbShowActivations.isSelected() ? taAgenda : null);

				btnStart.setText("Re_start");
			}
		});

		btnStep.setOnAction(new EventHandler<ActionEvent>()
		{

			@Override
			public void handle(ActionEvent event)
			{
				clips.run(1);
				updateDebugWindows(
									clips,
									cbShowFacts.isSelected() ? taFacts : null,
									cbShowActivations.isSelected() ? taAgenda : null);
			}
		});

		btnRun.setOnAction(new EventHandler<ActionEvent>()
		{

			@Override
			public void handle(ActionEvent event)
			{
				clips.run(tfRun.getValue());
			}
		});

		tfCommand.setOnAction(new EventHandler<ActionEvent>()
		{

			@Override
			public void handle(ActionEvent event)
			{
				btnExecute.fire();
			}
		});

		tfCommand.setOnKeyReleased(new EventHandler<KeyEvent>()
		{

			@Override
			public void handle(KeyEvent event)
			{
				if (event.getCode() == KeyCode.ESCAPE)
				{
					tfCommand.clear();
					event.consume();
				}
			}
		});

		btnExecute.setOnAction(new EventHandler<ActionEvent>()
		{

			@Override
			public void handle(ActionEvent event)
			{
				// since we added a router for (facts) and (agenda)
				// their output won't be displayed on console text area
				// the following workaround will copy the text from facts and activations text area
				if (tfCommand.getText().equals("(facts)"))
				{
					if (cbShowFacts.isSelected())
						router.println(taFacts.getText());
					else
					{
						updateDebugWindows(clips, taFacts, null);
						router.println(taFacts.getText());
						taFacts.clear();
					}
					return;
				}
				if (tfCommand.getText().equals("(agenda)"))
				{
					if (cbShowActivations.isSelected())
						router.println(taAgenda.getText());
					else
					{
						updateDebugWindows(clips, null, taAgenda);
						router.println(taAgenda.getText());
						taAgenda.clear();
					}
					return;
				}
				router.println(clips.eval(tfCommand.getText()).toString());
				updateDebugWindows(
									clips,
									cbShowFacts.isSelected() ? taFacts : null,
									cbShowActivations.isSelected() ? taAgenda : null);
			}
		});

		cbWatchFacts.selectedProperty().addListener(new ChangeListener<Boolean>()
		{

			@Override
			public void changed(ObservableValue<? extends Boolean> observable, Boolean oldValue,
					Boolean newValue)
			{
				if (newValue.booleanValue())
					clips.watch(Environment.FACTS);
				else
					clips.unwatch(Environment.FACTS);
			}
		});

		cbWatchActivations.selectedProperty().addListener(new ChangeListener<Boolean>()
		{

			@Override
			public void changed(ObservableValue<? extends Boolean> observable, Boolean oldValue,
					Boolean newValue)
			{
				if (newValue.booleanValue())
					clips.watch(Environment.ACTIVATIONS);
				else
					clips.unwatch(Environment.ACTIVATIONS);
			}
		});

		btnClearConsole.setOnAction(new EventHandler<ActionEvent>()
		{

			@Override
			public void handle(ActionEvent event)
			{
				taOutput.clear();
				clips.printBanner();
			}
		});

		HBox layout1 = HBoxBuilder.create().spacing(5.0).children(
																	btnStart,
																	btnStep,
																	btnRun,
																	tfRun,
																	btnClearConsole).build();
		HBox layout2 = HBoxBuilder.create().spacing(5.0).children(
																	cbWatchFacts,
																	cbWatchActivations,
																	cbShowFacts,
																	cbShowActivations).build();
		HBox layout3 = HBoxBuilder.create().spacing(5.0).children(tfCommand, btnExecute).build();
		HBox.setHgrow(tfCommand, Priority.ALWAYS);

		final SplitPane layout4 = SplitPaneBuilder
			.create()
			.orientation(Orientation.HORIZONTAL)
			.dividerPositions(new double[]
			{ 1.0 })
			.items(taOutput, taFacts)
			.build();
		SplitPane.setResizableWithParent(taFacts, false);

		final SplitPane layout5 = SplitPaneBuilder
			.create()
			.orientation(Orientation.VERTICAL)
			.dividerPositions(new double[]
			{ 0.75 })
			.items(layout4, taAgenda)
			.build();
		SplitPane.setResizableWithParent(taAgenda, false);

		VBox layout = VBoxBuilder
			.create()
			.spacing(5.0)
			.children(layout1, layout2, layout3, layout5)
			.build();
		VBox.setVgrow(layout5, Priority.ALWAYS);

		cbShowFacts.selectedProperty().addListener(new ChangeListener<Boolean>()
		{

			@Override
			public void changed(ObservableValue<? extends Boolean> observable, Boolean oldValue,
					Boolean newValue)
			{
				if (newValue.booleanValue())
				{
					layout4.setDividerPosition(0, .75);
					updateDebugWindows(clips, taFacts, null);
				} else
				{
					layout4.setDividerPosition(0, 1.0);
					taFacts.clear();
				}
			}

		});

		cbShowActivations.selectedProperty().addListener(new ChangeListener<Boolean>()
		{

			@Override
			public void changed(ObservableValue<? extends Boolean> observable, Boolean oldValue,
					Boolean newValue)
			{
				if (newValue.booleanValue())
				{
					layout5.setDividerPosition(0, .75);
					updateDebugWindows(clips, null, taAgenda);
				} else
				{
					layout5.setDividerPosition(0, 1.0);
					taAgenda.clear();
				}
			}

		});

		Stage stgDebug = new Stage();
		stgDebug.initModality(Modality.WINDOW_MODAL);
		stgDebug.initOwner(stage);
		stgDebug.setTitle("Clidoku Debug");
		stgDebug.setScene(SceneBuilder.create().root(layout).stylesheets(css).build());

		stgDebug.getScene().getAccelerators().put(
													new KeyCodeCombination(KeyCode.S,
															KeyCombination.SHORTCUT_DOWN),
													new Runnable()
													{

														@Override
														public void run()
														{
															btnStart.fire();
														}
													});
		stgDebug.getScene().getAccelerators().put(
													new KeyCodeCombination(KeyCode.T,
															KeyCombination.SHORTCUT_DOWN),
													new Runnable()
													{

														@Override
														public void run()
														{
															btnStep.fire();
														}
													});
		stgDebug.getScene().getAccelerators().put(
													new KeyCodeCombination(KeyCode.R,
															KeyCombination.SHORTCUT_DOWN),
													new Runnable()
													{

														@Override
														public void run()
														{
															btnRun.fire();
														}
													});
		stgDebug.getScene().getAccelerators().put(
													new KeyCodeCombination(KeyCode.C,
															KeyCombination.SHORTCUT_DOWN),
													new Runnable()
													{

														@Override
														public void run()
														{
															btnClearConsole.fire();
														}
													});
		stgDebug.getScene().getAccelerators().put(
													new KeyCodeCombination(KeyCode.X,
															KeyCombination.SHORTCUT_DOWN),
													new Runnable()
													{

														@Override
														public void run()
														{
															btnExecute.fire();
														}
													});
		stgDebug.getScene().getAccelerators().put(
													new KeyCodeCombination(KeyCode.F,
															KeyCombination.SHORTCUT_DOWN),
													new Runnable()
													{

														@Override
														public void run()
														{
															cbWatchFacts.setSelected(!cbWatchFacts
																.isSelected());
														}
													});
		stgDebug.getScene().getAccelerators().put(
													new KeyCodeCombination(KeyCode.A,
															KeyCombination.SHORTCUT_DOWN),
													new Runnable()
													{

														@Override
														public void run()
														{
															cbWatchActivations
																.setSelected(!cbWatchActivations
																	.isSelected());
														}
													});
		stgDebug.getScene().getAccelerators().put(
													new KeyCodeCombination(KeyCode.F,
															KeyCombination.SHORTCUT_DOWN,
															KeyCombination.SHIFT_DOWN),
													new Runnable()
													{

														@Override
														public void run()
														{
															cbShowFacts.setSelected(!cbShowFacts
																.isSelected());
														}
													});
		stgDebug.getScene().getAccelerators().put(
													new KeyCodeCombination(KeyCode.A,
															KeyCombination.SHORTCUT_DOWN,
															KeyCombination.SHIFT_DOWN),
													new Runnable()
													{

														@Override
														public void run()
														{
															cbShowActivations
																.setSelected(!cbShowActivations
																	.isSelected());
														}
													});

		stgDebug.showAndWait();

		clips.destroy();
	}

	private void updateDebugWindows(Environment clips, TextArea taf, TextArea taa)
	{
		if (taf != null)
		{
			facts = true; // will be used in the router and route output to facts text area
			taf.clear();
			clips.eval("(facts)");
		}
		if (taa != null)
		{
			facts = false; // will be used in the router and route output to activations text area
			taa.clear();
			clips.eval("(agenda)");
			taa.positionCaret(0);
		}
	}

	public static void main(String[] args) throws Exception
	{
		Application.launch(args);
	}

	/**
	 * A Cell is grid of 9 candidates or just a label of its value.
	 */
	private class Cell extends GridPane
	{
		Map<Integer, Hyperlink>	candidates;
		Map<Integer, Boolean>	candidateAvailable;
		Label					txtValue;
		public int				row	= 0;
		public int				col	= 0;

		public Cell()
		{
			this("0");
		}

		public Cell(String initialTxtValue)
		{
			candidates = new HashMap<>(9);
			candidateAvailable = new HashMap<>(9);
			txtValue = LabelBuilder
				.create()
				.text(initialTxtValue)
				.visible(false)
				.alignment(Pos.CENTER)
				.font(Font.font("sans", FontWeight.BOLD, 24.0))
				.build();
			txtValue.prefWidthProperty().bind(widthProperty());
			txtValue.prefHeightProperty().bind(heightProperty());
			txtValue.setContextMenu(ContextMenuBuilder
				.create()
				.items(
						MenuItemBuilder
							.create()
							.text("Unsolve")
							.onAction(new EventHandler<ActionEvent>()
							{

								@Override
								public void handle(ActionEvent event)
								{
									Cell.this.setSolved(false);
								}
							})
							.build())
				.build());
			txtValue.setOnMouseClicked(new EventHandler<MouseEvent>()
			{

				@Override
				public void handle(MouseEvent event)
				{
					if (event.getClickCount() >= 2)
					{
						setSolved(false);
					}
				}
			});

			add(txtValue, 0, 0, 3, 3);
			getStyleClass().add("thin-border");

			int x, y;
			double fontSize = 12.0;
			double btnSize = fontSize + 10;
			for (int i = 0; i < 9; i++)
			{
				x = i / 3;
				y = i % 3;
				final Hyperlink btn = HyperlinkBuilder
					.create()
					.alignment(Pos.CENTER)
					.font(Font.font("sans", fontSize))
					.minHeight(btnSize)
					.minWidth(btnSize)
					.maxHeight(btnSize)
					.maxWidth(btnSize)
					.text(String.valueOf(i + 1))
					.build();

				candidates.put(new Integer(i + 1), btn);
				candidateAvailable.put(new Integer(i + 1), true);
				add(btn, y, x);
				btn.setOnAction(new EventHandler<ActionEvent>()
				{

					@Override
					public void handle(ActionEvent event)
					{
						int v = Integer.parseInt(btn.getText());
						setSolved(v);
						txtValue.setTextFill(Paint.valueOf("blue"));
						updateGrid(Cell.this.row, Cell.this.col, v);
					}
				});

				btn.setOnMouseClicked(new EventHandler<MouseEvent>()
				{

					@Override
					public void handle(MouseEvent event)
					{
						if (event.isControlDown())
						{
							btn.setVisible(false);
						}
					}
				});
			} // for

			final ContextMenu cm = ContextMenuBuilder
				.create()
				.autoHide(true)
				.hideOnEscape(true)
				.items(
						MenuItemBuilder
							.create()
							.text("Hide all")
							.onAction(new EventHandler<ActionEvent>()
							{

								@Override
								public void handle(ActionEvent event)
								{
									for (Hyperlink btn : candidates.values())
									{
										btn.setVisible(false);
									}
								}
							})
							.build(),
						MenuItemBuilder
							.create()
							.text("Show all")
							.onAction(new EventHandler<ActionEvent>()
							{

								@Override
								public void handle(ActionEvent event)
								{
									for (Integer i : candidates.keySet())
									{
										if (candidateAvailable.get(i))
											candidates.get(i).setVisible(true);
									}
								}
							})
							.build())
				.build();
			cm.setOnHidden(new EventHandler<WindowEvent>()
			{

				@Override
				public void handle(WindowEvent event)
				{
					cm.getItems().remove(2, cm.getItems().size());
				}
			});

			setOnContextMenuRequested(new EventHandler<ContextMenuEvent>()
			{

				@Override
				public void handle(ContextMenuEvent event)
				{
					if (cm.isShowing()) return;
					Menu menuHide = new Menu("Hide");
					Menu menuShow = new Menu("Show");
					for (Integer i : candidates.keySet())
					{
						final Hyperlink btn = candidates.get(i);
						if (btn.isVisible())
							menuHide.getItems().add(
													MenuItemBuilder
														.create()
														.text("Hide " + btn.getText())
														.onAction(new EventHandler<ActionEvent>()
														{

															@Override
															public void handle(ActionEvent event)
															{
																btn.setVisible(false);
															}
														})
														.build());
						else if (candidateAvailable.get(i))
							menuShow.getItems().add(
													MenuItemBuilder
														.create()
														.text("Show " + btn.getText())
														.onAction(new EventHandler<ActionEvent>()
														{

															@Override
															public void handle(ActionEvent event)
															{
																btn.setVisible(true);
															}
														})
														.build());

					}
					if (!menuHide.getItems().isEmpty()) cm.getItems().add(menuHide);
					if (!menuShow.getItems().isEmpty()) cm.getItems().add(menuShow);
					cm.show(Cell.this, event.getScreenX(), event.getScreenY());
					event.consume();
				}
			});
		} // constructor

		//		public void enableCandidate(int v)
		//		{
		//			if (v > 9 || v < 1) return;
		//			candidates.get(v).setVisible(true);
		//		}

		public void disableCandidate(int v)
		{
			if (v > 9 || v < 1) return;
			candidates.get(v).setVisible(false);
			candidateAvailable.put(v, false);
		}

		public void disableAllCandidates()
		{
			for (int i = 1; i < 10; ++i)
			{
				candidates.get(i).setVisible(false);
				candidateAvailable.put(i, false);
			}
		}

		public void enableAllCandidates()
		{
			for (int i = 1; i < 10; ++i)
			{
				candidates.get(i).setVisible(true);
				candidateAvailable.put(i, true);
			}
		}

		public void setSolved(boolean state)
		{
			txtValue.setTextFill(Paint.valueOf("black"));
			if (state)
			{
				disableAllCandidates();
				txtValue.setVisible(true);
			} else
			{
				txtValue.setText("0");
				txtValue.setVisible(false);
				updateGrid();
			}
		}

		public void setSolved(int v)
		{
			setSolved(true);
			setValue(v);
		}

		public void setValue(int v)
		{
			txtValue.setText(String.valueOf(v));
		}

		public int getValue()
		{
			return Integer.parseInt(txtValue.getText());
		}

		public boolean isSolved()
		{
			return txtValue.isVisible();
		}
	}

	private MenuBar createMenuBar(final Stage stgOptions)
	{
		puzzles = new LinkedHashMap<>();

		try (DirectoryStream<Path> files = Files.newDirectoryStream(Paths.get("./clp/")))
		{
			for (Path f : files)
			{
				if (Files.isRegularFile(f, LinkOption.NOFOLLOW_LINKS))
				{
					if (f.getFileName().toString().startsWith("5 puzzle"))
					{
						puzzles.put(f.getFileName().toString(), f.toFile());
					}
				}
			}
		} catch (IOException e1)
		{}

		List<MenuItem> puzzlesMenu = new ArrayList<>();

		if (!puzzles.isEmpty())
		{
			for (String name : puzzles.keySet())
			{
				final String fname = name;
				puzzlesMenu.add(MenuItemBuilder
					.create()
					.text(name)
					.onAction(new EventHandler<ActionEvent>()
					{

						@Override
						public void handle(ActionEvent event)
						{
							readFromFile(puzzles.get(fname));
						}
					})
					.build());
			}
		}
		return MenuBarBuilder
			.create()
			.menus(
					MenuBuilder
						.create()
						.text("_File")
						.items(
								MenuItemBuilder
									.create()
									.text("Open")
									.accelerator(KeyCombination.valueOf("ctrl+o"))
									.onAction(new EventHandler<ActionEvent>()
									{

										@Override
										public void handle(ActionEvent event)
										{
											File f = FileChooserBuilder
												.create()
												.title("Choose a file to load Clidoku from")
												.extensionFilters(
																	new ExtensionFilter(
																			"Clidoku files",
																			"*.cld", "*.clp"))
												.build()
												.showOpenDialog(stage);
											if (f != null) readFromFile(f);
										}
									})
									.build(),
								MenuBuilder.create().text("Puzzles").items(puzzlesMenu).build(),
								MenuItemBuilder
									.create()
									.text("Save")
									.accelerator(KeyCombination.valueOf("ctrl+shift+s"))
									.onAction(new EventHandler<ActionEvent>()
									{

										@Override
										public void handle(ActionEvent event)
										{
											File f = FileChooserBuilder
												.create()
												.title("Choose a file to save Clidoku in")
												.extensionFilters(
																	new ExtensionFilter(
																			"Clidoku files",
																			"*.cld"))
												.build()
												.showSaveDialog(stage);
											if (f != null) saveToFile(f);
										}
									})
									.build(),
								MenuItemBuilder
									.create()
									.text("Utilities")
									.accelerator(KeyCombination.valueOf("ctrl+u"))
									.onAction(new EventHandler<ActionEvent>()
									{
										@Override
										public void handle(ActionEvent event)
										{
											Utils.createStage(null).show();
										}
									})
									.build(),
								MenuItemBuilder
									.create()
									.text("Exit")
									.accelerator(KeyCombination.valueOf("ctrl+w"))
									.onAction(new EventHandler<ActionEvent>()
									{

										@Override
										public void handle(ActionEvent event)
										{
											Platform.exit();
										}
									})
									.build())
						.build(),
					MenuBuilder
						.create()
						.text("_Edit")
						.items(
								MenuItemBuilder
									.create()
									.text("Copy")
									.accelerator(KeyCombination.valueOf("ctrl+c"))
									.onAction(new EventHandler<ActionEvent>()
									{
										@Override
										public void handle(ActionEvent event)
										{
											int[][] vals = new int[9][9];
											for (int i = 0; i < vals.length; i++)
											{
												for (int j = 0; j < vals[i].length; j++)
												{
													vals[i][j] = cells[i][j].getValue();
												}
											}
											StringWriter sw = new StringWriter();
											Utils.writeH(vals, sw);
											ClipboardContent cc = new ClipboardContent();
											cc.putString(sw.toString());
											Clipboard.getSystemClipboard().setContent(cc);
										}
									})
									.build(),
								MenuItemBuilder
									.create()
									.text("Paste")
									.accelerator(KeyCombination.valueOf("ctrl+v"))
									.onAction(new EventHandler<ActionEvent>()
									{

										@Override
										public void handle(ActionEvent event)
										{
											try
											{
												String data = Clipboard
													.getSystemClipboard()
													.getString();
												if (data == null) return;
												int[][] vals = Utils.readH(
																			data,
																			new int[9][9],
																			null);
												clear();
												for (int i = 0; i < vals.length; i++)
												{
													for (int j = 0; j < vals[i].length; j++)
													{
														if (vals[i][j] > 0)
														{
															cells[i][j].setSolved(vals[i][j]);
															updateGrid(i, j, vals[i][j]);
														}
													}
												}
											} catch (Exception e)
											{}
										}
									})
									.build(),
								MenuItemBuilder
									.create()
									.text("Copy Screenshot")
									.onAction(new EventHandler<ActionEvent>()
									{

										@Override
										public void handle(ActionEvent event)
										{
											Image img = stage
												.getScene()
												.getRoot()
												.getChildrenUnmodifiable()
												.get(0)
												.snapshot(null, null);
											ClipboardContent cc = new ClipboardContent();
											cc.putImage(img);
											Clipboard.getSystemClipboard().setContent(cc);
										}
									})
									.build(),
								MenuItemBuilder
									.create()
									.text("Save Screenshot")
									.onAction(new EventHandler<ActionEvent>()
									{

										@Override
										public void handle(ActionEvent event)
										{
											File f = FileChooserBuilder
												.create()
												.title("Save File")
												.extensionFilters(
																	new ExtensionFilter(
																			"JPG Images", "*.jpg",
																			"*.jpeg"))
												.build()
												.showSaveDialog(stage);
											if (f == null) return;

											Image img = stage
												.getScene()
												.getRoot()
												.getChildrenUnmodifiable()
												.get(0)
												.snapshot(null, null);
											try
											{
												ImageIO
													.write(
															SwingFXUtils.fromFXImage(img, null),
															"png",
															f);
											} catch (IOException e)
											{
												Utils.showError("ERROR", "I/O ERROR", e, stage);
											}
										}
									})
									.build(),
								MenuItemBuilder
									.create()
									.text("Options")
									.accelerator(KeyCombination.valueOf("ctrl+p"))
									.onAction(new EventHandler<ActionEvent>()
									{

										@Override
										public void handle(ActionEvent event)
										{
											stgOptions.show();
										}
									})
									.build())
						.build(),
					MenuBuilder
						.create()
						.text("_Play")
						.items(
								MenuItemBuilder
									.create()
									.text("Save State")
									.accelerator(KeyCombination.valueOf("ctrl+s"))
									.onAction(new EventHandler<ActionEvent>()
									{

										@Override
										public void handle(ActionEvent event)
										{
											saveState();
										}
									})
									.build(),
								MenuItemBuilder
									.create()
									.text("Reset")
									.accelerator(KeyCombination.valueOf("ctrl+r"))
									.onAction(new EventHandler<ActionEvent>()
									{

										@Override
										public void handle(ActionEvent event)
										{
											reset();
										}
									})
									.build(),
								MenuItemBuilder
									.create()
									.text("Clear")
									.accelerator(KeyCombination.valueOf("ctrl+shift+r"))
									.onAction(new EventHandler<ActionEvent>()
									{

										@Override
										public void handle(ActionEvent event)
										{
											clear();
										}
									})
									.build())
						.build(),
					MenuBuilder
						.create()
						.text("_Solve")
						.items(
								MenuItemBuilder
									.create()
									.text("Check")
									.accelerator(KeyCombination.valueOf("ctrl+k"))
									.onAction(new EventHandler<ActionEvent>()
									{

										@Override
										public void handle(ActionEvent event)
										{
											check();
										}
									})
									.build(),
								MenuItemBuilder
									.create()
									.text("Solve")
									.accelerator(KeyCombination.valueOf("ctrl+space"))
									.onAction(new EventHandler<ActionEvent>()
									{

										@Override
										public void handle(ActionEvent event)
										{
											final ProgressIndicator pi = new ProgressIndicator();
											pi.setProgress(-1.0);
											final Label lblMsg = new Label("Please wait..");
											final Button btnOk = new Button("OK");
											btnOk.setVisible(false);

											final VBox nodes = VBoxBuilder
												.create()
												.alignment(Pos.CENTER)
												.children(lblMsg, pi, btnOk)
												.spacing(2.0)
												.build();

											final Stage dialog = Utils.getDialog(
																					"Solving",
																					nodes,
																					stage);
											btnOk.setOnAction(new EventHandler<ActionEvent>()
											{

												@Override
												public void handle(ActionEvent event)
												{
													dialog.hide();
												}
											});
											dialog.show();
											dialog.getScene().setCursor(Cursor.WAIT);
											stage.getScene().getRoot().setDisable(true);
											stage.getScene().setCursor(Cursor.WAIT);

											loadGridToClips(clips);

											Worker<Void> w = new Task<Void>()
											{

												@Override
												protected Void call() throws Exception
												{

													clips
														.assertString("(manual-technique-assertion)");
													clips.assertString("(phase solve)");
													clips.assertString("(start-techniques)");

													for (CheckBox cb : techniques)
													{
														if (cb.isSelected())
															clips.assertString("(technique (name "
																	+ cb.getText() + ") (priority "
																	+ ((Integer) cb.getUserData())
																	+ ") (active no) (used no) )");
													}

													clips.run();

													clips.eval("(assert (phase check))");
													clips.run();

													PrimitiveValue pv = clips
														.eval("(find-fact ((?f invalid)) TRUE)");
													final String title = pv.size() == 0 ? "Solved"
															: "Not Solved";

													final StringBuilder techniques = new StringBuilder();
													pv = clips
														.eval("(find-all-facts ((?f technique)) (eq ?f:used yes))");
													if (pv.size() > 0)
													{
														for (int i = 0; i < pv.size(); i++)
														{
															techniques
																.append("\t")
																.append(
																		pv
																			.get(i)
																			.getFactSlot("name"))
																.append("\n");
														}
													}

													Platform.runLater(new Runnable()
													{

														@Override
														public void run()
														{
															loadGridFromClips();
															pi.setProgress(1.0);
															lblMsg.setText("Techniques Used:\n"
																	+ techniques.toString());
															lblMsg
																.setTextFill(Paint.valueOf(title
																	.equals("Solved") ? "blue"
																		: "red"));
															dialog.setTitle(title);
															stage
																.getScene()
																.getRoot()
																.setDisable(false);
															stage
																.getScene()
																.setCursor(Cursor.DEFAULT);
															dialog
																.getScene()
																.setCursor(Cursor.DEFAULT);
															btnOk.setVisible(true);
															dialog.sizeToScene();
														}
													});
													return null;
												}
											};
											new Thread((Runnable) w).start();
										}

									})
									.build())
						.build(),
					MenuBuilder
						.create()
						.text("_Debug")
						.items(
								MenuItemBuilder
									.create()
									.text("Watches")
									.accelerator(KeyCombination.valueOf("ctrl+d"))
									.onAction(new EventHandler<ActionEvent>()
									{

										@Override
										public void handle(ActionEvent event)
										{
											showDebug();
										}
									})
									.build())
						.build(),
					MenuBuilder
						.create()
						.text("?")
						.items(
								MenuItemBuilder
									.create()
									.text("Help")
									.accelerator(KeyCombination.valueOf("f1"))
									.onAction(new EventHandler<ActionEvent>()
									{

										@Override
										public void handle(ActionEvent event)
										{
											createHelpStage().show();
										}
									})
									.build(),
								MenuItemBuilder
									.create()
									.text("About")
									.accelerator(KeyCombination.valueOf("ctrl+a"))
									.onAction(new EventHandler<ActionEvent>()
									{

										@Override
										public void handle(ActionEvent event)
										{
											Stage about = new Stage();
											about.setTitle("Clidoku About");
											Text authorText = TextBuilder
												.create()
												.text("By Anas H. Sulaiman (ahs.pw)")
												.fill(Paint.valueOf("blue"))
												.smooth(true)
												.font(Font.font("sans", 24.0))
												.build();
											Text noteText = TextBuilder
												.create()
												.text(
														"This is a rapidly developed prototype. It's far from being complete.\nFeel free to improve.")
												.font(Font.font("sans", 18.0))
												.build();
											authorText
												.wrappingWidthProperty()
												.bind(about.widthProperty());
											noteText
												.wrappingWidthProperty()
												.bind(about.widthProperty());

											Hyperlink hlFork = HyperlinkBuilder
												.create()
												.text("fork..")
												.onAction(new EventHandler<ActionEvent>()
												{

													@Override
													public void handle(ActionEvent event)
													{
														getHostServices()
															.showDocument(
																			"https://github.com/ahspw/clidoku/fork");
													}
												})
												.build();

											about.setScene(new Scene(VBoxBuilder
												.create()
												.spacing(2.0)
												.children(authorText, noteText, hlFork)
												.build()));
											about.show();
										}
									})
									.build())
						.build())
			.build();
	}

	private Stage createHelpStage()
	{
		Stage stgHelp = new Stage();

		final Map<String, String> titleContent = new HashMap<>();
		ListView<String> titles = new ListView<String>();
		titles.setEditable(false);

		final TextArea txt = TextAreaBuilder
			.create()
			.editable(false)
			.wrapText(true)
			.style("-fx-font-size: 20")
			.build();

		titles.getSelectionModel().selectedItemProperty().addListener(new ChangeListener<String>()
		{

			@Override
			public void changed(ObservableValue<? extends String> observable, String oldValue,
					String newValue)
			{
				txt.setText(titleContent.get(newValue));
			}
		});

		SplitPane sp = SplitPaneBuilder
			.create()
			.orientation(Orientation.HORIZONTAL)
			.dividerPositions(new double[]
			{ 0.33 })
			.items(titles, txt)
			.build();

		try
		{
			Scanner scan = new Scanner(new File("res/help.txt"));

			boolean title = false;
			StringBuilder content = new StringBuilder();
			String lastTitle = "";
			if (scan.hasNext())
			{
				lastTitle = scan.nextLine();
				titles.getItems().add(lastTitle);
			}
			while (scan.hasNext())
			{
				String line = scan.nextLine();
				if (line.isEmpty())
				{
					titleContent.put(lastTitle, content.toString());
					content = new StringBuilder();
					title = true;
					continue;
				}
				if (title)
				{
					lastTitle = line;
					titles.getItems().add(line);
					title = false;
				} else
					content.append(line).append("\n");

			}
			titleContent.put(lastTitle, content.toString());
			scan.close();
		} catch (FileNotFoundException e)
		{
			Utils.showError("ERROR", e.getMessage(), e, stage);
		}
		titles.getSelectionModel().selectFirst();
		stgHelp.setTitle("Clidoku Help");
		stgHelp.setScene(SceneBuilder.create().root(sp).build());
		stgHelp.sizeToScene();
		return stgHelp;
	}

	private Stage createOptionsStage()
	{
		final Stage stgOptions = new Stage();

		// technique priority is its index in the array
		String[] techName = new String[]
		{
				"Full-House",
				"Naked-Single",
				"Hidden-Single",
				"Locked-Candidate-Pointing",
				"Locked-Candidate-Claiming",
				"Locked-Candidate-Multiple-Lines",
				"Naked-pair",
				"Hidden-Pair",
				"Locked-Pair",
				"X-Wing",
				"Naked-Triple",
				"Hidden-Triple",
				"Locked-Triple",
				"XY-Wing",
				"XYZ-Wing",
				"W-Wing",
				"Unique-Rectangle-1",
				"Unique-Rectangle-2",
				"Unique-Rectangle-4",
				"Unique-Rectangle-5",
				"Unique-Rectangle-6",
				"Swordfish",
				"Naked-Quadruple",
				"Hidden-Quadruple",
				"Jellyfish" };

		boolean[] techEnabled = new boolean[]
		{
				true,
				true,
				true,
				true,
				true,
				true,
				true,
				true,
				true,
				true,
				true,
				true,
				true,
				true,
				true,
				true,
				true,
				true,
				true,
				true,
				true,
				true,
				true,
				true,
				true };

		techniques = new CheckBox[techName.length];

		int j = -1;
		for (int i = 0; i < techniques.length; i++, j--)
		{
			techniques[i] = CheckBoxBuilder
				.create()
				.text(techName[i])
				.selected(techEnabled[i])
				.userData(new Integer(j))
				.maxWidth(Double.MAX_VALUE)
				.build();
		}

		TilePane layout = TilePaneBuilder
			.create()
			.vgap(2.0)
			.hgap(2.0)
			.alignment(Pos.CENTER_LEFT)
			.orientation(Orientation.VERTICAL)
			.prefRows(techName.length / 2 + 1)
			.children(techniques)
			.build();

		Button btnOk = new Button("OK");
		btnOk.setOnAction(new EventHandler<ActionEvent>()
		{

			@Override
			public void handle(ActionEvent event)
			{
				stgOptions.hide();
			}
		});

		VBox.setVgrow(layout, Priority.ALWAYS);

		stgOptions.setTitle("Cliduko Options");
		stgOptions.setScene(SceneBuilder.create().root(
														VBoxBuilder
															.create()
															.alignment(Pos.CENTER)
															.spacing(2.0)
															.children(layout, btnOk)
															.build()).build());
		stgOptions.sizeToScene();

		return stgOptions;
	}

	@Override
	public void stop() throws Exception
	{
		// 5) free resources
		clips.destroy();
	}
}
