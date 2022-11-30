import { Box, Heading, Container, Text, Stack } from "@chakra-ui/react";

export default function Header() {
  return (
    <>
      <Container maxW={"3xl"}>
        <Stack as={Box} textAlign={"center"} py={{ base: 10 }}>
          <Heading
            fontWeight={600}
            fontSize={{ base: "2xl", sm: "4xl", md: "6xl" }}
            lineHeight={"110%"}
          >
            <Text as={"span"} color={"green.400"}>
              <b>Zip Gameday</b>
            </Text>{" "}
            Admin
          </Heading>
        </Stack>
      </Container>
    </>
  );
}
