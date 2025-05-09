<template>
  <div>
    <h1>Recipe List</h1>
    <ul>
      <li v-for="recipe in recipes" :key="recipe.id">
        <h2>{{ recipe.title }}</h2>
        <p>{{ recipe.description }}</p>
        <p><strong>Ingredients:</strong> {{ recipe.ingredients.join(', ') }}</p>
        <p><strong>Prep Time:</strong> {{ recipe.prep_time }} minutes</p>
        <p><strong>Cook Time:</strong> {{ recipe.cook_time }} minutes</p>
        <p><strong>Instructions:</strong> {{ recipe.instructions }}</p>
        <p><strong>Dietary Tags:</strong> {{ recipe.dietary_tags.join(', ') }}</p>
      </li>
    </ul>
  </div>
</template>

<script>
export default {
  data() {
    return {
      recipes: []
    };
  },
  mounted() {
    this.fetchRecipes();
  },
  methods: {
    async fetchRecipes() {
      try {
        const response = await fetch('/api/recipes');
        if (!response.ok) {
          throw new Error('Network response was not ok');
        }
        this.recipes = await response.json();
      } catch (error) {
        console.error('Error fetching recipes:', error);
      }
    }
  }
};
</script>

<style scoped>
h1 {
  color: #333;
}
ul {
  list-style-type: none;
  padding: 0;
}
li {
  margin-bottom: 20px;
  border: 1px solid #ccc;
  padding: 10px;
  border-radius: 5px;
}
</style>