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

/*
PFNGLCREATEPROGRAMPROC glCreateProgram = NULL;
PFNGLGETSHADERIVPROC glGetShaderiv = NULL;
PFNGLGETSHADERINFOLOGPROC glGetShaderInfoLog = NULL;
PFNGLCREATESHADERPROC glCreateShader = NULL;
PFNGLSHADERSOURCEPROC glShaderSource = NULL;
PFNGLCOMPILESHADERPROC glCompileShader = NULL;
PFNGLATTACHSHADERPROC glAttachShader = NULL;
PFNGLLINKPROGRAMPROC glLinkProgram = NULL;
PFNGLGETPROGRAMIVPROC glGetProgramiv = NULL;
PFNGLGETATTRIBLOCATIONPROC glGetAttribLocation = NULL;
PFNGLGETUNIFORMLOCATIONPROC glGetUniformLocation = NULL;
PFNGLGENBUFFERSPROC glGenBuffers = NULL;
PFNGLBINDBUFFERPROC glBindBuffer = NULL;
PFNGLBUFFERDATAPROC glBufferData = NULL;
PFNGLUSEPROGRAMPROC glUseProgram = NULL;
PFNGLDELETEPROGRAMPROC glDeleteProgram = NULL;
PFNGLDELETEBUFFERSPROC glDeleteBuffers = NULL;
PFNGLUNIFORM4FVPROC glUniform4fv = NULL;
PFNGLENABLEVERTEXATTRIBARRAYPROC glEnableVertexAttribArray = NULL;
PFNGLVERTEXATTRIBPOINTERPROC glVertexAttribPointer = NULL;
PFNGLDISABLEVERTEXATTRIBARRAYPROC glDisableVertexAttribArray = NULL;

//#ifdef linux
//PFNGLXCREATECONTEXTATTRIBSARBPROC glXCreateContextAttribsARB = NULL;
//#endif

// макрос для получения указателя на функцию и проверка его на валидность
#define OPENGL_GET_PROC(p,n) \
//  n = reinterpret_cast<p>(wglGetProcAddress(#n)); \
  n = reinterpret_cast<p>(glXGetProcAddress(#n)); \
  if (NULL == n) \
  { \
    std::cout<< "Loading extension '"<< #n << "' fail (" << GetLatError() << \
      ")" << std::endl; \
    return false; \
  }

bool initGlExtProcs(){
  OPENGL_GET_PROC(PFNGLCREATEPROGRAMPROC, glCreateProgram);
  OPENGL_GET_PROC(PFNGLGETSHADERIVPROC, glGetShaderiv);
  OPENGL_GET_PROC(PFNGLGETSHADERINFOLOGPROC, glGetShaderInfoLog);
  OPENGL_GET_PROC(PFNGLCREATESHADERPROC, glCreateShader);
  OPENGL_GET_PROC(PFNGLSHADERSOURCEPROC, glShaderSource);
  OPENGL_GET_PROC(PFNGLCOMPILESHADERPROC, glCompileShader);
  OPENGL_GET_PROC(PFNGLATTACHSHADERPROC, glAttachShader);
  OPENGL_GET_PROC(PFNGLLINKPROGRAMPROC, glLinkProgram);
  OPENGL_GET_PROC(PFNGLGETPROGRAMIVPROC, glGetProgramiv);
  OPENGL_GET_PROC(PFNGLGETATTRIBLOCATIONPROC, glGetAttribLocation);
  OPENGL_GET_PROC(PFNGLGETUNIFORMLOCATIONPROC, glGetUniformLocation);
  OPENGL_GET_PROC(PFNGLGENBUFFERSPROC, glGenBuffers);
  OPENGL_GET_PROC(PFNGLBINDBUFFERPROC, glBindBuffer);
  OPENGL_GET_PROC(PFNGLBUFFERDATAPROC, glBufferData);
  OPENGL_GET_PROC(PFNGLUSEPROGRAMPROC, glUseProgram);
  OPENGL_GET_PROC(PFNGLDELETEPROGRAMPROC, glDeleteProgram);
  OPENGL_GET_PROC(PFNGLDELETEBUFFERSPROC, glDeleteBuffers);
  OPENGL_GET_PROC(PFNGLUNIFORM4FVPROC, glUniform4fv);
  OPENGL_GET_PROC(PFNGLENABLEVERTEXATTRIBARRAYPROC, glEnableVertexAttribArray);
  OPENGL_GET_PROC(PFNGLVERTEXATTRIBPOINTERPROC, glVertexAttribPointer);
  OPENGL_GET_PROC(PFNGLDISABLEVERTEXATTRIBARRAYPROC, glDisableVertexAttribArray);

//#ifdef linux
//  OPENGL_GET_PROC(PFNGLXCREATECONTEXTATTRIBSARBPROC, glXCreateContextAttribsARB);
//#endif

  return true;
}
*/
/*
void DebugLog ( GLenum source , GLenum type , GLuint id , GLenum severity ,
  GLsizei length , const GLchar * message , GLvoid * userParam)
{
  std::cout << " Type : " << getStringForType( type ) 
            << "; Source : " << getStringForSource( source ). c_str ()
            << "; ID : "<< id 
            << "; Severity : " << getStringForSeverity( severity ) << std::endl;
  std::cout << " Message :" << message << std::endl;
}
*/

