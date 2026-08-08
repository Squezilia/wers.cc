<script setup lang="ts">
import { useColorMode } from '@vueuse/core';

useColorMode().value = 'auto';
</script>

<template>
  <Header />
  <NuxtPage />
</template>
