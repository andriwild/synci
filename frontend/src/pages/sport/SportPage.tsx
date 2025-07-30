import { FC } from "react";
import {Flex, theme} from "antd";
import {SportTreeComponent} from "./desktop/SportTreeComponent.tsx";
import {SyncConfigComponent} from "./desktop/SyncConfigComponent.tsx";
import useBreakpoint from "antd/es/grid/hooks/useBreakpoint";
import './SportPage.css';
import {SportTreeMobileComponent} from "./mobile/SportTreeMobileComponent.tsx";


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
                {screens.md && <SportTreeComponent />}
                {!screens.md && <SportTreeMobileComponent />}

            </Flex>
            {screens.md &&
            <Flex id={'calender-container'} style={{
                backgroundColor: 'white',
                borderRadius: 20,
                flex: '0 1 33%',
                maxWidth: '400px'}}>
               <SyncConfigComponent />
            </Flex>
            }

        </Flex>
    );
};
