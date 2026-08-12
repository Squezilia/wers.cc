<script setup lang="ts">
import { Heart } from '@lucide/vue';

const speed = ref(5);

function speedUpdate(updated: number) {
  speed.value = updated;
}
</script>

<template>
  <div>
    <IndexHero @update-speed="speedUpdate" />
    <ClientOnly>
      <HeroBackgroundGL v-model:speed="speed" />
    </ClientOnly>
    <div
      class="absolute bottom-8 left-1/2 -translate-x-1/2 flex items-center gap-2.5 text-sm"
    >
      Made by humans with <Heart class="size-4" />
    </div>
  </div>
</template>
