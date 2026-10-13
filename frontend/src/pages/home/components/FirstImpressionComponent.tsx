import {Avatar, Button, Space, Typography} from "antd";
import {IconCalendarWeek, IconPlayerPlayFilled} from "@tabler/icons-react";
import {Link} from "react-router-dom";

export const FirstImpressionComponent = () => {
    return (
        <div id={"home-header"}>
            <div className={"container"}>
                <div className="hero">
                    <div className="hero__text">
                        <Typography.Title
                            level={1}
                            style={{fontWeight: 400, lineHeight: "1.2", margin: 0}}>
                            Verpasse nie wieder <br className="hero-break"/>
                            <span style={{color: "#3D5A80"}}>deine Lieblingsevents</span>
                        </Typography.Title>

                        <Typography.Text style={{maxWidth: "600px"}}>
                            Hast du den Überblick über deine Sportevents verloren?<br/>
                            Abonniere deine Lieblings-Sportligen, Teams und Events und sieh alle Spiele automatisch in
                            deinem persönlichen Kalender. NFL, NBA, Bundesliga und mehr - immer synchron mit Google
                            Kalender, Outlook & Co.
                        </Typography.Text>
                        <div className="hero__actions">
                            <Link to="/sport">
                                <Button type={"primary"} size={"middle"} icon={<IconCalendarWeek size={15}/>}>
                                    Jetzt starten
                                </Button>
                            </Link>
                            <Link to="/sport">
                                <Button type={"default"} size={"middle"} icon={<IconPlayerPlayFilled size={15}/>}>
                                    Verfügbare Sportarten erkunden
                                </Button>
                            </Link>
                        </div>
                        <Space size={[24, 8]} wrap style={{paddingTop: 8}}>
                            <Space>
                                <Avatar.Group max={{count: 3, style: {color: "#fff"}}}>
                                    <Avatar style={{backgroundColor: "#3b82f6", border: "2px solid white"}}>🏈</Avatar>
                                    <Avatar style={{backgroundColor: "#22c55e", border: "2px solid white"}}>⚽</Avatar>
                                    <Avatar style={{backgroundColor: "#a855f7", border: "2px solid white"}}>🏀</Avatar>
                                </Avatar.Group>
                                <span style={{fontSize: 14, color: "#4b5563"}}>50+ Sportligen verfügbar</span>
                            </Space>
                        </Space>
                    </div>
                    <div className="hero__image">
                        <picture>
                            <source srcSet="/assets/images/fan_hero.webp" type="image/webp"/>
                            <img
                                src="/assets/images/fan_hero.jpg"
                                alt="Jubelnde Fans im Stadion"
                                width={1456}
                                height={816}
                                loading="eager"
                                fetchPriority="high"
                            />
                        </picture>
                    </div>
                </div>
            </div>
        </div>
    );
}
