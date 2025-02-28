import { FC } from "react";
import {Flex, theme, Typography} from "antd";

export const SportPage: FC = () => {
    return (
        <Flex style={{
            backgroundColor: theme.useToken().token.colorBgContainer,
            gap: 20,
            borderRadius: 20,
            height: '100%',
        }}>
            <Flex id={'tree-container'} style={{
                backgroundColor: 'white',
                borderRadius: 20,
                flex: 1,
                padding: 20}}>
                <Typography.Title level={3} style={{margin: 0}}>Sportarten</Typography.Title>
            </Flex>
            <Flex id={'calender-container'} style={{
                backgroundColor: 'white',
                borderRadius: 20,
                flex: '0 1 33%',
                maxWidth: '400px',
                padding: 20}}>
                <Typography.Title level={3} style={{margin: 0}}>Kalender</Typography.Title>
            </Flex>

        </Flex>
    );
};
