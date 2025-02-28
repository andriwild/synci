import { FC } from "react";
import { Flex, Typography } from "antd";

export const HomePage: FC = () => {

    return (
        <Flex vertical style={{height: '100%', width: '100%', padding: 24}}>
            <Typography.Title>Synci</Typography.Title>
            <Typography.Text>Willkommen bei Synci...</Typography.Text>
        </Flex>
    );
};
