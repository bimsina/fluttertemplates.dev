import React from "react";
import Category from "./Category";

interface Product {
  id?: string;
  title: string;
  codeGistUrl?: string;
  codeUrl: string;
  categories: string[];
  demoUrl: string;
  imageUrl: string;
  packageLinks?: string[];
}

export default Product;
