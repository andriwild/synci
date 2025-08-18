import {Avatar, Button, Flex, Image, Space, Typography} from "antd";
import {IconCalendarWeek, IconPlayerPlayFilled, IconStarFilled} from "@tabler/icons-react";
import {useNavigate} from "react-router-dom";

export const FirstImpressionComponent = () => {
    const navigate = useNavigate();

    return (
        <div id={"home-header"}>
            <div className={"container"}>
                <Flex>
                    <Flex vertical
                          flex={"1 1 400px"}
                          gap={20}
                          style={{
                              justifyContent: 'center',
                              alignItems: 'start',
                              alignContent: 'center',
                              padding: '40px'
                          }}>
                        <Typography.Title
                            level={1}
                            style={{fontWeight: 400, lineHeight: '1.2'}}>
                            Verpasse nie wieder <br/>
                            <span style={{color: '#3D5A80'}}>
                    deine Lieblingsevents
                    </span>
                        </Typography.Title>

                        <Typography.Text
                            style={{maxWidth: "600px"}}>
                            Hast du den Überblick über deine Sportevents verloren?<br/>
                            Abonniere deine Lieblings-Sportligen, Teams und Events und sieh alle Spiele automatisch in
                            deinem persönlichen Kalender. NFL, NBA, Bundesliga und mehr - immer synchron mit Google
                            Kalender, Outlook & Co.
                        </Typography.Text>
                        <Flex style={{gap: 20, paddingTop: "20px", width: '100%'}}
                              justify={"start"}
                        >
                            <Button type={'primary'} size={"middle"} icon={<IconCalendarWeek size={15}/>}
                                    onClick={() => {
                                        navigate('/sport');
                                    }
                                    }
                            >
                                Jetzt abbonieren
                            </Button>
                            <Button type={"default"} size={"middle"} icon={<IconPlayerPlayFilled size={15}/>}
                                    onClick={() => {
                                        navigate('/sport');
                                    }
                                    }
                            >
                                Demo anschauen
                            </Button>
                        </Flex>
                        <Flex style={{gap: 20, paddingTop: "20px", width: '100%'}}>
                            <Space size="large" className="mt-8">
                                {/* Gruppe mit Avataren + Text */}
                                <Space>
                                    <Avatar.Group maxCount={3} maxStyle={{color: "#fff"}}>
                                        <Avatar
                                            style={{
                                                backgroundColor: "#3b82f6", // blue-500
                                                border: "2px solid white",
                                            }}
                                        >
                                            🏈
                                        </Avatar>
                                        <Avatar
                                            style={{
                                                backgroundColor: "#22c55e", // green-500
                                                border: "2px solid white",
                                            }}
                                        >
                                            ⚽
                                        </Avatar>
                                        <Avatar
                                            style={{
                                                backgroundColor: "#a855f7", // purple-500
                                                border: "2px solid white",
                                            }}
                                        >
                                            🏀
                                        </Avatar>
                                    </Avatar.Group>
                                    <span style={{fontSize: 14, color: "#4b5563"}}>
          50+ Sportligen verfügbar
        </span>
                                </Space>

                                {/* Bewertung */}
                                <Space>
                                    <IconStarFilled style={{color: "#facc15", fontSize: 20}}/>
                                    <span style={{fontSize: 14, color: "#4b5563"}}>4.9/5 Bewertung</span>
                                </Space>
                            </Space>
                        </Flex>
                    </Flex>
                    <Flex
                        flex={"1 1 400px"}
                        justify={"center"}
                    >
                        <Image
                            src={'./assets/images/fan_hero.png'}
                            preview={false}
                        />
                    </Flex>
                </Flex>
            </div>
        </div>
    );
}