using System;
using System.Drawing;
using System.Windows.Forms;
using OpenTK.Graphics.OpenGL;

namespace LorenzConv.NET
{
	public partial class MainForm: Form
	{
		private DataStorage settings = new DataStorage();

		private TextBox gammaEdit;
		private TrackBar gammaSlider;
		
		private GraphGLView distribView;

		private bool distribViewLoaded = true;

		public MainForm ()
		{
			Text = "Lorenz convolution";
			this.Size = new Size(800,600);
			this.Padding = new Padding(12);

			distribView = new GraphGLView();
			distribView.Dock = DockStyle.Fill;
			distribView.Paint += distribView_Paint;
			distribView.Load += distribView_Load;

			var gammaLabel = new Label();
			gammaLabel.Text = "Gamma";
			gammaLabel.Dock = DockStyle.Fill;

			gammaEdit = new TextBox();
			gammaEdit.Dock = DockStyle.Fill;

			var gammaEditBinding = new Binding("Text", settings, "Gamma");
			gammaEditBinding.Format += bind_FormatFloatToString; 
			gammaEditBinding.Parse += bind_FormatStrToFloat;
			gammaEditBinding.DataSourceUpdateMode = DataSourceUpdateMode.OnPropertyChanged;
			gammaEditBinding.ControlUpdateMode = ControlUpdateMode.OnPropertyChanged;

			gammaEdit.DataBindings.Add(gammaEditBinding);
			//gammaEdit.DataBindings.Add("Text", settings, "Gamma", true,
			//                              DataSourceUpdateMode.OnPropertyChanged);

			gammaSlider = new TrackBar();
			gammaSlider.Dock = DockStyle.Fill;
			gammaSlider.Minimum = 0;
			gammaSlider.Maximum = 1000;
			gammaSlider.TickFrequency = 100;
			gammaSlider.Value = 200;

			var gammaSliderBinding = new Binding("Value", settings, "Gamma");
			gammaSliderBinding.Format += bind_FormatFloatToSlider;
			gammaSliderBinding.Parse += bind_FormatSliderToFloat;
			gammaSliderBinding.DataSourceUpdateMode = DataSourceUpdateMode.OnPropertyChanged;
			gammaSliderBinding.ControlUpdateMode = ControlUpdateMode.OnPropertyChanged;

			gammaSlider.DataBindings.Add(gammaSliderBinding);

			var controlsPanel = new TableLayoutPanel();
			controlsPanel.Text = "Convolution parameters";
			controlsPanel.Dock = DockStyle.Left;
			controlsPanel.Padding = new Padding(12);

			controlsPanel.Controls.Add(gammaLabel, 0, 0);
			controlsPanel.Controls.Add(gammaEdit, 0, 1);
			controlsPanel.Controls.Add(gammaSlider, 0, 2);

			Controls.Add(controlsPanel);
			Controls.Add(distribView);

			settings.Gamma = 2.0f;

		}

		private static void bind_FormatFloatToString(object sender, ConvertEventArgs e){
			float f = (float)e.Value;
			e.Value = String.Format("{0:##.00}", f);
		}
		private static void bind_FormatStrToFloat(object sender, ConvertEventArgs e){
			string str = (string)e.Value;
			e.Value = float.Parse(str,System.Globalization.CultureInfo.InvariantCulture);
		}

		private static void bind_FormatFloatToSlider(object sender, ConvertEventArgs e){
			float f = (float)e.Value;
			e.Value = Math.Round(f*100);
		}
		private static void bind_FormatSliderToFloat(object sender, ConvertEventArgs e){
			int v = (int)e.Value;
			e.Value = v / 100.0f;
		}

		private void distribView_Load(object sender, EventArgs e)
		{
			distribViewLoaded = true;
		}

		private void distribView_Paint(object seder, PaintEventArgs e){
			if(!distribViewLoaded){
				return;
			}

			distribView.Context.MakeCurrent(distribView.WindowInfo);

			GL.Clear(ClearBufferMask.ColorBufferBit|ClearBufferMask.DepthBufferBit);

			distribView.SwapBuffers();
		}

		static void Main()
		{
			Application.Run(new MainForm());
		}
	}
}
