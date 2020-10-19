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

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.io.Reader;
import java.io.StringReader;
import java.io.StringWriter;
import java.io.Writer;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Formatter;
import java.util.List;
import java.util.Scanner;

import javafx.application.Application;
import javafx.concurrent.Task;
import javafx.concurrent.Worker;
import javafx.event.ActionEvent;
import javafx.event.EventHandler;
import javafx.geometry.Pos;
import javafx.scene.Node;
import javafx.scene.SceneBuilder;
import javafx.scene.control.Button;
import javafx.scene.control.ButtonBuilder;
import javafx.scene.control.ComboBox;
import javafx.scene.control.Label;
import javafx.scene.control.ProgressBar;
import javafx.scene.control.RadioButton;
import javafx.scene.control.RadioButtonBuilder;
import javafx.scene.control.TextArea;
import javafx.scene.control.TextAreaBuilder;
import javafx.scene.control.TextField;
import javafx.scene.control.TextFieldBuilder;
import javafx.scene.control.ToggleGroup;
import javafx.scene.layout.AnchorPaneBuilder;
import javafx.scene.layout.BorderPane;
import javafx.scene.layout.BorderPaneBuilder;
import javafx.scene.layout.HBox;
import javafx.scene.layout.HBoxBuilder;
import javafx.scene.layout.Priority;
import javafx.scene.layout.VBox;
import javafx.scene.layout.VBoxBuilder;
import javafx.stage.DirectoryChooserBuilder;
import javafx.stage.FileChooser.ExtensionFilter;
import javafx.stage.FileChooserBuilder;
import javafx.stage.Stage;
import javafx.stage.StageStyle;
import javafx.stage.WindowEvent;

public class Utils extends Application
{
	/**
	 * Convert from HoDoKu's one line string to Clidoku's CLP format.
	 * 
	 * @param hodoku
	 *            the one line string
	 * @param out
	 *            a Writer
	 */
	public static void h2p(String hodoku, Writer out)
	{
		int[][] s = hodoku.trim().length() > 162 ? new int[9][9] : null;
		writeClp(readH(hodoku, new int[9][9], s), s, out);
	}

	/**
	 * Convert from HoDoKu's one line string to Clidoku's CLP format.
	 * 
	 * @param in
	 * @param out
	 * @throws IOException
	 */
	public static void h2p(Reader in, Writer out) throws IOException
	{
		int[][] s = new int[9][9];
		writeClp(readH(in, new int[9][9], s), s, out);
	}

	/**
	 * Convert from HoDoKu's one line string to Clidoku's CLD format.
	 * 
	 * @param hodoku
	 * @param out
	 * @throws IOException
	 */
	public static void h2d(String hodoku, OutputStream out) throws IOException
	{
		writeCld(readH(hodoku, new int[9][9], null), out);
	}

	/**
	 * Convert from HoDoKu's one line string to Clidoku's CLD format.
	 * 
	 * @param in
	 * @param out
	 * @throws IOException
	 */
	public static void h2d(Reader in, OutputStream out) throws IOException
	{
		writeCld(readH(in, new int[9][9], null), out);
	}

	/**
	 * Convert from HoDoKu's one line string to Clidoku's CLD format.
	 * 
	 * @param hodoku
	 * @param out
	 */
	public static void h2d(String hodoku, Writer out)
	{
		writeCld(readH(hodoku, new int[9][9], null), out);
	}

	/**
	 * Convert from HoDoKu's one line string to Clidoku's CLD format.
	 * 
	 * @param in
	 * @param out
	 * @throws IOException
	 */
	public static void h2d(Reader in, Writer out) throws IOException
	{
		writeCld(readH(in, new int[9][9], null), out);
	}

	/**
	 * Convert from Clidoku's CLP format to Clidoku's CLD format.
	 * 
	 * @param in
	 * @param out
	 * @throws IOException
	 */
	public static void p2d(Reader in, OutputStream out) throws IOException
	{
		writeCld(readClp(in, new int[9][9]), out);
	}

