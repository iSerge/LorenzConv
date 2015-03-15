CFLAGS= -I/usr/local/include
LDFLAGS= -framework GLUT -framework OpenGL -L/usr/local/lib -lGLEW
CC=g++-4.9

.PHONY: all

all: main.cpp
		$(CC) $(CFLAGS) $(LDFLAGS) main.cpp -o test

