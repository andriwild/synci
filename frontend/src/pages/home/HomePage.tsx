import {FC} from "react";
import {Button, Flex, Image, theme, Typography} from "antd";
import './HomePage.css';
import {IconInfoCircle, IconPlayerPlayFilled, IconSoccerField, IconUser} from "@tabler/icons-react";
import {useNavigate} from "react-router-dom";

export const HomePage: FC = () => {
    const {token} = theme.useToken()
    const navigate = useNavigate();
    return (
        <Flex vertical style={{width: '100%'}} id={"home-container"}>
            <Flex style={{justifyContent: 'center', alignItems: 'center'}} id={"home-header"}>
                <Image
                    src={'./assets/synci_preview_straight_cut.png'}
                    preview={false}
                    style={{
                        padding: '10%',
                        flexBasis: "50%"
                    }
                    }
                />
                <Flex vertical style={{
                    justifyContent: 'center',
                    alignItems: 'start',
                    alignContent: 'center',
                    flexBasis: "50%",
                }}>
                    <Typography.Title
                        level={1}
                                      style={{width: '80%'}}>Deine Sportevents <br/>überblicken und synchronisieren</Typography.Title>

                    <Typography.Text
                        style={{width: '80%'}}>
                        Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.
                    </Typography.Text>
                    <Flex style={{gap: 20, paddingTop: "20px"}}>
                        <Button type={'primary'} size={"large"} icon={<IconPlayerPlayFilled size={20}/>}
                                onClick={() => {
                                    navigate("/sport");
                                }
                                }
                        >
                            GRATIS starten
                        </Button>
                        <Button type={'default'} size={"large"}
                                icon={<IconInfoCircle size={20}/>}
                        >Mehr erfahren</Button>
                    </Flex>
                </Flex>
            </Flex>
            <Flex vertical style={{justifyContent: 'start', alignItems: 'center', margin: "auto", padding:"60px 0"}}>
                <Typography.Title level={2} style={{marginBottom: 70}}>
                    Verfügbare Sportarten
                </Typography.Title>
                <Flex style={{justifyContent: 'start', alignItems: 'start', gap: "20px", flexWrap: "wrap", maxWidth: "1260px"}}>
                        <Flex vertical className={"sport-card"} style={{background: token.colorBgContainer}}>
                            <IconSoccerField size={50} style={{color: token.colorPrimary, marginTop: "20px"}}/>
                            <Typography.Title level={3}>Sport Name</Typography.Title>
                        </Flex>
                </Flex>
                <Button
                    type={'primary'}
                    size={"large"}
                    style={{
                        marginTop: '60px',
                    }}
                    onClick={() => {
                        navigate("/sport");
                    }}
                >
                    Jetzt Kalender konfigurieren
                </Button>
            </Flex>
            <Flex vertical style={{justifyContent: 'start', alignItems: 'center', paddingTop:"60px", backgroundColor: token.colorBgBase, padding:"60px 0"}}>
                <Typography.Title level={2} style={{marginBottom: 70}}>
                    Team
                </Typography.Title>
                <Flex style={{justifyContent: 'start', alignItems: 'start', gap: "20px", flexWrap: "wrap", maxWidth: "1260px"}}>
                        <Flex vertical className={"sport-card"} style={{background: token.colorBgContainer}}>
                            <IconUser size={50} style={{color: token.colorPrimary, marginTop: "20px"}}/>
                            <Typography.Title level={3}>Elias</Typography.Title>
                        </Flex>

                </Flex>
            </Flex>
        </Flex>
    );
};
