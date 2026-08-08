<script setup lang="ts">
const CanvasElement = ref<HTMLCanvasElement | null>(null);

function initCanvas(el: HTMLCanvasElement) {
  return el.getContext('2d');
}

async function main(ctx: CanvasRenderingContext2D) {}

onMounted(() => {
  if (!CanvasElement.value) return;
  const ctx = initCanvas(CanvasElement.value);
  if (!ctx) return;
  main(ctx);
});
</script>

<template>
  <canvas ref="CanvasElement" />
</template>