//! Переменные с индентификаторами ID
//! ID шейдерной программы
GLuint Program;
//! ID атрибута
GLint  Attrib_vx;
GLint  Attrib_vy;
//! ID юниформ переменной цвета
GLint  Unif_color;
// ID юниформ переменной матрицы проекции
GLint projectionMatrixLocation;
//! ID Vertex Buffer Object
GLuint VBOx;
GLuint VBOy;
GLuint VAO;

  // массив для хранения перспективной матрици проекции
static float projectionMatrix[16];
static float red[4] = {1.0f, 0.0f, 0.0f, 1.0f};
static float white[4] = {1.0f, 1.0f, 1.0f, 1.0f};

//! Инициализация OpenGL, здесь пока по минимальному=)
void initGL()
{
  glClearColor(0, 0, 0, 0);
}

//! Проверка ошибок OpenGL, если есть то выводит в консоль тип ошибки
void checkOpenGLerror()
{
  GLenum errCode;
  if((errCode=glGetError()) != GL_NO_ERROR){
    std::cout << "OpenGl error! - " << gluErrorString(errCode);
  }
}

// проверка статуса param шейдера shader
GLint ShaderStatus(GLuint shader, GLenum param)
{
  GLint status;

  // получим статус шейдера
  glGetShaderiv(shader, param, &status);

  // в случае ошибки запишем ее в лог-файл
  if (status != GL_TRUE)
  {
    int   infologLen   = 0;
    glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &infologLen);
    if(infologLen > 1){ 
      char *infoLog = new char[infologLen];
      if(infoLog == NULL)
      {
        std::cout<<"ERROR: Could not allocate InfoLog buffer\n";
        exit(1);
      }
      int   charsWritten = 0;
      glGetShaderInfoLog(shader, infologLen, &charsWritten, infoLog);
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
    "uniform vec4 color;\n"
    "out vec4 fragColor;\n"
    "void main() {\n"
    "  fragColor = color;\n"
    "}\n";
  //! Переменные для хранения идентификаторов шейдеров
  GLuint vShader, fShader;
  
  //! Создаем вершинный шейдер
  vShader = glCreateShader(GL_VERTEX_SHADER);
  //! Передаем исходный код
  glShaderSource(vShader, 1, &vsSource, NULL);
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
}

//! Инициализация VBO
void initVBO()
{
  //! Вершины нашего треугольника
  float x[3] = {-1.0f, 0.0f,  1.0f};
  float y[3] = {-1.0f, 1.0f, -1.0f};
  
  glGenVertexArrays(1, &VAO);
  glBindVertexArray(VAO);

  checkOpenGLerror();
  
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
  ///! Вытягиваем ID атрибута из собранной программы 
  const char* attrx_name = "coordx";
  Attrib_vx = glGetAttribLocation(Program, attrx_name);
  if(Attrib_vx == -1)
  {
    std::cout << "could not bind attrib coordx" << attrx_name << std::endl;
    return;
  }

  glVertexAttribPointer(Attrib_vx, 1, GL_FLOAT, GL_FALSE, 0, 0);
  glEnableVertexAttribArray(Attrib_vx);
  checkOpenGLerror();

  const char* attry_name = "coordy";
  Attrib_vy = glGetAttribLocation(Program, attry_name);
  if(Attrib_vy == -1)
  {
    std::cout << "could not bind attrib coordy" << attry_name << std::endl;
    return;
  }

  glVertexAttribPointer(Attrib_vy, 1, GL_FLOAT, GL_FALSE, 0, 0);
  glEnableVertexAttribArray(Attrib_vy);
  checkOpenGLerror();
  
  //! Вытягиваем ID юниформ
  const char* unif_name = "color";
  Unif_color = glGetUniformLocation(Program, unif_name);
  if(Unif_color == -1)
  {
    std::cout << "could not bind uniform " << unif_name << std::endl;
    return;
  }

  checkOpenGLerror();

  //! Передаем юниформ в шейдер
  glUniform4fv(Unif_color, 1, white);

  // коэффициент отношения сторон окна OpenGL
 // GLint dim[4];
 // glGet(GL_VIEWPORT, &dim);
//  const float aspectRatio = (float)dim[2] / (float)dim[3];
  const float aspectRatio = 800 / 600;

  // создадим перспективную матрицу проекции
  Matrix4Perspective(projectionMatrix, 45.0f, aspectRatio, 0.5f, 5.0f);

  // получим индекс юниформа projectionMatrix из шейдерной программы
  projectionMatrixLocation = glGetUniformLocation(Program, "projectionMatrix");

  // передадим матрицу в шейдер
  if (projectionMatrixLocation != -1){
    glUniformMatrix4fv(projectionMatrixLocation, 1, GL_TRUE, projectionMatrix);
  }
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

  float projectionMatrix[16];
  const float aspectRatio = (float)width / (float)height;
  Matrix4Perspective(projectionMatrix, 45.0f, aspectRatio, 0.5f, 5.0f);
  if (projectionMatrixLocation != -1){
    glUniformMatrix4fv(projectionMatrixLocation, 1, GL_TRUE, projectionMatrix);
  }
}

//! Отрисовка
void render()
{
  glClear(GL_COLOR_BUFFER_BIT| GL_DEPTH_BUFFER_BIT);
  //! Устанавливаем шейдерную программу текущей
  glUseProgram(Program); 
  
  glBindVertexArray(VAO);
  glDrawArrays(GL_TRIANGLES, 0, 3);

  //! Отключаем шейдерную программу
  glUseProgram(0); 

  checkOpenGLerror();

  glutSwapBuffers();
}

int main( int argc, char **argv )
{
  glutInit(&argc, argv);
  glutInitContextVersion(3, 3);
  glutInitContextProfile( GLUT_CORE_PROFILE );
  glutInitContextFlags(GLUT_FORWARD_COMPATIBLE | GLUT_DEBUG);
  glutInitDisplayMode(GLUT_RGBA | GLUT_ALPHA | GLUT_DOUBLE);
  glutInitWindowSize(800, 600);
  glutCreateWindow("Simple shaders");

  //! Обязательно перед инициализации шейдеров
  /*bool proc_init_status = initGlExtProcs();
  if(!proc_init_status) 
  {
    std::cout << "Failed to get GL func adress"<<std::endl;
    return 1;
  }
  */
  GLenum glew_status = glewInit();
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


  //! Инициализация
  initGL();
  initVBO();
  initShader();
  initData();
  
  glutReshapeFunc(resizeWindow);
  glutDisplayFunc(render);
  glutMainLoop();
  
  //! Освобождение ресурсов
  freeShader();
  freeVBO();
}