	/**
	 * Convert from Clidoku's CLP format to Clidoku's CLD format.
	 * 
	 * @param in
	 * @param out
	 */
	public static void p2d(Reader in, Writer out)
	{
		writeCld(readClp(in, new int[9][9]), out);
	}

	/**
	 * Convert from Clidoku's CLP format to HoDoKu's one line string.
	 * 
	 * @param in
	 * @param out
	 * @throws IOException
	 */
	public static void p2h(Reader in, Writer out) throws IOException
	{
		writeH(readClp(in, new int[9][9]), out);
	}

	/**
	 * Convert from Clidoku's CLD format to HoDoKu's one line string.
	 * 
	 * @param in
	 * @param out
	 * @throws IOException
	 */
	public static void d2h(InputStream in, Writer out) throws IOException
	{
		writeH(readCld(in, new int[9][9]), out);
	}

	/**
	 * Convert from Clidoku's CLD format to HoDoKu's one line string.
	 * 
	 * @param in
	 * @param out
	 * @throws IOException
	 */
	public static void d2h(Reader in, Writer out) throws IOException
	{
		writeH(readCld(in, new int[9][9]), out);
	}

	/**
	 * Convert from Clidoku's CLD format to Clidoku's CLP format.
	 * 
	 * @param in
	 * @param out
	 * @throws IOException
	 */
	public static void d2p(InputStream in, Writer out) throws IOException
	{
		writeClp(readCld(in, new int[9][9]), null, out);
	}

	/**
	 * Convert from Clidoku's CLD format to Clidoku's CLP format.
	 * 
	 * @param in
	 * @param out
	 * @throws IOException
	 */
	public static void d2p(Reader in, Writer out) throws IOException
	{
		writeClp(readCld(in, new int[9][9]), null, out);
	}

	/**
	 * Reads a CLD format into an array.
	 * 
	 * @param in
	 * @param v
	 *            The array to fill. Must not be null.
	 * @return the array parameter.
	 * @throws IOException
	 */
	public static int[][] readCld(InputStream in, int[][] v) throws IOException
	{
		DataInputStream dis = new DataInputStream(in);
		for (int i = 0; i < 9; i++)
		{
			for (int j = 0; j < 9; j++)
			{
				v[i][j] = dis.readInt();
			}
		}
		dis.close();
		return v;
	}

	/**
	 * Reads a CLD format into an array.
	 * 
	 * @param in
	 * @param v
	 *            The array to fill. Must not be null.
	 * @return the array parameter.
	 * @throws IOException
	 */
	public static int[][] readCld(Reader in, int[][] v) throws IOException
	{
		int c;

		outer:
		for (int i = 0; i < v.length; i++)
		{
			for (int j = 0; j < v[i].length; j++)
			{
				if ((c = in.read()) == -1) break outer;
				v[i][j] = Character.getNumericValue((char) c);
			}
		}
		in.close();
		return v;
	}

	/**
	 * Writes an array as Clikoku's CLD format.
	 * 
	 * @param v
	 *            The array to fill. Must not be null.
	 * @param out
	 * @throws IOException
	 */
	public static void writeCld(int[][] v, OutputStream out) throws IOException
	{
		DataOutputStream dos = new DataOutputStream(out);
		for (int i = 0; i < v.length; i++)
		{
			for (int j = 0; j < v[i].length; j++)
			{
				dos.writeInt(v[i][j]);
			}
		}
		dos.close();
	}

	/**
	 * Writes an array as Clikoku's CLD format.
	 * 
	 * @param v
	 *            The array to fill. Must not be null.
	 * @param out
	 */
	public static void writeCld(int[][] v, Writer out)
	{
		Formatter format = new Formatter(out);

		for (int i = 0; i < v.length; i++)
		{
			for (int j = 0; j < v[i].length; j++)
			{
				format.format("%d", v[i][j]);
			}
		}
		format.close();
	}

