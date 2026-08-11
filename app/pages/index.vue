<script setup lang="ts">
import { Mouse } from '@lucide/vue';

const speed = ref(5);
</script>

<template>
  <div>
    <IndexHero v-model:speed="speed" />
    <!-- <ClientOnly>
      <HeroBackgroundGL />
    </ClientOnly> -->
    <HeroBackground v-model:speed="speed" />
    <div
      class="absolute bottom-8 left-1/2 -translate-x-1/2 flex items-center gap-2.5 text-sm"
    >
      <Mouse class="size-4" /> Scroll to Read Blog
    </div>
  </div>
</template>
