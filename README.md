# C++ project simple template

This is a simple C++ template made to use with minimal setup and build using Visual Studio Code, CMake and GNU build tools. Expected C++ source file formats are `.hxx` and `.cxx` (can be changed in CMakeLists.txt).

## Setup

Several Visual Studio Code extensions are optional but highly recommended to build and debug project using it, you can install them manually (C/C++ and Task Explorer) or they will be installed via shell script if you're using this template through [Workspaces](https://github.com/0x2E757/Workspaces) project. You might want to change project name in CMakeLists.txt, though nothing is actually required to do here to start writing sources and building them.

## Build steps

### Initialize CMake

First of all, you need to initialize CMake. This is done using command `cmake -S . -B build` or using Visual Studio Code task `Setup debug build` or `Setup release build`.

### Build project

If CMake is initialized then you can start building your project. CMakeLists.txt is made in a way that it will look for `main.cxx` file, if it exists project will be built as executable, otherwise as library.

### Run project (if build as executable)

Executable output will be named as program (program.exe in Windows) and placed in a build directory. If you're using Visual Studio Code tasks then you can just use an appropriate task to run the executable.

### Dependencies

It is possible to use another template project as a dependency by putting it's name (specified in CMakeLists.txt) and repository path in CMakeLists.txt. Setup task will automatically do `git clone` for that project and place it under extern directory or perform `git pull` if directory already exists (this way dependencies can be updated). CMake will link to dependency headers from its `include` directory that should be located in the dependency root directory.