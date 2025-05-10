<template>
  <v-container>
    <v-card class="mx-auto" max-width="400">
      <v-card-title>Login</v-card-title>
      <v-card-text>
        <v-form @submit.prevent="handleLogin">
          <v-text-field v-model="username" label="Username" outlined></v-text-field>
          <v-text-field v-model="password" label="Password" type="password" outlined></v-text-field>
          <v-btn type="submit" color="primary" block>Login</v-btn>
        </v-form>
        <v-alert v-if="error" type="error" class="mt-3">{{ error }}</v-alert>
      </v-card-text>
    </v-card>
  </v-container>
</template>

<script>
import { login } from "../api";

export default {
  data() {
    return {
      username: "",
      password: "",
      error: null,
    };
  },
  methods: {
    async handleLogin() {
      try {
        const response = await login(this.username, this.password);
        localStorage.setItem("token", response.data.access_token);
        this.$router.push("/recipes");
      } catch (err) {
        this.error = "Invalid username or password";
      }
    },
  },
};
</script>
