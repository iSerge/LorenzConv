using OpenTK;
using OpenTK.Graphics;
using OpenTK.Graphics.OpenGL;

namespace LorenzConv.NET
{
	public class GraphGLView: OpenTK.GLControl
	{
		public GraphGLView ()
			:base(new GraphicsMode(24, 24), 3, 3, GraphicsContextFlags.ForwardCompatible|GraphicsContextFlags.Debug)
		{}

        public void SetupContext()
        {
            Context.MakeCurrent(this.WindowInfo);
            GL.ClearColor(0.0f, 0.0f, 0.0f, 0.0f);
            GL.Enable(EnableCap.LineSmooth);
            GL.Hint(HintTarget.LineSmoothHint, HintMode.Nicest);
            GL.Enable(EnableCap.Blend);
            GL.BlendFunc(BlendingFactorSrc.SrcAlpha, BlendingFactorDest.OneMinusSrcAlpha);
        }
	}
}

