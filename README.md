# vkgears

Port of the iconic gears demo to GLSL and the Vulkan API using GLFW.

## Overview

The gears demo remains a good test of basic display driver functionality
during driver bring up, making it a useful test program. There is more
complexity than the Vulkan triangle demo due to the use of vertex buffers
and uniform buffers. It is a good, simple, complete and stand-alone example.

### gl1_gears

_gl1_gears_ is the OpenGL 1.0 port of gears using immediate mode
vertices, call lists and the fixed function lighting model. This
code is derived from the gears port included with GLFW.

### gl2_gears

_gl2_gears_ is the OpenGL 2.0 port of gears using GLSL shaders.
It has been ported to use Wolfgang Draxinger's `"linmath.h"` `mat4x4`
for constructing the model, view and projection matrices. `"gl2_util.h"`
contains shader loading and a simple vertex and index buffer implementation.
The code uses vertex array objects and vertex buffer objects.

### vk1_gears

_vk1_gears_ is the Vulkan 1.1 port of gears using SPIR-V shaders.
It also uses Wolfgang Draxinger's `"linmath.h"` `mat4x4`. _vk1_gears_
uses the same vertex and index buffer creation code as _gl2_gears_.

The Vulkan port also takes several command line options to select display
size, sample buffers and to enable Vulkan validation or API dump layers.

```
$ vk1_gears -help
usage: ./build/vk1_gears [options]

Options

-max-swapchain-images <int>  specify max-swapchain-images
-max-samples <int>           specify max-samples
-[no-]api-dump               enable or disable api-dump
-[no-]validation             enable or disable validation
-[no-]multisampling          enable or disable multisampling
-[no-]animation              enable or disable animation
-[no-]verbose                enable or disable verbose
-width <int>                 specify width
-height <int>                specify height
-help <int>                  specify help
```