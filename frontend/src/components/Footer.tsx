import {Flex, Typography} from "antd";

export const Footer = () => {

    return (
        <Flex justify={'center'} align={'center'} gap={'middle'} style={{background: '#001529', height: 100}}>
            <Typography.Text style={{color: 'white'}}>Datenschutz</Typography.Text>
            <Typography.Text style={{color: 'white'}}>FAQ</Typography.Text>
        </Flex>
    )
}