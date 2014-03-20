/*
 * This source file is part of libRocket, the HTML/CSS Interface Middleware
 *
 * For the latest information, see http://www.librocket.com
 *
 * Copyright (c) 2008-2010 CodePoint Ltd, Shift Technology Ltd
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#include "../../../renderer/Renderer.h"
#include <sys/types.h>
//#include <sys/time.h>
#include <time.h>
//#include <unistd.h>
#include <stdio.h>
#include <GLFW/glfw3.h>
#include <Rocket/Core.h>
#include "../../../utils/Common.h"

#include "../Shell.h"
#include "../ShellFileInterface.h"

#include "InputX11.h"


//static timeval start_time;
static ShellFileInterface* file_interface = NULL;
GLFWwindow* glfwindow = 0;

bool Shell::Initialise(const Rocket::Core::String& path)
{
	//gettimeofday(&start_time, NULL);
    InputX11::Initialise();

	file_interface = new ShellFileInterface(path);
	Rocket::Core::SetFileInterface(file_interface);

	return true;
}

void Shell::Shutdown()
{
	InputX11::Shutdown();

	delete file_interface;
	file_interface = NULL;
}

bool Shell::OpenWindow(const char* name, bool attach_opengl)
{
	/*
	glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
	glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 2);
	glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_FALSE);
	glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_COMPAT_PROFILE);
	*/
    glfwindow = glfwCreateWindow(1024.0f, 768.0f, "GLFW", 0, 0);
	glfwMakeContextCurrent(glfwindow);

	/*
	// Set up the GL state.
	glClearColor(0, 0, 0, 1);
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_COLOR_ARRAY);

	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrtho(0, 1024, 768, 0, -1, 1);

	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	*/
    return true;
}

void Shell::CloseWindow()
{
	glfwDestroyWindow(glfwindow);
}

// Returns a platform-dependent handle to the window.
void* Shell::GetWindowHandle()
{
	return NULL;
}

// Flips the OpenGL buffers.
void Shell::FlipBuffers()
{
	glfwSwapBuffers(glfwindow);
}

void Shell::EventLoop(ShellIdleFunction idle_function)
{

}

void Shell::RequestExit()
{
	glfwTerminate();
}

void Shell::DisplayError(const char* fmt, ...)
{
	const int buffer_size = 1024;
	char buffer[buffer_size];
	va_list argument_list;

	// Print the message to the buffer.
	va_start(argument_list, fmt);
	int len = vsnprintf(buffer, buffer_size - 2, fmt, argument_list);	
	if ( len < 0 || len > buffer_size - 2 )	
	{
		len = buffer_size - 2;
	}	
	buffer[len] = '\n';
	buffer[len + 1] = '\0';
	va_end(argument_list);

	printf("%s", buffer);
}

void Shell::Log(const char* fmt, ...)
{
	const int buffer_size = 1024;
	char buffer[buffer_size];
	va_list argument_list;

	// Print the message to the buffer.
	va_start(argument_list, fmt);
	int len = vsnprintf(buffer, buffer_size - 2, fmt, argument_list);	
	if ( len < 0 || len > buffer_size - 2 )	
	{
		len = buffer_size - 2;
	}	
	buffer[len] = '\n';
	buffer[len + 1] = '\0';
	va_end(argument_list);

	printf("%s", buffer);
}

// Returns the seconds that have elapsed since program startup.
float Shell::GetElapsedTime() 
{
	return static_cast<float>(glfwGetTime());
}
