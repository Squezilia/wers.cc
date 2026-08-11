<script setup lang="ts">
import { createNoise2D } from 'simplex-noise';

const speed = defineModel('speed', {
  type: Number,
  required: true,
});

const CanvasElement = ref<HTMLCanvasElement | null>(null);
const windowWidth = ref(0);
const windowHeight = ref(0);
const horizontalPosition = ref(0);
const noiseFrame = computed(() =>
  generateNoise(windowWidth.value, windowHeight.value, horizontalPosition.value)
);

const generator = createNoise2D();
function generateNoise(w: number, h: number, t: number) {
  const frame = new Float32Array(w * h);
  const freq = 0.004;

  const bucket = new Map<number, [number, number][]>();
  const spacing = 6;
  const spacingSquared = Math.pow(6, 2);

  let idx = 0;
  for (let y = 0; y < h; y++) {
    for (let x = 0; x < w; x++, idx++) {
      const bucketHash = Math.floor(x / spacing) + Math.floor(y / spacing);
      const checkings = bucket.get(bucketHash) || [];

      let isNearby = false;
      for (const dot of checkings) {
        if (Math.pow(x - dot[0], 2) + Math.pow(y - dot[1], 2) < spacingSquared)
          isNearby = true;
      }

      if (isNearby) continue;

      frame[idx] = generator((x + t) * freq, y * freq);
    }
  }
  return frame;
}

function initCanvas(el: HTMLCanvasElement) {
  return el.getContext('2d');
}

type RGB = [number, number, number];
function calculateGradientPixel(from: RGB, to: RGB, gradient: number) {
  return [
    from[0] * gradient + to[0] * (1 - gradient),
    from[1] * gradient + to[1] * (1 - gradient),
    from[2] * gradient + to[2] * (1 - gradient),
  ];
}

function draw(ctx: CanvasRenderingContext2D) {
  // draw dots
  const activeColor: RGB = [225, 122, 100];
  const baseColor: RGB = [16, 16, 16];
  const threshold = 0.4;
  const spacing = 16;
  const spacingSquared = Math.pow(spacing, 2);
  const dotSize = 4;

  const bucket = new Map<number, [number, number][]>();
  horizontalPosition.value += speed.value;

  ctx.clearRect(0, 0, windowWidth.value, windowHeight.value);

  for (let y = 0; y < windowHeight.value; y++) {
    for (let x = 0; x < windowWidth.value; x += spacing) {
      const noisePixel = noiseFrame.value[x + y * windowWidth.value];
      if (!noisePixel || noisePixel < threshold) continue;

      const bucketHash = Math.floor(x / spacing) + Math.floor(y / spacing);
      const checkings = bucket.get(bucketHash) || [];

      let isNearby = false;
      for (const dot of checkings) {
        if (Math.pow(x - dot[0], 2) + Math.pow(y - dot[1], 2) < spacingSquared)
          isNearby = true;
      }

      if (isNearby) continue;

      const color = calculateGradientPixel(activeColor, baseColor, noisePixel);

      ctx.beginPath();
      ctx.fillStyle = `rgb(${color.join(',')})`;
      ctx.arc(dotSize / 2 + x, dotSize / 2 + y, dotSize / 2, 0, Math.PI * 2);
      ctx.fill();

      checkings.push([x, y]);
      bucket.set(bucketHash, checkings);
    }
  }

  requestAnimationFrame(() => draw(ctx));
}

async function main(ctx: CanvasRenderingContext2D) {
  requestAnimationFrame(() => draw(ctx));
}

onMounted(() => {
  windowHeight.value = window.innerHeight;
  windowWidth.value = window.innerWidth;
  if (!CanvasElement.value) return;
  const ctx = initCanvas(CanvasElement.value);
  if (!ctx) return;
  main(ctx);
});
</script>

<template>
  <canvas
    ref="CanvasElement"
    class="w-screen, h-screen position absolute top-0 left-0 z-20"
    :width="windowWidth"
    :height="windowHeight"
  />
</template>
