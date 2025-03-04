import {Button, Flex, Typography} from "antd";

export const CalendarComponent = () => {
    return (
        <Flex vertical style={{gap: 20, padding: "0 20px"}}>

            <h1>Meine Abos</h1>

            <Flex vertical style={{flexDirection: "column", gap: 20}}>
            <Typography.Text>
                Du bis noch nicht Angemeldet
            </Typography.Text>
            <Button type="primary">Anmelden</Button>
            </Flex>


        </Flex>
    );
}