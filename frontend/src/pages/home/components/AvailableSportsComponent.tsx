import {Button, Flex, theme, Typography} from "antd";
import {IconCalendarWeek, IconLaurelWreath} from "@tabler/icons-react";
import useBreakpoint from "antd/es/grid/hooks/useBreakpoint";
import {sportApi} from "../../../services/sport/sportApi.ts";
import {useNavigate} from "react-router-dom";

export const AvailableSportsComponent = () => {
    const screens = useBreakpoint();
    const sports = sportApi.useGetAllQuery();
    const {token} = theme.useToken();
    const navigate = useNavigate();

    return (

       <div style={{
            background: token.colorBgBase,
            padding: '40px 0',
        }}>
       <div className={"container"}>
        <Flex vertical style={{alignItems: 'center'}}>
            <Typography.Title level={2} style={{marginBottom: 70, fontWeight: 400}}>
                Verfügbare Sportarten
            </Typography.Title>
            <Flex
                gap={'middle'}
                justify={'center'}
                wrap
                style={{
                    flexDirection: screens.md ? 'row' : 'column',
                    alignItems: 'center',
                }}
            >
                {sports.data?.map((sport) => (
                    <Flex
                        className="sport-card"
                        vertical
                        key={sport.id}
                        style={{
                            background: '#fff',
                            alignItems: 'center',
                            width: '360px',
                        }}
                    >
                        <IconLaurelWreath size={50} style={{color: token.colorPrimary, marginTop: '20px'}}/>
                        <Typography.Title level={3}>{sport.label}</Typography.Title>
                    </Flex>
                ))}
            </Flex>

            <Button
                type={'primary'}
                size={'middle'}
                style={{
                    marginTop: '60px',
                }}
                icon={<IconCalendarWeek size={15}/>}
                onClick={() => {
                    navigate('/sport');
                }}
            >
                Jetzt Kalender konfigurieren
            </Button>
        </Flex>
         </div>
         </div>
    )
}