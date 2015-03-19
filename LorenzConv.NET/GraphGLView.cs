using OpenTK;
using OpenTK.Graphics;
using OpenTK.Graphics.OpenGL;

namespace LorenzConv.NET
{
	public class GraphGLView: OpenTK.GLControl
	{
		public GraphGLView ()
			:base(new GraphicsMode(new ColorFormat(8,8,8,8), 16), 3, 3, GraphicsContextFlags.ForwardCompatible|GraphicsContextFlags.Debug)
		{}

        public void SetupContext()
        {
            Context.MakeCurrent(WindowInfo);
            GL.ClearColor(0.0f, 0.0f, 0.0f, 0.0f);
            GL.Enable(EnableCap.LineSmooth);
            GL.Hint(HintTarget.LineSmoothHint, HintMode.Nicest);
            GL.Enable(EnableCap.Blend);
            GL.BlendFunc(BlendingFactorSrc.SrcAlpha, BlendingFactorDest.OneMinusSrcAlpha);
        }
	}
}

