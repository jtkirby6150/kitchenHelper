<template>
  <div id="app">
    <h1>Recipe Management App</h1>
    <RecipeList />
  </div>
</template>

<script>
import RecipeList from './components/RecipeList.vue';

export default {
  name: 'App',
  components: {
    RecipeList
  }
};
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}
</style>