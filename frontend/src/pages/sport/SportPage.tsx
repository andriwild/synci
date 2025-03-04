import { FC } from "react";
import {Flex, theme} from "antd";
import {SportTreeComponent} from "./SportTreeComponent.tsx";
import {CalendarComponent} from "./CalendarComponent.tsx";
import useBreakpoint from "antd/es/grid/hooks/useBreakpoint";
import './Sportpage.css';


export const SportPage: FC = () => {
    const screens = useBreakpoint();
    return (
        <Flex id={"sport-container"} style={{
            backgroundColor: theme.useToken().token.colorBgContainer,
        }}>
            <Flex id={'tree-container'} style={{
                backgroundColor: 'white',
                borderRadius: 20,
                flex: 1}}>
                <SportTreeComponent />
            </Flex>
            {screens.md &&
            <Flex id={'calender-container'} style={{
                backgroundColor: 'white',
                borderRadius: 20,
                flex: '0 1 33%',
                maxWidth: '400px'}}>
               <CalendarComponent />
            </Flex>
            }

        </Flex>
    );
};
