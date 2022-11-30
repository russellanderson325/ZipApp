import { firestoreDB, realtimeDB } from "./helpers/firebase";
import { useState, useEffect } from "react";
import { ChakraProvider, Stack } from "@chakra-ui/react";
import { Helmet } from "react-helmet";

import Header from "./components/Header";
import Stats from "./components/Stats";
import ConfigSection from "./components/ConfigSection";
import PromoSection from "./components/PromoSection";
import UserSection from "./components/UserSection";

import "./App.css";

function App() {
  const [promoCodes, setPromoCodes] = useState([]);
  const [userAccounts, setUserAccounts] = useState([]);
  const [riderAccounts, setRiderAccounts] = useState([]);
  const [configs, setConfig] = useState([]);

  const getPromoCodes = () => {
    const getFromFirebase = firestoreDB.collection("promos");
    getFromFirebase.onSnapshot((querySnapShot) => {
      const temp = [];
      querySnapShot.forEach((doc) => {
        const id = doc.id;
        temp.push({...doc.data(), id});
      });
      setPromoCodes(temp);
    });
  };
  const getUserAccounts = () => {
    const getFromFirebase = firestoreDB.collection("users");
    getFromFirebase.onSnapshot((querySnapShot) => {
      const temp = [];
      querySnapShot.forEach((doc) => {
        temp.push(doc.data());
      });
      setUserAccounts(temp);
    });
  };
  const getDriverAccounts = () => {
    const getFromFirebase = firestoreDB.collection("drivers");
    getFromFirebase.onSnapshot((querySnapShot) => {
      const temp = [];
      querySnapShot.forEach((doc) => {
        temp.push(doc.data());
      });
      setRiderAccounts(temp);
    });
  };

  const getConfigData = () => {
    const configRef = realtimeDB.ref("/");
    configRef.once("value", function (snapshot) {
      const keyValues = [];

      snapshot.forEach(function (childSnapshot) {
        const key = childSnapshot.key;
        const data = childSnapshot.val();

        keyValues.push({ key: key, data: data });
      });
      setConfig(keyValues);
    });
  };

  useEffect(() => {
    Promise.all([
      getPromoCodes(),
      getUserAccounts(),
      getDriverAccounts(),
      getConfigData(),
    ]);
  }, []);
  
  return (
    <ChakraProvider>
      <Helmet>
        <meta charSet="utf-8" />
        <title>Zip Gameday Admin</title>
      </Helmet>
      <Header />
      <Stats
        users={userAccounts.length}
        drivers={riderAccounts.length}
        promos={promoCodes.length}
      />
      <Stack spacing={8} direction="row" py={10} justify="center">
        <PromoSection promos={promoCodes} />
        <UserSection users={userAccounts} />
      </Stack>
      <ConfigSection configurations={configs} />
    </ChakraProvider>
  );
}

export default App;
