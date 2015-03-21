using System;
using System.ComponentModel;
using System.Drawing;
using System.Windows.Forms;
using OpenTK.Graphics.OpenGL;

namespace LorenzConv.NET
{
	public partial class MainForm: Form
	{
		private DataStorage settings = new DataStorage();

        private TableLayoutPanel tableLayoutPanel1;
        private TextBox gammaEdit;
        private Label label1;
        private TrackBar gammaSlider;
        private GraphGLView distribView;
        private GraphGLView convolutionView;

		private bool distribViewLoaded = false;
        private bool distribConvolutionLoaded = false;

		public MainForm ()
		{
            InitializeComponent();

            var gammaEditBinding = new Binding("Text", settings, "Gamma");
			gammaEditBinding.Format += bind_FormatFloatToString; 
			gammaEditBinding.Parse += bind_FormatStrToFloat;
			gammaEditBinding.DataSourceUpdateMode = DataSourceUpdateMode.OnValidation;

			gammaEdit.DataBindings.Add(gammaEditBinding);

			var gammaSliderBinding = new Binding("Value", settings, "Gamma");
			gammaSliderBinding.Format += bind_FormatFloatToSlider;
			gammaSliderBinding.Parse += bind_FormatSliderToFloat;
			gammaSliderBinding.DataSourceUpdateMode = DataSourceUpdateMode.OnPropertyChanged;

			gammaSlider.DataBindings.Add(gammaSliderBinding);

			settings.Gamma = 2.0f;
			settings.PropertyChanged += settings_PropertyChanged;
		}

		private static void bind_FormatFloatToString(object sender, ConvertEventArgs e){
			float f = (float)e.Value;
			e.Value = String.Format("{0:#0.00}", f);
		}
		private static void bind_FormatStrToFloat(object sender, ConvertEventArgs e){
			string str = (string)e.Value;
			e.Value = float.Parse(str,System.Globalization.CultureInfo.InvariantCulture);
		}

		private void bind_FormatFloatToSlider(object sender, ConvertEventArgs e){
			float f = (float)e.Value;
            e.Value = Math.Max(gammaSlider.Minimum, Math.Min(Math.Round(f * 100000), gammaSlider.Maximum));
		}
		private static void bind_FormatSliderToFloat(object sender, ConvertEventArgs e){
			int v = (int)e.Value;
            e.Value = v / 100000.0f;
		}

		private void distribView_Load(object sender, EventArgs e)
		{
			distribViewLoaded = true;
            distribView.SetupContext();
		}

		private void distribView_Paint(object seder, PaintEventArgs e){
			if(!distribViewLoaded){
				return;
			}

			distribView.MakeCurrent();
            GL.Viewport(0, 0, distribView.Size.Width, distribView.Size.Height);
			GL.Clear(ClearBufferMask.ColorBufferBit|ClearBufferMask.DepthBufferBit);

            GL.UseProgram(GraphManager.Program);
            GraphManager.DistrGrapth.draw(GraphManager.Unif_color, 0, 0);
            GL.UseProgram(0); 

			distribView.SwapBuffers();
            distribView.Context.MakeCurrent(null);
		}

