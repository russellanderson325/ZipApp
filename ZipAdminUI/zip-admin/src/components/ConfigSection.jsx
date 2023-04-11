import {
  Modal,
  ModalOverlay,
  ModalContent,
  ModalHeader,
  ModalFooter,
  SimpleGrid,
  Textarea,
  Box,
  chakra,
  Button,
  useDisclosure,
  ModalBody,
  Tooltip,
  ModalCloseButton,
} from "@chakra-ui/react";

import { BiEdit } from "react-icons/bi";
import { useState } from "react";
import { firestoreDB } from "../helpers/firebase";

const ConfigSection = (props) => {
  const configs = props.configurations;
  const { isOpen, onOpen, onClose } = useDisclosure();
  const [selectedKey, setSelectedKey] = useState("");
  let [textValue, setTextValue] = useState("");

  const configObj = {};
  configs.forEach((config) => {
    configObj[config.key] = config.value;
  });

  const handleInputChange = (e) => {
    const inputValue = e.target.value;
    setTextValue(inputValue);
  };

  const openModal = (key) => {
    setSelectedKey(key);
    setTextValue(configObj[key]);
    onOpen();
  };

  const saveChange = async () => {
    onClose();
    firestoreDB.collection("config_settings").doc("admin_settings").update({
      [selectedKey]: textValue,
    });
    configObj[selectedKey] = textValue;
    console.log(selectedKey);
    if (selectedKey === "TermsAndConditions") {
      const acceptedUsersSnapshot = await firestoreDB.collection("users").where("acceptedtc", '==', true).get();
      acceptedUsersSnapshot.forEach((user) => {
        console.log(user.id);
        firestoreDB.collection("users").doc(user.id).update({"acceptedtc": false,});
      });
    }
  };

  return (
    <>
      <Box
        maxW="7xl"
        mx={"auto"}
        marginBottom={5}
        px={{ base: 2, sm: 12, md: 17 }}
      >
        <chakra.h1
          textAlign={"center"}
          fontSize={"4xl"}
          py={10}
          fontWeight={"bold"}
        >
          App Configuration
        </chakra.h1>

        <SimpleGrid columns={{ base: 1, md: 3 }} spacing={{ base: 5, lg: 8 }}>
          {configs && configs.length > 0 ? (
            configs.map((config) => (
              <Tooltip key={config.key} label="Click to edit">
                <Button
                  key={config.key}
                  onClick={() => openModal(config.key)}
                  colorScheme="gray"
                  rightIcon={<BiEdit />}
                >
                  {config.key}
                </Button>
              </Tooltip>
            ))
          ) : (
            <p>No configuration keys found :(</p>
          )}
        </SimpleGrid>
      </Box>
      <Modal isOpen={isOpen} onClose={onClose}>
        <ModalOverlay />
        <ModalContent>
          <ModalHeader>{selectedKey}</ModalHeader>
          <ModalCloseButton />
          <ModalBody>
            <Textarea
              value={textValue}
              onChange={handleInputChange}
              placeholder="Add something here!"
              size="sm"
            />
          </ModalBody>
          <ModalFooter>
            {configObj[selectedKey] !== textValue ? (
              <>
                <Button colorScheme="blue" mr={3} onClick={() => saveChange()}>
                  Save
                </Button>
                <Button variant="gray" onClick={onClose}>
                  Cancel
                </Button>
              </>
            ) : (
              <Button colorScheme="blue" mr={3} onClick={onClose}>
                Close
              </Button>
            )}
          </ModalFooter>
        </ModalContent>
      </Modal>
    </>
  );
};

export default ConfigSection;
