import { FC } from "react";
import {Flex, Typography} from "antd";

// TODO: Footer should be at the bottom of the page - always
export const Footer: FC = () => {

    return (
        <Flex style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            padding: '10px  24px',
            height: "auto",
            backgroundColor: '#3D5A80' }}>
            <Typography.Text style={{color: 'white', padding: '0 1rem'}}>Datenschutz</Typography.Text>
            <Typography.Text style={{color: 'white', padding: '0 1rem'}}>Impressum</Typography.Text>
            <Typography.Text style={{color: 'white', padding: '0 1rem'}}>FAQ</Typography.Text>
        </Flex>
    )
}
