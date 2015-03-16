#ifdef linux
#include "GL/glew.h"
#include "GL/glut.h"
#else
#include "GL/glew.h"
#include "GLUT/glut.h"
#endif

#include <iostream>
#include <stdlib.h>

//! Переменные с индентификаторами ID
//! ID шейдерной программы
GLuint Program;
//! ID атрибута
GLint  Attrib_vx;
GLint  Attrib_vy;
//! ID юниформ переменной цвета
GLint  Unif_color;
//! ID Vertex Buffer Object
GLuint VBOx;
GLuint VBOy;

//! Вершина
//struct vertex
//{
//  GLfloat x;
//  GLfloat y;
//};

//! Функция печати лога шейдера
void shaderLog(unsigned int shader) 
{ 
  int   infologLen   = 0;
  int   charsWritten = 0;
  char *infoLog;

  glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &infologLen);

  if(infologLen > 1)
  { 
    infoLog = new char[infologLen];
    if(infoLog == NULL)
    {
      std::cout<<"ERROR: Could not allocate InfoLog buffer\n";
       exit(1);
    }
    glGetShaderInfoLog(shader, infologLen, &charsWritten, infoLog);
    std::cout<< "InfoLog: " << infoLog << "\n\n\n";
    delete[] infoLog;
  }
}

//! Инициализация OpenGL, здесь пока по минимальному=)
void initGL()
{
  glClearColor(0, 0, 0, 0);
}

//! Проверка ошибок OpenGL, если есть то выводит в консоль тип ошибки
void checkOpenGLerror()
{
  GLenum errCode;
  if((errCode=glGetError()) != GL_NO_ERROR)
    std::cout << "OpenGl error! - " << gluErrorString(errCode);
}

//! Инициализация шейдеров
void initShader()
{
  //! Исходный код шейдеров
  const char* vsSource = 
    "attribute float coordx;\n"
    "attribute float coordy;\n"
    "void main() {\n"
    "  gl_Position = vec4(coordx, coordy, 0.0, 1.0);\n"
    "}\n";
  const char* fsSource = 
    "uniform vec4 color;\n"
    "void main() {\n"
    "  gl_FragColor = color;\n"
    "}\n";
  //! Переменные для хранения идентификаторов шейдеров
  GLuint vShader, fShader;
  
  //! Создаем вершинный шейдер
  vShader = glCreateShader(GL_VERTEX_SHADER);
  //! Передаем исходный код
  glShaderSource(vShader, 1, &vsSource, NULL);
  //! Компилируем шейдер
  glCompileShader(vShader);

  std::cout << "vertex shader \n";
  shaderLog(vShader);

  //! Создаем фрагментный шейдер
  fShader = glCreateShader(GL_FRAGMENT_SHADER);
  //! Передаем исходный код
  glShaderSource(fShader, 1, &fsSource, NULL);
  //! Компилируем шейдер
  glCompileShader(fShader);

  std::cout << "fragment shader \n";
  shaderLog(fShader);

  //! Создаем программу и прикрепляем шейдеры к ней
  Program = glCreateProgram();
  glAttachShader(Program, vShader);
  glAttachShader(Program, fShader);

  //! Линкуем шейдерную программу
  glLinkProgram(Program);

  //! Проверяем статус сборки
  int link_ok;
  glGetProgramiv(Program, GL_LINK_STATUS, &link_ok);
  if(!link_ok)
  {
    std::cout << "error attach shaders \n";
    return;
  }
  ///! Вытягиваем ID атрибута из собранной программы 
  const char* attrx_name = "coordx";
  Attrib_vx = glGetAttribLocation(Program, attrx_name);
  if(Attrib_vx == -1)
  {
    std::cout << "could not bind attrib coorx" << attrx_name << std::endl;
    return;
  }
    const char* attry_name = "coordy";
    Attrib_vy = glGetAttribLocation(Program, attry_name);
    if(Attrib_vy == -1)
    {
        std::cout << "could not bind attrib coory" << attry_name << std::endl;
        return;
    }
  //! Вытягиваем ID юниформ
  const char* unif_name = "color";
  Unif_color = glGetUniformLocation(Program, unif_name);
  if(Unif_color == -1)
  {
    std::cout << "could not bind uniform " << unif_name << std::endl;
    return;
  }

  checkOpenGLerror();
}

