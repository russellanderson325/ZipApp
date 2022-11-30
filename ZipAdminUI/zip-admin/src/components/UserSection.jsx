import {
  Table,
  Thead,
  Tbody,
  Tr,
  Th,
  chakra,
  Td,
  TableContainer,
  VStack,
} from "@chakra-ui/react";
const UserSection = (props) => {
  const users = props.users.sort((x, y) => {
    return y.lastActivity - x.lastActivity;
  });
  return (
    <>
      <VStack align="stretch">
        <chakra.h1
          textAlign={"center"}
          fontSize={"2xl"}
          paddingTop={5}
          fontWeight={"bold"}
        >
          User Accounts
        </chakra.h1>
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
                <Th>Name</Th>
                <Th>Email</Th>
                <Th>Last Activity</Th>
              </Tr>
            </Thead>
            <Tbody>
              {users.map((user) => (
                <Tr key={user.uid}>
                  <Td>{`${user.firstName} ${user.lastName}`}</Td>
                  <Td>{user.email}</Td>
                  <Td>{user.lastActivity.toDate().toDateString()}</Td>
                </Tr>
              ))}
            </Tbody>
          </Table>
        </TableContainer>
      </VStack>
    </>
  );
};

export default UserSection;
