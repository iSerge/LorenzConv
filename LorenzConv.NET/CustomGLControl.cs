using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using OpenTK.Graphics;
using OpenTK.Graphics.OpenGL;

namespace LorenzConv.NET
{
	public partial class CustomGLControl : OpenTK.GLControl
	{
		public CustomGLControl()
            :base( (new GraphicsMode(new ColorFormat(8,8,8,8), 16)), 3, 3, GraphicsContextFlags.ForwardCompatible)
		{
			InitializeComponent();

            Context.MakeCurrent(WindowInfo);
            GL.ClearColor(0.0f, 0.0f, 0.0f, 0.0f);
            GL.Enable(EnableCap.LineSmooth);
            GL.Hint(HintTarget.LineSmoothHint, HintMode.Nicest);
            GL.Enable(EnableCap.Blend);
            GL.BlendFunc(BlendingFactorSrc.SrcAlpha, BlendingFactorDest.OneMinusSrcAlpha);
        }
	}
}