	/**
	 * Reads a CLP format into an array.
	 * 
	 * @param in
	 * @param v
	 *            The array to fill. Must not be null.
	 * @return the array parameter.
	 */
	public static int[][] readClp(Reader in, int[][] v)
	{
		Scanner scan = new Scanner(in);

		while (scan.hasNext())
		{
			String line = scan.nextLine();
			if (line.contains("cell"))
			{
				int iv = line.indexOf("val");
				if (iv >= 0)
				{
					int ir = line.indexOf("row");
					int ic = line.indexOf("col");
					int r = Integer.parseInt(line.substring(ir + 3, line.indexOf(")", ir)).trim());
					int c = Integer.parseInt(line.substring(ic + 3, line.indexOf(")", ic)).trim());
					v[r - 1][c - 1] = Integer.parseInt(line
						.substring(iv + 3, line.indexOf(")", iv))
						.trim());
				}
			}
		}
		scan.close();
		return v;
	}

	/**
	 * Writes an array as CLP format. if a second array is provided, it's considered the solution
	 * array.
	 * 
	 * @param v
	 *            the array to write. Must not be null.
	 * @param s
	 *            the solution array. May be null.
	 * @param out
	 */
	public static void writeClp(int[][] v, int[][] s, Writer out)
	{

		Formatter formatter = new Formatter(out);
		boolean hasSol = s != null;

		StringBuilder puz = new StringBuilder();
		for (int i = 0; i < 9; i++)
		{
			for (int j = 0; j < 9; j++)
			{
				int id = i + 1;
				int g = (i / 3) * 3 + j / 3;
				puz.append("\t\t").append("(cell ");
				puz.append("(id ").append(id < 10 ? "0" + id : id).append(") ");
				puz.append("(val ").append(v[i][j]).append(") ");
				puz.append("(group ").append(g + 1).append(") ");
				puz.append("(row ").append(i + 1).append(") ");
				puz.append("(col ").append(j + 1).append(") ");
				puz.append(")\n");
			}

		}

		puz
			.insert(
					0,
					"(defrule build-puzzle\n\t?f <- (phase build-puzzle)\n\t=>\n\t(retract ?f)\n\t(assert \n");
		puz.append("\t)\n)");

		StringBuilder puzHeader = new StringBuilder("; Puzzle:\n");
		StringBuilder puzHeaderSol = new StringBuilder("; Solution:\n");
		for (int i = 0; i < v.length; i++)
		{
			puzHeader.append(";\t");
			puzHeaderSol.append(";\t");
			for (int j = 0; j < v[i].length; j++)
			{
				puzHeader.append(v[i][j] == 0 ? "*" : v[i][j]);
				if (hasSol) puzHeaderSol.append(s[i][j]);
				if (j == 2 || j == 5)
				{
					puzHeader.append("  ");
					puzHeaderSol.append("  ");
				} else if (j != 8)
				{
					puzHeader.append(" ");
					puzHeaderSol.append(" ");
				}
			}
			if (i == 2 || i == 5)
			{
				puzHeader.append("\n;\n");
				puzHeaderSol.append("\n;\n");
			} else
			{
				puzHeader.append("\n");
				puzHeaderSol.append("\n");
			}
		}
		puzHeader.append("\n");
		puzHeaderSol.append("\n");

		if (hasSol) puzHeader.append(puzHeaderSol);

		puz.insert(0, puzHeader);
		formatter.format("%s", puz);
		formatter.close();
	}

