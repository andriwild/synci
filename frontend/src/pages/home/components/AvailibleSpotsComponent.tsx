import {Button, Flex, theme, Typography} from "antd";
import {IconLaurelWreath} from "@tabler/icons-react";
import useBreakpoint from "antd/es/grid/hooks/useBreakpoint";
import {sportApi} from "../../../services/sport/sportApi.ts";
import {useNavigate} from "react-router-dom";

export const AvailibleSpotsComponent = () => {
    const screens = useBreakpoint();
    const sports = sportApi.useGetAllQuery();
    const {token} = theme.useToken();
    const navigate = useNavigate();

    return (
        <Flex vertical style={{justifyContent: 'start', alignItems: 'center', margin: 'auto', padding: '60px 0'}}>
            <Typography.Title level={2} style={{marginBottom: 70}}>
                Verfügbare Sportarten
            </Typography.Title>
            <Flex
                gap={'middle'}
                style={{
                    flexDirection: screens.md ? 'row' : 'column',
                    alignItems: 'center',
                }}
            >
                {sports.data?.map((sport) => (
                    <Flex
                        className="sport-card"
                        vertical
                        style={{
                            background: token.colorBgContainer,
                            alignItems: 'center',
                            width: '360px',
                        }}
                    >
                        <IconLaurelWreath size={50} style={{color: token.colorPrimary, marginTop: '20px'}}/>
                        <Typography.Title level={3}>{sport.name}</Typography.Title>
                    </Flex>
                ))}
            </Flex>

            <Button
                type={'primary'}
                size={'large'}
                style={{
                    marginTop: '60px',
                }}
                onClick={() => {
                    navigate('/sport');
                }}
            >
                Jetzt Kalender konfigurieren
            </Button>
        </Flex>
    )
}