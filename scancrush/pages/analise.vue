<script setup lang="ts">
const route = useRoute()
await navigateTo({ path: '/scan', query: route.query }, { replace: true })
</script>