	/**
	 * Reads a HoDoKu's one line string into an array. If a second array was provided, it will be
	 * filled with the solution if it was provided in the string.
	 * 
	 * @param h
	 *            the one line string.
	 * @param v
	 *            the array to fill. Must not be null.
	 * @param s
	 *            the solution array. May be null.
	 * @return the first array parameter.
	 */
	public static int[][] readH(String h, int[][] v, int[][] s)
	{
		h = h.trim();

		if (h.length() < 81) throw new IllegalArgumentException("short string");
		if (!h.matches("^[0-9\\.\\n\\r]+$"))
			throw new IllegalArgumentException("string is not just digits");

		boolean hasSol = h.length() > 162 && s != null;
		for (int i = 0; i < 81; i++)
		{
			String vs = h.substring(i, i + 1);
			int r = i / 9;
			int c = i % 9;
			int val = vs.equals(".") ? 0 : Integer.parseInt(vs);
			v[r][c] = val;
			if (hasSol)
			{
				int sval = Integer.parseInt(h.substring(i + 82, i + 83));
				s[r][c] = sval;
			}
		}
		return v;
	}

	/**
	 * 
	 Reads a HoDoKu's one line string into an array. If a second array was provided, it will be
	 * filled with the solution if it was provided in the string.
	 * 
	 * @param in
	 *            the one line string.
	 * @param v
	 *            the array to fill. Must not be null.
	 * @param s
	 *            the solution array. May be null.
	 * @return the first array parameter.
	 */
	public static int[][] readH(Reader in, int[][] v, int[][] s) throws IOException
	{

		for (int i = 0; i < 81; i++)
		{
			int ch = in.read();
			if (ch < 0) break;
			int r = i / 9;
			int c = i % 9;
			int val = ch == '.' ? 0 : Character.getNumericValue(ch);
			v[r][c] = val;
		}

		for (int i = 0; i < 81; i++)
		{
			int ch = in.read();
			if (ch < 0) break;
			int r = i / 9;
			int c = i % 9;
			int val = ch == '.' ? 0 : Character.getNumericValue(ch);
			s[r][c] = val;
		}

		in.close();
		return v;
	}

	/**
	 * Writes an array as HoDoKu's one line string.
	 * @param v the array to write.
	 * @param out
	 */
	public static void writeH(int[][] v, Writer out)
	{
		Formatter format = new Formatter(out);

		for (int i = 0; i < v.length; i++)
		{
			for (int j = 0; j < v[i].length; j++)
			{
				if (v[i][j] == 0)
					format.format("%s", ".");
				else
					format.format("%d", v[i][j]);
			}
		}
		format.close();
	}

	//	private static String ints2string(byte[] ints) throws IOException
	//	{
	//		DataInputStream dis = new DataInputStream(new ByteArrayInputStream(ints));
	//		int size = ints.length / 4;
	//		StringBuilder s = new StringBuilder();
	//		for (int i = 0; i < size; i++)
	//		{
	//			s.append(dis.readInt());
	//		}
	//		return s.toString();
	//	}

	public static void main(String[] args) throws IOException
	{
		Application.launch(args);
	}

	@Override
	public void start(final Stage primaryStage) throws Exception
	{
		createStage(primaryStage).show();
	}

