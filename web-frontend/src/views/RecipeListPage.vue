<template>
  <v-container>
    <v-row>
      <v-col cols="12" md="4">
        <v-text-field v-model="filters.name" label="Search by Name" outlined></v-text-field>
      </v-col>
      <v-col cols="12" md="4">
        <v-text-field v-model="filters.cuisine" label="Cuisine" outlined></v-text-field>
      </v-col>
      <v-col cols="12" md="4">
        <v-btn @click="fetchRecipes" color="primary">Search</v-btn>
      </v-col>
    </v-row>
    <v-row>
      <v-col cols="12" v-for="recipe in recipes" :key="recipe.id">
        <v-card>
          <v-card-title>{{ recipe.name }}</v-card-title>
          <v-card-text>{{ recipe.cuisine }}</v-card-text>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import { api } from "../api";

export default {
  data() {
    return {
      filters: {
        name: "",
        cuisine: "",
      },
      recipes: [],
    };
  },
  methods: {
    async fetchRecipes() {
      const params = { ...this.filters };
      const response = await api.get("/recipes", { params });
      this.recipes = response.data.items;
    },
  },
  async created() {
    await this.fetchRecipes();
  },
};
</script>
