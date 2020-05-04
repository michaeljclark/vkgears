#version 450

layout (location = 0) in vec4 v_color;
layout (location = 1) in vec2 v_uv0;
layout (location = 2) in float v_gamma;

layout (binding = 1) uniform sampler2D u_tex0;

layout (location = 0) out vec4 outColor;

void main()
{
    vec4 t_color = texture(u_tex0, v_uv0);
    outColor = v_color * vec4(pow(t_color.rgb, vec3(1.0/v_gamma)), t_color.a);
}
