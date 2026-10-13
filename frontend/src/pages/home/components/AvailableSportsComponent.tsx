import {Button, Flex, theme, Typography} from "antd";
import {IconCalendarWeek, IconLaurelWreath} from "@tabler/icons-react";
import {sportApi} from "../../../services/sport/sportApi.ts";
import {Link} from "react-router-dom";

export const AvailableSportsComponent = () => {
    const sports = sportApi.useGetAllQuery();
    const {token} = theme.useToken();

    return (
        <div style={{background: token.colorBgBase, padding: "40px 0"}}>
            <div className={"container"}>
                <Flex vertical style={{alignItems: "center"}}>
                    <Typography.Title level={2} className="section-title" style={{fontWeight: 400}}>
                        Verfügbare Sportarten
                    </Typography.Title>
                    <div className="sport-grid">
                        {sports.data?.map((sport) => (
                            <Flex className="sport-card" vertical key={sport.id} align={"center"}>
                                <IconLaurelWreath size={50} style={{color: token.colorPrimary, marginTop: "20px"}}/>
                                <Typography.Title level={3} style={{textAlign: "center"}}>{sport.label}</Typography.Title>
                            </Flex>
                        ))}
                    </div>

                    <Link to="/sport" style={{marginTop: "clamp(32px, 5vw, 60px)"}}>
                        <Button type={"primary"} size={"middle"} icon={<IconCalendarWeek size={15}/>}>
                            Jetzt Kalender konfigurieren
                        </Button>
                    </Link>
                </Flex>
            </div>
        </div>
    )
}
