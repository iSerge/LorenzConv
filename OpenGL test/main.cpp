#ifdef linux
#include <GL/glew.h>
#include <GL/freeglut.h>
#else
#include <GL/glew.h>
#include <GLUT/glut.h>
#endif

#include <iostream>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <list>

//! Проверка ошибок OpenGL, если есть то выводит в консоль тип ошибки
void checkOpenGLerror()
{
  GLenum errCode;
  if((errCode=glGetError()) != GL_NO_ERROR){
    std::cout << "OpenGl error! - " << gluErrorString(errCode) << std::endl;
  }
}

//! Переменные с индентификаторами ID
//! ID шейдерной программы
static GLuint Program;

static GLint  Attrib_vx;
static GLint  Attrib_vy;

//! ID юниформ переменной цвета
static GLint  Unif_color;
static GLint  Unif_pattern;
static GLint  Unif_factor;
// ID юниформ переменной матрицы проекции
static GLint projectionMatrixLocation;

static const int nPoints = 401;
static const float G = 0.3f;
static const float x1 = -3.9f;
static const float x2 =  3.9f;
static const float dx = (x2-x1)/nPoints;

  // массив для хранения перспективной матрици проекции
static float projectionMatrix[16] = { 0.25f, 0.0f, 0.0f,  0.0f,
                                      0.0f,  2.0f, 0.0f, -1.0f,
                                      0.0f,  0.0f, 1.0f,  0.0f,
                                      0.0f,  0.0f, 0.0f,  1.0f
                                    };
static float red[4] = {1.0f, 0.0f, 0.0f, 1.0f};
static float white[4] = {1.0f, 1.0f, 1.0f, 1.0f};

std::list<GLuint> vbo_list;
std::list<GLuint> ubo_list;
std::list<GLuint> vao_list;
std::list<GLuint> program_list;

GLuint genBuffer(float* v, GLsizei count){
  GLuint VBO;	

  glGenBuffers(1, &VBO);
  glBindBuffer(GL_ARRAY_BUFFER, VBO);
  glBufferData(GL_ARRAY_BUFFER, count*sizeof(float), v, GL_STATIC_DRAW);
  glBindBuffer(GL_ARRAY_BUFFER, 0);
  
  vbo_list.push_back(VBO);
  
  return VBO;
}

GLuint genVao(){
  GLuint VAO;	

  glGenVertexArrays(1, &VAO);
      checkOpenGLerror();
      std::cout << "genVao::glGenVertexArrays" << std::endl;
  
  vao_list.push_back(VAO);
  
  return VAO;
}


struct graph {
  GLuint  vao;
  GLuint  xVbo;
  GLuint  yVbo;

//  GLuint  color_uniform;
//  GLuint  factor_uniform;
//  GLuint  pattern_uniform;
//  GLuint  style;
  GLsizei n;
  
  GLfloat color[4];
  GLuint pattern;
  GLfloat factor;
  
  graph(float* x, float* y, GLsizei count, GLfloat aColor[4],
  	GLuint aPattern = 0xFFFF, GLfloat aFactor = 1.0f)
    :n(count), pattern(aPattern), factor(aFactor)
  {
    memcpy(color, aColor, 4*sizeof(GLfloat));
    
    xVbo = genBuffer(x, count);
    yVbo = genBuffer(y, count);

    vao = genVao();
    
    glBindVertexArray(vao);

    glBindBuffer(GL_ARRAY_BUFFER, xVbo);
    glEnableVertexAttribArray(Attrib_vx);
    glVertexAttribPointer(Attrib_vx, 1, GL_FLOAT, GL_FALSE, 0, 0);
    
    glBindBuffer(GL_ARRAY_BUFFER, yVbo);
    glEnableVertexAttribArray(Attrib_vy);
    glVertexAttribPointer(Attrib_vy, 1, GL_FLOAT, GL_FALSE, 0, 0);
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
  }
  
  graph(const graph& other)
    : vao(other.vao), xVbo(other.xVbo), yVbo(other.yVbo),
      n(other.n), pattern(other.pattern), factor(other.factor)
  {
    memcpy(color, other.color, 4*sizeof(GLfloat));
  }
  
  void draw(GLuint color_uniform, GLuint factor_uniform, GLuint pattern_uniform) const
  {
    glBindVertexArray(vao);

    glUniform4fv(color_uniform, 1, color);
//    glUniform1ui(pattern_uniform, pattern);
//    glUniform1f(factor_uniform, factor);

    glDrawArrays(GL_LINE_STRIP, 0, n);
    glBindVertexArray(0);
  }
};

