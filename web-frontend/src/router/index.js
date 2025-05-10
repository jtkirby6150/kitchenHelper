import Vue from "vue";
import VueRouter from "vue-router";
import RecipeList from "../views/RecipeList.vue";
import RecipeDetails from "../views/RecipeDetails.vue";
import RecipeForm from "../views/RecipeForm.vue";

Vue.use(VueRouter);

const routes = [
  {
    path: "/",
    name: "RecipeList",
    component: RecipeList,
  },
  {
    path: "/recipes/:id",
    name: "RecipeDetails",
    component: RecipeDetails,
  },
  {
    path: "/recipes/new",
    name: "RecipeCreate",
    component: RecipeForm,
  },
  {
    path: "/recipes/:id/edit",
    name: "RecipeEdit",
    component: RecipeForm,
    props: true,
  },
];

const router = new VueRouter({
  mode: "history",
  base: process.env.BASE_URL,
  routes,
});

export default router;
