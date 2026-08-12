<script setup lang="ts">
import type { RouteLocationAsString } from 'vue-router';
import { cn } from '~/lib/utils';
import { Icon } from '#components';

interface Position {
  x: number;
  y: number;
}

interface HeroText {
  type: 'text';
  title: string;
  path: RouteLocationAsString;
}

interface HeroComponent {
  type: 'component';
  component: Component;
}

type HeroItem = HeroComponent | HeroText;

const emit = defineEmits<{
  updateSpeed: [speed: number];
}>();

let speed = 5;

const items = ref<HeroItem[]>([
  {
    type: 'text',
    title: 'WERS',
    path: '/',
  },
  {
    type: 'component',
    component: h(Icon, { name: 'ph:star-four-fill' }),
  },
  {
    type: 'text',
    title: 'COMING',
    path: '/',
  },
  {
    type: 'component',
    component: h(Icon, { name: 'ic:round-dark-mode' }),
  },
  {
    type: 'text',
    title: 'SOON',
    path: '/',
  },
  {
    type: 'component',
    component: h(Icon, { name: 'ic:round-wb-cloudy' }),
  },
]);

const SliderContent = ref<HTMLDivElement | null>(null);
let isPressed = false;
const isDragging = ref(false);

function mouseDown() {
  isPressed = true;
}

function mouseUp() {
  isPressed = false;
  isDragging.value = false;
}

let lastMousePosition: Position | null = null;
const speedConstant = 5.0;
// let speed = 5;
const accelerationConstant = 100.0;
const resistanceConstant = 0.02;
const speedImpact = ref(speed);
function moveFrame(event: MouseEvent) {
  if (!isPressed) {
    lastMousePosition = null;
    isDragging.value = false;
    return;
  }
  if (!lastMousePosition) {
    lastMousePosition = {
      x: event.clientX,
      y: event.clientY,
    };
    return;
  }

  const delta: Position = {
    x: lastMousePosition.x - event.clientX,
    y: lastMousePosition.y - event.clientY,
  };
  isDragging.value = true;

  const acceleration = accelerationConstant * (delta.x / window.innerWidth);
  speed += acceleration;
  emit('updateSpeed', speed);
  speedImpact.value = Math.min(
    Math.max(Math.abs(speed / 5), speedConstant),
    45
  );
  console.log(speed);

  lastMousePosition = {
    x: event.clientX,
    y: event.clientY,
  };
}

onMounted(() => {
  if (!SliderContent.value) return;

  const requestFrame = () => {
    if (!SliderContent.value) return;

    SliderContent.value.scrollTo({
      left: SliderContent.value.scrollLeft + speed,
    });

    if (
      speed - resistanceConstant * speed > speedConstant ||
      speed - resistanceConstant * speed < -speedConstant
    ) {
      speed -= resistanceConstant * speed;
      emit('updateSpeed', speed);
    }

    speedImpact.value = Math.min(
      Math.max(Math.abs(speed / 5), speedConstant),
      45
    );

    const cellSize = SliderContent.value.scrollWidth / items.value.length;
    if (
      SliderContent.value.scrollWidth - SliderContent.value.scrollLeft <
      cellSize * 1.5
    ) {
      const shifted = items.value.shift();
      SliderContent.value.scrollTo({
        left: SliderContent.value.scrollLeft - cellSize,
      });
      if (!shifted) return;
      items.value.push(shifted);
    }

    if (SliderContent.value.scrollLeft < cellSize * 1.5) {
      const popped = items.value.pop();
      SliderContent.value.scrollTo({
        left: SliderContent.value.scrollLeft + cellSize,
      });
      if (!popped) return;
      items.value = [popped, ...items.value];
    }

    requestAnimationFrame(requestFrame);
  };

  requestAnimationFrame(requestFrame);
});
</script>

<template>
  <div class="z-50 relative top-0 left-0">
    <svg style="display: none">
      <filter id="horizontal-blur">
        <feGaussianBlur
          :stdDeviation="`${Math.floor(speedImpact - 5) * 1.5} 0`"
        />
      </filter>
    </svg>
    <div
      ref="SliderContent"
      class="min-w-screen w-auto max-w-none h-screen flex items-center overflow-hidden relative"
      @mousedown="mouseDown"
      @mouseup="mouseUp"
      @mousemove="moveFrame"
    >
      <div
        v-for="(item, index) of items"
        :key="index"
        :class="
          cn(`shrink-0 font-slider text-9xl text-center select-none w-[70%]`)
        "
        :style="{
          transform: `skew(${-speedImpact}deg)`,
          fontWeight: `${400 + Math.max(speedImpact - 6, 0) * 100}`,
          filter: 'url(#horizontal-blur)',
        }"
      >
        <template v-if="item.type === 'text'">
          <button
            :data-drag="isDragging"
            class="relative group/hero-item-text scale-100 data-[drag=false]:active:scale-90 transition-all focus-visible:outline-0 data-[drag=false]:cursor-pointer"
          >
            {{ item.title }}
            <div
              class="absolute bottom-0 left-1/2 -translate-x-1/2 w-0 h-4 bg-white transition-all group-data-[drag=false]/hero-item-text:group-hover/hero-item-text:w-full data-[drag=false]:group-active/hero-item-text:scale-95"
            />
          </button>
        </template>
        <template v-else>
          <component :is="item.component" />
        </template>
      </div>
    </div>
  </div>
</template>
