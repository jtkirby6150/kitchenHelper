import axios from "axios";

const API_BASE_URL = "http://localhost:8000";

export const api = axios.create({
  baseURL: API_BASE_URL,
});

export const login = (username, password) =>
  api.post("/token", `username=${username}&password=${password}`, {
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
  });

export const fetchRecipes = () => api.get("/recipes");

export const fetchRecipeDetails = (id) => api.get(`/recipes/${id}`);

export const createRecipe = (recipe, token) =>
  api.post("/recipes", recipe, {
    headers: { Authorization: `Bearer ${token}` },
  });

export const fetchNotifications = (token) =>
  api.get("/notifications", {
    headers: { Authorization: `Bearer ${token}` },
  });
