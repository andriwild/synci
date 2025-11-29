import { FC } from "react";
import { Button, Flex} from "antd";
import { useNavigate } from "react-router-dom";

// TODO: Footer should be at the bottom of the page - always
export const Footer: FC = () => {

    const navigate = useNavigate();

    return (
        <Flex style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            padding: '10px  24px',
            height: "auto",
            backgroundColor: '#3D5A80' }}>
            <Button type="link" style={{color: 'white'}}
                onClick={() => { navigate("/impressum"); }} >
                Impressum & Datenschutz
            </Button>
            <Button type="link" style={{color: 'white'}}
                onClick={() => { navigate("/faq"); }} >
                FAQ
            </Button>
        </Flex>
    )
}