//! Инициализация VBO
void initVBO()
{
  //! Вершины нашего треугольника
    float x[3] = {-1.0f, 0.0f,  1.0f};
    float y[3] = {-1.0f, 1.0f, -1.0f};
    glGenBuffers(1, &VBOx);
    glBindBuffer(GL_ARRAY_BUFFER, VBOx);
  //! Передаем вершины в буфер
  glBufferData(GL_ARRAY_BUFFER, sizeof(x), x, GL_STATIC_DRAW);
    
    checkOpenGLerror();

    glGenBuffers(1, &VBOy);
    glBindBuffer(GL_ARRAY_BUFFER, VBOy);
    //! Вершины нашего треугольника
    //! Передаем вершины в буфер
    glBufferData(GL_ARRAY_BUFFER, sizeof(y), y, GL_STATIC_DRAW);
    
  checkOpenGLerror();
}

//! Освобождение шейдеров
void freeShader()
{
  //! Передавая ноль, мы отключаем шейдрную программу
  glUseProgram(0); 
  //! Удаляем шейдерную программу
  glDeleteProgram(Program);
}

//! Освобождение шейдеров
void freeVBO()
{
  glBindBuffer(GL_ARRAY_BUFFER, 0);
  glDeleteBuffers(1, &VBOx);
    glDeleteBuffers(1, &VBOy);
}

void resizeWindow(int width, int height)
{
  glViewport(0, 0, width, height);
}

//! Отрисовка
void render()
{
  glClear(GL_COLOR_BUFFER_BIT);
  //! Устанавливаем шейдерную программу текущей
  glUseProgram(Program); 
  
  static float red[4] = {1.0f, 0.0f, 0.0f, 1.0f};
  //! Передаем юниформ в шейдер
  glUniform4fv(Unif_color, 1, red);

  //! Включаем массив атрибутов
  glEnableVertexAttribArray(Attrib_vx);
    glEnableVertexAttribArray(Attrib_vy);
    //! Подключаем VBO
    glBindBuffer(GL_ARRAY_BUFFER, VBOx);
      //! Указывая pointer 0 при подключенном буфере, мы указываем что данные в VBO
      glVertexAttribPointer(Attrib_vx, 1, GL_FLOAT, GL_FALSE, 0, 0);
    glBindBuffer(GL_ARRAY_BUFFER, VBOy);
    //! Указывая pointer 0 при подключенном буфере, мы указываем что данные в VBO
    glVertexAttribPointer(Attrib_vy, 1, GL_FLOAT, GL_FALSE, 0, 0);
    //! Отключаем VBO
    //! Отключаем VBO
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    //! Передаем данные на видеокарту(рисуем)
    glDrawArrays(GL_TRIANGLES, 0, sizeof (float));

  //! Отключаем массив атрибутов
  glDisableVertexAttribArray(Attrib_vx);
    glDisableVertexAttribArray(Attrib_vy);

  //! Отключаем шейдерную программу
  glUseProgram(0); 

  checkOpenGLerror();

  glutSwapBuffers();
}

int main( int argc, char **argv )
{
  glutInit(&argc, argv);
  glutInitDisplayMode(GLUT_RGBA | GLUT_ALPHA | GLUT_DOUBLE);
  glutInitWindowSize(800, 600);
  glutCreateWindow("Simple shaders");

  //! Обязательно перед инициализации шейдеров
  GLenum glew_status = glewInit();
  if(GLEW_OK != glew_status) 
  {
     //! GLEW не проинициализировалась
    std::cout << "Error: " << glewGetErrorString(glew_status) << "\n";
    return 1;
  }

  //! Проверяем доступность OpenGL 2.0
  if(!GLEW_VERSION_2_0) 
   {
     //! OpenGl 2.0 оказалась не доступна
    std::cout << "No support for OpenGL 2.0 found\n";
    return 1;
  }

  //! Инициализация
  initGL();
  initVBO();
  initShader();
  
  glutReshapeFunc(resizeWindow);
  glutDisplayFunc(render);
  glutMainLoop();
  
  //! Освобождение ресурсов
  freeShader();
  freeVBO();
}
