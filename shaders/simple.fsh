#version 120

varying vec4 v_color;
varying vec2 v_uv0;
varying float v_gamma;

uniform sampler2D u_tex0;

void main()
{
    vec4 t_color = texture2D(u_tex0, v_uv0);
    gl_FragColor = v_color * vec4(pow(t_color.rgb, vec3(1.0/v_gamma)), t_color.a);
}
