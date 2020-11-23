cmake_minimum_required (VERSION 3.16)

project(vkgears VERSION 0.0.1)

set (VULKAN_SDK "/opt/vulkan/1.2.154.0/x86_64")
find_program (GLSL_LANG_VALIDATOR NAMES glslangValidator PATHS ${VULKAN_SDK}/bin)
set (SHADER_DIR shaders)

file(GLOB_RECURSE VERTEX_SHADER_SOURCE "${SHADER_DIR}/*.vert")
file(GLOB_RECURSE FRAGMENT_SHADER_SOURCE "${SHADER_DIR}/*.frag")
set(SHADER_SOURCE ${VERTEX_SHADER_SOURCE} ${FRAGMENT_SHADER_SOURCE})
source_group("shaders" FILES ${SHADER_SOURCE})

foreach(shader ${SHADER_SOURCE})
	add_custom_command(OUTPUT ${shader}.spv DEPENDS ${shader}
		COMMAND ${GLSL_LANG_VALIDATOR} -V ${shader} -o ${shader}.spv)
	list(APPEND SHADERS ${shader}.spv)
endforeach(shader)

add_custom_target(generate-shaders DEPENDS ${SHADERS})

add_executable(gl1_gears src/gl1_gears.c)
target_link_libraries(gl1_gears GL m glfw)

add_executable(gl2_gears src/gl2_gears.c)
target_link_libraries(gl2_gears GL m glfw)

add_executable(vk1_gears src/vk1_gears.c)
target_link_libraries(vk1_gears vulkan m glfw)
add_dependencies(vk1_gears generate-shaders)
