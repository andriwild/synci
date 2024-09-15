import {Flex, Typography} from "antd";

export const Footer = () => {

    return (
        <Flex justify={'center'} align={'center'} gap={'middle'} style={{height: 100}}>
            <Typography.Text style={{color: 'black'}}>Datenschutz</Typography.Text>
            <Typography.Text style={{color: 'black'}}>FAQ</Typography.Text>
        </Flex>
    )
}