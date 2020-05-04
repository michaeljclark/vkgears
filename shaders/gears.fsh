#version 120

varying in vec3 v_normal;
varying in vec4 v_color;
varying in vec3 v_fragPos;
varying in vec3 v_lightDir;

void main()
{
  float ambient = 0.1;
  float diff = max(dot(v_normal, v_lightDir), 0.0);
 
  vec4 finalColor = (ambient + diff) * v_color;

  gl_FragColor = vec4(finalColor.rgb, v_color.a);
}