		static void Main()
		{
			Application.Run(new MainForm());
		}

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.tableLayoutPanel1 = new System.Windows.Forms.TableLayoutPanel();
            this.gammaEdit = new System.Windows.Forms.TextBox();
            this.label1 = new System.Windows.Forms.Label();
            this.gammaSlider = new System.Windows.Forms.TrackBar();
            this.distribView = new LorenzConv.NET.GraphGLView();
            this.convolutionView = new LorenzConv.NET.GraphGLView();
            this.tableLayoutPanel1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.gammaSlider)).BeginInit();
            this.SuspendLayout();
            // 
            // tableLayoutPanel1
            // 
            this.tableLayoutPanel1.ColumnCount = 1;
            this.tableLayoutPanel1.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 100F));
            this.tableLayoutPanel1.Controls.Add(this.gammaEdit, 0, 1);
            this.tableLayoutPanel1.Controls.Add(this.label1, 0, 0);
            this.tableLayoutPanel1.Controls.Add(this.gammaSlider, 0, 2);
            this.tableLayoutPanel1.Controls.Add(this.distribView, 0, 3);
            this.tableLayoutPanel1.Dock = System.Windows.Forms.DockStyle.Left;
            this.tableLayoutPanel1.Location = new System.Drawing.Point(12, 12);
            this.tableLayoutPanel1.Name = "tableLayoutPanel1";
            this.tableLayoutPanel1.Padding = new System.Windows.Forms.Padding(0, 0, 6, 0);
            this.tableLayoutPanel1.RowCount = 5;
            this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle());
            this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle());
            this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle());
            this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle());
            this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle());
            this.tableLayoutPanel1.Size = new System.Drawing.Size(200, 537);
            this.tableLayoutPanel1.TabIndex = 0;
            // 
            // gammaEdit
            // 
            this.gammaEdit.Dock = System.Windows.Forms.DockStyle.Fill;
            this.gammaEdit.Location = new System.Drawing.Point(3, 16);
            this.gammaEdit.Name = "gammaEdit";
            this.gammaEdit.Size = new System.Drawing.Size(188, 20);
            this.gammaEdit.TabIndex = 0;
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.label1.Location = new System.Drawing.Point(3, 0);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(188, 13);
            this.label1.TabIndex = 1;
            this.label1.Text = "Gamma";
            // 
            // gammaSlider
            // 
            this.gammaSlider.Dock = System.Windows.Forms.DockStyle.Fill;
            this.gammaSlider.Location = new System.Drawing.Point(3, 42);
            this.gammaSlider.Minimum = 1;
            this.gammaSlider.Maximum = 1000000;
            this.gammaSlider.Name = "gammaSlider";
            this.gammaSlider.Size = new System.Drawing.Size(188, 45);
            this.gammaSlider.TabIndex = 2;
            this.gammaSlider.TickFrequency = 100000;
            // 
            // distribView
            // 
            this.distribView.BackColor = System.Drawing.Color.Black;
            this.distribView.Dock = System.Windows.Forms.DockStyle.Fill;
            this.distribView.Location = new System.Drawing.Point(3, 93);
            this.distribView.Name = "distribView";
            this.distribView.Size = new System.Drawing.Size(188, 150);
            this.distribView.TabIndex = 3;
            this.distribView.VSync = true;
            this.distribView.Load += new System.EventHandler(this.distribView_Load);
            this.distribView.Paint += new System.Windows.Forms.PaintEventHandler(this.distribView_Paint);
            // 
            // convolutionView
            // 
            this.convolutionView.BackColor = System.Drawing.Color.Black;
            this.convolutionView.Dock = System.Windows.Forms.DockStyle.Fill;
            this.convolutionView.Location = new System.Drawing.Point(212, 12);
            this.convolutionView.Name = "convolutionView";
            this.convolutionView.Size = new System.Drawing.Size(560, 537);
            this.convolutionView.TabIndex = 1;
            this.convolutionView.VSync = true;
            this.convolutionView.Load += new System.EventHandler(this.convolutionView_Load);
            this.convolutionView.Paint += new System.Windows.Forms.PaintEventHandler(this.convolutionView_Paint);
            // 
            // MainForm
            // 
            this.ClientSize = new System.Drawing.Size(784, 561);
            this.Controls.Add(this.convolutionView);
            this.Controls.Add(this.tableLayoutPanel1);
            this.Name = "MainForm";
            this.Padding = new System.Windows.Forms.Padding(12);
            this.Text = "Lorenz convolution";
            this.Load += new System.EventHandler(this.MainForm_Load);
            this.tableLayoutPanel1.ResumeLayout(false);
            this.tableLayoutPanel1.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.gammaSlider)).EndInit();
            this.ResumeLayout(false);

        }
        #endregion

        private void convolutionView_Load(object sender, EventArgs e)
        {
            distribConvolutionLoaded = true;
            convolutionView.SetupContext();
        }

        private void convolutionView_Paint(object sender, PaintEventArgs e)
        {
            if (!distribConvolutionLoaded)
            {
                return;
            }
            convolutionView.MakeCurrent();
            distribView.Context.MakeCurrent(convolutionView.WindowInfo);
            GL.Viewport(0,0,convolutionView.Size.Width, convolutionView.Size.Height);

            GL.Clear(ClearBufferMask.ColorBufferBit | ClearBufferMask.DepthBufferBit);

            GL.UseProgram(GraphManager.Program);
            GraphManager.DistrGrapth.draw(GraphManager.Unif_color, 0, 0);
            GL.UseProgram(0);

            //convolutionView.SwapBuffers();
            distribView.SwapBuffers();
        }

        private void MainForm_Load(object sender, EventArgs e)
        {
            distribView.MakeCurrent();
            GraphManager.InitData();
        }

		protected override void Dispose(bool disposing)
        {
            distribView.MakeCurrent();
			GraphManager.FreeData();

			base.Dispose(disposing);
		}

		private void settings_PropertyChanged(object sender, PropertyChangedEventArgs e){
			if(e.PropertyName.Equals("Gamma")){
                distribView.MakeCurrent();
				GraphManager.UpdateDistrGraph(settings.Gamma);
				distribView.Invalidate();
				convolutionView.Invalidate();
			}
		}
	}
}