	public static Stage createStage(Stage stage)
	{
		final Stage primaryStage = stage == null ? new Stage() : stage;
		final TextArea taFrom = TextAreaBuilder
			.create()
			.prefColumnCount(50)
			.prefRowCount(10)
			.style("-fx-font-family: monospace;")
			.promptText("Input")
			.build();
		final TextArea taTo = TextAreaBuilder
			.create()
			.prefColumnCount(50)
			.prefRowCount(10)
			.style("-fx-font-family: monospace;")
			.promptText("Output")
			.build();

		final Button btnFrom = ButtonBuilder.create().text("Browse").build();
		final TextField tfFrom = TextFieldBuilder
			.create()
			.editable(false)
			.promptText("Input File Path")
			.build();

		Button btnSwitch = ButtonBuilder.create().text("<--").maxWidth(Double.MAX_VALUE).build();
		Button btnConvert = ButtonBuilder
			.create()
			.text("Convert")
			.maxWidth(Double.MAX_VALUE)
			.build();
		Button btnSave = ButtonBuilder.create().text("Save").maxWidth(Double.MAX_VALUE).build();
		Button btnBatch = ButtonBuilder.create().text("Batch").maxWidth(Double.MAX_VALUE).build();

		ToggleGroup tgFrom = new ToggleGroup();
		final RadioButton rbFromHodoku = RadioButtonBuilder
			.create()
			.text("HoDoKu")
			.toggleGroup(tgFrom)
			.build();
		final RadioButton rbFromClp = RadioButtonBuilder
			.create()
			.text("CLP")
			.toggleGroup(tgFrom)
			.build();
		final RadioButton rbFromCld = RadioButtonBuilder
			.create()
			.text("CLD")
			.toggleGroup(tgFrom)
			.build();

		ToggleGroup tgTo = new ToggleGroup();
		final RadioButton rbToHodoku = RadioButtonBuilder
			.create()
			.text("HoDoKu")
			.toggleGroup(tgTo)
			.build();
		final RadioButton rbToClp = RadioButtonBuilder
			.create()
			.text("CLP")
			.toggleGroup(tgTo)
			.build();
		final RadioButton rbToCld = RadioButtonBuilder
			.create()
			.text("CLD")
			.toggleGroup(tgTo)
			.build();

		tgFrom.selectToggle(rbFromHodoku);
		tgTo.selectToggle(rbToCld);

		btnSwitch.setOnAction(new EventHandler<ActionEvent>()
		{
			@Override
			public void handle(ActionEvent event)
			{
				taFrom.setText(taTo.getText());
			}

		});
		btnFrom.setOnAction(new EventHandler<ActionEvent>()
		{

			@Override
			public void handle(ActionEvent event)
			{
				File f = FileChooserBuilder
					.create()
					.title("Open File")
					.extensionFilters(
										new ExtensionFilter("Cliduko or HoDoKu one line", "*.txt",
												"*.clp", "*.cld"))
					.build()
					.showOpenDialog(primaryStage);
				if (f == null) return;

				tfFrom.setText(f.getAbsolutePath());

				boolean clpFile = f.getName().toLowerCase().lastIndexOf(".clp") == f
					.getName()
					.length() - 4;
				boolean txtFile = !clpFile
						&& f.getName().toLowerCase().lastIndexOf(".txt") == f.getName().length() - 4;
				boolean cldFile = !clpFile
						&& !txtFile
						&& f.getName().toLowerCase().lastIndexOf(".cld") == f.getName().length() - 4;
				try
				{

					if (clpFile || txtFile)
					{
						Scanner scan = new Scanner(f);
						taFrom.setText(scan.useDelimiter("\\Z").next());
						scan.close();
					} else
					{
						DataInputStream dis = new DataInputStream(new BufferedInputStream(
								new FileInputStream(f)));
						taFrom.clear();
						for (int i = 0; i < 81; i++)
						{
							taFrom.appendText(String.valueOf(dis.readInt()));
						}
						dis.close();
					}
				} catch (IOException e)
				{
					taFrom.setText("ERROR");
				}

				rbFromClp.setSelected(clpFile);
				rbFromHodoku.setSelected(txtFile);
				rbFromCld.setSelected(cldFile);
			}
		});

		btnConvert.setOnAction(new EventHandler<ActionEvent>()
		{
			@Override
			public void handle(ActionEvent event)
			{
				try
				{
					if (rbFromHodoku.isSelected() && rbToClp.isSelected())
					{
						// h2p
						StringWriter sw = new StringWriter();
						h2p(taFrom.getText(), sw);
						taTo.setText(sw.toString());
						return;
					}

					if (rbFromHodoku.isSelected() && rbToCld.isSelected())
					{
						// h2d
						StringWriter sw = new StringWriter();
						h2d(taFrom.getText(), sw);
						taTo.setText(sw.toString());
						return;
					}

					if (rbFromClp.isSelected() && rbToHodoku.isSelected())
					{
						// p2h
						StringWriter sw = new StringWriter();
						p2h(new StringReader(taFrom.getText()), sw);
						taTo.setText(sw.toString());
						return;
					}

					if (rbFromClp.isSelected() && rbToCld.isSelected())
					{
						// p2d
						StringWriter sw = new StringWriter();
						p2d(new StringReader(taFrom.getText()), sw);
						taTo.setText(sw.toString());
						return;
					}

					if (rbFromCld.isSelected() && rbToHodoku.isSelected())
					{
						// d2h
						StringWriter sw = new StringWriter();
						d2h(new StringReader(taFrom.getText()), sw);
						taTo.setText(sw.toString());
						return;
					}

					if (rbFromCld.isSelected() && rbToClp.isSelected())
					{
						// d2p
						StringWriter sw = new StringWriter();
						d2p(new StringReader(taFrom.getText()), sw);
						taTo.setText(sw.toString());
						return;
					}

					taTo.setText(taFrom.getText());

				} catch (Exception e)
				{
					showError("ERROR", "There was an error!", e, primaryStage);
					// showMessage("ERROR", e.getMessage(), primaryStage);
				}
			}
		});

		btnSave.setOnAction(new EventHandler<ActionEvent>()
		{
			@Override
			public void handle(ActionEvent event)
			{
				try
				{
					if (rbToHodoku.isSelected() || rbToClp.isSelected())
					{
						String ext = rbToHodoku.isSelected() ? "*.txt" : "*.clp";
						String desc = rbToHodoku.isSelected() ? "Text Files" : "Cliduko CLP Files";
						File f = FileChooserBuilder
							.create()
							.title("Save File")
							.extensionFilters(new ExtensionFilter(desc, ext))
							.build()
							.showSaveDialog(primaryStage);
						if (f == null) return;

						Formatter ff = new Formatter(f);
						ff.format("%s", taTo.getText());
						ff.close();
					} else
					{
						String s = taTo.getText().trim();
						if (!s.matches("^[0-9]+$"))
							throw new IllegalArgumentException("string is not just digits");

						File f = FileChooserBuilder
							.create()
							.title("Save File")
							.extensionFilters(new ExtensionFilter("Cliduko Files", "*.cld"))
							.build()
							.showSaveDialog(primaryStage);
						DataOutputStream dos = new DataOutputStream(new BufferedOutputStream(
								new FileOutputStream(f)));

						for (int i = 0; i < s.length(); i++)
						{
							dos.writeInt(Integer.parseInt(s.substring(i, i + 1)));
						}

						dos.close();
					}
				} catch (Exception e)
				{
					showMessage("ERROR", e.getMessage(), primaryStage);
				}
			}
		});

		btnBatch.setOnAction(new EventHandler<ActionEvent>()
		{
			@Override
			public void handle(ActionEvent event)
			{
				showMessage("Note", "File extension matters!", primaryStage);
				final ComboBox<String> cb = new ComboBox<>();
				cb.getItems().addAll("CLD", "CLP", "HoDoKu");
				cb.getSelectionModel().select(0);
				showMessage("Convert to", "Choose output files format", cb, primaryStage, true);
				final List<File> fs = FileChooserBuilder
					.create()
					.title("Choose Files")
					.extensionFilters(
										new ExtensionFilter("Clidoku or HoDoKu one line Files",
												"*.txt", "*.clp", "*.cld"))
					.build()
					.showOpenMultipleDialog(primaryStage);
				if (fs == null) return;
				final File dir = DirectoryChooserBuilder
					.create()
					.title("Choose Directory")
					.build()
					.showDialog(primaryStage);
				if (dir == null) return;

				final ProgressBar pb = new ProgressBar();
				Stage dialog = getDialog("Converting", pb, primaryStage);
				dialog.show();

				Worker<Void> w = new Task<Void>()
				{

					@Override
					protected Void call() throws Exception
					{
						updateProgress(0, fs.size());

						String selectedItem = cb.getSelectionModel().getSelectedItem();
						int i = 0;

						for (File file : fs)
						{
							String fileName = file.getName().replaceAll("\\..*$", "");
							Path dirPath = Paths.get(dir.getAbsolutePath());

							if (file.getName().toLowerCase().lastIndexOf(".clp") == file
								.getName()
								.length() - 4)
							{
								FileReader fr = new FileReader(file);

								if (selectedItem.equals("CLP"))
								{
									Files.copy(Paths.get(file.getAbsolutePath()), dirPath
										.resolve(fileName + ".clp"));
								} else if (selectedItem.equals("CLD"))
								{
									File f = dirPath.resolve(fileName + ".cld").toFile();
									p2d(fr, new FileOutputStream(f));
								} else if (selectedItem.equals("HoDoKu"))
								{
									File f = dirPath.resolve(fileName + ".txt").toFile();
									p2h(fr, new FileWriter(f));
								}
							} else if (file.getName().toLowerCase().lastIndexOf(".cld") == file
								.getName()
								.length() - 4)
							{

								FileInputStream fis = new FileInputStream(file);
								if (selectedItem.equals("CLD"))
								{
									Files.copy(Paths.get(file.getAbsolutePath()), dirPath
										.resolve(fileName + ".cld"));
								} else if (selectedItem.equals("CLP"))
								{
									File f = dirPath.resolve(fileName + ".clp").toFile();
									d2p(fis, new FileWriter(f));
								} else if (selectedItem.equals("HoDoKu"))
								{
									File f = dirPath.resolve(fileName + ".txt").toFile();
									d2h(fis, new FileWriter(f));
								}
							} else if (file.getName().toLowerCase().lastIndexOf(".txt") == file
								.getName()
								.length() - 4)
							{

								FileReader fr = new FileReader(file);
								if (selectedItem.equals("HoDoKu"))
								{
									Files.copy(Paths.get(file.getAbsolutePath()), dirPath
										.resolve(fileName + ".txt"));
								} else if (selectedItem.equals("CLD"))
								{
									File f = dirPath.resolve(fileName + ".cld").toFile();
									h2d(fr, new FileOutputStream(f));
								} else if (selectedItem.equals("CLP"))
								{
									File f = dirPath.resolve(fileName + ".clp").toFile();
									h2p(fr, new FileWriter(f));
								}
							}

							++i;
							updateProgress(i, fs.size());
						}
						return null;
					}

				};
				pb.progressProperty().bind(w.progressProperty());
				new Thread((Runnable) w).start();
			}
		});

		HBox layout1 = HBoxBuilder
			.create()
			.children(rbFromHodoku, rbFromClp, rbFromCld)
			.spacing(2.0)
			.alignment(Pos.CENTER_LEFT)
			.build();

		HBox layout2 = HBoxBuilder.create().children(tfFrom, btnFrom).spacing(2.0).build();
		HBox.setHgrow(tfFrom, Priority.ALWAYS);

		HBox layout3 = HBoxBuilder
			.create()
			.children(rbToHodoku, rbToClp, rbToCld)
			.spacing(2.0)
			.alignment(Pos.CENTER_RIGHT)
			.build();

		VBox layout4 = VBoxBuilder
			.create()
			.children(btnSwitch, btnConvert, btnSave, btnBatch)
			.spacing(2.0)
			.alignment(Pos.CENTER)
			.build();

		VBox layout5 = VBoxBuilder.create().children(layout1, taFrom, layout2).spacing(2.0).build();
		VBox.setVgrow(taFrom, Priority.ALWAYS);

		VBox layout6 = VBoxBuilder.create().children(layout3, taTo).spacing(2.0).build();
		VBox.setVgrow(taTo, Priority.ALWAYS);

		HBox layout = HBoxBuilder.create().children(layout5, layout4, layout6).spacing(2.0).build();
		HBox.setHgrow(layout5, Priority.ALWAYS);
		HBox.setHgrow(layout6, Priority.ALWAYS);

		primaryStage.setTitle("Cliduko Utilities");
		primaryStage.setScene(SceneBuilder.create().root(layout).build());
		primaryStage.sizeToScene();
		return primaryStage;
	}

