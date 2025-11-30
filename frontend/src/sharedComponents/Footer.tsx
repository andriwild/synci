import { FC } from "react";
import { Button, Flex} from "antd";
import { useNavigate } from "react-router-dom";
import useBreakpoint from "antd/es/grid/hooks/useBreakpoint";

// TODO: Footer should be at the bottom of the page - always
export const Footer: FC = () => {
    const screens = useBreakpoint();
    const navigate = useNavigate();

    return (
        screens.md &&
        <Flex style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            padding: '0px 24px 10px 24px',
            height: "auto",
            backgroundColor: 'rgb(235, 240, 246)' }}>
            <Button type="link" style={{color: '#3D5A80'}}
                onClick={() => { navigate("/impressum"); }} >
                Impressum & Datenschutz
            </Button>
            <Button type="link" style={{color: '#3D5A80'}}
                onClick={() => { navigate("/faq"); }} >
                FAQ
            </Button>
        </Flex>
    )
}
