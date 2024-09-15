import { useNavigate } from "react-router-dom";
import {Button, Flex} from "antd";

export const Home = () => {
    const navigate = useNavigate();

    return (
        <Flex style={{height: '100%', width: '100%'}}>
            Hello Home
            <Button onClick={() => navigate('/config')}>Config erstellen</Button>
        </Flex>
    );
};
