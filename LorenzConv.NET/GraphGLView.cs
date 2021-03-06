using OpenTK;
using OpenTK.Graphics;
using OpenTK.Graphics.OpenGL;

namespace LorenzConv.NET
{
	public class GraphGLView: OpenTK.GLControl
	{
		public GraphGLView ()
			:base(new GraphicsMode(32, 16), 3, 3, GraphicsContextFlags.ForwardCompatible|GraphicsContextFlags.Debug)
		{}

        public void SetupContext()
        {
            Context.MakeCurrent(this.WindowInfo);
            GL.ClearColor(1.0f, 1.0f, 1.0f, 1.0f);
            GL.Enable(EnableCap.LineSmooth);
            GL.Hint(HintTarget.LineSmoothHint, HintMode.Nicest);
            GL.Enable(EnableCap.Blend);
            GL.BlendFunc(BlendingFactorSrc.SrcAlpha, BlendingFactorDest.OneMinusSrcAlpha);
        }
	}
}

