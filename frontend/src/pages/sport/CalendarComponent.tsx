import {Alert, Button, Flex} from "antd";

export const CalendarComponent = () => {
    return (
        <Flex vertical style={{gap: 20, padding: "0 20px"}}>

            <h1>Meine Abos</h1>
            <Flex vertical style={{flexDirection: "column", gap: 20}}>
                <Alert
                    message="Du bis noch nicht angemeldet"
                    description="Melde dich an, um deine Abos zu sehen"
                    type="warning"
                    showIcon
                    action={
                        <Button>Anmelden</Button>
                    }
                />
            </Flex>
        </Flex>
    );
}