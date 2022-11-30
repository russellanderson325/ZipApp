import { useState } from "react";
import {
  Table,
  Thead,
  Tbody,
  Tr,
  Box,
  Th,
  chakra,
  Text,
  Td,
  TableContainer,
  VStack,
  Button,
  IconButton,
  useDisclosure,
  ModalContent,
  ModalOverlay,
  ModalFooter,
  ModalBody,
  ModalCloseButton,
  Modal,
  ModalHeader,
  Input,
} from "@chakra-ui/react";

import { DeleteIcon, AddIcon } from "@chakra-ui/icons";
import { firestoreDB,  } from "../helpers/firebase";
import { Timestamp } from "@firebase/firestore";
import moment from "moment/moment";

const PromoSection = (props) => {
  const promos = props.promos;

  const { isOpen, onToggle, onClose } = useDisclosure();

  // handle new promotion form state
  const [rewardID, setRewardID] = useState("");
  const [credits, setCredits] = useState(0);
  const [promoMessage, setPromoMessage] = useState("");
  const [selectedPromotion, setSelectedPromotion] = useState({});
  const [expirationDate, setExpirationDate] = useState({date:new Date()})

  const handleRewardIDChange = (event) => setRewardID(event.target.value);
  const handleCreditsChange = (event) => setCredits(event.target.value);
  const handleExpirationChange = (event) => setExpirationDate({date: new Date(event.target.value)});
  const handlePromoMessageChange = (event) =>
    setPromoMessage(event.target.value);

  const {
    isOpen: isNewPromoOpen,
    onOpen: onNewPromoOpen,
    onClose: onNewPromoClose,
  } = useDisclosure();

  const createNewPromotion = () => {
    onNewPromoClose();
    firestoreDB.collection("promos").add({
      reward_id: rewardID,
      message: promoMessage,
      expiration: Timestamp.fromDate(expirationDate.date),
      credits: parseInt(credits),
    });
    setSelectedPromotion({})
    setExpirationDate({date:new Date()})
    setPromoMessage("")
    setCredits(0)
    setRewardID("")
  };

  const toggleDeleteWindow = (promotion) => {
    setSelectedPromotion(promotion);
    onToggle();
  }

  const deletePromotion = (promotion) => {
    onClose();
    firestoreDB.collection("promos").doc(promotion.id).delete();
  };

  return (
    <>
      <VStack align="stretch">
        <chakra.h1
          textAlign={"center"}
          fontSize={"2xl"}
          paddingTop={5}
          fontWeight={"bold"}
        >
          Promotions
        </chakra.h1>
        {promos.length > 0 ? (
          <TableContainer
            style={{
              overflow: "scroll",
              maxHeight: "300px",
              width: "100%",
              overflow: "auto",
            }}
            padding={10}
          >
            <Table size="sm">
              <Thead>
                <Tr>
                  <Th>Reward ID</Th>
                  <Th>Message</Th>
                  <Th>Expiration</Th>
                  <Th isNumeric>Redeemed Users</Th>
                  <Th>Delete</Th>
                </Tr>
              </Thead>
              <Tbody>
                {promos.map((promotion) => (
                  <Tr key={promotion.uid}>
                    <Td>{promotion.reward_id}</Td>
                    <Td>{promotion.message}</Td>
                    <Td>
                      {promotion.expiration?.toDate().toDateString() || "None"}
                    </Td>
                    <Td isNumeric>{promotion.redeemed_users?.length || 0}</Td>
                    <Td>
                      <IconButton
                        colorScheme="red"
                        aria-label="Delete Promotion"
                        onClick={() => toggleDeleteWindow(promotion)}
                        icon={<DeleteIcon />}
                      />
                    </Td>
                  </Tr>
                ))}
              </Tbody>
            </Table>
          </TableContainer>
        ) : (
          <p>Sorry, there are no promotions 🙁</p>
        )}
        <Box>
          <Button
            float="right"
            marginRight="30px"
            leftIcon={<AddIcon />}
            onClick={onNewPromoOpen}
            colorScheme="green"
            variant="solid"
          >
            Add Promotion
          </Button>
        </Box>
      </VStack>
      <Modal onClose={onNewPromoClose} size={"xl"} isOpen={isNewPromoOpen}>
        <ModalOverlay />
        <ModalContent>
          <ModalHeader>Create a new promotion</ModalHeader>
          <ModalCloseButton />
          <ModalBody>
            <Text fontSize="xl">Message</Text>
            <Input
              mb={5}
              value={promoMessage}
              onChange={handlePromoMessageChange}
              placeholder="Congratulations and thank you for participating in the launch!"
              size="md"
            />
            <Text fontSize="xl">Reward ID</Text>
            <Input
              value={rewardID}
              onChange={handleRewardIDChange}
              mb={5}
              placeholder="LAUNCHDAY"
              size="md"
            />
            <Text fontSize="xl">Credits</Text>
            <Input
              value={credits}
              onChange={handleCreditsChange}
              type="number"
              mb={5}
              placeholder="35"
              size="md"
            />
            <Text fontSize="xl">Expiration Date</Text>
            <Input
              placeholder="Select Date and Time"
              size="md"
              type="datetime-local"
              value={moment(expirationDate.date).format("YYYY-MM-DDTkk:mm")}
              onChange={handleExpirationChange}
            />
          </ModalBody>
          <ModalFooter>
            <Button onClick={onNewPromoClose}>Close</Button>
            <Button onClick={createNewPromotion} colorScheme="blue" ml={5}>
              Save
            </Button>
          </ModalFooter>
        </ModalContent>
      </Modal>
      <Modal onClose={onClose} size={"xl"} isOpen={isOpen}>
        <ModalOverlay />
        <ModalContent>
          <ModalHeader>Promotion Deletion</ModalHeader>
          <ModalCloseButton />
          <ModalBody>
            Are you sure you would like to delete the promotion?
          </ModalBody>
          <ModalFooter>
            <Button variant="outline" onClick={onClose}>
              Cancel
            </Button>
            <Button
              ml={10}
              colorScheme="blue"
              onClick={() => deletePromotion(selectedPromotion)}
            >
              Confirm Deletion
            </Button>
          </ModalFooter>
        </ModalContent>
      </Modal>
    </>
  );
};

export default PromoSection;
