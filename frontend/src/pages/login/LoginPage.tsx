import { FC } from "react";
import { Flex, Typography } from "antd";

export const LoginPage: FC = () => {

    return (
        <Flex vertical style={{height: '100%', width: '100%', padding: 24}}>
            <Typography.Title>Hier Sportarten baumartig auflisten</Typography.Title>
            <Typography.Text>Wähle deinen Sport aus</Typography.Text>
        </Flex>
    );
};
