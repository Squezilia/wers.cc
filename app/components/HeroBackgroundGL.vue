<script setup lang="ts">
import vertexShader from '@/assets/glsl/background_vertex.glsl';
import fragmentShader from '@/assets/glsl/background_fragment.glsl';
import { Simplex, patchShaders } from 'gl-noise';
import { useColorMode } from '@vueuse/core';

interface ProgramInfo {
  program: WebGLProgram;
  attribLocations: {
    vertexPosition: number;
  };
  uniformLocations: {
    uResolution: WebGLUniformLocation | null;
    uPositionOffset: WebGLUniformLocation | null;
    uBlendColor: WebGLUniformLocation | null;
    uTime: WebGLUniformLocation | null;
  };
}

type vec4 = [number, number, number, number];

const blendColor: vec4 =
  useColorMode().state.value == 'dark'
    ? [0.24, 0.42, 1.0, 1.0]
    : [0.1, 0.16, 0.44, 1.0];

const speed = defineModel('speed', {
  type: Number,
  required: true,
});

const CanvasElement = ref<HTMLCanvasElement | null>(null);
const width = ref(0);
const height = ref(0);
const horizontalPosition = ref(0);

let time = 0;
let lastRenderedAt = Date.now();

const [readyVertexShader, readyFragmentShader] = patchShaders(
  [vertexShader, fragmentShader],
  [[], [Simplex]]
);

function getContext(canvas: HTMLCanvasElement) {
  return canvas.getContext('webgl2', { alpha: true });
}

function loadShader(
  ctx: WebGL2RenderingContext,
  type: 35632 | 35633,
  source: string
) {
  const shader = ctx.createShader(type);

  if (!shader) {
    alert(`An error occurred compiling the shaders: Couldn't get shader}`);
    return null;
  }

  ctx.shaderSource(shader, source);
  ctx.compileShader(shader);

  if (!ctx.getShaderParameter(shader, ctx.COMPILE_STATUS)) {
    alert(
      `An error occurred compiling the shaders: ${ctx.getShaderInfoLog(shader)}`
    );
    ctx.deleteShader(shader);
    return null;
  }

  return shader;
}

function render(
  ctx: WebGL2RenderingContext,
  programInfo: ProgramInfo,
  buffers: ReturnType<typeof initBuffers>
) {
  horizontalPosition.value += speed.value;

  drawScene(ctx, programInfo, buffers);

  time += Date.now() - lastRenderedAt;
  lastRenderedAt = Date.now();

  requestAnimationFrame(() => render(ctx, programInfo, buffers));
}

function initShaderProgram(
  ctx: WebGL2RenderingContext,
  vSource: string,
  fSource: string
) {
  const vertexShader = loadShader(ctx, ctx.VERTEX_SHADER, vSource);
  const fragmentShader = loadShader(ctx, ctx.FRAGMENT_SHADER, fSource);

  if (!vertexShader || !fragmentShader) return null;

  const shaderProgram = ctx.createProgram();
  ctx.attachShader(shaderProgram, vertexShader);
  ctx.attachShader(shaderProgram, fragmentShader);
  ctx.linkProgram(shaderProgram);

  if (!ctx.getProgramParameter(shaderProgram, ctx.LINK_STATUS)) {
    alert(
      `Unable to initialize the shader program: ${ctx.getProgramInfoLog(
        shaderProgram
      )}`
    );
    return null;
  }

  return shaderProgram;
}

function initBuffers(ctx: WebGL2RenderingContext) {
  const positionBuffer = initPositionBuffer(ctx);

  return {
    position: positionBuffer,
  };
}

function initPositionBuffer(ctx: WebGL2RenderingContext) {
  const positionBuffer = ctx.createBuffer();

  ctx.bindBuffer(ctx.ARRAY_BUFFER, positionBuffer);

  const positions = [
    -1,
    -1, // Sol alt
    1,
    -1, // Sağ alt
    -1,
    1, // Sol üst

    -1,
    1, // Sol üst
    1,
    -1, // Sağ alt
    1,
    1, // Sağ üst
  ];

  ctx.bufferData(
    ctx.ARRAY_BUFFER,
    new Float32Array(positions),
    ctx.STATIC_DRAW
  );

  return positionBuffer;
}

function drawScene(
  ctx: WebGL2RenderingContext,
  programInfo: ProgramInfo,
  buffers: ReturnType<typeof initBuffers>
) {
  const canvasWidth = CanvasElement.value?.width ?? width.value;
  const canvasHeight = CanvasElement.value?.height ?? height.value;
  ctx.viewport(0, 0, canvasWidth, canvasHeight);
  ctx.clearColor(0.0, 0.0, 0.0, 0.0);
  ctx.clearDepth(1.0);
  ctx.enable(ctx.DEPTH_TEST);
  ctx.enable(ctx.BLEND);
  ctx.depthFunc(ctx.LEQUAL);

  ctx.clear(ctx.COLOR_BUFFER_BIT | ctx.DEPTH_BUFFER_BIT);

  // setPositionAttribute(ctx, buffers, programInfo);

  ctx.useProgram(programInfo.program);

  ctx.uniform2f(
    programInfo.uniformLocations.uResolution,
    canvasWidth,
    canvasHeight
  );

  ctx.uniform1f(
    programInfo.uniformLocations.uPositionOffset,
    horizontalPosition.value
  );

  ctx.uniform4f(programInfo.uniformLocations.uBlendColor, ...blendColor);

  ctx.uniform1f(programInfo.uniformLocations.uTime, time);

  ctx.enableVertexAttribArray(programInfo.attribLocations.vertexPosition);
  ctx.bindBuffer(ctx.ARRAY_BUFFER, buffers.position);
  ctx.vertexAttribPointer(
    programInfo.attribLocations.vertexPosition,
    2,
    ctx.FLOAT,
    false,
    0,
    0
  );
  ctx.drawArrays(ctx.TRIANGLES, 0, 6);
}

onMounted(async () => {
  width.value = window.innerWidth;
  height.value = window.innerHeight;

  window.addEventListener('resize', () => {
    width.value = window.innerWidth;
    height.value = window.innerHeight;
  });

  if (!CanvasElement.value || !readyFragmentShader || !readyVertexShader)
    return;

  const ctx = getContext(CanvasElement.value);

  if (!ctx) return;

  console.log(readyFragmentShader);

  const shaderProgram = initShaderProgram(
    ctx,
    `#version 300 es
${readyVertexShader}`,
    `#version 300 es
precision highp float;
precision mediump int;
${readyFragmentShader}`
  );

  if (!shaderProgram) return;

  const programInfo: ProgramInfo = {
    program: shaderProgram,
    attribLocations: {
      vertexPosition: ctx.getAttribLocation(shaderProgram, 'aVertexPosition'),
    },
    uniformLocations: {
      uResolution: ctx.getUniformLocation(shaderProgram, 'uResolution'),
      uPositionOffset: ctx.getUniformLocation(shaderProgram, 'uPositionOffset'),
      uBlendColor: ctx.getUniformLocation(shaderProgram, 'uBlendColor'),
      uTime: ctx.getUniformLocation(shaderProgram, 'uTime'),
    },
  };

  const buffers = initBuffers(ctx);

  requestAnimationFrame(() => render(ctx, programInfo, buffers));
});
</script>

<template>
  <canvas
    ref="CanvasElement"
    :width="width"
    :height="height"
    class="absolute top-0 left-0 w-screen h-screen select-none pointer-events-none z-0"
  />
</template>
