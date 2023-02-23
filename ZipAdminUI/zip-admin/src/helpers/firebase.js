import firebase from "firebase/compat/app";
import "firebase/compat/firestore"; //v9
import "firebase/compat/auth"; //v9
import "firebase/compat/database"; //v9

const firebaseConfig = {
  apiKey: "AIzaSyDE2_TigFEdBuJbeL3gecgtzbllVK8YMUg",
  authDomain: "zipgameday-6ef28.firebaseapp.com",
  databaseURL: "https://zipgameday-6ef28.firebaseio.com",
  projectId: "zipgameday-6ef28",
  storageBucket: "zipgameday-6ef28.appspot.com",
  messagingSenderId: "174497811264",
  appId: "1:174497811264:web:6564d0e753aee066fd08a5",
  measurementId: "G-2KLVLNW4F5",
};

// Initialize Firebase
const app = firebase.initializeApp(firebaseConfig);
export const firestoreDB = app.firestore();