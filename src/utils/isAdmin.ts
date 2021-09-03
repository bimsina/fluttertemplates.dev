import firebase from "../firebase/clientApp";

export const checkifIsAdmin = async (id: string): Promise<boolean> => {
  const querySnapshot = await firebase
    .firestore()
    .collection("users")
    .doc(id)
    .get();

  if (querySnapshot) {
    if (querySnapshot?.data()?.isAdmin ?? false) {
      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
};
