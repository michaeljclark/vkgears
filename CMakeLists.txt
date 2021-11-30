cmake_minimum_required (VERSION 3.12)
project(vkgears VERSION 0.0.1)

set (VULKAN_SDK "/opt/vulkan/1.2.182.0/x86_64")
set (SHADER_DIR shaders)

include(CheckLibraryExists)
check_library_exists(m sqrtf "" HAVE_LIB_M)
if (HAVE_LIB_M)
    set(EXTRA_LIBS ${EXTRA_LIBS} m)
endif (HAVE_LIB_M)

find_package(PkgConfig)
pkg_check_modules(GLFW3 glfw3)
pkg_check_modules(VULKAN vulkan)

# Find OpenGL library
include(FindOpenGL)

# Find Vulkan library
include(FindVulkan)
if (NOT Vulkan_GLSLANG_VALIDATOR_EXECUTABLE)
    find_program (GLSL_LANG_VALIDATOR NAMES glslangValidator PATHS ${VULKAN_SDK}/bin)
    set(Vulkan_GLSLANG_VALIDATOR_EXECUTABLE "${GLSL_LANG_VALIDATOR}")
endif()

# set defaults for options
set (OPENGL_EXAMPLES_DEFAULT ${OpenGL_OpenGL_FOUND})
set (VULKAN_EXAMPLES_DEFAULT ${VULKAN_FOUND})
if(NOT Vulkan_GLSLANG_VALIDATOR_EXECUTABLE)
    set (VULKAN_EXAMPLES_DEFAULT OFF)
endif()

# user configurable options
option(OPENGL_EXAMPLES "Build OpenGL examples" ${OPENGL_EXAMPLES_DEFAULT})
option(VULKAN_EXAMPLES "Build Vulkan examples" ${VULKAN_EXAMPLES_DEFAULT})
option(EXTERNAL_GLFW "Use external GLFW project" ON)
option(EXTERNAL_GLAD "Use external GLAD project" ON)

message(STATUS "OPENGL_EXAMPLES = ${OPENGL_EXAMPLES}")
message(STATUS "VULKAN_EXAMPLES = ${VULKAN_EXAMPLES}")
message(STATUS "EXTERNAL_GLFW = ${EXTERNAL_GLFW}")
message(STATUS "EXTERNAL_GLAD = ${EXTERNAL_GLAD}")

# Support for external glfw
if (EXTERNAL_GLFW)
    include(ExternalProject)
    ExternalProject_Add(
        GLFW
        GIT_REPOSITORY "https://github.com/glfw/glfw.git"
        SOURCE_DIR "${CMAKE_BINARY_DIR}/third_party/glfw3"
        STEP_TARGETS build
        EXCLUDE_FROM_ALL TRUE
        CMAKE_ARGS -DGLFW_BUILD_EXAMPLES=OFF -DGLFW_BUILD_TESTS=OFF
                   -DGLFW_BUILD_DOCS=OFF -DGLFW_INSTALL=OFF
    )
    set(GLFW_INCLUDE_DIRS "${CMAKE_BINARY_DIR}/third_party/glfw3/include")
    set(GLFW_LIBRARY_DIR "${CMAKE_BINARY_DIR}/GLFW-prefix/src/GLFW-build/src/")
    set(GLFW_LIBRARIES glfw3 pthread dl)
    include_directories(${GLFW_INCLUDE_DIRS})
    link_directories(${GLFW_LIBRARY_DIR})
    set(GLFW_LIBS_ALL ${GLFW_LIBRARIES} ${EXTRA_LIBS})
else ()
    add_definitions(${GLFW3_CFLAGS})
    set(GLFW_LIBS_ALL ${GLFW3_LDFLAGS} ${EXTRA_LIBS})
endif ()

# Support for external glad
if (EXTERNAL_GLAD)
    include(ExternalProject)
    ExternalProject_Add(
        GLAD
        GIT_REPOSITORY "https://github.com/Dav1dde/glad.git"
        SOURCE_DIR "${CMAKE_BINARY_DIR}/third_party/glad"
        STEP_TARGETS build
        EXCLUDE_FROM_ALL TRUE
        CMAKE_ARGS -DGLAD_EXPORT=OFF
    )
    set(GLAD_INCLUDE_DIRS "${CMAKE_BINARY_DIR}/GLAD-prefix/src/GLAD-build/include/")
    set(GLAD_LIBRARY_DIR "${CMAKE_BINARY_DIR}/GLAD-prefix/src/GLAD-build/")
    set(GLAD_LIBRARIES glad)
    include_directories(${GLAD_INCLUDE_DIRS})
    link_directories(${GLAD_LIBRARY_DIR})
    list(APPEND OPENGL_LOADER_LIBS ${GLAD_LIBRARIES})
else ()
    list(APPEND OPENGL_LOADER_LIBS ${OPENGL_opengl_LIBRARY})
endif ()

if (OPENGL_EXAMPLES)
    foreach(prog IN ITEMS gl1_gears gl2_gears gl3_gears gl4_gears)
        message("-- Adding: ${prog}")
        add_executable(${prog} src/${prog}.c)
        target_link_libraries(${prog} ${GLFW_LIBS_ALL} ${OPENGL_LOADER_LIBS})
        if (EXTERNAL_GLAD)
            target_compile_definitions(${prog} PRIVATE -DHAVE_GLAD)
        endif ()
        if (EXTERNAL_GLFW)
            add_dependencies(${prog} GLFW-build)
        endif ()
        if (EXTERNAL_GLAD)
            add_dependencies(${prog} GLAD-build)
        endif ()
    endforeach(prog)
endif (OPENGL_EXAMPLES)

if (VULKAN_EXAMPLES)
    file(GLOB_RECURSE VERTEX_SHADER_SOURCE "${SHADER_DIR}/*.vert")
    file(GLOB_RECURSE FRAGMENT_SHADER_SOURCE "${SHADER_DIR}/*.frag")
    set(SHADER_SOURCE ${VERTEX_SHADER_SOURCE} ${FRAGMENT_SHADER_SOURCE})
    source_group("shaders" FILES ${SHADER_SOURCE})

    foreach(shader ${SHADER_SOURCE})
        add_custom_command(OUTPUT ${shader}.spv DEPENDS ${shader}
            COMMAND ${Vulkan_GLSLANG_VALIDATOR_EXECUTABLE} -V ${shader} -o ${shader}.spv)
        list(APPEND SHADERS ${shader}.spv)
    endforeach(shader)

    include_directories(${Vulkan_INCLUDE_DIRS})

    message("-- Adding: vk1_gears")
    add_executable(vk1_gears src/vk1_gears.c ${SHADERS})
    target_link_libraries(vk1_gears ${Vulkan_LIBRARIES} ${GLFW_LIBS_ALL})

    if (EXTERNAL_GLFW)
        add_dependencies(vk1_gears GLFW-build)
    endif ()
    if (EXTERNAL_GLAD)
        add_dependencies(vk1_gears GLAD-build)
    endif ()
endif (VULKAN_EXAMPLES)
