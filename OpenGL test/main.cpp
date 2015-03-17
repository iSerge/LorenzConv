#ifdef linux
#include <GL/glew.h>
#include <GL/freeglut.h>
#else
#include <GL/glew.h>
#include <GLUT/glut.h>
#endif

#include <iostream>
#include <stdlib.h>
#include <math.h>

//! Переменные с индентификаторами ID
//! ID шейдерной программы
static GLuint Program;
//! ID атрибута
static GLint  Attrib_vx;
static GLint  Attrib_vy;
//! ID юниформ переменной цвета
static GLint  Unif_color;
// ID юниформ переменной матрицы проекции
static GLint projectionMatrixLocation;
//! ID Vertex Buffer Object
static GLuint VBOx;
static GLuint VBOy;
static GLuint VAO;

static const int nPoints = 151;
static const float G = 0.3f;
static const float x1 = -0.9f;
static const float x2 =  0.9f;
static const float dx = (x2-x1)/nPoints;

  // массив для хранения перспективной матрици проекции
static float projectionMatrix[16] = { 1.0f, 0.0f, 0.0f, 0.0f,
                                      0.0f, 1.0f, 0.0f, 0.0f,
                                      0.0f, 0.0f, 1.0f, 0.0f,
                                      0.0f, 0.0f, 0.0f, 1.0f
                                    };
static float red[4] = {1.0f, 0.0f, 0.0f, 1.0f};
static float white[4] = {1.0f, 1.0f, 1.0f, 1.0f};

//! Проверка ошибок OpenGL, если есть то выводит в консоль тип ошибки
void checkOpenGLerror()
{
  GLenum errCode;
  if((errCode=glGetError()) != GL_NO_ERROR){
    std::cout << "OpenGl error! - " << gluErrorString(errCode) << std::endl;
  }
}

//! Инициализация OpenGL, здесь пока по минимальному=)
void initGL()
{
  glClearColor(0, 0, 0, 0);
      checkOpenGLerror();
      std::cout << "initGL::glClearColor" << std::endl;
  glLineWidth(1.0f);
      checkOpenGLerror();
      std::cout << "initGL::glLineWidth" << std::endl;
  glEnable(GL_LINE_SMOOTH);
      checkOpenGLerror();
      std::cout << "initGL::glEnable(GL_LINE_SMOOTH)" << std::endl;
  glHint(GL_LINE_SMOOTH_HINT,  GL_NICEST);
      checkOpenGLerror();
      std::cout << "initGL::glHint" << std::endl;
  glEnable(GL_BLEND);
      checkOpenGLerror();
      std::cout << "initGL::glEnable(GL_BLEND)" << std::endl;
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
      checkOpenGLerror();
      std::cout << "initGL::glBlendFunc" << std::endl;
//  glEnable(GL_MULTISAMPLE);
//      checkOpenGLerror();
//      std::cout << "initGL::glEnable(GL_MULTISAMPLE)" << std::endl;
//  glSampleCoverage(0.5f, GL_FALSE);
//      checkOpenGLerror();
//      std::cout << "initGL::glSampleCoverage" << std::endl;
}

// проверка статуса param шейдера shader
GLint ShaderStatus(GLuint shader, GLenum param)
{
  GLint status;

  // получим статус шейдера
  glGetShaderiv(shader, param, &status);
  checkOpenGLerror();
  std::cout << "ShaderStatus::glGetShaderiv" << std::endl;

  // в случае ошибки запишем ее в лог-файл
  if (status != GL_TRUE)
  {
    int   infologLen   = 0;
    glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &infologLen);
    checkOpenGLerror();
    std::cout << "ShaderStatus::glGetShaderiv" << std::endl;
    if(infologLen > 1){ 
      char *infoLog = new char[infologLen];
      if(infoLog == NULL)
      {
        std::cout<<"ERROR: Could not allocate InfoLog buffer\n";
        exit(1);
      }
      int   charsWritten = 0;
      glGetShaderInfoLog(shader, infologLen, &charsWritten, infoLog);
      checkOpenGLerror();
      std::cout << "ShaderStatus::glGetShaderInfoLog" << std::endl;
      std::cout << "Shader program: " << infoLog << "\n\n\n";
      delete[] infoLog;
    }
  }
  // проверим не было ли ошибок OpenGL
  checkOpenGLerror();

  // вернем статус
  return status;
}

// проверка статуса param шейдерной программы program
GLint ShaderProgramStatus(GLuint program, GLenum param)
{
  GLint status;

  // получим статус шейдерной программы
  glGetProgramiv(program, param, &status);

  // в случае ошибки запишем ее в лог-файл
  if (status != GL_TRUE)
  {
    int   infologLen   = 0;
    glGetProgramiv(program, GL_INFO_LOG_LENGTH, &infologLen);
    if(infologLen > 1){ 
      char *infoLog = new char[infologLen];
      if(infoLog == NULL)
      {
        std::cout<<"ERROR: Could not allocate InfoLog buffer\n";
        exit(1);
      }
      int   charsWritten = 0;
      glGetProgramInfoLog(program, infologLen, &charsWritten, infoLog);
      std::cout << "Shader program: " << infoLog << "\n\n\n";
      delete[] infoLog;
    }
  }
  // проверим не было ли ошибок OpenGL
  checkOpenGLerror();

  // вернем статус
  return status;
}

