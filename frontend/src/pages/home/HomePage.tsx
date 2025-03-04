import { FC } from "react";
import {Flex, Image, Typography} from "antd";
import './HomePage.css';

export const HomePage: FC = () => {

    return (
        <Flex vertical style={{height: "auto", width: '100%'}} id={"home-container"}>
            <Flex style={{justifyContent: 'center', alignItems: 'center'}} id={"home-header"}>
                <Image
                    src={'./assets/synci_preview_straight_cut.png'}
                    preview={false}
                    style={{
                        padding: '10%',
                        flexBasis: "50%"
                    }
                    }
                />
            <Flex vertical style={{
                justifyContent: 'center',
                alignItems: 'start',
                alignContent: 'center',
                flexBasis: "50%",
            }}>
                <Typography.Title level={1}>Sportevents syncronisieren?</Typography.Title>
                <Typography.Title level={3}>Das ist Synci!</Typography.Title>
            </Flex>
            </Flex>
            <Typography.Title>Synci ist ..</Typography.Title>
        </Flex>
    );
};