	public static void showMessage(String title, String msg, Stage owner)
	{

		final Stage dialog = new Stage(StageStyle.UTILITY);
		dialog.initOwner(owner);
		dialog.setTitle(title);
		Button btnOk = ButtonBuilder.create().text("OK").onAction(new EventHandler<ActionEvent>()
		{

			@Override
			public void handle(ActionEvent event)
			{
				dialog.hide();
			}
		}).build();
		Label lblMsg = new Label(msg);
		BorderPane.setAlignment(lblMsg, Pos.CENTER);
		BorderPane.setAlignment(btnOk, Pos.BOTTOM_CENTER);
		dialog.setScene(SceneBuilder.create().root(
													BorderPaneBuilder
														.create()
														.prefHeight(100)
														.prefWidth(200)
														.center(lblMsg)
														.bottom(btnOk)
														.build()).build());
		dialog.sizeToScene();
		dialog.showAndWait();

	}

	public static void showError(String title, String msg, Throwable t, Stage owner)
	{

		final Stage dialog = new Stage(StageStyle.UTILITY);
		dialog.initOwner(owner);
		dialog.setTitle(title);
		Button btnOk = ButtonBuilder.create().text("OK").onAction(new EventHandler<ActionEvent>()
		{

			@Override
			public void handle(ActionEvent event)
			{
				dialog.hide();
			}
		}).build();
		Label lblMsg = new Label(msg);
		StringWriter sw = new StringWriter();
		t.printStackTrace(new PrintWriter(sw, true));
		TextArea taStack = TextAreaBuilder.create().text(sw.toString()).editable(false).build();

		taStack.autosize();

		VBox layout = VBoxBuilder.create().spacing(2.0).children(lblMsg, taStack).build();
		VBox.setVgrow(taStack, Priority.ALWAYS);

		BorderPane.setAlignment(lblMsg, Pos.CENTER);
		BorderPane.setAlignment(btnOk, Pos.BOTTOM_CENTER);
		dialog.setScene(SceneBuilder.create().root(
													BorderPaneBuilder
														.create()
														.prefHeight(100)
														.prefWidth(200)
														.center(layout)
														.bottom(btnOk)
														.build()).build());
		dialog.sizeToScene();
		dialog.showAndWait();
	}

