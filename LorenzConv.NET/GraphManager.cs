﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using OpenTK;
using OpenTK.Graphics;
using OpenTK.Graphics.OpenGL;

namespace LorenzConv.NET
{
    static class GraphManager
    {
        public static int Program;

        public static int  Attrib_vx;
        public static int  Attrib_vy;

        //! ID юниформ переменной цвета
        public static int  Unif_color;
        public static int  Unif_pattern;
        public static int  Unif_factor;
        // ID юниформ переменной матрицы проекции
        public static int projectionMatrixLocation;

        public const int nPoints = 201;
        public const float G = 0.3f;
        public const float x1 = -3.9f;
        public const float x2 =  3.9f;
        public const float dx = (x2-x1)/nPoints;

        // массив для хранения перспективной матрици проекции
        public static Matrix4 projectionMatrix = new Matrix4( 0.25f, 0.0f, 0.0f,  0.0f,
                                                              0.0f,  2.0f, 0.0f, -1.0f,
                                                              0.0f,  0.0f, 1.0f,  0.0f,
                                                              0.0f,  0.0f, 0.0f,  1.0f
                                                            );
        public static Color4 red = new Color4(1.0f, 0.0f, 0.0f, 1.0f);
        public static Color4 white = new Color4(1.0f, 1.0f, 1.0f, 1.0f);

        public static List<int> vbo_list = new List<int>();
        public static List<int> ubo_list = new List<int>();
        public static List<int> vao_list = new List<int>();
        public static List<int> program_list = new List<int>();

        public static int genBuffer(float[] v, int count){
            int VBO;	

            GL.GenBuffers(1, out VBO);
            GL.BindBuffer(BufferTarget.ArrayBuffer, VBO);
            GL.BufferData<float>(BufferTarget.ArrayBuffer, new IntPtr(count*sizeof(float)), v, BufferUsageHint.StaticDraw);
            GL.BindBuffer(BufferTarget.ArrayBuffer, 0);
  
            vbo_list.Add(VBO);
  
            return VBO;
        }

        public static int genVao(){
            int VAO;	

            GL.GenVertexArrays(1, out VAO);
  
            vao_list.Add(VAO);
  
            return VAO;
        }


        public class graph {
            int  vao;
            int  xVbo;
            int  yVbo;
            int n;

            Color4 color;
            uint pattern;
            float factor;

            public graph(int xVBO, int yVBO, int count, Color4 color,
  	                     uint aPattern = 0xFFFF, float aFactor = 1.0f)
            {
                this.xVbo = xVBO;
                this.yVbo = yVBO;
                this.n = count;
                this.pattern = aPattern;
                this.factor = aFactor;
                this.color = color;
    
                this.vao = genVao();
    
                GL.BindVertexArray(vao);

                GL.BindBuffer(BufferTarget.ArrayBuffer, xVbo);
                GL.EnableVertexAttribArray(Attrib_vx);
                GL.VertexAttribPointer(Attrib_vx, 1, VertexAttribPointerType.Float, false, 0, 0);
    
                GL.BindBuffer(BufferTarget.ArrayBuffer, yVbo);
                GL.EnableVertexAttribArray(Attrib_vy);
                GL.VertexAttribPointer(Attrib_vy, 1, VertexAttribPointerType.Float, false, 0, 0);
    
                GL.BindBuffer(BufferTarget.ArrayBuffer, 0);
                GL.BindVertexArray(0);
            }
  
            public void draw(int color_uniform, int factor_uniform, int pattern_uniform)
            {
                GL.BindVertexArray(this.vao);

                GL.Uniform4(color_uniform, color);

                GL.DrawArrays(BeginMode.LineStrip, 0, n);
                GL.BindVertexArray(0);
            }
        }

        public static List<graph> graph_list = new List<graph>();

        public static graph DistrGrapth;

        private static float f(float x, float g)
        {
            return g / (3.14159f * (x * x + g * g));
        }


        public static void InitData()
        {
              //! Исходный код шейдеров
            var vsSource = @"
#version 330 core
uniform mat4 projectionMatrix;
in float coordx;
in float coordy;
void main() {
    gl_Position = projectionMatrix * vec4(coordx, coordy, 0.0, 1.0);
}";
            var fsSource = @"
#version 330 core
//    uniform uint pattern;
//    uniform float factor;
uniform vec4 solidColor;
out vec4 color;
void main() {
//      uint bit = uint(round(linePos/factor)) & 31U;
//      if((pattern & (1U<<bit)) == 0U)
//        discard;
  color = solidColor;
}";
            int vShader, fShader;
  
            vShader = GL.CreateShader(ShaderType.VertexShader);
            fShader = GL.CreateShader(ShaderType.FragmentShader);
  
            GL.ShaderSource(vShader, vsSource);
            GL.ShaderSource(fShader, fsSource);
  
            GL.CompileShader(vShader);
            GL.CompileShader(fShader);
            Console.WriteLine(GL.GetShaderInfoLog(vShader));
			Console.WriteLine(GL.GetShaderInfoLog(fShader));

            Program = GL.CreateProgram();
            GL.AttachShader(Program, vShader);
            GL.AttachShader(Program, fShader);
            GL.LinkProgram(Program);
            Console.WriteLine(GL.GetProgramInfoLog(Program));

            GL.UseProgram(Program);
            GL.ValidateProgram(Program);

            Attrib_vx = GL.GetAttribLocation(Program, "coordx");
            Attrib_vy = GL.GetAttribLocation(Program, "coordy");

            Unif_color = GL.GetUniformLocation(Program, "solidColor");

            projectionMatrixLocation = GL.GetUniformLocation(Program, "projectionMatrix");
  
            GL.UniformMatrix4(projectionMatrixLocation, true, ref projectionMatrix);

            GL.UseProgram(0);
            program_list.Add(Program);


            var x = new float[nPoints];
            var y = new float[nPoints];
            var y1 = new float[nPoints];
  
            for(int i = 0; i < nPoints; ++i){
                x[i] = x1+dx*i;
                y[i] = f(x[i], G);
                y1[i] = f(x[i], 0.5f);
            }
  
            int xVBO = genBuffer(x, nPoints);
            int yVBO = genBuffer(y, nPoints);
            int y1VBO = genBuffer(y1, nPoints);

            DistrGrapth = new graph(xVBO, yVBO, nPoints, white);
            graph_list.Add(DistrGrapth);
            graph_list.Add(new graph(xVBO,y1VBO,nPoints, red, 0xF0F0));
        }

        public static void FreeData()
        {
            GL.UseProgram(0); 
            foreach(var p in program_list){
                GL.DeleteProgram(p);
            }
            
            GL.BindVertexArray(0);
            foreach(var a in vao_list){
                GL.DeleteVertexArray(a);
            }

            GL.BindBuffer(BufferTarget.ArrayBuffer, 0);
            foreach(var b in vbo_list){
                GL.DeleteBuffer(b);
            }
        }
    }
}
