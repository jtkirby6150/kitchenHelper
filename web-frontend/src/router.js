import { createRouter, createWebHistory } from "vue-router";
import HomePage from "./views/HomePage.vue";
import LoginPage from "./views/LoginPage.vue";
import DashboardPage from "./views/DashboardPage.vue";
import RecipeDetailsPage from "./views/RecipeDetailsPage.vue";
import AdminDashboard from "./views/AdminDashboard.vue";
import RecipeSubmissionPage from "./views/RecipeSubmissionPage.vue";
import NotificationsPage from "./views/NotificationsPage.vue";
import RecipeListPage from "./views/RecipeListPage.vue";

const routes = [
  { path: "/", component: HomePage },
  { path: "/login", component: LoginPage },
  { path: "/dashboard", component: DashboardPage },
  { path: "/recipes/:id", component: RecipeDetailsPage },
  { path: "/admin", component: AdminDashboard },
  { path: "/submit-recipe", component: RecipeSubmissionPage },
  { path: "/notifications", component: NotificationsPage },
  { path: "/recipes", component: RecipeListPage },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

export default router;
