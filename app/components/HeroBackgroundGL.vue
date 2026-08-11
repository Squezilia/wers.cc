<script setup lang="ts">
import { PicoGL } from 'picogl';
import vertexShader from '@/assets/glsl/background_vertex.glsl';
import fragmentShader from '@/assets/glsl/background_fragment.glsl';
import { Simplex, patchShaders } from 'gl-noise';

const CanvasElement = ref<HTMLCanvasElement | null>(null);
const width = ref(0);
const height = ref(0);

const [readyVertexShader, readyFragmentShader] = patchShaders(
  [vertexShader, fragmentShader],
  [[], [Simplex]]
);

onMounted(async () => {
  width.value = window.innerWidth;
  height.value = window.innerHeight;

  if (!CanvasElement.value || !readyFragmentShader || !readyVertexShader)
    return;
  // if (import.meta.env.SSR) return;

  const app = PicoGL.createApp(CanvasElement.value).clearColor(
    0.0,
    0.0,
    0.0,
    1.0
  );

  const shaderProgram = app.createProgram(
    vertexShader.trim(),
    fragmentShader.trim()
  );

  const positions = app.createVertexBuffer(
    PicoGL.FLOAT,
    2,
    new Float32Array([-0.5, -0.5, 0.5, -0.5, 0.0, 0.5])
  );

  const colors = app.createVertexBuffer(
    PicoGL.FLOAT,
    3,
    new Float32Array([1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0])
  );

  const triangleArray = app
    .createVertexArray()
    .vertexAttributeBuffer(0, positions)
    .vertexAttributeBuffer(1, colors);

  // Create DrawCall from Program and VertexArray (both required),
  // and a UniformBuffer.
  const drawCall = app.createDrawCall(shaderProgram, triangleArray);

  // const drawCall = app.createDrawCall(shaderProgram);

  const draw = () => {
    app.clear();
    drawCall.draw();

    requestAnimationFrame(draw);
  };

  requestAnimationFrame(draw);
});
</script>

<template>
  <canvas
    ref="CanvasElement"
    :width="width"
    :height="height"
    class="absolute top-0 left-0 z-25 w-screen h-screen"
  />
</template>
