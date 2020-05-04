#version 450

layout (location = 0) in vec3 a_pos;
layout (location = 1) in vec2 a_uv0;
layout (location = 3) in vec4 a_color;
layout (location = 2) in float a_gamma;

layout (binding = 0) uniform UBO
{
    mat4 modelViewProjection;
} ubo;

layout (location = 0) out vec4 v_color;
layout (location = 1) out vec2 v_uv0;
layout (location = 2) out float v_gamma;

out gl_PerVertex
{
    vec4 gl_Position;
};

void main()
{
    v_color = a_color;
    v_uv0 = a_uv0;
    v_gamma = a_gamma;
    gl_Position = ubo.modelViewProjection * vec4(a_pos.xyz, 1.0);
}