std::list<graph> graph_list;

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

GLuint getAttribLocation(GLuint program, const char* attr_name){
  GLuint attr_location = glGetAttribLocation(program, attr_name);
  if(attr_location == -1)
  {
    std::cout << "could not bind attrib " << attr_name << std::endl;
    checkOpenGLerror();
    exit(1);
  }
  return attr_location;
}

GLuint getUniformLocation(GLuint program, const char* unif_name){
  GLuint unif_location = glGetUniformLocation(program, unif_name);
  if(unif_location == -1)
  {
    std::cout << "could not bind uniform " << unif_name << std::endl;
    checkOpenGLerror();
    exit(1);
  }
  return unif_location;
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
//    "uniform uint pattern;\n"
//    "uniform float factor;\n"
    "uniform vec4 solidColor;\n"
    "out vec4 color;\n"
    "void main() {\n"
//    "  uint bit = uint(round(linePos/factor)) & 31U;\n"
//    "  if((pattern & (1U<<bit)) == 0U)\n"
//    "    discard;\n"
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
    std::cout << "Shader program link OK\n";
  } else {
    exit(1);
  }
  
  glUseProgram(Program);

  if(GL_TRUE == ShaderProgramStatus(Program, GL_VALIDATE_STATUS)){
    std::cout << "Shader program validation OK\n";
  } else {
    exit(1);
  }
  
  Attrib_vx = getAttribLocation(Program, "coordx");
  Attrib_vy = getAttribLocation(Program, "coordy");

  Unif_color = getUniformLocation(Program, "solidColor");
//  Unif_pattern = getUniformLocation(Program, "pattern");
//  Unif_factor = getUniformLocation(Program, "factor");

  projectionMatrixLocation = getUniformLocation(Program, "projectionMatrix");
  
//  glUniform4fv(Unif_color, 1, white);
  glUniformMatrix4fv(projectionMatrixLocation, 1, GL_TRUE, projectionMatrix);
  checkOpenGLerror();

  glUseProgram(0);
  program_list.push_back(Program);
}

float f(float x, float g){
  return g/(M_PI*(x*x+g*g));
}

//! Инициализация VBO
void initVBO()
{
  //! Вершины нашего треугольника
  float x[nPoints];
  float y[nPoints];
  float y1[nPoints];
  
  for(int i = 0; i < nPoints; ++i){
    x[i] = x1+dx*i;
    y[i] = f(x[i], G);
    y1[i] = f(x[i], 0.5);
  }
  
  graph_list.push_back(graph(x,y,nPoints, white));
  checkOpenGLerror();
  std::cout << "Grpaph 1 init\n";
  
  graph_list.push_back(graph(x,y1,nPoints, red, 0xF0F0));
  checkOpenGLerror();
  std::cout << "Grpaph 2 init\n";
}

//! Освобождение шейдеров
void freeShader()
{
  glUseProgram(0); 
  for(std::list<GLuint>::const_iterator p = program_list.begin(); p != program_list.end(); ++p){
    glDeleteProgram(*p);
  }
}

//! Освобождение шейдеров
void freeVBO()
{
  glBindVertexArray(0);
  for(std::list<GLuint>::const_iterator p = vao_list.begin(); p != vao_list.end(); ++p){
    glDeleteVertexArrays(1, &(*p));
  }

  glBindBuffer(GL_ARRAY_BUFFER, 0);
  for(std::list<GLuint>::const_iterator p = vao_list.begin(); p != vao_list.end(); ++p){
    glDeleteBuffers(1, &(*p));
  }
}

void resizeWindow(int width, int height)
{
  glViewport(0, 0, width, height);
}

//! Отрисовка
void render()
{
  glClear(GL_COLOR_BUFFER_BIT| GL_DEPTH_BUFFER_BIT);
  //! Устанавливаем шейдерную программу текущей
  glUseProgram(Program);
//  glUniform4fv(Unif_color, 1, white);
//  glUniformMatrix4fv(projectionMatrixLocation, 1, GL_TRUE, projectionMatrix);

  for(std::list<graph>::const_iterator p = graph_list.begin(); p != graph_list.end(); ++p){
    p->draw(Unif_color, Unif_pattern, Unif_factor);
  }

  //! Отключаем шейдерную программу
  glBindVertexArray(0);
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

  glutReshapeFunc(resizeWindow);
  glutDisplayFunc(render);
  glutMainLoop();
  
  //! Освобождение ресурсов
  freeShader();
  freeVBO();
}