//! Инициализация шейдеров
void initShader()
{
  //! Исходный код шейдеров
  const char* vsSource = 
    "#version 330 core\n"
    "uniform mat4 projectionMatrix;\n"
    "in float coordx;\n"
    "in float coordy;\n"
    "void main() {\n"
    "  gl_Position = projectionMatrix * vec4(coordx, coordy, 0.0, 1.0);\n"
    "}\n";
  const char* fsSource = 
    "#version 330 core\n"
    "uniform vec4 solidColor;\n"
    "out vec4 color;\n"
    "void main() {\n"
    "  color = solidColor;\n"
    "}\n";
  //! Переменные для хранения идентификаторов шейдеров
  GLuint vShader, fShader;
  
  //! Создаем вершинный шейдер
  vShader = glCreateShader(GL_VERTEX_SHADER);
  checkOpenGLerror();
  std::cout << "glCreateShader" << std::endl;
  
  //! Передаем исходный код
  glShaderSource(vShader, 1, &vsSource, NULL);
  checkOpenGLerror();
  std::cout << "glCreateSource" << std::endl;
  
  //! Компилируем шейдер
  glCompileShader(vShader);

  if(GL_TRUE == ShaderStatus(vShader, GL_COMPILE_STATUS)){
    std::cout << "Vertex shader OK\n";
  } else {
    exit(1);
  }

  //! Создаем фрагментный шейдер
  fShader = glCreateShader(GL_FRAGMENT_SHADER);
  //! Передаем исходный код
  glShaderSource(fShader, 1, &fsSource, NULL);
  //! Компилируем шейдер
  glCompileShader(fShader);

  if(GL_TRUE == ShaderStatus(fShader, GL_COMPILE_STATUS)){
    std::cout << "Fragment shader OK\n";
  } else {
    exit(1);
  }

  //! Создаем программу и прикрепляем шейдеры к ней
  Program = glCreateProgram();
  glAttachShader(Program, vShader);
  glAttachShader(Program, fShader);

  //! Линкуем шейдерную программу
  glLinkProgram(Program);

  //! Проверяем статус сборки
  if(GL_TRUE == ShaderProgramStatus(Program, GL_LINK_STATUS)){
    std::cout << "Shader program OK\n";
  } else {
    exit(1);
  }
  
  glUseProgram(Program);

  if(GL_TRUE == ShaderProgramStatus(Program, GL_VALIDATE_STATUS)){
    std::cout << "Shader program validation OK\n";
  } else {
    exit(1);
  }
  
  const char* attrx_name = "coordx";
  Attrib_vx = glGetAttribLocation(Program, attrx_name);
  if(Attrib_vx == -1)
  {
    std::cout << "could not bind attrib " << attrx_name << std::endl;
    checkOpenGLerror();
    exit(1);
  }
  
  const char* attry_name = "coordy";
  Attrib_vy = glGetAttribLocation(Program, attry_name);
  if(Attrib_vy == -1)
  {
    std::cout << "could not bind attrib " << attry_name << std::endl;
    checkOpenGLerror();
    exit(1);
  }

  const char* unif_name = "solidColor";
  Unif_color = glGetUniformLocation(Program, unif_name);
  if(Unif_color == -1)
  {
    std::cout << "could not bind uniform " << unif_name << std::endl;
    checkOpenGLerror();
    exit(1);
  }

  const char* projectionMatrix_name = "projectionMatrix";
  projectionMatrixLocation = glGetUniformLocation(Program, projectionMatrix_name);
  if(projectionMatrixLocation == -1)
  {
    std::cout << "could not bind uniform " << projectionMatrix_name << std::endl;
    checkOpenGLerror();
    exit(1);
  }
  
  glUniform4fv(Unif_color, 1, white);
  glUniformMatrix4fv(projectionMatrixLocation, 1, GL_TRUE, projectionMatrix);
  checkOpenGLerror();

  glUseProgram(0);
}

float f(float x){
  return G/(M_PI*(x*x+G*G));
}

//! Инициализация VBO
void initVBO()
{
  //! Вершины нашего треугольника
  float x[nPoints];
  float y[nPoints];
  
  for(int i = 0; i < nPoints; ++i){
    x[i] = x1+dx*i;
    y[i] = f(x[i]);
  }
  
  glGenVertexArrays(1, &VAO);
  glBindVertexArray(VAO);

  checkOpenGLerror();
  
  glGenBuffers(1, &VBOx);
  glBindBuffer(GL_ARRAY_BUFFER, VBOx);
  glBufferData(GL_ARRAY_BUFFER, sizeof(x), x, GL_STATIC_DRAW);
  glEnableVertexAttribArray(Attrib_vx);
  glVertexAttribPointer(Attrib_vx, 1, GL_FLOAT, GL_FALSE, 0, 0);
    
  checkOpenGLerror();

  glGenBuffers(1, &VBOy);
  glBindBuffer(GL_ARRAY_BUFFER, VBOy);
  glBufferData(GL_ARRAY_BUFFER, sizeof(y), y, GL_STATIC_DRAW);
  glEnableVertexAttribArray(Attrib_vy);
  glVertexAttribPointer(Attrib_vy, 1, GL_FLOAT, GL_FALSE, 0, 0);
    
  checkOpenGLerror();
  
  glBindVertexArray(0);
}

