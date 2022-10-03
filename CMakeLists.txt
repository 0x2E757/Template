cmake_minimum_required(VERSION 3.12.0 FATAL_ERROR)
project("template" CXX)

# Setup compiler
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_VERBOSE_MAKEFILE OFF)

# Dependencies
set(dependencies
    # "name" "repository address"
)

# Gather all headers and sources
file(GLOB_RECURSE headers CONFIGURE_DEPENDS "include/*.hxx")
file(GLOB_RECURSE sources CONFIGURE_DEPENDS "source/*.hxx" "source/*.cxx")

# If project contains main.cxx then build executable, otherwise library
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/source/main.cxx")
    add_executable(${PROJECT_NAME} ${headers} ${sources})
    set_target_properties(${PROJECT_NAME} PROPERTIES OUTPUT_NAME "program")
else()
    add_library(${PROJECT_NAME} ${headers} ${sources})
endif()
target_include_directories(${PROJECT_NAME} PRIVATE "include")
set_target_properties(${PROJECT_NAME} PROPERTIES LINKER_LANGUAGE CXX)

# Iterate dependencies
list(LENGTH dependencies dependencies_length)
math(EXPR dependencies_last_index "${dependencies_length} - 1")
if(dependencies_last_index GREATER 0)
    foreach(dependency_name_index RANGE 0 ${dependencies_last_index} 2)

        # Acquire each dependency name and repository address
        math(EXPR dependency_repository_index "${dependency_name_index} + 1")
        list(GET dependencies ${dependency_name_index} dependency_name)
        list(GET dependencies ${dependency_repository_index} dependency_repository)

        # Check if external was initialized and corresponding directory exists
        get_property(${dependency_name}_initialized GLOBAL PROPERTY ${dependency_name}_initialized_property)
        if(NOT ${dependency_name}_initialized)
            if(NOT EXISTS "${CMAKE_SOURCE_DIR}/extern/${dependency_name}")

                # Create external using git clone
                execute_process(COMMAND git clone ${dependency_repository} "${CMAKE_SOURCE_DIR}/extern/${dependency_name}" --quiet COMMAND_ERROR_IS_FATAL ANY)
                if(CMAKE_CURRENT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR)
                    message("-- Cloned ${dependency_name} to extern")
                else()
                    message("-- Cloned ${dependency_name} (by ${PROJECT_NAME}) to extern")
                endif()

            else()

                # Update external using git pull
                execute_process(COMMAND git -C "${CMAKE_SOURCE_DIR}/extern/${dependency_name}" rev-parse HEAD OUTPUT_VARIABLE hash_before_pull COMMAND_ECHO NONE COMMAND_ERROR_IS_FATAL ANY)
                execute_process(COMMAND git -C "${CMAKE_SOURCE_DIR}/extern/${dependency_name}" pull --quiet COMMAND_ERROR_IS_FATAL ANY)
                execute_process(COMMAND git -C "${CMAKE_SOURCE_DIR}/extern/${dependency_name}" rev-parse HEAD OUTPUT_VARIABLE hash_after_pull COMMAND_ECHO NONE COMMAND_ERROR_IS_FATAL ANY)
                if(NOT "${hash_before_pull}" STREQUAL "${hash_after_pull}")
                    message("-- Updated extern ${dependency_name}")
                endif()

            endif()
            set_property(GLOBAL PROPERTY ${dependency_name}_initialized_property TRUE)
        endif()

        # Add subdirectory if not already
        if(NOT TARGET ${dependency_name})
            add_subdirectory("${CMAKE_SOURCE_DIR}/extern/${dependency_name}" "${CMAKE_SOURCE_DIR}/build/extern/${dependency_name}")
        endif()

        # Link includes and library
        target_include_directories(${PROJECT_NAME} PRIVATE "${CMAKE_SOURCE_DIR}/extern/${dependency_name}/include")
        target_link_libraries(${PROJECT_NAME} PRIVATE ${dependency_name})

    endforeach()
endif()

# Extending compiler flags with -ffile-prefix-map
if(CMAKE_CURRENT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -ffile-prefix-map=\"${CMAKE_CURRENT_SOURCE_DIR}/include/\"=")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -ffile-prefix-map=\"${CMAKE_CURRENT_SOURCE_DIR}/source/\"=")
else()
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -ffile-prefix-map=\"${CMAKE_CURRENT_SOURCE_DIR}/include/\"=${PROJECT_NAME}/")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -ffile-prefix-map=\"${CMAKE_CURRENT_SOURCE_DIR}/source/\"=${PROJECT_NAME}/")
endif()
