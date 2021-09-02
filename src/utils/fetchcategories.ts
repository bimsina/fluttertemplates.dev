import Category from "../models/Category";
import firebase from "../firebase/clientApp";
import Cookies from "js-cookie";

export const fetchCategories = async (): Promise<Category[]> => {
  const _storeData = Cookies.get("categories");
  if (_storeData) {
    const _categories: Category[] = JSON.parse(_storeData);
    console.log("Offline data");
    return _categories;
  }

  try {
    const querySnapshot = await firebase
      .firestore()
      .collection("categories")
      .get();
    if (querySnapshot) {
      const _categories: Category[] = [];
      querySnapshot.forEach(function (doc) {
        _categories.push({ title: doc.data().title, id: doc.id });
      });
      Cookies.set("categories", JSON.stringify(_categories), {
        expires: 1 / 48,
      });

      return _categories;
    } else {
      return [];
    }
  } catch (e) {
    return [];
  }
};
