import { FC } from "react";
import { Flex, Typography } from "antd";

// TODO: Footer should be at the bottom of the page - always
export const Footer: FC = () => {

    return (
        <Flex justify={'center'} align={'center'} gap={'middle'} style={{height: 100}}>
            <Typography.Text style={{color: 'black'}}>Datenschutz</Typography.Text>
            <Typography.Text style={{color: 'black'}}>FAQ</Typography.Text>
        </Flex>
    )
}