	public static void showMessage(String title, String msg, Node n, Stage owner, boolean block)
	{

		final Stage dialog = new Stage(StageStyle.UTILITY);
		dialog.initOwner(owner);
		dialog.setTitle(title);
		Button btnOk = ButtonBuilder.create().text("OK").onAction(new EventHandler<ActionEvent>()
		{

			@Override
			public void handle(ActionEvent event)
			{
				dialog.hide();
			}
		}).build();
		Label lblMsg = new Label(msg);

		VBox layout = VBoxBuilder.create().spacing(2.0).children(lblMsg, n).build();
		VBox.setVgrow(n, Priority.ALWAYS);

		BorderPane.setAlignment(lblMsg, Pos.CENTER);
		BorderPane.setAlignment(btnOk, Pos.BOTTOM_CENTER);
		dialog.setScene(SceneBuilder.create().root(
													BorderPaneBuilder
														.create()
														.prefHeight(100)
														.prefWidth(200)
														.center(layout)
														.bottom(btnOk)
														.build()).build());
		dialog.sizeToScene();
		if (block)
			dialog.showAndWait();
		else
			dialog.show();
	}

	public static Stage getDialog(String title, Node n, Stage owner)
	{

		final Stage dialog = new Stage(StageStyle.UTILITY);
		dialog.initOwner(owner);
		dialog.setTitle(title);
		dialog.setOnCloseRequest(new EventHandler<WindowEvent>()
		{

			@Override
			public void handle(WindowEvent event)
			{}
		});
		dialog.setScene(SceneBuilder
			.create()
			.root(AnchorPaneBuilder.create().children(n).build())
			.build());
		dialog.sizeToScene();

		return dialog;
	}
}