//static const float M_PI = 3.14159265359f; 

// построение перспективной матрицы проекции
void Matrix4Perspective(float *M, float fovy, float aspect, float znear, float zfar)
{
        // fovy передается в градусах - сконвертируем его в радианы
        float f = 1 / tanf(fovy * M_PI / 360),
              A = (zfar + znear) / (znear - zfar),
              B = (2 * zfar * znear) / (znear - zfar);

        M[ 0] = f / aspect; M[ 1] =  0; M[ 2] =  0; M[ 3] =  0;
        M[ 4] = 0;          M[ 5] =  f; M[ 6] =  0; M[ 7] =  0;
        M[ 8] = 0;          M[ 9] =  0; M[10] =  A; M[11] =  B;
        M[12] = 0;          M[13] =  0; M[14] = -1; M[15] =  0;
}

void initData(){
  // коэффициент отношения сторон окна OpenGL
  const float aspectRatio = 800 / 600;

  // создадим перспективную матрицу проекции
  //Matrix4Perspective(projectionMatrix, 45.0f, aspectRatio, 0.5f, 5.0f);
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
  glBindVertexArray(0);
  glDeleteBuffers(1, &VBOx);
  glDeleteBuffers(1, &VBOy);
  glDeleteVertexArrays(1, &VAO);
}

void resizeWindow(int width, int height)
{
  glViewport(0, 0, width, height);

  const float aspectRatio = (float)width / (float)height;
  //Matrix4Perspective(projectionMatrix, 45.0f, aspectRatio, 0.5f, 5.0f);
}

//! Отрисовка
void render()
{
  glClear(GL_COLOR_BUFFER_BIT| GL_DEPTH_BUFFER_BIT);
  //! Устанавливаем шейдерную программу текущей
  glUseProgram(Program);
//  glUniform4fv(Unif_color, 1, white);
//  glUniformMatrix4fv(projectionMatrixLocation, 1, GL_TRUE, projectionMatrix);
  
  glBindVertexArray(VAO);
  glDrawArrays(GL_LINE_STRIP, 0, nPoints);

  //! Отключаем шейдерную программу
  glBindVertexArray(VAO);
  glUseProgram(0); 

  checkOpenGLerror();

  glutSwapBuffers();
}

int main( int argc, char **argv )
{
  glutInit(&argc, argv);
  checkOpenGLerror();
  std::cout << "glutInit()" << std::endl;
  
  glutInitContextVersion(3, 3);
  checkOpenGLerror();
  std::cout << "glutInitContextVersion()" << std::endl;
  
  glutInitContextProfile( GLUT_CORE_PROFILE );
  checkOpenGLerror();
  std::cout << "glutInitContextProfile()" << std::endl;
  
  glutInitContextFlags(GLUT_FORWARD_COMPATIBLE | GLUT_DEBUG);
  checkOpenGLerror();
  std::cout << "glutInitContextFlags()" << std::endl;
  
  glutInitDisplayMode(GLUT_RGBA | GLUT_ALPHA | GLUT_DOUBLE);
  checkOpenGLerror();
  std::cout << "glutInitDisplayMode()" << std::endl;
  
  glutInitWindowSize(800, 600);
  checkOpenGLerror();
  std::cout << "glutInitWindowSize()" << std::endl;
  
  glutCreateWindow("Simple shaders");
  checkOpenGLerror();
  std::cout << "Window created" << std::endl;

  //! Обязательно перед инициализации шейдеров
  glewExperimental = GL_TRUE;
  GLenum glew_status = glewInit();
  checkOpenGLerror();
  std::cout << "glewInit()" << std::endl;
  if(GLEW_OK != glew_status) 
  {
     //! GLEW не проинициализировалась
    std::cout << "Error: " << glewGetErrorString(glew_status) << "\n";
    return 1;
  }

  //! Проверяем доступность OpenGL 3.3
  if(!GLEW_VERSION_3_3) 
   {
     //! OpenGl 3.# оказалась не доступна
    std::cout << "No support for OpenGL 3.3 found\n";
    return 1;
  }

  std::cout << "GLEW initialized" << std::endl;


  //! Инициализация
  initGL();
  std::cout << "initGL OK" << std::endl;

  initShader();
  std::cout << "initShader OK" << std::endl;

  initVBO();
  std::cout << "initVBO OK" << std::endl;

  initData();
  std::cout << "initData OK" << std::endl;

  glutReshapeFunc(resizeWindow);
  glutDisplayFunc(render);
  glutMainLoop();
  
  //! Освобождение ресурсов
  freeShader();
  freeVBO();
}
