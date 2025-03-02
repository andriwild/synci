import { FC } from "react";
import {Button, Flex, Image, theme, Typography} from "antd";
import {GoogleLogo} from "@phosphor-icons/react";
import {useNavigate} from "react-router-dom";

export const LoginPage: FC = () => {
    const customTheme = theme.useToken();
    const navigate = useNavigate();

    return (
        <Flex
            id={'background-container'}
            style={{
            backgroundColor: customTheme.token.colorBgContainer,
                height: '100vh',
        }}>
            <Flex
                vertical
                id={'login-container'}
                style={{
                backgroundColor: 'white',
                    alignItems: 'center',
                borderRadius: 20,
                flex: 1,
                padding: 50,
                margin: 'auto',
                maxWidth: '500px',
                    gap: 20,

            }}>
                <Flex
                    style={{
                    gap: 60,
                    width: '100%',
                    justifyContent: 'space-between',
                        alignItems: 'baseline',
                }}>
                    <Typography.Title level={3} style={{margin: 0}}>Login</Typography.Title>
                    <Image src={'./assets/Logo_synci.png'} preview={false} style={{maxHeight: 60, marginBottom: 20}}/>
                </Flex>
                    <Typography.Title level={2} style={{margin: 0}}>Hey, cool dass du da bist!</Typography.Title>
                <Button
                    type='primary'
                    icon={<GoogleLogo />}
                    size={'large'}
                    style={{marginTop: 20}}
                    onClick={ () => {
                        navigate('/sport');
                    }
                    }
                >
                    Mit Google anmelden
                </Button>
                <Typography.Title level={5} style={{margin: 0}}>Version 1.1.0</Typography.Title>

            </Flex>
        </Flex>
    );
};
