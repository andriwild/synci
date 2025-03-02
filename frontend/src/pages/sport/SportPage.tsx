import { FC } from "react";
import {Flex, theme} from "antd";
import {SportTreeComponent} from "./SportTreeComponent.tsx";
import {CalendarComponent} from "./CalendarComponent.tsx";

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
                flex: 1}}>
                <SportTreeComponent />
            </Flex>
            <Flex id={'calender-container'} style={{
                backgroundColor: 'white',
                borderRadius: 20,
                flex: '0 1 33%',
                maxWidth: '400px'}}>
               <CalendarComponent />
            </Flex>

        </Flex>
    );
};
